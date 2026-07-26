package com.medicine.medicine;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication(scanBasePackages = {"com.medicine.medicine", "com.medicine.common"})
@EnableDiscoveryClient
@EnableCaching
public class MedicineServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(MedicineServiceApplication.class, args);
    }
}
