package com.medicine.medicine.service;

import com.medicine.common.enums.ActionType;
import com.medicine.common.enums.EntityType;
import com.medicine.common.service.AuditService;
import com.medicine.medicine.entity.Medicine;
import com.medicine.medicine.entity.SkuMaster;
import com.medicine.medicine.repository.MedicineRepository;
import com.medicine.medicine.repository.SkuRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SkuService {

    private final SkuRepository skuRepository;
    private final MedicineRepository medicineRepository;
    private final AuditService auditService;

    public List<SkuMaster> findAvailableByMedicine(Long medicineId) {
        return skuRepository.findByMedicineIdAndIsActiveTrueAndQuantityAvailableGreaterThan(medicineId, 0);
    }

    public List<SkuMaster> findAllByMedicine(Long medicineId) {
        return skuRepository.findByMedicineId(medicineId);
    }

    @CacheEvict(value = {"medicines", "medicine"}, allEntries = true)
    public SkuMaster createSku(Long medicineId, SkuMaster sku, String performedBy) {
        if (skuRepository.existsBySkuCode(sku.getSkuCode())) {
            throw new IllegalArgumentException("SKU code already exists: " + sku.getSkuCode());
        }
        Medicine medicine = medicineRepository.findById(medicineId)
                .orElseThrow(() -> new IllegalArgumentException("Medicine not found: " + medicineId));
        sku.setMedicine(medicine);
        SkuMaster saved = skuRepository.save(sku);
        auditService.logAction(ActionType.CREATE_SKU, EntityType.SKU, saved.getId(),
                performedBy, null, Map.of("skuCode", saved.getSkuCode(), "price", saved.getUnitPrice()), null);
        return saved;
    }

    @CacheEvict(value = {"medicines", "medicine"}, allEntries = true)
    public SkuMaster updateSku(Long skuId, SkuMaster updates, String performedBy) {
        SkuMaster existing = skuRepository.findById(skuId)
                .orElseThrow(() -> new IllegalArgumentException("SKU not found: " + skuId));
        Map<String, Object> oldValue = Map.of(
                "unitPrice", existing.getUnitPrice(),
                "quantityAvailable", existing.getQuantityAvailable(),
                "unitLabel", existing.getUnitLabel());
        existing.setUnitLabel(updates.getUnitLabel());
        existing.setUnitPrice(updates.getUnitPrice());
        existing.setQuantityAvailable(updates.getQuantityAvailable());
        SkuMaster saved = skuRepository.save(existing);
        auditService.logAction(ActionType.UPDATE_SKU, EntityType.SKU, skuId, performedBy, oldValue,
                Map.of("unitPrice", saved.getUnitPrice(), "quantityAvailable", saved.getQuantityAvailable()), null);
        return saved;
    }

    @Transactional
    @CacheEvict(value = {"medicines", "medicine"}, allEntries = true)
    public void inactivateSku(Long skuId, String performedBy, String remarks) {
        SkuMaster sku = skuRepository.findById(skuId)
                .orElseThrow(() -> new IllegalArgumentException("SKU not found: " + skuId));
        Map<String, Object> oldValue = Map.of("isActive", sku.getIsActive(), "skuCode", sku.getSkuCode());
        sku.setIsActive(false);
        skuRepository.save(sku);
        auditService.logAction(ActionType.INACTIVATE_SKU, EntityType.SKU, skuId,
                performedBy, oldValue, Map.of("isActive", false), remarks);
    }
}
