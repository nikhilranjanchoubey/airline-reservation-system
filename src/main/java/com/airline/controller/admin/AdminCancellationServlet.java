package com.airline.controller.admin;

import com.airline.model.User;
import com.skytech.dao.AdminCancellationDao;
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
 * Administrative controller for flight cancellation processing, refund tracking,
 * and transactional seat inventory reinstatement.
 */
@WebServlet(name = "AdminCancellationServlet", urlPatterns = {"/admin/cancellations"})
public class AdminCancellationServlet extends HttpServlet {

    private final AdminCancellationDao cancellationDao = new AdminCancellationDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        String refundStatus = request.getParameter("refundStatus");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");

        int page = 1;
        int pageSize = 10;
        try {
            String pStr = request.getParameter("page");
            if (pStr != null) page = Math.max(1, Integer.parseInt(pStr));
        } catch (NumberFormatException ignored) {}

        List<Map<String, Object>> cancellations = cancellationDao.searchCancellations(search, refundStatus, fromDate, toDate, page, pageSize);
        int totalCount = cancellationDao.countCancellations(search, refundStatus, fromDate, toDate);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);

        request.setAttribute("cancellations", cancellations);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", Math.max(1, totalPages));
        request.setAttribute("search", search);
        request.setAttribute("refundStatus", refundStatus);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);

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

        request.getRequestDispatcher("/WEB-INF/views/admin/cancellations.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User admin = (session != null) ? (User) session.getAttribute("currentUser") : null;
        int adminId = (admin != null) ? admin.getUserId() : 1;
        String adminName = (admin != null) ? (admin.getFirstName() + " " + admin.getLastName()).trim() : "Administrator";

        String action = request.getParameter("action");
        String bookingIdStr = request.getParameter("bookingId");
        String reason = request.getParameter("reason");

        if ("cancel_booking".equalsIgnoreCase(action) && bookingIdStr != null) {
            try {
                long bookingId = Long.parseLong(bookingIdStr);
                boolean success = cancellationDao.processAdminCancellation(bookingId, reason, adminId, adminName);
                if (success) {
                    if (session != null) session.setAttribute("flashSuccess", "Reservation #" + bookingId + " cancelled and flight seat inventory successfully restored.");
                } else {
                    if (session != null) session.setAttribute("flashError", "Failed to cancel reservation #" + bookingId + ". Ensure it is not already cancelled.");
                }
            } catch (NumberFormatException e) {
                if (session != null) session.setAttribute("flashError", "Invalid booking identifier.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/cancellations");
    }
}
