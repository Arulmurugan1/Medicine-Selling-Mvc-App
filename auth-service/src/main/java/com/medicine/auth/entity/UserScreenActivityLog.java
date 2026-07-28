package com.medicine.auth.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "users_screen_activity_log")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserScreenActivityLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "ip_address", nullable = false, length = 45)
    private String ipAddress;

    @Column(name = "activity_type", nullable = false, length = 50)
    private String activityType;

    @Column(name = "screen_name", nullable = false, length = 100)
    private String screenName;

    @Column(name = "error_message", length = 500)
    private String errorMessage;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }
}
