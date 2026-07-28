package com.medicine.order.kafka;

import com.medicine.order.entity.Order;
import com.medicine.order.entity.Payment;
import com.medicine.order.repository.OrderRepository;
import com.medicine.order.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Automatically advances order statuses through the COD fulfilment pipeline:
 * PENDING → PROCESSING → OUT_FOR_DELIVERY → DELIVERED → COD_PAYMENT_SUCCESS
 * Each transition occurs after the order has been in the current status for ≥ 1 minute.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class OrderPipelineScheduler {

    private static final long STAGE_DELAY_MINUTES = 1;

    private final OrderRepository orderRepository;
    private final PaymentRepository paymentRepository;
    private final KafkaOrderProducer kafkaProducer;

    @Scheduled(fixedDelay = 30_000)   // runs every 30 seconds
    @Transactional
    public void advanceOrders() {
        LocalDateTime cutoff = LocalDateTime.now().minusMinutes(STAGE_DELAY_MINUTES);

        List<Order> pendingOrders = orderRepository.findByStatus(Order.OrderStatus.PENDING);
        List<Order> processingOrders = orderRepository.findByStatus(Order.OrderStatus.PROCESSING);
        List<Order> outForDeliveryOrders = orderRepository.findByStatus(Order.OrderStatus.OUT_FOR_DELIVERY);
        List<Order> deliveredOrders = orderRepository.findByStatus(Order.OrderStatus.DELIVERED);

        for (Order order : pendingOrders) {
            if (isEligible(order, cutoff)) {
                advance(order, Order.OrderStatus.PROCESSING);
            }
        }
        for (Order order : processingOrders) {
            if (isEligible(order, cutoff)) {
                advance(order, Order.OrderStatus.OUT_FOR_DELIVERY);
            }
        }
        for (Order order : outForDeliveryOrders) {
            if (isEligible(order, cutoff)) {
                advance(order, Order.OrderStatus.DELIVERED);
            }
        }
        for (Order order : deliveredOrders) {
            if (isEligible(order, cutoff)) {
                advanceToPaymentSuccess(order);
            }
        }
    }

    private boolean isEligible(Order order, LocalDateTime cutoff) {
        LocalDateTime reference = order.getStatusUpdatedAt() != null
                ? order.getStatusUpdatedAt()
                : order.getCreatedAt();
        return reference != null && reference.isBefore(cutoff);
    }

    private void advance(Order order, Order.OrderStatus newStatus) {
        log.info("[PIPELINE] Order #{}: {} → {}", order.getId(), order.getStatus(), newStatus);
        order.setStatus(newStatus);
        order.setStatusUpdatedAt(LocalDateTime.now());
        orderRepository.save(order);
        kafkaProducer.publishStatusUpdated(order.getId(), order.getUserId(), newStatus.name());
    }

    private void advanceToPaymentSuccess(Order order) {
        log.info("[PIPELINE] Order #{}: DELIVERED → COD_PAYMENT_SUCCESS", order.getId());
        order.setStatus(Order.OrderStatus.COD_PAYMENT_SUCCESS);
        order.setStatusUpdatedAt(LocalDateTime.now());
        orderRepository.save(order);

        // Mark payment as PAID
        paymentRepository.findByOrderId(order.getId()).ifPresent(payment -> {
            payment.setPaymentStatus(Payment.PaymentStatus.PAID);
            payment.setPaidAt(LocalDateTime.now());
            paymentRepository.save(payment);
            log.info("[PIPELINE] Payment for order #{} marked as PAID", order.getId());
        });

        kafkaProducer.publishStatusUpdated(order.getId(), order.getUserId(), "COD_PAYMENT_SUCCESS");
    }
}
