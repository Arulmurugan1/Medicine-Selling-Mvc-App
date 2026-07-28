package com.medicine.auth.dto;

import lombok.Data;

@Data
public class ActivityLogRequest {
    private Long userId;
    private String ipAddress;
    private String activityType;
    private String screenName;
    private String errorMessage;
}
