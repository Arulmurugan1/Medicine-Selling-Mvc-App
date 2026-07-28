package com.medicine.auth.service;

import com.medicine.auth.entity.UserScreenActivityLog;
import com.medicine.auth.repository.UserScreenActivityLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class ActivityLogService {

    private final UserScreenActivityLogRepository repository;

    public void log(Long userId, String ipAddress, String activityType, String screenName, String errorMessage) {
        try {
            UserScreenActivityLog entry = UserScreenActivityLog.builder()
                    .userId(userId)
                    .ipAddress(ipAddress != null ? ipAddress : "unknown")
                    .activityType(activityType)
                    .screenName(screenName)
                    .errorMessage(errorMessage)
                    .build();
            repository.save(entry);
        } catch (Exception ex) {
            log.error("Failed to save activity log: activityType={}, screen={}", activityType, screenName, ex);
        }
    }
}
