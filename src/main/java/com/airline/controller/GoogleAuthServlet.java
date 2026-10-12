package com.airline.controller;

import com.airline.model.Role;
import com.airline.model.User;
import com.airline.service.ServiceResult;
import com.airline.service.UserService;
import com.airline.util.ConfigUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Endpoint handling Google Identity Services POST authentication callbacks.
 */
@WebServlet(name = "GoogleAuthServlet", urlPatterns = {"/auth/google"})
public class GoogleAuthServlet extends HttpServlet {

    private final UserService userService;

    public GoogleAuthServlet() {
        this.userService = new UserService();
    }

    public GoogleAuthServlet(UserService userService) {
        this.userService = userService;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Verify CSRF Token per Google Identity Services integration guidelines
        String csrfCookieValue = getCookieValue(request, "g_csrf_token");
        String csrfBodyValue = request.getParameter("g_csrf_token");

        if (csrfCookieValue == null || csrfBodyValue == null || !csrfCookieValue.equals(csrfBodyValue)) {
            HttpSession session = request.getSession(true);
            session.setAttribute("flashError", "Google authentication failed: CSRF verification token mismatch.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Extract Google Credential (JWT ID Token)
        String idTokenString = request.getParameter("credential");
        if (idTokenString == null || idTokenString.isBlank()) {
            HttpSession session = request.getSession(true);
            session.setAttribute("flashError", "Google authentication failed: Missing ID token.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 3. Process token verification & account management
        String googleClientId = ConfigUtil.getGoogleClientId();
        ServiceResult<User> result = userService.processGoogleLogin(idTokenString, googleClientId);

        if (result.isSuccess()) {
            User user = result.getData();

            // Session fixation protection: invalidate old session and create a new session
            HttpSession oldSession = request.getSession(false);
            String redirectUrl = null;
            if (oldSession != null) {
                redirectUrl = (String) oldSession.getAttribute("redirectAfterLogin");
                oldSession.invalidate();
            }

            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("currentUser", user);
            newSession.setAttribute("flashSuccess", result.getMessage());

            if (redirectUrl != null && !redirectUrl.isBlank()) {
                response.sendRedirect(redirectUrl);
            } else if (user.getRole() == Role.ADMIN) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/profile");
            }
        } else {
            HttpSession session = request.getSession(true);
            session.setAttribute("flashError", result.getMessage());
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Direct GET requests to /auth/google redirect to login
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private String getCookieValue(HttpServletRequest request, String cookieName) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookieName.equals(cookie.getName())) {
                    return cookie.getValue();
                }
            }
        }
        return null;
    }
}
