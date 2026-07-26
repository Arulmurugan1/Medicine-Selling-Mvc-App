package com.medicine.frontend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.medicine.frontend.util.ApiClient;
import com.medicine.frontend.util.SessionUtil;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class FrontendController {

    private final ApiClient apiClient;
    private final SessionUtil sessionUtil;
    private final ObjectMapper objectMapper;

    // =================== PUBLIC PAGES ===================

    @GetMapping("/")
    public String index(HttpSession session, Model model) {
        model.addAttribute("loggedIn", sessionUtil.isLoggedIn(session));
        model.addAttribute("role", sessionUtil.getRole(session));
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
        return "index";
    }

    @GetMapping("/login")
    public String loginPage(HttpSession session) {
        if (sessionUtil.isLoggedIn(session)) return "redirect:/";
        return "login";
    }

    @PostMapping("/login")
    public String doLogin(@RequestParam String email, @RequestParam String password,
                          HttpSession session, RedirectAttributes ra) {
        try {
            Map<String, String> body = Map.of("email", email, "password", password);
            Map response = apiClient.post("/api/auth/login", null, body, Map.class);
            if (response != null && response.get("token") != null) {
                sessionUtil.setSession(session,
                        (String) response.get("token"),
                        (String) response.get("email"),
                        (String) response.get("name"),
                        (String) response.get("role"),
                        ((Number) response.get("userId")).longValue());
                if ("ADMIN".equals(response.get("role"))) return "redirect:/admin/dashboard";
                return "redirect:/medicines";
            }
            ra.addFlashAttribute("error", "Invalid credentials");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Login failed: " + e.getMessage());
        }
        return "redirect:/login";
    }

    @GetMapping("/register")
    public String registerPage(HttpSession session) {
        if (sessionUtil.isLoggedIn(session)) return "redirect:/";
        return "register";
    }

    @PostMapping("/register")
    public String doRegister(@RequestParam String name, @RequestParam String email,
                             @RequestParam String password, RedirectAttributes ra) {
        try {
            Map<String, String> body = Map.of("name", name, "email", email, "password", password);
            Map response = apiClient.post("/api/auth/register", null, body, Map.class);
            if (response != null) {
                ra.addFlashAttribute("success", "Registration successful! Please login.");
                return "redirect:/login";
            }
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Registration failed: " + e.getMessage());
        }
        return "redirect:/register";
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        sessionUtil.clearSession(session);
        return "redirect:/";
    }

    // =================== MEDICINE CATALOG ===================

    @GetMapping("/medicines")
    public String medicines(HttpSession session, Model model) {
        if (!sessionUtil.isLoggedIn(session)) return "redirect:/login";
        String token = sessionUtil.getToken(session);
        List medicines = apiClient.get("/api/medicines", token, List.class);
        model.addAttribute("medicines", medicines);
        model.addAttribute("role", sessionUtil.getRole(session));
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
        return "medicines";
    }

    // =================== CART & CHECKOUT ===================

    @GetMapping("/cart")
    public String cart(HttpSession session, Model model) {
        if (!sessionUtil.isLoggedIn(session)) return "redirect:/login";
        model.addAttribute("role", sessionUtil.getRole(session));
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
        return "cart";
    }

    @GetMapping("/checkout")
    public String checkout(HttpSession session, Model model) {
        if (!sessionUtil.isLoggedIn(session)) return "redirect:/login";
        String token = sessionUtil.getToken(session);
        Long userId = sessionUtil.getUserId(session);

        List addresses = apiClient.get("/api/addresses", token, List.class);
        List customers = apiClient.get("/api/customers", token, List.class);
        model.addAttribute("addresses", addresses);
        model.addAttribute("customers", customers);
        model.addAttribute("role", sessionUtil.getRole(session));
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
        return "checkout";
    }

    @PostMapping("/checkout/place-order")
    public String placeOrder(@RequestParam Long customerId, @RequestParam Long addressId,
                             @RequestParam String itemsJson,
                             HttpSession session, RedirectAttributes ra) {
        if (!sessionUtil.isLoggedIn(session)) return "redirect:/login";
        try {
            String token = sessionUtil.getToken(session);
            List items = objectMapper.readValue(itemsJson, List.class);
            Map<String, Object> body = new HashMap<>();
            body.put("customerId", customerId);
            body.put("shippingAddressId", addressId);
            body.put("items", items);
            Map response = apiClient.post("/api/orders", token, body, Map.class);
            ra.addFlashAttribute("success", "Order placed successfully!");
            return "redirect:/orders/my";
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Failed to place order: " + e.getMessage());
            return "redirect:/checkout";
        }
    }

    // =================== GUEST - MY ORDERS ===================

    @GetMapping("/orders/my")
    public String myOrders(HttpSession session, Model model) {
        if (!sessionUtil.isLoggedIn(session)) return "redirect:/login";
        String token = sessionUtil.getToken(session);
        List orders = apiClient.get("/api/orders/my", token, List.class);
        model.addAttribute("orders", orders);
        model.addAttribute("role", sessionUtil.getRole(session));
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
        return "my-orders";
    }

    // =================== ADMIN DASHBOARD ===================

    @GetMapping("/admin/dashboard")
    public String adminDashboard(HttpSession session, Model model) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/login";
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
        return "admin/dashboard";
    }

    // =================== ADMIN - ORDERS ===================

    @GetMapping("/admin/orders")
    public String adminOrders(HttpSession session, Model model,
                              @RequestParam(required = false) String status) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/login";
        String token = sessionUtil.getToken(session);
        List orders;
        if (status != null && !status.isEmpty()) {
            orders = apiClient.get("/api/orders/status/" + status, token, List.class);
        } else {
            orders = apiClient.get("/api/orders", token, List.class);
        }
        model.addAttribute("orders", orders);
        model.addAttribute("activeStatus", status);
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
        return "admin/orders";
    }

    @PostMapping("/admin/orders/{id}/cancel")
    public String cancelOrder(@PathVariable Long id, @RequestParam(required = false) String remarks,
                              HttpSession session, RedirectAttributes ra) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/login";
        Map<String, String> body = Map.of("remarks", remarks != null ? remarks : "");
        apiClient.put("/api/orders/" + id + "/cancel", sessionUtil.getToken(session), body, Map.class);
        ra.addFlashAttribute("success", "Order #" + id + " cancelled.");
        return "redirect:/admin/orders";
    }

    @PostMapping("/admin/orders/{id}/status")
    public String updateOrderStatus(@PathVariable Long id, @RequestParam String status,
                                    @RequestParam(required = false) String remarks,
                                    HttpSession session, RedirectAttributes ra) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/login";
        Map<String, String> body = Map.of("status", status, "remarks", remarks != null ? remarks : "");
        apiClient.put("/api/orders/" + id + "/status", sessionUtil.getToken(session), body, Map.class);
        ra.addFlashAttribute("success", "Order status updated.");
        return "redirect:/admin/orders";
    }

    // =================== ADMIN - PAYMENTS ===================

    @GetMapping("/admin/payments")
    public String adminPayments(HttpSession session, Model model) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/login";
        List payments = apiClient.get("/api/payments", sessionUtil.getToken(session), List.class);
        model.addAttribute("payments", payments);
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
        return "admin/payments";
    }

    // =================== ADMIN - CUSTOMERS ===================

    @GetMapping("/admin/customers")
    public String adminCustomers(HttpSession session, Model model) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/login";
        List customers = apiClient.get("/api/customers", sessionUtil.getToken(session), List.class);
        model.addAttribute("customers", customers);
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
        return "admin/customers";
    }

    @PostMapping("/admin/customers/{id}/inactivate")
    public String inactivateCustomer(@PathVariable Long id, @RequestParam(required = false) String remarks,
                                     HttpSession session, RedirectAttributes ra) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/login";
        Map<String, String> body = Map.of("remarks", remarks != null ? remarks : "");
        apiClient.put("/api/customers/" + id + "/inactivate", sessionUtil.getToken(session), body, Map.class);
        ra.addFlashAttribute("success", "Customer inactivated.");
        return "redirect:/admin/customers";
    }

    // =================== ADMIN - USERS ===================

    @GetMapping("/admin/users")
    public String adminUsers(HttpSession session, Model model) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/login";
        List users = apiClient.get("/api/auth/users", sessionUtil.getToken(session), List.class);
        model.addAttribute("users", users);
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
        return "admin/users";
    }

    @PostMapping("/admin/users/{id}/inactivate")
    public String inactivateUser(@PathVariable Long id, @RequestParam(required = false) String remarks,
                                 HttpSession session, RedirectAttributes ra) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/login";
        Map<String, String> body = Map.of("remarks", remarks != null ? remarks : "");
        apiClient.put("/api/auth/users/" + id + "/inactivate", sessionUtil.getToken(session), body, Map.class);
        ra.addFlashAttribute("success", "User inactivated.");
        return "redirect:/admin/users";
    }

    // =================== ADMIN - SKU MANAGER ===================

    @GetMapping("/admin/skus")
    public String adminSkus(HttpSession session, Model model) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/login";
        String token = sessionUtil.getToken(session);
        List medicines = apiClient.get("/api/medicines/all", token, List.class);
        model.addAttribute("medicines", medicines);
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
        return "admin/skus";
    }

    // =================== ADMIN - MEDICINES ===================

    @GetMapping("/admin/medicines")
    public String adminMedicines(HttpSession session, Model model) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/login";
        List medicines = apiClient.get("/api/medicines/all", sessionUtil.getToken(session), List.class);
        model.addAttribute("medicines", medicines);
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
        return "admin/medicines";
    }

    // =================== ADMIN - AUDIT LOG ===================

    @GetMapping("/admin/audit-log")
    public String adminAuditLog(HttpSession session, Model model,
                                @RequestParam(defaultValue = "0") int page) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/login";
        Map logs = apiClient.get("/api/audit-logs?page=" + page + "&size=20",
                sessionUtil.getToken(session), Map.class);
        model.addAttribute("logs", logs);
        model.addAttribute("page", page);
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
        return "admin/audit-log";
    }
}
