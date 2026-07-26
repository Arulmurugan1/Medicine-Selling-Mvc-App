package com.medicine.medicine.controller;

import com.medicine.medicine.entity.SkuMaster;
import com.medicine.medicine.service.SkuService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/skus")
@RequiredArgsConstructor
public class SkuController {

    private final SkuService skuService;

    @PostMapping("/medicine/{medicineId}")
    public ResponseEntity<SkuMaster> createSku(
            @PathVariable Long medicineId,
            @RequestBody SkuMaster sku,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role,
            @RequestHeader("X-User-Email") String performedBy) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        return ResponseEntity.ok(skuService.createSku(medicineId, sku, performedBy));
    }

    @PutMapping("/{skuId}")
    public ResponseEntity<SkuMaster> updateSku(
            @PathVariable Long skuId,
            @RequestBody SkuMaster sku,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role,
            @RequestHeader("X-User-Email") String performedBy) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        return ResponseEntity.ok(skuService.updateSku(skuId, sku, performedBy));
    }

    @PutMapping("/{skuId}/inactivate")
    public ResponseEntity<Map<String, String>> inactivateSku(
            @PathVariable Long skuId,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role,
            @RequestHeader("X-User-Email") String performedBy,
            @RequestBody(required = false) Map<String, String> body) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        String remarks = body != null ? body.getOrDefault("remarks", "") : "";
        skuService.inactivateSku(skuId, performedBy, remarks);
        return ResponseEntity.ok(Map.of("message", "SKU inactivated"));
    }
}
