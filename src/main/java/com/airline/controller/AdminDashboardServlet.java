package com.airline.controller;

import com.airline.model.Role;
import com.airline.model.User;
import com.airline.service.UserService;
import com.skytech.service.BookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Controller providing administrative user, flight, and booking management dashboard.
 * Access is guarded by AdminAuthorizationFilter.
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final UserService userService;
    private final BookingService bookingService;

    public AdminDashboardServlet() {
        this.userService = new UserService();
        this.bookingService = new BookingService();
    }

    public AdminDashboardServlet(UserService userService) {
        this.userService = userService;
        this.bookingService = null;
    }

    public AdminDashboardServlet(UserService userService, BookingService bookingService) {
        this.userService = userService;
        this.bookingService = bookingService;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> userList = userService.getAllUsers();
        request.setAttribute("users", userList);

        long passengerCount = userList.stream().filter(u -> u.getRole() == Role.PASSENGER).count();
        long adminCount = userList.stream().filter(u -> u.getRole() == Role.ADMIN).count();
        long activeCount = userList.stream().filter(u -> "ACTIVE".equalsIgnoreCase(u.getStatus())).count();

        request.setAttribute("totalUsers", userList.size());
        request.setAttribute("passengerCount", passengerCount);
        request.setAttribute("adminCount", adminCount);
        request.setAttribute("activeCount", activeCount);

        if (bookingService != null) {
            request.setAttribute("totalBookings", bookingService.countTotalBookings());
            request.setAttribute("confirmedBookings", bookingService.countConfirmedBookings());
            request.setAttribute("pendingBookings", bookingService.countPendingBookings());
            request.setAttribute("cancelledBookings", bookingService.countCancelledBookings());
            request.setAttribute("totalRevenue", bookingService.calculateTotalRevenue());
            request.setAttribute("allBookings", bookingService.getAllBookings());
        }

        HttpSession session = request.getSession(false);
        if (session != null) {
            String flashSuccess = (String) session.getAttribute("flashSuccess");
            if (flashSuccess != null) {
                request.setAttribute("flashSuccess", flashSuccess);
                session.removeAttribute("flashSuccess");
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String userIdStr = request.getParameter("userId");

        if ("toggle_status".equalsIgnoreCase(action) && userIdStr != null) {
            try {
                int targetUserId = Integer.parseInt(userIdStr);
                HttpSession session = request.getSession(false);
                User currentAdmin = (session != null) ? (User) session.getAttribute("currentUser") : null;

                // Prevent admin from disabling themselves
                if (currentAdmin != null && currentAdmin.getUserId() == targetUserId) {
                    session.setAttribute("flashError", "You cannot modify your own administrator account status.");
                } else {
                    boolean updated = userService.toggleUserStatus(targetUserId);
                    if (updated && session != null) {
                        session.setAttribute("flashSuccess", "User account status updated successfully.");
                    }
                }
            } catch (NumberFormatException ignored) {
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    }
}
