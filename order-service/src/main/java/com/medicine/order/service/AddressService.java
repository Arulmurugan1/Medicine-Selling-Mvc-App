package com.medicine.order.service;

import com.medicine.order.entity.Address;
import com.medicine.order.repository.AddressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AddressService {

    private final AddressRepository addressRepository;

    public List<Address> findByUserId(Long userId) {
        return addressRepository.findByUserId(userId);
    }

    public Address findById(Long id) {
        return addressRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Address not found: " + id));
    }

    public Address saveOrReuse(Address address) {
        Optional<Address> existing = addressRepository.findByUserIdAndAddressLine1AndCityAndPincode(
                address.getUserId(), address.getAddressLine1(), address.getCity(), address.getPincode());
        if (existing.isPresent()) {
            return existing.get();
        }
        return addressRepository.save(address);
    }

    public Address save(Address address) {
        return addressRepository.save(address);
    }

    public void setDefault(Long userId, Long addressId) {
        addressRepository.findByUserId(userId).forEach(a -> {
            a.setIsDefault(a.getId().equals(addressId));
            addressRepository.save(a);
        });
    }
}
