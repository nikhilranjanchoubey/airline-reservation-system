package com.airline.controller.admin;

import com.skytech.dao.AdminBookingDao;
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
 * Administrative controller for the Master Reservations & Booking Registry.
 * Allows deep search by PNR, booking reference, passenger email, status, flight number,
 * and date ranges, with detailed passenger manifest inspection.
 */
@WebServlet(name = "AdminBookingServlet", urlPatterns = {"/admin/bookings"})
public class AdminBookingServlet extends HttpServlet {

    private final AdminBookingDao bookingDao = new AdminBookingDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("view".equalsIgnoreCase(action)) {
            String bookingIdStr = request.getParameter("bookingId");
            if (bookingIdStr != null) {
                try {
                    long bId = Long.parseLong(bookingIdStr);
                    Map<String, Object> details = bookingDao.getBookingFullDetails(bId);
                    if (details != null) {
                        request.setAttribute("bookingDetails", details);
                    }
                } catch (NumberFormatException ignored) {}
            }
        }

        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String flightNumber = request.getParameter("flightNumber");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");

        int page = 1;
        int pageSize = 10;
        try {
            String pStr = request.getParameter("page");
            if (pStr != null) page = Math.max(1, Integer.parseInt(pStr));
        } catch (NumberFormatException ignored) {}

        List<Map<String, Object>> bookings = bookingDao.searchBookings(search, status, flightNumber, fromDate, toDate, page, pageSize);
        int totalCount = bookingDao.countBookings(search, status, flightNumber, fromDate, toDate);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);

        request.setAttribute("bookings", bookings);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", Math.max(1, totalPages));
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("flightNumber", flightNumber);
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

        request.getRequestDispatcher("/WEB-INF/views/admin/bookings.jsp").forward(request, response);
    }
}
