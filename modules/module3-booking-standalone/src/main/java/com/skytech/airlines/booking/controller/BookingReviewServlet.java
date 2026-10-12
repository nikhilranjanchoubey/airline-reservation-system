package com.skytech.airlines.booking.controller;

import com.skytech.airlines.booking.exception.BookingException;
import com.skytech.airlines.booking.integration.DatabaseFlightProvider;
import com.skytech.airlines.booking.integration.FlightSummary;
import com.skytech.airlines.booking.integration.IFlightProvider;
import com.skytech.airlines.booking.model.Booking;
import com.skytech.airlines.booking.model.FareBreakdown;
import com.skytech.airlines.booking.model.Passenger;
import com.skytech.airlines.booking.model.SeatAllocation;
import com.skytech.airlines.booking.service.BookingService;
import com.skytech.airlines.booking.service.SeatAllocationService;
import com.skytech.airlines.booking.util.FareCalculator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "BookingReviewServlet", urlPatterns = {"/booking/review"})
public class BookingReviewServlet extends BaseBookingServlet {
    private static final long serialVersionUID = 1L;

    private final IFlightProvider flightProvider = new DatabaseFlightProvider();
    private final BookingService bookingService = new BookingService();
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

        @SuppressWarnings("unchecked")
        List<Passenger> passengers = (List<Passenger>) session.getAttribute("bookingPassengers");
        @SuppressWarnings("unchecked")
        List<String> selectedSeats = (List<String>) session.getAttribute("selectedSeats");
        String contactEmail = (String) session.getAttribute("contactEmail");
        String contactPhone = (String) session.getAttribute("contactPhone");

        if (passengers == null || selectedSeats == null) {
            response.sendRedirect(request.getContextPath() + "/booking/passengers");
            return;
        }

        FlightSummary flight = flightProvider.getFlightById(flightId);

        List<SeatAllocation> allocations = new ArrayList<>();
        for (int i = 0; i < passengers.size(); i++) {
            String seat = selectedSeats.get(i);
            passengers.get(i).setSeatNumber(seat);
            allocations.add(new SeatAllocation(null, null, flightId, seat,
                    seatAllocationService.getClassForSeat(seat), seatAllocationService.getFeeForSeat(seat), "HELD"));
        }

        FareBreakdown fare = FareCalculator.calculateFare(flight.getBaseFare(), passengers, allocations);

        request.setAttribute("stepNumber", 4);
        request.setAttribute("flight", flight);
        request.setAttribute("passengers", passengers);
        request.setAttribute("selectedSeats", selectedSeats);
        request.setAttribute("fare", fare);
        request.setAttribute("contactEmail", contactEmail);
        request.setAttribute("contactPhone", contactPhone);

        forwardToJsp("/booking/booking-review.jsp", request, response);
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
        @SuppressWarnings("unchecked")
        List<String> selectedSeats = (List<String>) session.getAttribute("selectedSeats");
        String contactEmail = (String) session.getAttribute("contactEmail");
        String contactPhone = (String) session.getAttribute("contactPhone");

        FlightSummary flight = flightProvider.getFlightById(flightId);
        Long userId = getUserId(request);

        try {
            Booking pendingBooking = bookingService.createPendingBooking(
                    userId, flightId, passengers, selectedSeats, flight.getBaseFare(), contactEmail, contactPhone
            );
            session.setAttribute("currentPendingBooking", pendingBooking);
            response.sendRedirect(request.getContextPath() + "/booking/payment?pnr=" + pendingBooking.getPnr());

        } catch (BookingException e) {
            setSessionError(request, "Error creating booking: " + e.getMessage());
            doGet(request, response);
        }
    }
}
