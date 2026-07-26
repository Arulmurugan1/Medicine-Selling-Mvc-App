package com.medicine.order.service;

import com.medicine.common.enums.ActionType;
import com.medicine.common.enums.EntityType;
import com.medicine.common.service.AuditService;
import com.medicine.order.entity.Customer;
import com.medicine.order.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CustomerService {

    private final CustomerRepository customerRepository;
    private final AuditService auditService;

    public List<Customer> findByUser(Long userId) {
        return customerRepository.findByCreatedByUserIdAndIsActiveTrue(userId);
    }

    public List<Customer> findAll() {
        return customerRepository.findAll();
    }

    public Customer findById(Long id) {
        return customerRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + id));
    }

    public Customer save(Customer customer) {
        return customerRepository.save(customer);
    }

    @Transactional
    public void inactivate(Long id, String performedBy, String remarks) {
        Customer customer = findById(id);
        Map<String, Object> oldValue = Map.of("isActive", customer.getIsActive(), "name", customer.getCustomerName());
        customer.setIsActive(false);
        customerRepository.save(customer);
        auditService.logAction(ActionType.INACTIVATE_CUSTOMER, EntityType.CUSTOMER, id,
                performedBy, oldValue, Map.of("isActive", false), remarks);
    }
}
