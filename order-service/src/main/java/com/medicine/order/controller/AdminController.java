package com.medicine.order.controller;

import com.medicine.common.entity.AuditLog;
import com.medicine.common.service.AuditService;
import com.medicine.order.entity.Payment;
import com.medicine.order.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class AdminController {

    private final PaymentRepository paymentRepository;
    private final AuditService auditService;

    @GetMapping("/api/payments")
    public ResponseEntity<List<Payment>> getPayments(
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        return ResponseEntity.ok(paymentRepository.findAllByOrderByCreatedAtDesc());
    }

    @GetMapping("/api/audit-logs")
    public ResponseEntity<Page<AuditLog>> getAuditLogs(
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        return ResponseEntity.ok(auditService.findAll(PageRequest.of(page, size)));
    }
}
