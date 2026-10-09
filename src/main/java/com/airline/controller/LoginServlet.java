package com.airline.controller;

import com.airline.model.Role;
import com.airline.model.User;
import com.airline.service.ServiceResult;
import com.airline.service.UserService;
import com.airline.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Controller handling user authentication (Login).
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            User user = (User) session.getAttribute("currentUser");
            if (user.getRole() == Role.ADMIN) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/profile");
            }
            return;
        }

        // Transfer flash messages if present in session
        if (session != null) {
            String flashSuccess = (String) session.getAttribute("flashSuccess");
            String flashError = (String) session.getAttribute("flashError");
            if (flashSuccess != null) {
                request.setAttribute("flashSuccess", flashSuccess);
                session.removeAttribute("flashSuccess");
            }
            if (flashError != null) {
                request.setAttribute("flashError", flashError);
                session.removeAttribute("flashError");
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = ValidationUtil.clean(request.getParameter("email"));
        String password = request.getParameter("password");

        ServiceResult<User> result = userService.login(email, password);

        if (result.isSuccess()) {
            User user = result.getData();

            // Session fixation protection: invalidate old session and create a brand new session
            HttpSession oldSession = request.getSession(false);
            String redirectUrl = null;
            if (oldSession != null) {
                redirectUrl = (String) oldSession.getAttribute("redirectAfterLogin");
                oldSession.invalidate();
            }

            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("currentUser", user);

            if (redirectUrl != null && !redirectUrl.isBlank()) {
                response.sendRedirect(redirectUrl);
            } else if (user.getRole() == Role.ADMIN) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/profile");
            }
        } else {
            request.setAttribute("errorMessage", result.getMessage());
            request.setAttribute("loginEmail", email);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        }
    }
}
