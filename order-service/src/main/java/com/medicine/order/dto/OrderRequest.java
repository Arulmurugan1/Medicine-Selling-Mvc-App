package com.medicine.order.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class OrderRequest {
    private Long customerId;
    private Long shippingAddressId;
    private List<OrderItemRequest> items;

    @Data
    public static class OrderItemRequest {
        private Long skuId;
        private String medicineName;
        private String skuCode;
        private String unitLabel;
        private Integer quantity;
        private BigDecimal unitPrice;
    }
}
