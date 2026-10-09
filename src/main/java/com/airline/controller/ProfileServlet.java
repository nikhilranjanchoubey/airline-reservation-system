package com.airline.controller;

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
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/**
 * Controller managing passenger and admin profile viewing and updating.
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Always refresh user details from the database
        User freshUser = userService.getUserById(sessionUser.getUserId());
        if (freshUser != null) {
            session.setAttribute("currentUser", freshUser);
            request.setAttribute("user", freshUser);
        } else {
            request.setAttribute("user", sessionUser);
        }

        // Deliver flash messages if any
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

        request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("change_password".equalsIgnoreCase(action)) {
            handlePasswordChange(request, response, session, sessionUser);
        } else {
            handleProfileUpdate(request, response, session, sessionUser);
        }
    }

    private void handleProfileUpdate(HttpServletRequest request, HttpServletResponse response,
                                     HttpSession session, User sessionUser)
            throws ServletException, IOException {
        String firstName = ValidationUtil.clean(request.getParameter("firstName"));
        String lastName = ValidationUtil.clean(request.getParameter("lastName"));
        String phone = ValidationUtil.clean(request.getParameter("phone"));
        String passportNumber = ValidationUtil.clean(request.getParameter("passportNumber"));
        String dobStr = ValidationUtil.clean(request.getParameter("dateOfBirth"));

        LocalDate dob = null;
        if (!dobStr.isEmpty()) {
            try {
                dob = LocalDate.parse(dobStr);
            } catch (DateTimeParseException e) {
                request.setAttribute("errorMessage", "Invalid date format for Date of Birth. Use YYYY-MM-DD.");
                request.setAttribute("user", sessionUser);
                request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
                return;
            }
        }

        ServiceResult<User> result = userService.updateProfile(
                sessionUser.getUserId(), firstName, lastName, phone, passportNumber, dob
        );

        if (result.isSuccess()) {
            session.setAttribute("currentUser", result.getData());
            session.setAttribute("flashSuccess", "Your profile details have been updated successfully.");
            response.sendRedirect(request.getContextPath() + "/profile");
        } else {
            request.setAttribute("errorMessage", result.getMessage());
            request.setAttribute("user", sessionUser);
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
        }
    }

    private void handlePasswordChange(HttpServletRequest request, HttpServletResponse response,
                                      HttpSession session, User sessionUser)
            throws ServletException, IOException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        ServiceResult<Void> result = userService.changePassword(
                sessionUser.getUserId(), currentPassword, newPassword, confirmPassword
        );

        if (result.isSuccess()) {
            session.setAttribute("flashSuccess", "Your password has been changed successfully.");
            response.sendRedirect(request.getContextPath() + "/profile");
        } else {
            request.setAttribute("passwordError", result.getMessage());
            request.setAttribute("user", sessionUser);
            request.setAttribute("activeTab", "password");
            request.getRequestDispatcher("/WEB-INF/views/profile/profile.jsp").forward(request, response);
        }
    }
}
