package com.medicine.auth.config;

import com.medicine.auth.entity.User;
import com.medicine.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        if (!userRepository.existsByEmail("admin@medicine.com")) {
            User admin = User.builder()
                    .name("Admin User")
                    .email("admin@medicine.com")
                    .passwordHash(passwordEncoder.encode("admin123"))
                    .role(User.Role.ADMIN)
                    .isActive(true)
                    .build();
            userRepository.save(admin);
            log.info("Admin user created");
        } else {
            // Update password hash in case it was seeded with a wrong hash
            userRepository.findByEmail("admin@medicine.com").ifPresent(admin -> {
                if (!passwordEncoder.matches("admin123", admin.getPasswordHash())) {
                    admin.setPasswordHash(passwordEncoder.encode("admin123"));
                    userRepository.save(admin);
                    log.info("Admin password hash corrected");
                }
            });
        }
    }
}
