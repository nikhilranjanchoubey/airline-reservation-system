package com.airline.controller.admin;

import com.airline.dao.AdminAuditDao;
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
 * Controller managing administrator profile inspection, contact details updates,
 * and security credentials within the Admin Console workspace.
 */
@WebServlet(name = "AdminProfileServlet", urlPatterns = {"/admin/profile"})
public class AdminProfileServlet extends HttpServlet {

    private final UserService userService = new UserService();
    private final AdminAuditDao auditDao = new AdminAuditDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (sessionUser == null || sessionUser.getRole() != Role.ADMIN) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/admin/profile");
            return;
        }

        // Always refresh user details from the database
        User freshUser = userService.getUserById(sessionUser.getUserId());
        User activeUser = (freshUser != null) ? freshUser : sessionUser;
        session.setAttribute("currentUser", activeUser);
        request.setAttribute("user", activeUser);
        request.setAttribute("activeTab", "profile");

        // Flash message handling
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

        request.getRequestDispatcher("/WEB-INF/views/admin/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (sessionUser == null || sessionUser.getRole() != Role.ADMIN) {
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
            throws IOException {
        String firstName = ValidationUtil.clean(request.getParameter("firstName"));
        String lastName = ValidationUtil.clean(request.getParameter("lastName"));
        String phone = ValidationUtil.clean(request.getParameter("phone"));
        String passportNumber = ValidationUtil.clean(request.getParameter("passportNumber"));

        if (firstName.isEmpty() || lastName.isEmpty()) {
            session.setAttribute("flashError", "First name and last name are required fields.");
            response.sendRedirect(request.getContextPath() + "/admin/profile");
            return;
        }

        ServiceResult<User> result = userService.updateProfile(
                sessionUser.getUserId(), firstName, lastName, phone,
                passportNumber.isEmpty() ? sessionUser.getPassportNumber() : passportNumber,
                sessionUser.getDateOfBirth()
        );

        if (result.isSuccess()) {
            session.setAttribute("currentUser", result.getData());
            session.setAttribute("flashSuccess", "Administrator profile updated successfully.");
            auditDao.logAction(sessionUser.getUserId(), sessionUser.getFullName(), "UPDATE_ADMIN_PROFILE",
                    "USER", String.valueOf(sessionUser.getUserId()),
                    "Updated administrator name to " + firstName + " " + lastName + " (Phone: " + phone + ")",
                    "SUCCESS");
        } else {
            session.setAttribute("flashError", result.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/profile");
    }

    private void handlePasswordChange(HttpServletRequest request, HttpServletResponse response,
                                      HttpSession session, User sessionUser)
            throws IOException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        ServiceResult<Void> result = userService.changePassword(
                sessionUser.getUserId(), currentPassword, newPassword, confirmPassword
        );

        if (result.isSuccess()) {
            session.setAttribute("flashSuccess", "Administrator security password updated successfully.");
            auditDao.logAction(sessionUser.getUserId(), sessionUser.getFullName(), "CHANGE_ADMIN_PASSWORD",
                    "USER", String.valueOf(sessionUser.getUserId()),
                    "Administrator updated their account login password credentials",
                    "SUCCESS");
        } else {
            session.setAttribute("flashError", result.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/profile");
    }
}
