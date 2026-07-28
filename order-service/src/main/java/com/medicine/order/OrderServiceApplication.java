package com.medicine.order;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication(scanBasePackages = {"com.medicine.order", "com.medicine.common"})
@EnableJpaRepositories(basePackages = {"com.medicine.order", "com.medicine.common"})
@EntityScan(basePackages = {"com.medicine.order", "com.medicine.common"})
@EnableDiscoveryClient
@EnableScheduling
public class OrderServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }
}
