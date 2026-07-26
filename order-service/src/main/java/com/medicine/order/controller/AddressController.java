package com.medicine.order.controller;

import com.medicine.order.entity.Address;
import com.medicine.order.service.AddressService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/addresses")
@RequiredArgsConstructor
public class AddressController {

    private final AddressService addressService;

    @GetMapping
    public ResponseEntity<List<Address>> getAddresses(@RequestHeader("X-User-Id") String userId) {
        return ResponseEntity.ok(addressService.findByUserId(Long.parseLong(userId)));
    }

    @PostMapping
    public ResponseEntity<Address> saveOrReuseAddress(
            @RequestBody Address address,
            @RequestHeader("X-User-Id") String userId) {
        address.setUserId(Long.parseLong(userId));
        return ResponseEntity.ok(addressService.saveOrReuse(address));
    }

    @PutMapping("/{id}/default")
    public ResponseEntity<Void> setDefault(
            @PathVariable Long id,
            @RequestHeader("X-User-Id") String userId) {
        addressService.setDefault(Long.parseLong(userId), id);
        return ResponseEntity.ok().build();
    }
}
