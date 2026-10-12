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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "MyBookingsServlet", urlPatterns = {"/booking/my-bookings", "/my-bookings"})
public class MyBookingsServlet extends BaseBookingServlet {
    private static final long serialVersionUID = 1L;

    private final BookingService bookingService = new BookingService();
    private final IFlightProvider flightProvider = new DatabaseFlightProvider();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAuthenticationOrRedirect(request, response)) {
            return;
        }

        Long userId = getUserId(request);
        List<Booking> bookings = bookingService.getUserBookings(userId);

        Map<Long, FlightSummary> flightMap = new HashMap<>();
        for (Booking b : bookings) {
            if (!flightMap.containsKey(b.getFlightId())) {
                flightMap.put(b.getFlightId(), flightProvider.getFlightById(b.getFlightId()));
            }
        }

        request.setAttribute("bookings", bookings);
        request.setAttribute("flightMap", flightMap);
        request.setAttribute("userName", getUserName(request));

        forwardToJsp("/booking/my-bookings.jsp", request, response);
    }
}
