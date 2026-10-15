package com.skytech.controller.api;

import com.airline.model.Role;
import com.airline.model.User;
import com.google.gson.Gson;
import com.skytech.dao.BookingDao;
import com.skytech.model.Booking;
import com.skytech.service.FlightSearchService;
import com.skytech.util.JsonUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * REST API Controller for Administration and Management:
 *   - GET /api/admin/overview
 *   - GET /api/admin/bookings
 *
 * Protected: requires Role.ADMIN session authorization.
 */
@WebServlet(name = "AdminApiController", urlPatterns = {
        "/api/admin/overview",
        "/api/admin/bookings"
})
public class AdminApiController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminApiController.class.getName());
    private final Gson gson = JsonUtil.getGson();
    private BookingDao bookingDao;
    private FlightSearchService flightSearchService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.bookingDao = new BookingDao();
        this.flightSearchService = new FlightSearchService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED, "Unauthenticated. Admin sign in required.");
            return;
        }

        if (currentUser.getRole() != Role.ADMIN) {
            writeError(response, HttpServletResponse.SC_FORBIDDEN, "Access denied. Administrator privileges required.");
            return;
        }

        String path = request.getServletPath();
        if ("/api/admin/overview".equalsIgnoreCase(path)) {
            handleAdminOverview(request, response);
        } else if ("/api/admin/bookings".equalsIgnoreCase(path)) {
            handleAdminBookings(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void handleAdminOverview(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            List<Booking> allBookings = bookingDao.getAllBookings();
            long totalBookings = allBookings.size();
            long confirmedCount = allBookings.stream().filter(Booking::isConfirmed).count();
            long pendingCount = allBookings.stream().filter(Booking::isPending).count();
            long cancelledCount = allBookings.stream().filter(Booking::isCancelled).count();

            double totalRevenue = allBookings.stream()
                    .filter(Booking::isConfirmed)
                    .mapToDouble(b -> b.getTotalAmount() != null ? b.getTotalAmount().doubleValue() : 0.0)
                    .sum();

            Map<String, Object> stats = new LinkedHashMap<>();
            stats.put("totalBookings", totalBookings);
            stats.put("confirmedCount", confirmedCount);
            stats.put("pendingCount", pendingCount);
            stats.put("cancelledCount", cancelledCount);
            stats.put("totalRevenue", totalRevenue);

            Map<String, Object> resp = new LinkedHashMap<>();
            resp.put("success", true);
            resp.put("stats", stats);
            resp.put("recentBookings", allBookings.stream().limit(10).toList());

            writeJsonResponse(response, HttpServletResponse.SC_OK, resp);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Admin overview error: " + e.getMessage(), e);
            writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    private void handleAdminBookings(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            List<Booking> allBookings = bookingDao.getAllBookings();
            Map<String, Object> resp = new LinkedHashMap<>();
            resp.put("success", true);
            resp.put("count", allBookings.size());
            resp.put("bookings", allBookings);

            writeJsonResponse(response, HttpServletResponse.SC_OK, resp);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Admin bookings error: " + e.getMessage(), e);
            writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    private void writeJsonResponse(HttpServletResponse response, int status, Object data) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        try (PrintWriter out = response.getWriter()) {
            out.print(gson.toJson(data));
            out.flush();
        }
    }

    private void writeError(HttpServletResponse response, int status, String message) throws IOException {
        Map<String, Object> err = new LinkedHashMap<>();
        err.put("success", false);
        err.put("error", message);
        writeJsonResponse(response, status, err);
    }
}
