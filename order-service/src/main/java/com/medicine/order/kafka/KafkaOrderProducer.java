package com.medicine.order.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
@Slf4j
public class KafkaOrderProducer {

    private static final String TOPIC = "order-placed";
    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    public void publishOrderPlaced(Map<String, Object> event) {
        try {
            String message = objectMapper.writeValueAsString(event);
            kafkaTemplate.send(TOPIC, message);
            log.info("[KAFKA] Published to '{}': {}", TOPIC, message);
        } catch (Exception e) {
            log.error("[KAFKA] Failed to publish order event", e);
        }
    }

    public void publishOrderCancelled(Map<String, Object> event) {
        try {
            String message = objectMapper.writeValueAsString(event);
            kafkaTemplate.send("order-cancelled", message);
            log.info("[KAFKA] Published to 'order-cancelled': {}", message);
        } catch (Exception e) {
            log.error("[KAFKA] Failed to publish cancel event", e);
        }
    }
}
