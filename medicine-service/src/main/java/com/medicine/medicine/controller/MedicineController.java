package com.medicine.medicine.controller;

import com.medicine.medicine.entity.Medicine;
import com.medicine.medicine.entity.SkuMaster;
import com.medicine.medicine.service.MedicineService;
import com.medicine.medicine.service.SkuService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/medicines")
@RequiredArgsConstructor
public class MedicineController {

    private final MedicineService medicineService;
    private final SkuService skuService;

    @GetMapping
    public ResponseEntity<List<Medicine>> getAvailableMedicines() {
        return ResponseEntity.ok(medicineService.findAllWithAvailableSkus());
    }

    @GetMapping("/all")
    public ResponseEntity<List<Medicine>> getAllMedicines(
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        return ResponseEntity.ok(medicineService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Medicine> getMedicine(@PathVariable Long id) {
        return ResponseEntity.ok(medicineService.findById(id));
    }

    @GetMapping("/{id}/skus")
    public ResponseEntity<List<SkuMaster>> getAvailableSkus(@PathVariable Long id) {
        return ResponseEntity.ok(skuService.findAvailableByMedicine(id));
    }

    @GetMapping("/{id}/skus/all")
    public ResponseEntity<List<SkuMaster>> getAllSkus(
            @PathVariable Long id,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        return ResponseEntity.ok(skuService.findAllByMedicine(id));
    }

    @PostMapping
    public ResponseEntity<Medicine> createMedicine(
            @RequestBody Medicine medicine,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        return ResponseEntity.ok(medicineService.save(medicine));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Medicine> updateMedicine(
            @PathVariable Long id,
            @RequestBody Medicine medicine,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        medicine.setId(id);
        return ResponseEntity.ok(medicineService.save(medicine));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> deleteMedicine(
            @PathVariable Long id,
            @RequestHeader(value = "X-User-Role", defaultValue = "") String role) {
        if (!"ADMIN".equals(role)) return ResponseEntity.status(403).build();
        medicineService.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Medicine deleted"));
    }

    @PostMapping("/{id}/deduct-stock")
    public ResponseEntity<Map<String, String>> deductStock(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> body) {
        medicineService.deductStock(id, body.get("quantity"));
        return ResponseEntity.ok(Map.of("message", "Stock deducted"));
    }
}
