package com.medicine.medicine.repository;

import com.medicine.medicine.entity.SkuMaster;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SkuRepository extends JpaRepository<SkuMaster, Long> {
    List<SkuMaster> findByMedicineIdAndIsActiveTrueAndQuantityAvailableGreaterThan(Long medicineId, int qty);
    List<SkuMaster> findByMedicineIdAndIsActiveTrue(Long medicineId);
    List<SkuMaster> findByMedicineId(Long medicineId);
    boolean existsBySkuCode(String skuCode);
}
