package com.medicine.order.controller;

import com.medicine.order.dto.OrderRequest;
import com.medicine.order.entity.Order;
import com.medicine.order.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    public ResponseEntity<Order> placeOrder(
            @RequestBody OrderRequest request,
            @RequestHeader("X-User-Id") String userId,
            @RequestHeader("X-User-Email") String userEmail) {
        return ResponseEntity.ok(orderService.placeOrder(request, Long.parseLong(userId), userEmail));
    }

    @GetMapping("/my")
    public ResponseEntity<List<Order>> myOrders(@RequestHeader("X-User-Id") String userId) {
        return ResponseEntity.ok(orderService.findByUserId(Long.parseLong(userId)));
    }

    @GetMapping
    public ResponseEntity<List<Order>> allOrders(
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        return ResponseEntity.ok(orderService.findAll());
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<Order>> ordersByStatus(
            @PathVariable String status,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        return ResponseEntity.ok(orderService.findByStatus(status.toUpperCase()));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Order> updateStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> body,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role,
            @RequestHeader("X-User-Email") String performedBy) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        return ResponseEntity.ok(orderService.updateStatus(id, body.get("status"),
                performedBy, body.getOrDefault("remarks", "")));
    }

    @PutMapping("/{id}/cancel")
    public ResponseEntity<Order> cancelOrder(
            @PathVariable Long id,
            @RequestBody(required = false) Map<String, String> body,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role,
            @RequestHeader("X-User-Email") String performedBy) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        String remarks = body != null ? body.getOrDefault("remarks", "") : "";
        return ResponseEntity.ok(orderService.cancelOrder(id, performedBy, remarks));
    }
}
