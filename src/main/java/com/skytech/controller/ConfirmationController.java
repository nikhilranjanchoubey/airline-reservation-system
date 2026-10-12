package com.skytech.controller;

import com.airline.model.Role;
import com.airline.model.User;
import com.skytech.model.Booking;
import com.skytech.service.BookingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Controller displaying the confirmed reservation summary, PNR, and ticketing actions.
 */
@WebServlet(name = "ConfirmationController", urlPatterns = {"/booking/confirmation"})
public class ConfirmationController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookingService bookingService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.bookingService = new BookingService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/search-flights");
            return;
        }

        long bookingId;
        try {
            bookingId = Long.parseLong(idParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/search-flights");
            return;
        }

        Booking booking = bookingService.getBookingById(bookingId, currentUser);
        if (booking == null) {
            response.sendRedirect(request.getContextPath() + "/search-flights");
            return;
        }

        if (currentUser.getRole() != Role.ADMIN && booking.getUserId() != null && booking.getUserId() != currentUser.getUserId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied to booking confirmation.");
            return;
        }

        request.setAttribute("booking", booking);
        request.setAttribute("pageTitle", "Booking Confirmed (" + booking.getPnr() + ") - SkyTech");
        request.getRequestDispatcher("/WEB-INF/views/booking/confirmation.jsp").forward(request, response);
    }
}
