package com.medicine.frontend.util;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Component
public class ApiClient {

    private final RestTemplate restTemplate;
    private final String gatewayUrl;

    public ApiClient(RestTemplate restTemplate,
                     @Value("${gateway.url:http://localhost:3001}") String gatewayUrl) {
        this.restTemplate = restTemplate;
        this.gatewayUrl = gatewayUrl;
    }

    public <T> T get(String path, String token, Class<T> responseType) {
        try {
            HttpHeaders headers = buildHeaders(token);
            HttpEntity<Void> entity = new HttpEntity<>(headers);
            ResponseEntity<T> response = restTemplate.exchange(
                    gatewayUrl + path, HttpMethod.GET, entity, responseType);
            return response.getBody();
        } catch (RestClientException e) {
            return null;
        }
    }

    public <T> T post(String path, String token, Object body, Class<T> responseType) {
        try {
            HttpHeaders headers = buildHeaders(token);
            HttpEntity<Object> entity = new HttpEntity<>(body, headers);
            ResponseEntity<T> response = restTemplate.exchange(
                    gatewayUrl + path, HttpMethod.POST, entity, responseType);
            return response.getBody();
        } catch (RestClientException e) {
            return null;
        }
    }

    public <T> T put(String path, String token, Object body, Class<T> responseType) {
        try {
            HttpHeaders headers = buildHeaders(token);
            HttpEntity<Object> entity = new HttpEntity<>(body, headers);
            ResponseEntity<T> response = restTemplate.exchange(
                    gatewayUrl + path, HttpMethod.PUT, entity, responseType);
            return response.getBody();
        } catch (HttpClientErrorException e) {
            return null;
        }
    }

    private HttpHeaders buildHeaders(String token) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (token != null && !token.isEmpty()) {
            headers.setBearerAuth(token);
        }
        return headers;
    }
}
