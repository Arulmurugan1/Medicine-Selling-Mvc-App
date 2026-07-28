package com.medicine.frontend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.medicine.frontend.util.ActivityLogClient;
import com.medicine.frontend.util.ApiClient;
import com.medicine.frontend.util.SessionUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@Slf4j
public class FrontendController {

    private final ApiClient apiClient;
    private final SessionUtil sessionUtil;
    private final ObjectMapper objectMapper;
    private final ActivityLogClient activityLogClient;

    /** Automatically populate session-based attributes into every view model. */
    @ModelAttribute
    public void addSessionAttributes(HttpSession session, Model model) {
        model.addAttribute("loggedIn", sessionUtil.isLoggedIn(session));
        model.addAttribute("role", sessionUtil.getRole(session));
        model.addAttribute("userName", session.getAttribute(SessionUtil.SESSION_NAME));
    }

    // =================== PUBLIC PAGES ===================

    @GetMapping("/")
    public String index() {
        return "index";
    }

    @GetMapping("/login")
    public String loginPage(HttpSession session) {
        if (sessionUtil.isLoggedIn(session)) return "redirect:/";
        return "login";
    }

    @PostMapping("/login")
    public String doLogin(@RequestParam String email, @RequestParam String password,
                          HttpServletRequest request, HttpSession session, RedirectAttributes ra) {
        String ipAddress = resolveIp(request);
        try {
            Map<String, String> body = Map.of("email", email, "password", password);
            Map response = apiClient.post("/api/auth/login", null, body, Map.class);
            if (response != null && response.get("token") != null) {
                Long userId = ((Number) response.get("userId")).longValue();
                sessionUtil.setSession(session,
                        (String) response.get("token"),
                        (String) response.get("email"),
                        (String) response.get("name"),
                        (String) response.get("role"),
                        userId);
                activityLogClient.logActivity(userId, ipAddress, "LOGIN", "LOGIN_PAGE", null);
                if ("ADMIN".equals(response.get("role"))) return "redirect:/admin/dashboard";
                return "redirect:/medicines";
            }
            activityLogClient.logActivity(null, ipAddress, "LOGIN_FAILED", "LOGIN_PAGE", "Invalid credentials");
            ra.addFlashAttribute("error", "Invalid credentials");
        } catch (Exception e) {
            activityLogClient.logActivity(null, ipAddress, "LOGIN_FAILED", "LOGIN_PAGE", e.getMessage());
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
                             @RequestParam String password,
                             HttpServletRequest request, RedirectAttributes ra) {
        String ipAddress = resolveIp(request);
        try {
            Map<String, String> body = Map.of("name", name, "email", email, "password", password);
            Map response = apiClient.post("/api/auth/register", null, body, Map.class);
            if (response != null) {
                Long userId = response.get("userId") != null ? ((Number) response.get("userId")).longValue() : null;
                activityLogClient.logActivity(userId, ipAddress, "REGISTER", "REGISTER_PAGE", null);
                ra.addFlashAttribute("success", "Registration successful! Please login.");
                return "redirect:/login";
            }
        } catch (Exception e) {
            activityLogClient.logActivity(null, ipAddress, "REGISTER_FAILED", "REGISTER_PAGE", e.getMessage());
            ra.addFlashAttribute("error", "Registration failed: " + e.getMessage());
        }
        return "redirect:/register";
    }

    @GetMapping("/logout")
    public String logout(HttpServletRequest request, HttpSession session) {
        Long userId = sessionUtil.getUserId(session);
        activityLogClient.logActivity(userId, resolveIp(request), "LOGOUT", "LOGOUT", null);
        sessionUtil.clearSession(session);
        return "redirect:/";
    }

    // ── Helper ────────────────────────────────────────────────

    private String resolveIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isBlank()) return ip.split(",")[0].trim();
        return request.getRemoteAddr();
    }

    // =================== MEDICINE CATALOG ===================

    @GetMapping("/medicines")
    public String medicines(HttpSession session, Model model) {
        if (!sessionUtil.isLoggedIn(session)) return "redirect:/";
        if (sessionUtil.isAdmin(session)) return "redirect:/admin/dashboard";
        List medicines = apiClient.get("/api/medicines", sessionUtil.getToken(session), List.class);
        model.addAttribute("medicines", medicines);
        return "medicines";
    }

    // =================== ADMIN - ORDER NOW ===================

    @GetMapping("/admin/order")
    public String adminOrder(HttpSession session, Model model) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        String token = sessionUtil.getToken(session);

        // Fetch all available medicines
        List<Map> medicines = apiClient.get("/api/medicines", token, List.class);
        if (medicines == null) medicines = List.of();

        // Fetch recent orders to determine which medicines were ordered most
        List<Map> orders = apiClient.get("/api/orders", token, List.class);
        Map<String, Long> orderFrequency = new java.util.LinkedHashMap<>();
        if (orders != null) {
            for (Map order : orders) {
                Object items = order.get("items");
                if (items instanceof List<?> itemList) {
                    for (Object item : itemList) {
                        if (item instanceof Map<?,?> itemMap) {
                            String medName = (String) itemMap.get("medicineName");
                            if (medName != null) {
                                orderFrequency.merge(medName.toLowerCase(), 1L, Long::sum);
                            }
                        }
                    }
                }
            }
        }

        // Sort: previously ordered medicines first (by frequency desc), then the rest
        final Map<String, Long> freq = orderFrequency;
        medicines.sort((a, b) -> {
            long fa = freq.getOrDefault(String.valueOf(a.get("name")).toLowerCase(), 0L);
            long fb = freq.getOrDefault(String.valueOf(b.get("name")).toLowerCase(), 0L);
            return Long.compare(fb, fa);
        });

        model.addAttribute("medicines", medicines);
        return "medicines";
    }

    // =================== CART & CHECKOUT ===================

    @GetMapping("/cart")
    public String cart(HttpSession session) {
        if (!sessionUtil.isLoggedIn(session)) return "redirect:/";
        return "cart";
    }

    @GetMapping("/checkout")
    public String checkout(HttpSession session, Model model) {
        if (!sessionUtil.isLoggedIn(session)) return "redirect:/";

        String token = sessionUtil.getToken(session);

        log.info("Fetching addresses and customers for checkout... {}", token);

        List addresses = apiClient.get("/api/addresses", token, List.class);
        List customers = apiClient.get("/api/customers", token, List.class);

        model.addAttribute("addresses", addresses);
        model.addAttribute("customers", customers);

        return "checkout";
    }

    @PostMapping("/checkout/place-order")
    public String placeOrder(@RequestParam Long customerId, @RequestParam Long addressId,
                             @RequestParam String itemsJson,
                             HttpSession session, RedirectAttributes ra) {
        if (!sessionUtil.isLoggedIn(session)) return "redirect:/";
        try {
            String token = sessionUtil.getToken(session);
            List<Map<String, Object>> items = objectMapper.readValue(itemsJson,
                    objectMapper.getTypeFactory().constructCollectionType(List.class, Map.class));
            Map<String, Object> body = new HashMap<>();
            body.put("customerId", customerId);
            body.put("shippingAddressId", addressId);
            body.put("items", items);
            apiClient.post("/api/orders", token, body, Map.class);
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
        if (!sessionUtil.isLoggedIn(session)) return "redirect:/";
        
        List orders = apiClient.get("/api/orders/my", sessionUtil.getToken(session), List.class);
        model.addAttribute("orders", orders);
        
        return "my-orders";
    }

    /** Lightweight JSON endpoint polled by JS to detect status changes. */
    @GetMapping(value = "/orders/my/statuses", produces = "application/json")
    @ResponseBody
    public ResponseEntity<?> myOrderStatuses(HttpSession session) {
        if (!sessionUtil.isLoggedIn(session)) return ResponseEntity.status(401).build();
        List<java.util.Map> orders = apiClient.get("/api/orders/my", sessionUtil.getToken(session), List.class);
        if (orders == null) return ResponseEntity.ok(List.of());
        List<java.util.Map<String, Object>> statuses = orders.stream().map(o -> {
            java.util.Map<String, Object> m = new java.util.HashMap<>();
            m.put("id", o.get("id"));
            m.put("status", o.get("status"));
            m.put("statusUpdatedAt", o.get("statusUpdatedAt"));
            return m;
        }).toList();
        return ResponseEntity.ok(statuses);
    }

    // =================== ADMIN DASHBOARD ===================

    @GetMapping("/admin/dashboard")
    public String adminDashboard(HttpSession session) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        return "admin/dashboard";
    }

    // =================== ADMIN - ORDERS ===================

    @GetMapping("/admin/orders")
    public String adminOrders(HttpSession session, Model model,
                              @RequestParam(required = false) String status) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        String token = sessionUtil.getToken(session);
        List orders = (status != null && !status.isEmpty())
                ? apiClient.get("/api/orders/status/" + status, token, List.class)
                : apiClient.get("/api/orders", token, List.class);
        model.addAttribute("orders", orders);
        model.addAttribute("activeStatus", status);
        return "admin/orders";
    }

    @PostMapping("/admin/orders/{id}/cancel")
    public String cancelOrder(@PathVariable Long id, @RequestParam(required = false) String remarks,
                              HttpSession session, RedirectAttributes ra) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        apiClient.put("/api/orders/" + id + "/cancel", sessionUtil.getToken(session),
                Map.of("remarks", remarks != null ? remarks : ""), Map.class);
        ra.addFlashAttribute("success", "Order #" + id + " cancelled.");
        return "redirect:/admin/orders";
    }

    @PostMapping("/admin/orders/{id}/status")
    public String updateOrderStatus(@PathVariable Long id, @RequestParam String status,
                                    @RequestParam(required = false) String remarks,
                                    HttpSession session, RedirectAttributes ra) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        apiClient.put("/api/orders/" + id + "/status", sessionUtil.getToken(session),
                Map.of("status", status, "remarks", remarks != null ? remarks : ""), Map.class);
        ra.addFlashAttribute("success", "Order status updated.");
        return "redirect:/admin/orders";
    }

    // =================== ADMIN - PAYMENTS ===================

    @GetMapping("/admin/payments")
    public String adminPayments(HttpSession session, Model model) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        model.addAttribute("payments", apiClient.get("/api/payments", sessionUtil.getToken(session), List.class));
        return "admin/payments";
    }

    // =================== ADMIN - CUSTOMERS ===================

    @GetMapping("/admin/customers")
    public String adminCustomers(HttpSession session, Model model) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        model.addAttribute("customers", apiClient.get("/api/customers", sessionUtil.getToken(session), List.class));
        return "admin/customers";
    }

    @PostMapping("/admin/customers/{id}/inactivate")
    public String inactivateCustomer(@PathVariable Long id, @RequestParam(required = false) String remarks,
                                     HttpSession session, RedirectAttributes ra) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        apiClient.put("/api/customers/" + id + "/inactivate", sessionUtil.getToken(session),
                Map.of("remarks", remarks != null ? remarks : ""), Map.class);
        ra.addFlashAttribute("success", "Customer inactivated.");
        return "redirect:/admin/customers";
    }

    // =================== ADMIN - USERS ===================

    @GetMapping("/admin/users")
    public String adminUsers(HttpSession session, Model model) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        model.addAttribute("users", apiClient.get("/api/auth/users", sessionUtil.getToken(session), List.class));
        return "admin/users";
    }

    @PostMapping("/admin/users/{id}/inactivate")
    public String inactivateUser(@PathVariable Long id, @RequestParam(required = false) String remarks,
                                 HttpSession session, RedirectAttributes ra) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        apiClient.put("/api/auth/users/" + id + "/inactivate", sessionUtil.getToken(session),
                Map.of("remarks", remarks != null ? remarks : ""), Map.class);
        ra.addFlashAttribute("success", "User inactivated.");
        return "redirect:/admin/users";
    }

    @PostMapping("/admin/users/{id}/promote")
    public String promoteUser(@PathVariable Long id, HttpSession session, RedirectAttributes ra) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        apiClient.put("/api/auth/users/" + id + "/promote", sessionUtil.getToken(session), null, Map.class);
        ra.addFlashAttribute("success", "User has been promoted to ADMIN.");
        return "redirect:/admin/users";
    }

    // =================== ADMIN - SKU MANAGER ===================

    @GetMapping("/admin/skus")
    public String adminSkus(HttpSession session, Model model) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        model.addAttribute("medicines", apiClient.get("/api/medicines/all", sessionUtil.getToken(session), List.class));
        return "admin/skus";
    }

    // =================== ADMIN - MEDICINES ===================

    @GetMapping("/admin/medicines")
    public String adminMedicines(HttpSession session, Model model) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        model.addAttribute("medicines", apiClient.get("/api/medicines/all", sessionUtil.getToken(session), List.class));
        return "admin/medicines";
    }

    // =================== ADMIN - AUDIT LOG ===================

    @GetMapping("/admin/audit-log")
    public String adminAuditLog(HttpSession session, Model model,
                                @RequestParam(defaultValue = "0") int page) {
        if (!sessionUtil.isAdmin(session)) return "redirect:/";
        model.addAttribute("logs", apiClient.get("/api/audit-logs?page=" + page + "&size=20",
                sessionUtil.getToken(session), Map.class));
        model.addAttribute("page", page);
        return "admin/audit-log";
    }
}
