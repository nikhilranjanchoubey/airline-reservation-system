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
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller for Manage Booking portal: PNR lookup, itinerary display, and ticket cancellation.
 */
@WebServlet(name = "ManageBookingController", urlPatterns = {"/manage-booking", "/booking/cancel"})
public class ManageBookingController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(ManageBookingController.class.getName());

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

        String pnr = request.getParameter("pnr");
        String lastName = request.getParameter("lastName");

        if (pnr != null && !pnr.trim().isEmpty()) {
            Booking booking = bookingService.getBookingByPnrAndLastName(pnr.trim(), lastName, currentUser);
            if (booking != null) {
                request.setAttribute("booking", booking);
            } else {
                request.setAttribute("errorMessage", "No booking records found for reference '" + pnr.trim() + "'. If you are not logged in, please provide the passenger last name for verification.");
            }
            request.setAttribute("searchedPnr", pnr.trim());
            request.setAttribute("searchedLastName", lastName != null ? lastName.trim() : "");
        } else if (currentUser != null) {
            // Pre-load recent passenger bookings for quick navigation
            List<Booking> userBookings = bookingService.getUserBookings((long) currentUser.getUserId());
            request.setAttribute("userBookings", userBookings);
        }

        // Deliver flash messages
        if (session != null) {
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
        }

        request.setAttribute("pageTitle", "Manage Your Booking - SkyTech");
        request.getRequestDispatcher("/WEB-INF/views/flight/manage-booking.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        String action = request.getParameter("action");

        if ("cancel".equalsIgnoreCase(action)) {
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            String bookingIdStr = request.getParameter("bookingId");
            String reason = request.getParameter("reason");
            long bookingId = Long.parseLong(bookingIdStr);

            try {
                boolean cancelled = bookingService.cancelBooking(bookingId, reason, currentUser);
                if (cancelled && session != null) {
                    session.setAttribute("flashSuccess", "Your reservation has been successfully cancelled. The refund has been recorded under the project cancellation policy.");
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Cancellation failed: " + e.getMessage(), e);
                if (session != null) {
                    session.setAttribute("flashError", e.getMessage());
                }
            }

            String pnr = request.getParameter("pnr");
            response.sendRedirect(request.getContextPath() + "/manage-booking" + (pnr != null ? "?pnr=" + pnr : ""));
            return;
        }

        // Default: Search submit
        String pnr = request.getParameter("pnr");
        String lastName = request.getParameter("lastName");
        response.sendRedirect(request.getContextPath() + "/manage-booking?pnr=" + (pnr != null ? pnr.trim() : "") +
                "&lastName=" + (lastName != null ? lastName.trim() : ""));
    }
}
