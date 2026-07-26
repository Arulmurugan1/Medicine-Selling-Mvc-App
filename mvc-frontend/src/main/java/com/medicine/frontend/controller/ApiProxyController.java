package com.medicine.frontend.controller;

import com.medicine.frontend.util.ApiClient;
import com.medicine.frontend.util.SessionUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.Map;

/**
 * Transparent API proxy so JSP pages can make fetch() calls to /api-proxy/**
 * without needing to manage tokens in JavaScript (token is read from server session).
 */
@RestController
@RequestMapping("/api-proxy")
@RequiredArgsConstructor
public class ApiProxyController {

    private final ApiClient apiClient;
    private final SessionUtil sessionUtil;

    @GetMapping("/**")
    public ResponseEntity<Object> proxyGet(HttpServletRequest request, HttpSession session) {
        String path = extractPath(request, "/api-proxy");
        String token = sessionUtil.getToken(session);
        Object result = apiClient.get("/api/" + path, token, Object.class);
        return result != null ? ResponseEntity.ok(result) : ResponseEntity.noContent().build();
    }

    @PostMapping("/**")
    public ResponseEntity<Object> proxyPost(HttpServletRequest request, HttpSession session,
                                            @RequestBody(required = false) Object body) {
        String path = extractPath(request, "/api-proxy");
        String token = sessionUtil.getToken(session);
        Object result = apiClient.post("/api/" + path, token, body, Object.class);
        return result != null ? ResponseEntity.ok(result) : ResponseEntity.noContent().build();
    }

    @PutMapping("/**")
    public ResponseEntity<Object> proxyPut(HttpServletRequest request, HttpSession session,
                                           @RequestBody(required = false) Object body) {
        String path = extractPath(request, "/api-proxy");
        String token = sessionUtil.getToken(session);
        Object result = apiClient.put("/api/" + path, token, body, Object.class);
        return result != null ? ResponseEntity.ok(result) : ResponseEntity.noContent().build();
    }

    private String extractPath(HttpServletRequest request, String prefix) {
        String uri = request.getRequestURI();
        String path = uri.substring(prefix.length() + 1); // remove /api-proxy/
        String query = request.getQueryString();
        return query != null ? path + "?" + query : path;
    }
}
