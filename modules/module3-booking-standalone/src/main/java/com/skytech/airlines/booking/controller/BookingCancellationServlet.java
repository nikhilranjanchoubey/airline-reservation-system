package com.skytech.airlines.booking.controller;

import com.skytech.airlines.booking.exception.BookingException;
import com.skytech.airlines.booking.service.BookingService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.logging.Logger;

/**
 * Controller servlet handling passenger flight booking cancellation and seat release.
 */
@WebServlet("/booking/cancel")
public class BookingCancellationServlet extends BaseBookingServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(BookingCancellationServlet.class.getName());

    private final BookingService bookingService = new BookingService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAuthenticationOrRedirect(request, response)) {
            return;
        }

        String pnr = request.getParameter("pnr");
        String reason = request.getParameter("reason");
        if (reason == null || reason.trim().isEmpty()) {
            reason = "Passenger request";
        }

        if (pnr == null || pnr.trim().isEmpty()) {
            setSessionError(request, "PNR reference is required for cancellation.");
            response.sendRedirect(request.getContextPath() + "/booking/my-bookings");
            return;
        }

        pnr = pnr.trim().toUpperCase();
        Long userId = getUserId(request);

        try {
            boolean success = bookingService.cancelBooking(pnr, userId, reason);
            if (success) {
                setSessionSuccess(request, "Reservation " + pnr + " was cancelled successfully. Seats have been released and refund initiated.");
                response.sendRedirect(request.getContextPath() + "/booking/confirmation?pnr=" + pnr);
            } else {
                setSessionError(request, "Unable to cancel reservation " + pnr + ". Please contact airline support.");
                response.sendRedirect(request.getContextPath() + "/booking/confirmation?pnr=" + pnr);
            }
        } catch (BookingException be) {
            LOGGER.warning("Cancellation failed for PNR " + pnr + ": " + be.getMessage());
            setSessionError(request, be.getMessage());
            response.sendRedirect(request.getContextPath() + "/booking/confirmation?pnr=" + pnr);
        } catch (Exception e) {
            LOGGER.severe("Unexpected error during cancellation of PNR " + pnr + ": " + e.getMessage());
            setSessionError(request, "An unexpected error occurred while processing cancellation.");
            response.sendRedirect(request.getContextPath() + "/booking/confirmation?pnr=" + pnr);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pnr = request.getParameter("pnr");
        if (pnr != null && !pnr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/booking/confirmation?pnr=" + pnr.trim().toUpperCase());
        } else {
            response.sendRedirect(request.getContextPath() + "/booking/my-bookings");
        }
    }
}
