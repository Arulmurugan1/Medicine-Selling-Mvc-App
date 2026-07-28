package com.medicine.auth.controller;

import com.medicine.auth.dto.ActivityLogRequest;
import com.medicine.auth.dto.AuthResponse;
import com.medicine.auth.dto.LoginRequest;
import com.medicine.auth.dto.RegisterRequest;
import com.medicine.auth.entity.User;
import com.medicine.auth.service.ActivityLogService;
import com.medicine.auth.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final ActivityLogService activityLogService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @GetMapping("/me")
    public ResponseEntity<User> me(@RequestHeader("X-User-Email") String email) {
        return authService.getAllUsers().stream()
                .filter(u -> u.getEmail().equals(email))
                .findFirst()
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/users")
    public ResponseEntity<List<User>> getAllUsers(
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role) {
        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(403).build();
        }
        return ResponseEntity.ok(authService.getAllUsers());
    }

    @PutMapping("/users/{id}/inactivate")
    public ResponseEntity<Map<String, String>> inactivateUser(
            @PathVariable Long id,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role,
            @RequestHeader("X-User-Email") String performedBy,
            @RequestBody(required = false) Map<String, String> body) {
        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(403).build();
        }
        String remarks = body != null ? body.getOrDefault("remarks", "") : "";
        authService.inactivateUser(id, performedBy, remarks);
        return ResponseEntity.ok(Map.of("message", "User inactivated successfully"));
    }

    @PutMapping("/users/{id}/promote")
    public ResponseEntity<Map<String, String>> promoteToAdmin(
            @PathVariable Long id,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role,
            @RequestHeader("X-User-Email") String performedBy) {
        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(403).build();
        }
        authService.promoteToAdmin(id, performedBy);
        return ResponseEntity.ok(Map.of("message", "User promoted to ADMIN successfully"));
    }

    @PostMapping("/activity")
    public ResponseEntity<Void> logActivity(@RequestBody ActivityLogRequest request) {
        activityLogService.log(
                request.getUserId(),
                request.getIpAddress(),
                request.getActivityType(),
                request.getScreenName(),
                request.getErrorMessage());
        return ResponseEntity.ok().build();
    }
}
