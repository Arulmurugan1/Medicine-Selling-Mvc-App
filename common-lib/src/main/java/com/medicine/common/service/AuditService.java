package com.medicine.common.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.medicine.common.entity.AuditLog;
import com.medicine.common.enums.ActionType;
import com.medicine.common.enums.EntityType;
import com.medicine.common.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuditService {

    private final AuditLogRepository auditLogRepository;
    private final ObjectMapper objectMapper;

    public void logAction(ActionType actionType, EntityType entityType, Long entityId,
                          String performedBy, Object oldValue, Object newValue, String remarks) {
        try {
            AuditLog auditLog = AuditLog.builder()
                    .actionType(actionType)
                    .entityType(entityType)
                    .entityId(entityId)
                    .performedBy(performedBy)
                    .oldValue(oldValue != null ? objectMapper.writeValueAsString(oldValue) : null)
                    .newValue(newValue != null ? objectMapper.writeValueAsString(newValue) : null)
                    .remarks(remarks)
                    .build();
            auditLogRepository.save(auditLog);
            log.info("[AUDIT] {} on {} #{} by {} | {}", actionType, entityType, entityId, performedBy, remarks);
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize audit log values", e);
        }
    }

    public Page<AuditLog> findAll(Pageable pageable) {
        return auditLogRepository.findAll(pageable);
    }

    public Page<AuditLog> findByEntityType(EntityType entityType, Pageable pageable) {
        return auditLogRepository.findByEntityType(entityType, pageable);
    }

    public Page<AuditLog> findByActionType(ActionType actionType, Pageable pageable) {
        return auditLogRepository.findByActionType(actionType, pageable);
    }
}
