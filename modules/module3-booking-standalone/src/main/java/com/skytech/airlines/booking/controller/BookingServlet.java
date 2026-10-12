package com.skytech.airlines.booking.controller;

import com.skytech.airlines.booking.integration.DatabaseFlightProvider;
import com.skytech.airlines.booking.integration.FlightSummary;
import com.skytech.airlines.booking.integration.IFlightProvider;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Entry router for the booking flow:
 * Validates selected flight and initializes the booking workflow session.
 * Mapped to /booking and /booking/start
 */
@WebServlet(name = "BookingServlet", urlPatterns = {"/booking", "/booking/start"})
public class BookingServlet extends BaseBookingServlet {
    private static final long serialVersionUID = 1L;

    private final IFlightProvider flightProvider = new DatabaseFlightProvider();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAuthenticationOrRedirect(request, response)) {
            return;
        }

        String flightIdParam = request.getParameter("flightId");
        Long flightId = 101L; // Default to Flight 101 (DEL -> BOM)
        if (flightIdParam != null && !flightIdParam.trim().isEmpty()) {
            try {
                flightId = Long.parseLong(flightIdParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        FlightSummary flight = flightProvider.getFlightById(flightId);
        if (flight == null) {
            setSessionError(request, "Selected flight is not available. Please choose a flight from the schedule.");
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        HttpSession session = request.getSession(true);
        session.setAttribute("selectedFlightId", flightId);
        session.setAttribute("selectedFlight", flight);

        response.sendRedirect(request.getContextPath() + "/booking/passengers?flightId=" + flightId);
    }
}
