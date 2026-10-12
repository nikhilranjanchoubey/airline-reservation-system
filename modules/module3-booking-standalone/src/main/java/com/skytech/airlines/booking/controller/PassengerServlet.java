package com.skytech.airlines.booking.controller;

import com.skytech.airlines.booking.exception.InvalidPassengerException;
import com.skytech.airlines.booking.integration.DatabaseFlightProvider;
import com.skytech.airlines.booking.integration.FlightSummary;
import com.skytech.airlines.booking.integration.IFlightProvider;
import com.skytech.airlines.booking.model.Passenger;
import com.skytech.airlines.booking.model.PassengerType;
import com.skytech.airlines.booking.service.PassengerService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "PassengerServlet", urlPatterns = {"/booking/passengers"})
public class PassengerServlet extends BaseBookingServlet {
    private static final long serialVersionUID = 1L;

    private final IFlightProvider flightProvider = new DatabaseFlightProvider();
    private final PassengerService passengerService = new PassengerService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAuthenticationOrRedirect(request, response)) {
            return;
        }

        HttpSession session = request.getSession(true);
        Long flightId = (Long) session.getAttribute("selectedFlightId");

        String fParam = request.getParameter("flightId");
        if (fParam != null && !fParam.trim().isEmpty()) {
            try {
                flightId = Long.parseLong(fParam.trim());
                session.setAttribute("selectedFlightId", flightId);
            } catch (NumberFormatException ignored) {}
        }

        if (flightId == null) {
            flightId = 101L;
            session.setAttribute("selectedFlightId", flightId);
        }

        FlightSummary flight = flightProvider.getFlightById(flightId);
        request.setAttribute("stepNumber", 2);
        request.setAttribute("flight", flight);
        request.setAttribute("userName", getUserName(request));
        request.setAttribute("userEmail", getUserEmail(request));

        forwardToJsp("/booking/passenger-details.jsp", request, response);
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

        String contactEmail = request.getParameter("contactEmail");
        String contactPhone = request.getParameter("contactPhone");
        String frequentFlyerOption = request.getParameter("frequentFlyerOption");
        String frequentFlyerNumber = request.getParameter("frequentFlyerNumber");

        String[] firstNames = request.getParameterValues("firstName[]");
        String[] lastNames = request.getParameterValues("lastName[]");
        String[] dobs = request.getParameterValues("dateOfBirth[]");
        String[] genders = request.getParameterValues("gender[]");
        String[] types = request.getParameterValues("passengerType[]");
        String[] ids = request.getParameterValues("passportOrId[]");
        String[] nationalities = request.getParameterValues("nationality[]");

        List<Passenger> passengers = new ArrayList<>();
        if (firstNames != null) {
            for (int i = 0; i < firstNames.length; i++) {
                try {
                    String fn = firstNames[i];
                    String ln = (lastNames != null && i < lastNames.length) ? lastNames[i] : "";
                    LocalDate dob = (dobs != null && i < dobs.length && !dobs[i].isBlank()) ? LocalDate.parse(dobs[i].trim()) : null;
                    String gen = (genders != null && i < genders.length) ? genders[i] : "MALE";
                    PassengerType pt = PassengerType.ADULT;
                    if (types != null && i < types.length && !types[i].isBlank()) {
                        try { pt = PassengerType.valueOf(types[i]); } catch (Exception ignored) {}
                    }
                    String doc = (ids != null && i < ids.length) ? ids[i] : "";
                    String nat = (nationalities != null && i < nationalities.length) ? nationalities[i] : "Indian";

                    passengers.add(new Passenger(fn, ln, dob, gen, pt, doc, nat));
                } catch (DateTimeParseException dtpe) {
                    setSessionError(request, "Invalid date format for Passenger #" + (i + 1));
                    doGet(request, response);
                    return;
                }
            }
        }

        try {
            passengerService.validatePassengerList(passengers, contactEmail, contactPhone);
            session.setAttribute("bookingPassengers", passengers);
            session.setAttribute("contactEmail", contactEmail.trim());
            session.setAttribute("contactPhone", contactPhone.trim());
            if (frequentFlyerOption != null && !frequentFlyerOption.trim().isEmpty()) {
                session.setAttribute("frequentFlyerOption", frequentFlyerOption.trim());
            }
            if (frequentFlyerNumber != null && !frequentFlyerNumber.trim().isEmpty()) {
                session.setAttribute("frequentFlyerNumber", frequentFlyerNumber.trim());
            }

            response.sendRedirect(request.getContextPath() + "/booking/seats");

        } catch (InvalidPassengerException e) {
            request.setAttribute("validationError", e.getMessage());
            request.setAttribute("passengersForm", passengers);
            request.setAttribute("contactEmailForm", contactEmail);
            request.setAttribute("contactPhoneForm", contactPhone);
            doGet(request, response);
        }
    }
}
