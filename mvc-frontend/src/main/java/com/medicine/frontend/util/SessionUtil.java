package com.medicine.frontend.util;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Component;

@Component
public class SessionUtil {

    public static final String SESSION_TOKEN = "jwt_token";
    public static final String SESSION_EMAIL = "user_email";
    public static final String SESSION_ROLE = "user_role";
    public static final String SESSION_NAME = "user_name";
    public static final String SESSION_USER_ID = "user_id";

    public void setSession(HttpSession session, String token, String email, String name, String role, Long userId) {
        session.setAttribute(SESSION_TOKEN, token);
        session.setAttribute(SESSION_EMAIL, email);
        session.setAttribute(SESSION_NAME, name);
        session.setAttribute(SESSION_ROLE, role);
        session.setAttribute(SESSION_USER_ID, userId);
    }

    public String getToken(HttpSession session) {
        return (String) session.getAttribute(SESSION_TOKEN);
    }

    public String getRole(HttpSession session) {
        return (String) session.getAttribute(SESSION_ROLE);
    }

    public Long getUserId(HttpSession session) {
        Object id = session.getAttribute(SESSION_USER_ID);
        return id != null ? ((Number) id).longValue() : null;
    }

    public boolean isLoggedIn(HttpSession session) {
        return session.getAttribute(SESSION_TOKEN) != null;
    }

    public boolean isAdmin(HttpSession session) {
        return "ADMIN".equals(session.getAttribute(SESSION_ROLE));
    }

    public void clearSession(HttpSession session) {
        session.invalidate();
    }
}
