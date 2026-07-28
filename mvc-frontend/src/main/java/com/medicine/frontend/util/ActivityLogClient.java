package com.medicine.frontend.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

/**
 * Fire-and-forget client that posts screen activity log entries
 * to the auth-service via the API gateway.
 */
@Component
@Slf4j
public class ActivityLogClient {

    private final RestTemplate restTemplate;
    private final String gatewayUrl;

    public ActivityLogClient(RestTemplate restTemplate,
                             @Value("${gateway.url:http://localhost:3001}") String gatewayUrl) {
        this.restTemplate = restTemplate;
        this.gatewayUrl = gatewayUrl;
    }

    public void logActivity(Long userId, String ipAddress, String activityType,
                            String screenName, String errorMessage) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("userId", userId);
            body.put("ipAddress", ipAddress);
            body.put("activityType", activityType);
            body.put("screenName", screenName);
            body.put("errorMessage", errorMessage);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

            restTemplate.postForEntity(gatewayUrl + "/api/auth/activity", entity, Void.class);
        } catch (Exception ex) {
            log.warn("Could not persist activity log: activityType={}, screen={}, exception={}", activityType, screenName, ex.getMessage());
        }
    }
}
