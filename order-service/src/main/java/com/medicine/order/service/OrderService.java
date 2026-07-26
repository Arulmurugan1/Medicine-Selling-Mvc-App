package com.medicine.order.service;

import com.medicine.common.enums.ActionType;
import com.medicine.common.enums.EntityType;
import com.medicine.common.service.AuditService;
import com.medicine.order.dto.OrderRequest;
import com.medicine.order.entity.Order;
import com.medicine.order.entity.OrderItem;
import com.medicine.order.entity.Payment;
import com.medicine.order.kafka.KafkaOrderProducer;
import com.medicine.order.repository.OrderRepository;
import com.medicine.order.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final PaymentRepository paymentRepository;
    private final AuditService auditService;
    private final KafkaOrderProducer kafkaProducer;

    @Transactional
    public Order placeOrder(OrderRequest request, Long userId, String userEmail) {
        BigDecimal total = request.getItems().stream()
                .map(i -> i.getUnitPrice().multiply(BigDecimal.valueOf(i.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Order order = Order.builder()
                .userId(userId)
                .userEmail(userEmail)
                .customerId(request.getCustomerId())
                .shippingAddressId(request.getShippingAddressId())
                .totalAmount(total)
                .status(Order.OrderStatus.PENDING)
                .build();

        List<OrderItem> items = request.getItems().stream()
                .map(i -> OrderItem.builder()
                        .order(order)
                        .skuId(i.getSkuId())
                        .medicineName(i.getMedicineName())
                        .skuCode(i.getSkuCode())
                        .unitLabel(i.getUnitLabel())
                        .quantity(i.getQuantity())
                        .unitPrice(i.getUnitPrice())
                        .build())
                .toList();
        order.setItems(items);

        Order saved = orderRepository.save(order);

        Payment payment = Payment.builder()
                .orderId(saved.getId())
                .amount(total)
                .paymentMethod("COD")
                .paymentStatus(Payment.PaymentStatus.PENDING)
                .build();
        paymentRepository.save(payment);

        auditService.logAction(ActionType.CREATE_ORDER, EntityType.ORDER, saved.getId(),
                userEmail, null, Map.of("status", "PENDING", "total", total), null);

        Map<String, Object> kafkaEvent = Map.of(
                "orderId", saved.getId(),
                "userEmail", userEmail,
                "customerId", request.getCustomerId(),
                "totalAmount", total,
                "itemCount", items.size()
        );
        kafkaProducer.publishOrderPlaced(kafkaEvent);

        return saved;
    }

    public List<Order> findByUserId(Long userId) {
        return orderRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public List<Order> findAll() {
        return orderRepository.findAllByOrderByCreatedAtDesc();
    }

    public List<Order> findByStatus(String status) {
        return orderRepository.findByStatus(Order.OrderStatus.valueOf(status));
    }

    public Order findById(Long id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Order not found: " + id));
    }

    @Transactional
    public Order updateStatus(Long id, String newStatus, String performedBy, String remarks) {
        Order order = findById(id);
        String oldStatus = order.getStatus().name();
        order.setStatus(Order.OrderStatus.valueOf(newStatus));
        Order saved = orderRepository.save(order);
        auditService.logAction(ActionType.ORDER_STATUS_UPDATE, EntityType.ORDER, id,
                performedBy, Map.of("status", oldStatus), Map.of("status", newStatus), remarks);
        return saved;
    }

    @Transactional
    public Order cancelOrder(Long id, String performedBy, String remarks) {
        Order order = findById(id);
        String oldStatus = order.getStatus().name();
        order.setStatus(Order.OrderStatus.CANCELLED);
        Order saved = orderRepository.save(order);
        auditService.logAction(ActionType.CANCEL_ORDER, EntityType.ORDER, id,
                performedBy, Map.of("status", oldStatus), Map.of("status", "CANCELLED"), remarks);
        kafkaProducer.publishOrderCancelled(Map.of(
                "orderId", id, "performedBy", performedBy, "reason", remarks));
        return saved;
    }
}
