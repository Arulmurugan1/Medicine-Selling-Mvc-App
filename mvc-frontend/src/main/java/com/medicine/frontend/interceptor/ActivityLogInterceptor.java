package com.medicine.frontend.interceptor;

import com.medicine.frontend.util.ActivityLogClient;
import com.medicine.frontend.util.SessionUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.Map;

/**
 * Logs every screen navigation (GET page requests) and unauthorised access
 * attempts to the users_screen_activity_log table via the auth-service API.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class ActivityLogInterceptor implements HandlerInterceptor {

    private static final Map<String, String> SCREEN_NAMES = Map.ofEntries(
            Map.entry("/", "HOME"),
            Map.entry("/login", "LOGIN_PAGE"),
            Map.entry("/register", "REGISTER_PAGE"),
            Map.entry("/logout", "LOGOUT"),
            Map.entry("/medicines", "MEDICINES"),
            Map.entry("/cart", "CART"),
            Map.entry("/checkout", "CHECKOUT"),
            Map.entry("/orders/my", "MY_ORDERS"),
            Map.entry("/admin/dashboard", "ADMIN_DASHBOARD"),
            Map.entry("/admin/orders", "ADMIN_ORDERS"),
            Map.entry("/admin/payments", "ADMIN_PAYMENTS"),
            Map.entry("/admin/customers", "ADMIN_CUSTOMERS"),
            Map.entry("/admin/users", "ADMIN_USERS"),
            Map.entry("/admin/medicines", "ADMIN_MEDICINES"),
            Map.entry("/admin/skus", "ADMIN_SKUS"),
            Map.entry("/admin/order", "ADMIN_ORDER"),
            Map.entry("/admin/audit-log", "ADMIN_AUDIT_LOG")
    );

    private static final java.util.Set<String> PROTECTED_PATHS = java.util.Set.of(
            "/medicines", "/cart", "/checkout", "/orders/my",
            "/admin/dashboard", "/admin/orders", "/admin/payments",
            "/admin/customers", "/admin/users", "/admin/medicines",
            "/admin/skus", "/admin/order", "/admin/audit-log"
    );

    private final SessionUtil sessionUtil;
    private final ActivityLogClient activityLogClient;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // Only log GET requests for navigable screens
        if (!"GET".equalsIgnoreCase(request.getMethod())) return true;

        String uri = request.getRequestURI();
        // Skip static resources and actuator endpoints
        if (uri.startsWith("/static/") || uri.startsWith("/webjars/") || uri.startsWith("/actuator/")) {
            return true;
        }

        String screenName = resolveScreenName(uri);
        if (screenName == null) return true; // not a tracked screen

        String ipAddress = resolveIp(request);
        Long userId = sessionUtil.getUserId(request.getSession(false));
        boolean isLoggedIn = userId != null;

        boolean isProtected = PROTECTED_PATHS.contains(uri) ||
                uri.startsWith("/admin/");

        if (isProtected && !isLoggedIn) {
            // Unauthorised access attempt
            activityLogClient.logActivity(null, ipAddress, "UNAUTHORIZED_ACCESS", screenName,
                    "Attempted to access " + uri + " without authentication");
        } else {
            activityLogClient.logActivity(userId, ipAddress, "SCREEN_VIEW", screenName, null);
        }

        return true;
    }

    private String resolveScreenName(String uri) {
        if (SCREEN_NAMES.containsKey(uri)) return SCREEN_NAMES.get(uri);
        // Partial match for dynamic paths (e.g. /admin/orders/5/cancel)
        for (Map.Entry<String, String> entry : SCREEN_NAMES.entrySet()) {
            if (uri.startsWith(entry.getKey() + "/")) return entry.getValue();
        }
        return null;
    }

    private String resolveIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isBlank()) {
            return ip.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
