package com.airline.controller.admin;

import com.airline.dao.AdminAuditDao;
import com.airline.model.User;
import com.skytech.dao.AdminBookingDao;
import com.skytech.dao.AdminPassengerDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Administrative controller for passenger directory, profile inspection,
 * account status management, and booking history lookups.
 */
@WebServlet(name = "AdminPassengerServlet", urlPatterns = {"/admin/passengers"})
public class AdminPassengerServlet extends HttpServlet {

    private final AdminPassengerDao passengerDao = new AdminPassengerDao();
    private final AdminBookingDao bookingDao = new AdminBookingDao();
    private final AdminAuditDao auditDao = new AdminAuditDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("view".equalsIgnoreCase(action)) {
            String userIdStr = request.getParameter("userId");
            if (userIdStr != null) {
                try {
                    int targetId = Integer.parseInt(userIdStr);
                    Map<String, Object> details = passengerDao.getPassengerDetails(targetId);
                    if (details != null) {
                        request.setAttribute("passengerDetails", details);
                        // Also retrieve recent bookings for this passenger
                        List<Map<String, Object>> passengerBookings = bookingDao.searchBookings(
                                (String) details.get("email"), null, null, null, null, 1, 10
                        );
                        request.setAttribute("passengerBookings", passengerBookings);
                    }
                } catch (NumberFormatException ignored) {}
            }
        }

        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String role = request.getParameter("role");

        int page = 1;
        int pageSize = 10;
        try {
            String pStr = request.getParameter("page");
            if (pStr != null) page = Math.max(1, Integer.parseInt(pStr));
        } catch (NumberFormatException ignored) {}

        List<Map<String, Object>> passengers = passengerDao.getPassengers(search, status, role, page, pageSize);
        int totalCount = passengerDao.countPassengers(search, status, role);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);

        request.setAttribute("passengers", passengers);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", Math.max(1, totalPages));
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("role", role);

        HttpSession session = request.getSession(false);
        if (session != null) {
            String flashSuccess = (String) session.getAttribute("flashSuccess");
            if (flashSuccess != null) {
                request.setAttribute("flashSuccess", flashSuccess);
                session.removeAttribute("flashSuccess");
            }
            String flashError = (String) session.getAttribute("flashError");
            if (flashError != null) {
                request.setAttribute("flashError", flashError);
                session.removeAttribute("flashError");
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/passengers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User admin = (session != null) ? (User) session.getAttribute("currentUser") : null;
        int adminId = (admin != null) ? admin.getUserId() : 1;
        String adminName = (admin != null) ? (admin.getFirstName() + " " + admin.getLastName()).trim() : "Administrator";

        String action = request.getParameter("action");
        String userIdStr = request.getParameter("userId");

        if ("toggle_status".equalsIgnoreCase(action) && userIdStr != null) {
            try {
                int targetId = Integer.parseInt(userIdStr);
                // Self-protection guard
                if (admin != null && admin.getUserId() == targetId) {
                    if (session != null) session.setAttribute("flashError", "Security restriction: You cannot modify your own administrator account status.");
                } else {
                    String newStatus = request.getParameter("newStatus");
                    if (newStatus == null || (!newStatus.equalsIgnoreCase("ACTIVE") && !newStatus.equalsIgnoreCase("SUSPENDED"))) {
                        newStatus = "ACTIVE";
                    }
                    boolean ok = passengerDao.updateStatus(targetId, newStatus);
                    if (ok) {
                        if (session != null) session.setAttribute("flashSuccess", "Passenger account status updated to " + newStatus + ".");
                        auditDao.logAction(adminId, adminName, "USER_STATUS_CHANGE", "USER", String.valueOf(targetId),
                                "Changed account status to " + newStatus, "SUCCESS");
                    } else {
                        if (session != null) session.setAttribute("flashError", "Failed to update user account status.");
                    }
                }
            } catch (NumberFormatException ignored) {}
        }

        response.sendRedirect(request.getContextPath() + "/admin/passengers");
    }
}
