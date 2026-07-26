package com.medicine.order.controller;

import com.medicine.order.entity.Customer;
import com.medicine.order.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;

    @GetMapping
    public ResponseEntity<List<Customer>> getCustomers(
            @RequestHeader("X-User-Id") String userId,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role) {
        if ("ADMIN".equals(role)) {
            return ResponseEntity.ok(customerService.findAll());
        }
        return ResponseEntity.ok(customerService.findByUser(Long.parseLong(userId)));
    }

    @PostMapping
    public ResponseEntity<Customer> createCustomer(
            @RequestBody Customer customer,
            @RequestHeader("X-User-Id") String userId) {
        customer.setCreatedByUserId(Long.parseLong(userId));
        return ResponseEntity.ok(customerService.save(customer));
    }

    @PutMapping("/{id}/inactivate")
    public ResponseEntity<Map<String, String>> inactivate(
            @PathVariable Long id,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role,
            @RequestHeader("X-User-Email") String performedBy,
            @RequestBody(required = false) Map<String, String> body) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        String remarks = body != null ? body.getOrDefault("remarks", "") : "";
        customerService.inactivate(id, performedBy, remarks);
        return ResponseEntity.ok(Map.of("message", "Customer inactivated"));
    }
}
