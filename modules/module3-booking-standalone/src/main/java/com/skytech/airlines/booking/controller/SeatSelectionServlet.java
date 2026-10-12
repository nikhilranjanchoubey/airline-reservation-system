package com.skytech.airlines.booking.controller;

import com.skytech.airlines.booking.exception.SeatUnavailableException;
import com.skytech.airlines.booking.integration.DatabaseFlightProvider;
import com.skytech.airlines.booking.integration.FlightSummary;
import com.skytech.airlines.booking.integration.IFlightProvider;
import com.skytech.airlines.booking.model.Passenger;
import com.skytech.airlines.booking.model.Seat;
import com.skytech.airlines.booking.service.SeatAllocationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@WebServlet(name = "SeatSelectionServlet", urlPatterns = {"/booking/seats", "/booking/seats/map"})
public class SeatSelectionServlet extends BaseBookingServlet {
    private static final long serialVersionUID = 1L;

    private final IFlightProvider flightProvider = new DatabaseFlightProvider();
    private final SeatAllocationService seatAllocationService = new SeatAllocationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAuthenticationOrRedirect(request, response)) {
            return;
        }

        HttpSession session = request.getSession(true);
        Long flightId = (Long) session.getAttribute("selectedFlightId");
        if (flightId == null) flightId = 101L;

        if (request.getRequestURI().endsWith("/map")) {
            List<Seat> seatMap = seatAllocationService.getCabinSeatMap(flightId);
            writeJsonResponse(response, seatMap);
            return;
        }

        @SuppressWarnings("unchecked")
        List<Passenger> passengers = (List<Passenger>) session.getAttribute("bookingPassengers");
        if (passengers == null || passengers.isEmpty()) {
            setSessionError(request, "Please fill in passenger details first.");
            response.sendRedirect(request.getContextPath() + "/booking/passengers");
            return;
        }

        FlightSummary flight = flightProvider.getFlightById(flightId);
        List<Seat> cabinSeats = seatAllocationService.getCabinSeatMap(flightId);

        request.setAttribute("stepNumber", 3);
        request.setAttribute("flight", flight);
        request.setAttribute("passengers", passengers);
        request.setAttribute("cabinSeats", cabinSeats);

        forwardToJsp("/booking/seat-selection.jsp", request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAuthenticationOrRedirect(request, response)) {
            return;
        }

        HttpSession session = request.getSession(true);
        Long flightId = (Long) session.getAttribute("selectedFlightId");
        if (flightId == null) flightId = 101L;

        @SuppressWarnings("unchecked")
        List<Passenger> passengers = (List<Passenger>) session.getAttribute("bookingPassengers");
        if (passengers == null || passengers.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/booking/passengers");
            return;
        }

        String[] selectedSeatsArr = request.getParameterValues("selectedSeats[]");
        List<String> selectedSeats = new ArrayList<>();
        if (selectedSeatsArr != null) {
            for (String s : selectedSeatsArr) {
                if (s != null && !s.trim().isEmpty()) selectedSeats.add(s.trim().toUpperCase());
            }
        }

        try {
            seatAllocationService.validateSeatSelections(flightId, selectedSeats, passengers.size());
            session.setAttribute("selectedSeats", selectedSeats);
            response.sendRedirect(request.getContextPath() + "/booking/review");

        } catch (SeatUnavailableException e) {
            request.setAttribute("seatError", e.getMessage());
            doGet(request, response);
        }
    }
}
