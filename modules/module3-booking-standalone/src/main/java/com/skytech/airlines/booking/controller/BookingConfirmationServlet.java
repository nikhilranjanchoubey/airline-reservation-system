package com.skytech.airlines.booking.controller;

import com.skytech.airlines.booking.integration.DatabaseFlightProvider;
import com.skytech.airlines.booking.integration.FlightSummary;
import com.skytech.airlines.booking.integration.IFlightProvider;
import com.skytech.airlines.booking.model.Booking;
import com.skytech.airlines.booking.service.BookingService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "BookingConfirmationServlet", urlPatterns = {"/booking/confirmation"})
public class BookingConfirmationServlet extends BaseBookingServlet {
    private static final long serialVersionUID = 1L;

    private final BookingService bookingService = new BookingService();
    private final IFlightProvider flightProvider = new DatabaseFlightProvider();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAuthenticationOrRedirect(request, response)) {
            return;
        }

        String pnr = request.getParameter("pnr");
        if (pnr == null || pnr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/booking/my-bookings");
            return;
        }

        pnr = pnr.trim().toUpperCase();
        Long userId = getUserId(request);
        Booking booking = bookingService.getBookingByPnrAndUser(pnr, userId);

        if (booking == null) {
            setSessionError(request, "Booking not found or unauthorized access for PNR: " + pnr);
            response.sendRedirect(request.getContextPath() + "/booking/my-bookings");
            return;
        }

        FlightSummary flight = flightProvider.getFlightById(booking.getFlightId());

        request.setAttribute("stepNumber", 6);
        request.setAttribute("booking", booking);
        request.setAttribute("flight", flight);
        request.setAttribute("passengers", booking.getPassengers());
        request.setAttribute("payment", booking.getPayment());

        forwardToJsp("/booking/booking-confirmation.jsp", request, response);
    }
}
