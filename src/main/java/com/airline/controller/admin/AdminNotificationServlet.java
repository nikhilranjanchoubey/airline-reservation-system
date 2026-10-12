package com.airline.controller.admin;

import com.skytech.dao.AdminDashboardDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Administrative controller for operational notifications and system alerts.
 */
@WebServlet(name = "AdminNotificationServlet", urlPatterns = {"/admin/notifications"})
public class AdminNotificationServlet extends HttpServlet {

    private final AdminDashboardDao dashboardDao = new AdminDashboardDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Map<String, Object>> pendingBookings = dashboardDao.getPendingPaymentBookings(20);
        List<Map<String, Object>> recentCancellations = dashboardDao.getRecentCancellations(20);

        request.setAttribute("pendingBookings", pendingBookings);
        request.setAttribute("recentCancellations", recentCancellations);

        request.getRequestDispatcher("/WEB-INF/views/admin/notifications.jsp").forward(request, response);
    }
}
