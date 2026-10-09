package com.skytech.controller;

import com.skytech.model.FlightSchedule;
import com.skytech.service.FlightSearchService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.Locale;

/**
 * Controller for Flight Status tracking.
 */
@WebServlet(name = "FlightStatusController", urlPatterns = {"/flight-status"})
public class FlightStatusController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final ZoneId APP_ZONE_ID = ZoneId.of("Asia/Kolkata");

    private FlightSearchService flightSearchService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.flightSearchService = new FlightSearchService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LocalDate today = LocalDate.now(APP_ZONE_ID);
        String flightNum = request.getParameter("flightNumber");
        String dateParam = request.getParameter("departureDate");
        if (dateParam == null || dateParam.trim().isEmpty()) {
            dateParam = request.getParameter("flightDate");
        }

        LocalDate selectedDate = today;
        if (dateParam != null && !dateParam.trim().isEmpty()) {
            try {
                selectedDate = LocalDate.parse(dateParam.trim());
            } catch (Exception ignored) {
                selectedDate = today;
            }
        }

        request.setAttribute("todayDate", today.toString());
        request.setAttribute("minDate", today.toString());
        request.setAttribute("selectedFlightDate", selectedDate.toString());
        request.setAttribute("formattedFlightDate", selectedDate.format(DateTimeFormatter.ofPattern("dd MMM uuuu", Locale.ENGLISH)));
        request.setAttribute("flightDayOfWeek", selectedDate.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.ENGLISH));

        if (flightNum != null && !flightNum.trim().isEmpty()) {
            flightNum = flightNum.trim().toUpperCase();
            request.setAttribute("flightNumber", flightNum);
            request.setAttribute("searched", true);

            FlightSchedule schedule = flightSearchService.getFlightByFlightNumber(flightNum, selectedDate);
            request.setAttribute("flightSchedule", schedule);
        }

        request.setAttribute("pageTitle", "Flight Status - SkyTech");
        request.getRequestDispatcher("/WEB-INF/views/flight/flight-status.jsp").forward(request, response);
    }
}
