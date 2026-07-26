package com.medicine.auth.service;

import com.medicine.auth.dto.AuthResponse;
import com.medicine.auth.dto.LoginRequest;
import com.medicine.auth.dto.RegisterRequest;
import com.medicine.auth.entity.User;
import com.medicine.auth.repository.UserRepository;
import com.medicine.auth.util.JwtUtil;
import com.medicine.common.enums.ActionType;
import com.medicine.common.enums.EntityType;
import com.medicine.common.service.AuditService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuditService auditService;

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already registered");
        }
        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .role(User.Role.GUEST)
                .build();
        userRepository.save(user);
        String token = jwtUtil.generateToken(user.getEmail(), user.getRole().name(), user.getId());
        return AuthResponse.builder()
                .token(token).email(user.getEmail())
                .name(user.getName()).role(user.getRole().name())
                .userId(user.getId()).build();
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));
        if (!user.getIsActive()) {
            throw new IllegalArgumentException("Account is inactive. Please contact admin.");
        }
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Invalid email or password");
        }
        String token = jwtUtil.generateToken(user.getEmail(), user.getRole().name(), user.getId());
        return AuthResponse.builder()
                .token(token).email(user.getEmail())
                .name(user.getName()).role(user.getRole().name())
                .userId(user.getId()).build();
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + id));
    }

    @Transactional
    public void inactivateUser(Long id, String performedBy, String remarks) {
        User user = getUserById(id);
        Map<String, Object> oldValue = Map.of("isActive", user.getIsActive(), "email", user.getEmail());
        user.setIsActive(false);
        userRepository.save(user);
        auditService.logAction(ActionType.INACTIVATE_USER, EntityType.USER, id,
                performedBy, oldValue, Map.of("isActive", false), remarks);
    }

    @Transactional
    public void promoteToAdmin(Long id, String performedBy) {
        User user = getUserById(id);
        Map<String, Object> oldValue = Map.of("role", user.getRole().name(), "email", user.getEmail());
        user.setRole(User.Role.ADMIN);
        userRepository.save(user);
        auditService.logAction(ActionType.PROMOTE_USER, EntityType.USER, id,
                performedBy, oldValue, Map.of("role", "ADMIN"), "Promoted to ADMIN");
    }
}
