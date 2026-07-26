package com.medicine.order.repository;

import com.medicine.order.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {
    List<Customer> findByCreatedByUserIdAndIsActiveTrue(Long userId);
    List<Customer> findAll();
}
