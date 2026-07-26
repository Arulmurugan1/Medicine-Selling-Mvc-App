package com.medicine.medicine.service;

import com.medicine.medicine.entity.Medicine;
import com.medicine.medicine.entity.SkuMaster;
import com.medicine.medicine.repository.MedicineRepository;
import com.medicine.medicine.repository.SkuRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MedicineService {

    private final MedicineRepository medicineRepository;
    private final SkuRepository skuRepository;

    @Cacheable(value = "medicines")
    public List<Medicine> findAllWithAvailableSkus() {
        return medicineRepository.findAll().stream()
                .filter(m -> skuRepository
                        .findByMedicineIdAndIsActiveTrueAndQuantityAvailableGreaterThan(m.getId(), 0)
                        .size() > 0)
                .toList();
    }

    @Cacheable(value = "medicine", key = "#id")
    public Medicine findById(Long id) {
        return medicineRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Medicine not found: " + id));
    }

    public List<Medicine> findAll() {
        return medicineRepository.findAll();
    }

    @CacheEvict(value = {"medicines", "medicine"}, allEntries = true)
    public Medicine save(Medicine medicine) {
        return medicineRepository.save(medicine);
    }

    @CacheEvict(value = {"medicines", "medicine"}, allEntries = true)
    public void deleteById(Long id) {
        medicineRepository.deleteById(id);
    }

    @Transactional
    public void deductStock(Long skuId, int quantity) {
        SkuMaster sku = skuRepository.findById(skuId)
                .orElseThrow(() -> new IllegalArgumentException("SKU not found: " + skuId));
        if (sku.getQuantityAvailable() < quantity) {
            throw new IllegalArgumentException("Insufficient stock for SKU: " + sku.getSkuCode());
        }
        sku.setQuantityAvailable(sku.getQuantityAvailable() - quantity);
        skuRepository.save(sku);
    }
}
