package com.medicine.notification.consumer;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
@Slf4j
public class OrderEventConsumer {

    private final ObjectMapper objectMapper;

    @KafkaListener(topics = "order-placed", groupId = "notification-group")
    public void handleOrderPlaced(String message) {
        try {
            Map<?, ?> event = objectMapper.readValue(message, Map.class);
            String userEmail = String.valueOf(event.get("userEmail"));
            Object orderId = event.get("orderId");
            Object total = event.get("totalAmount");
            Object itemCount = event.get("itemCount");

            log.info("==========================================================");
            log.info("[EMAIL SENT]");
            log.info("  To      : {}", userEmail);
            log.info("  Subject : Order #{} Confirmed!", orderId);
            log.info("  Body    : Dear Customer,");
            log.info("            Your order #{} with {} item(s) totalling ₹{} has been placed successfully.",
                    orderId, itemCount, total);
            log.info("            Payment Method: Cash on Delivery");
            log.info("            We will notify you once your order is dispatched.");
            log.info("            Thank you for shopping with MediMart!");
            log.info("==========================================================");
        } catch (Exception e) {
            log.error("[NOTIFICATION] Failed to process order-placed event: {}", e.getMessage());
        }
    }

    @KafkaListener(topics = "order-cancelled", groupId = "notification-group")
    public void handleOrderCancelled(String message) {
        try {
            Map<?, ?> event = objectMapper.readValue(message, Map.class);
            Object orderId = event.get("orderId");
            String performedBy = String.valueOf(event.get("performedBy"));
            String reason = String.valueOf(event.get("reason"));

            log.info("==========================================================");
            log.info("[EMAIL SENT - ORDER CANCELLED]");
            log.info("  Order #{} has been cancelled by {}", orderId, performedBy);
            log.info("  Reason  : {}", reason);
            log.info("  A notification email has been logged for the customer.");
            log.info("==========================================================");
        } catch (Exception e) {
            log.error("[NOTIFICATION] Failed to process order-cancelled event: {}", e.getMessage());
        }
    }
}
