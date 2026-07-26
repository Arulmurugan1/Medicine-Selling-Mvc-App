package com.medicine.common.repository;

import com.medicine.common.entity.AuditLog;
import com.medicine.common.enums.ActionType;
import com.medicine.common.enums.EntityType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;

@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {

    Page<AuditLog> findByEntityType(EntityType entityType, Pageable pageable);

    Page<AuditLog> findByActionType(ActionType actionType, Pageable pageable);

    Page<AuditLog> findByPerformedBy(String performedBy, Pageable pageable);

    Page<AuditLog> findByCreatedAtBetween(LocalDateTime from, LocalDateTime to, Pageable pageable);

    Page<AuditLog> findByEntityTypeAndActionType(EntityType entityType, ActionType actionType, Pageable pageable);
}
