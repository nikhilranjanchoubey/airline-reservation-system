package com.skytech.airlines.booking.integration;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.lang.reflect.Method;
import java.util.logging.Logger;

/**
 * Adaptive authentication extractor that inspects HTTP session for standard attributes
 * or Module 1 user objects via reflection, with safe fallback to development mock.
 */
public class AdaptiveAuthenticationProvider implements AuthenticationProvider {
    private static final Logger LOGGER = Logger.getLogger(AdaptiveAuthenticationProvider.class.getName());

    @Override
    public Long getAuthenticatedUserId(HttpServletRequest request) {
        if (request == null) return 1L;
        HttpSession session = request.getSession(false);
        if (session == null) return 1L;

        Object uid = session.getAttribute("userId");
        if (uid instanceof Long) return (Long) uid;
        if (uid instanceof Integer) return ((Integer) uid).longValue();
        if (uid instanceof String) {
            try { return Long.parseLong((String) uid); } catch (NumberFormatException ignored) {}
        }

        Object userObj = session.getAttribute("user");
        if (userObj != null) {
            try {
                Method m = userObj.getClass().getMethod("getUserId");
                Object res = m.invoke(userObj);
                if (res instanceof Long) return (Long) res;
                if (res instanceof Integer) return ((Integer) res).longValue();
            } catch (Exception ignored) {}
        }
        return 1L; // Development fallback
    }

    @Override
    public String getAuthenticatedUserEmail(HttpServletRequest request) {
        if (request == null) return "rajesh.sharma@example.com";
        HttpSession session = request.getSession(false);
        if (session == null) return "rajesh.sharma@example.com";

        Object email = session.getAttribute("userEmail");
        if (email instanceof String && !((String) email).isBlank()) return (String) email;

        Object userObj = session.getAttribute("user");
        if (userObj != null) {
            try {
                Method m = userObj.getClass().getMethod("getEmail");
                Object res = m.invoke(userObj);
                if (res instanceof String && !((String) res).isBlank()) return (String) res;
            } catch (Exception ignored) {}
        }
        return "rajesh.sharma@example.com";
    }

    @Override
    public String getAuthenticatedUserName(HttpServletRequest request) {
        if (request == null) return "Rajesh Sharma";
        HttpSession session = request.getSession(false);
        if (session == null) return "Rajesh Sharma";

        Object name = session.getAttribute("userName");
        if (name instanceof String && !((String) name).isBlank()) return (String) name;

        Object userObj = session.getAttribute("user");
        if (userObj != null) {
            try {
                Method m = userObj.getClass().getMethod("getFullName");
                Object res = m.invoke(userObj);
                if (res instanceof String && !((String) res).isBlank()) return (String) res;
            } catch (Exception ignored) {}
        }
        return "Rajesh Sharma";
    }

    @Override
    public boolean isAuthenticated(HttpServletRequest request) {
        return true; // Active development authentication
    }
}
