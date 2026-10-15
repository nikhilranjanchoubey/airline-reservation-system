package com.skytech.controller;

import com.airline.model.User;
import com.skytech.model.Booking;
import com.skytech.model.FlightSchedule;
import com.skytech.model.Passenger;
import com.skytech.service.BookingService;
import com.skytech.service.FareCalculationService;
import com.skytech.service.FlightSearchService;
import com.skytech.service.SeatPricingConfig;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller managing the flight booking workflow:
 * authentication enforcement, passenger details collection, and pending booking creation.
 */
@WebServlet(name = "BookingController", urlPatterns = {"/book-flight", "/booking/passenger-details"})
public class BookingController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(BookingController.class.getName());

    private BookingService bookingService;
    private FlightSearchService flightSearchService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.bookingService = new BookingService();
        this.flightSearchService = new FlightSearchService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // 1. Mandatory Authentication Check
        if (currentUser == null) {
            String queryString = request.getQueryString();
            String targetUrl = request.getContextPath() + "/book-flight" + (queryString != null ? "?" + queryString : "");

            HttpSession newOrExistingSession = request.getSession(true);
            newOrExistingSession.setAttribute("redirectAfterLogin", targetUrl);
            newOrExistingSession.setAttribute("flashError", "Please sign in or create a SkyTech account to proceed with your booking.");

            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Parse and validate flight parameters
        String scheduleIdParam = request.getParameter("scheduleId");
        if (scheduleIdParam == null || scheduleIdParam.trim().isEmpty()) {
            scheduleIdParam = request.getParameter("id");
        }

        String flightNumberParam = request.getParameter("flightNumber");
        String sourceParam = request.getParameter("source");
        if (sourceParam == null || sourceParam.trim().isEmpty()) {
            sourceParam = request.getParameter("origin");
        }
        String destParam = request.getParameter("destination");
        if (destParam == null || destParam.trim().isEmpty()) {
            destParam = request.getParameter("dest");
        }

        String travelClass = request.getParameter("travelClass");
        if (travelClass == null || travelClass.trim().isEmpty()) {
            travelClass = "Economy";
        }

        int passengersCount = 1;
        String passParam = request.getParameter("passengers");
        if (passParam != null && !passParam.trim().isEmpty()) {
            try {
                passengersCount = Math.max(1, Integer.parseInt(passParam.trim()));
            } catch (NumberFormatException ignored) {
            }
        }

        String departureDateStr = request.getParameter("departureDate");
        LocalDate departureDate = null;
        if (departureDateStr != null && !departureDateStr.trim().isEmpty()) {
            try {
                departureDate = LocalDate.parse(departureDateStr.trim());
            } catch (Exception ignored) {
            }
        }

        int scheduleId = -1;
        if (scheduleIdParam != null && !scheduleIdParam.trim().isEmpty()) {
            try {
                scheduleId = Integer.parseInt(scheduleIdParam.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        FlightSchedule schedule = null;
        if (scheduleId > 0) {
            try {
                schedule = flightSearchService.getFlightDetails(scheduleId, departureDate);
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Failed to retrieve schedule details for ID " + scheduleId + ": " + e.getMessage());
            }
        }

        // Fallback: Resolve by flight number and route if scheduleId alone expired
        if (schedule == null && flightNumberParam != null && !flightNumberParam.trim().isEmpty()) {
            try {
                schedule = flightSearchService.getFlightDetailsByRouteAndFlightNumber(flightNumberParam, sourceParam, destParam, departureDate);
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Failed to fallback retrieve schedule by flightNumber: " + e.getMessage());
            }
        }

        if (schedule == null) {
            HttpSession s = request.getSession(true);
            s.setAttribute("flashError", "The requested flight schedule could not be found or has expired. Please select an available flight.");
            String redirectUrl = request.getContextPath() + "/search-flights";
            if (sourceParam != null && destParam != null && departureDateStr != null) {
                redirectUrl += "?source=" + URLEncoder.encode(sourceParam, StandardCharsets.UTF_8)
                            + "&origin=" + URLEncoder.encode(sourceParam, StandardCharsets.UTF_8)
                            + "&destination=" + URLEncoder.encode(destParam, StandardCharsets.UTF_8)
                            + "&dest=" + URLEncoder.encode(destParam, StandardCharsets.UTF_8)
                            + "&departureDate=" + URLEncoder.encode(departureDateStr, StandardCharsets.UTF_8)
                            + "&tripType=one-way&adults=1&passengers=1&travelClass=Economy";
            }
            response.sendRedirect(redirectUrl);
            return;
        }

        if (departureDate != null) {
            schedule.setFlightDate(java.sql.Date.valueOf(departureDate));
        }

        // Selected Seats Parsing
        String seatNumbersParam = request.getParameter("selectedSeats");
        List<String> selectedSeats = new ArrayList<>();
        if (seatNumbersParam != null && !seatNumbersParam.trim().isEmpty()) {
            String[] split = seatNumbersParam.split(",");
            for (String s : split) {
                if (!s.trim().isEmpty()) {
                    selectedSeats.add(s.trim().toUpperCase());
                }
            }
        }

        // Calculate Pricing Summary
        BigDecimal perPassengerFare = schedule.getPriceForClass(travelClass);
        FareCalculationService.FareSummary fareSummary =
                FareCalculationService.calculateFare(perPassengerFare, passengersCount, null);

        // Calculate seat fees if seats selected
        BigDecimal seatFeesTotal = BigDecimal.ZERO;
        String airlineCode = (schedule.getFlight() != null && schedule.getFlight().getAirline() != null)
                ? schedule.getFlight().getAirline().getAirlineCode() : "6E";

        for (String s : selectedSeats) {
            if (s.length() >= 2) {
                try {
                    int row = Integer.parseInt(s.replaceAll("[^0-9]", ""));
                    String col = s.replaceAll("[^A-Za-z]", "").toUpperCase();
                    SeatPricingConfig.SeatPricingInfo pInfo = SeatPricingConfig.resolveSeatPricing(airlineCode, row, col);
                    seatFeesTotal = seatFeesTotal.add(pInfo.getPrice());
                } catch (Exception ignored) {
                }
            }
        }

        BigDecimal subtotal = fareSummary.getBaseFareTotal().add(seatFeesTotal);
        BigDecimal taxesAndFees = subtotal.multiply(new BigDecimal("0.12")).setScale(2, java.math.RoundingMode.HALF_UP);
        BigDecimal grandTotal = subtotal.add(taxesAndFees).setScale(2, java.math.RoundingMode.HALF_UP);

        request.setAttribute("schedule", schedule);
        request.setAttribute("travelClass", travelClass);
        request.setAttribute("passengersCount", passengersCount);
        request.setAttribute("departureDate", departureDateStr);
        request.setAttribute("selectedSeats", selectedSeats);
        request.setAttribute("selectedSeatsStr", String.join(", ", selectedSeats));
        request.setAttribute("perPassengerFare", perPassengerFare);
        request.setAttribute("baseTotal", fareSummary.getBaseFareTotal());
        request.setAttribute("seatFeesTotal", seatFeesTotal);
        request.setAttribute("taxesAndFees", taxesAndFees);
        request.setAttribute("grandTotal", grandTotal);
        request.setAttribute("currentUser", currentUser);
        request.setAttribute("pageTitle", "Passenger Details - SkyTech");

        request.getRequestDispatcher("/WEB-INF/views/booking/passenger-details.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String scheduleIdStr = request.getParameter("scheduleId");
        String travelClass = request.getParameter("travelClass");
        String passCountStr = request.getParameter("passengersCount");
        String selectedSeatsStr = request.getParameter("selectedSeats");
        String contactEmail = request.getParameter("contactEmail");
        String contactPhone = request.getParameter("contactPhone");

        int scheduleId = Integer.parseInt(scheduleIdStr);
        int passengersCount = Integer.parseInt(passCountStr != null ? passCountStr : "1");

        List<String> seatList = new ArrayList<>();
        if (selectedSeatsStr != null && !selectedSeatsStr.trim().isEmpty()) {
            String[] split = selectedSeatsStr.split(",");
            for (String s : split) {
                if (!s.trim().isEmpty()) {
                    seatList.add(s.trim().toUpperCase());
                }
            }
        }

        // Collect individual passenger records from form fields
        List<Passenger> passengers = new ArrayList<>();
        for (int i = 1; i <= passengersCount; i++) {
            String firstName = request.getParameter("firstName_" + i);
            String lastName = request.getParameter("lastName_" + i);
            String gender = request.getParameter("gender_" + i);
            String dobStr = request.getParameter("dob_" + i);
            String passport = request.getParameter("passport_" + i);
            String nationality = request.getParameter("nationality_" + i);
            String type = request.getParameter("type_" + i);

            if (firstName == null || firstName.trim().isEmpty()) {
                firstName = (i == 1) ? currentUser.getFirstName() : "Passenger " + i;
            }
            if (lastName == null || lastName.trim().isEmpty()) {
                lastName = (i == 1) ? currentUser.getLastName() : "";
            }

            Passenger p = new Passenger();
            p.setFirstName(firstName.trim());
            p.setLastName(lastName.trim());
            p.setGender(gender != null ? gender.trim() : "MALE");
            p.setPassengerType(type != null ? type.trim() : "ADULT");
            p.setPassportNumber(passport != null ? passport.trim() : null);
            p.setNationality(nationality != null && !nationality.trim().isEmpty() ? nationality.trim() : "Indian");

            if (dobStr != null && !dobStr.trim().isEmpty()) {
                try {
                    p.setDateOfBirth(LocalDate.parse(dobStr.trim()));
                } catch (Exception ignored) {
                }
            }

            if (i - 1 < seatList.size()) {
                p.setSeatNumber(seatList.get(i - 1));
            }

            passengers.add(p);
        }

        try {
            Booking booking = bookingService.createPendingBooking(
                    currentUser,
                    scheduleId,
                    travelClass,
                    passengers,
                    seatList,
                    contactEmail != null ? contactEmail.trim() : currentUser.getEmail(),
                    contactPhone != null ? contactPhone.trim() : currentUser.getPhone()
            );

            // Redirect to checkout payment step
            response.sendRedirect(request.getContextPath() + "/booking/checkout?bookingId=" + booking.getId());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Booking initiation failure: " + e.getMessage(), e);
            request.setAttribute("errorMessage", e.getMessage());
            doGet(request, response);
        }
    }
}
