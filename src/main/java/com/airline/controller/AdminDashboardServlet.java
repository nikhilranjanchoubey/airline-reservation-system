package com.airline.controller;

import com.airline.model.Role;
import com.airline.model.User;
import com.skytech.dao.AdminDashboardDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

/**
 * Controller providing the airline operations executive dashboard.
 * Aggregates database-derived KPIs, operational queues (departures, recent bookings,
 * payments, cancellations), seat inventory metrics, and analytics charts.
 * Access is guarded by AdminAuthorizationFilter.
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin", "/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final AdminDashboardDao dashboardDao;

    public AdminDashboardServlet() {
        this.dashboardDao = new AdminDashboardDao();
    }

    public AdminDashboardServlet(AdminDashboardDao dashboardDao) {
        this.dashboardDao = dashboardDao != null ? dashboardDao : new AdminDashboardDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Current Date & Time info
        request.setAttribute("currentDateFormatted", LocalDate.now().format(DateTimeFormatter.ofPattern("EEEE, d MMMM yyyy")));

        // 2. Database-Derived KPIs (8 Required Metrics)
        Map<String, Object> kpis = dashboardDao.getDashboardKpis();
        request.setAttribute("kpis", kpis);

        // 3. Operational Overview Lists
        List<Map<String, Object>> upcomingDepartures = dashboardDao.getUpcomingDepartures(5);
        List<Map<String, Object>> recentReservations = dashboardDao.getRecentReservations(6);
        List<Map<String, Object>> recentPayments = dashboardDao.getRecentSuccessfulPayments(5);
        List<Map<String, Object>> pendingBookings = dashboardDao.getPendingPaymentBookings(5);
        List<Map<String, Object>> recentCancellations = dashboardDao.getRecentCancellations(5);
        Map<String, Object> inventorySummary = dashboardDao.getInventorySummary();

        request.setAttribute("upcomingDepartures", upcomingDepartures);
        request.setAttribute("recentReservations", recentReservations);
        request.setAttribute("recentPayments", recentPayments);
        request.setAttribute("pendingBookings", pendingBookings);
        request.setAttribute("recentCancellations", recentCancellations);
        request.setAttribute("inventorySummary", inventorySummary);

        // 4. Chart Analytics Data
        List<Map<String, Object>> bookings7Days = dashboardDao.getBookingsLast7Days();
        List<Map<String, Object>> revenue7Days = dashboardDao.getRevenueLast7Days();
        Map<String, Integer> statusDistribution = dashboardDao.getBookingStatusDistribution();
        List<Map<String, Object>> popularRoutes = dashboardDao.getPopularRoutes(5);

        request.setAttribute("chartBookings7Days", bookings7Days);
        request.setAttribute("chartRevenue7Days", revenue7Days);
        request.setAttribute("chartStatusDistribution", statusDistribution);
        request.setAttribute("chartPopularRoutes", popularRoutes);

        // Flash Messages
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

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
    }
}
