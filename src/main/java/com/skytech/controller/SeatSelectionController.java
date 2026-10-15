package com.skytech.controller;

import com.skytech.model.FlightSchedule;
import com.skytech.model.Seat;
import com.skytech.service.FlightSearchService;
import com.skytech.service.SeatMapService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller servlet displaying the interactive aircraft cabin seat map.
 */
@WebServlet(name = "SeatSelectionController", urlPatterns = {"/seat-selection"})
public class SeatSelectionController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(SeatSelectionController.class.getName());

    private FlightSearchService flightSearchService;
    private SeatMapService seatMapService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.flightSearchService = new FlightSearchService();
        this.seatMapService = new SeatMapService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            idParam = request.getParameter("scheduleId");
        }
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/search-flights");
            return;
        }

        int scheduleId;
        try {
            scheduleId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/search-flights");
            return;
        }

        String travelClass = request.getParameter("travelClass");
        if (travelClass == null || travelClass.trim().isEmpty()) {
            travelClass = "Economy";
        }

        int passengers = 1;
        String passParam = request.getParameter("passengers");
        if (passParam != null && !passParam.trim().isEmpty()) {
            try {
                passengers = Math.max(1, Integer.parseInt(passParam.trim()));
            } catch (NumberFormatException ignored) {
            }
        }

        String departureDateParam = request.getParameter("departureDate");
        java.time.LocalDate selectedDate = null;
        if (departureDateParam != null && !departureDateParam.trim().isEmpty()) {
            try {
                selectedDate = java.time.LocalDate.parse(departureDateParam.trim());
            } catch (Exception ignored) {}
        }

        FlightSchedule schedule = null;
        try {
            schedule = flightSearchService.getFlightDetails(scheduleId, selectedDate);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error retrieving schedule for seat selection: " + e.getMessage());
        }

        String flightNumberParam = request.getParameter("flightNumber");
        if (schedule == null && flightNumberParam != null && !flightNumberParam.trim().isEmpty()) {
            schedule = flightSearchService.getFlightByFlightNumber(flightNumberParam, selectedDate);
        }

        if (schedule == null) {
            response.sendRedirect(request.getContextPath() + "/search-flights");
            return;
        }

        if (selectedDate != null) {
            schedule.setFlightDate(java.sql.Date.valueOf(selectedDate));
        }

        String airlineCode = (schedule.getFlight() != null && schedule.getFlight().getAirline() != null)
                ? schedule.getFlight().getAirline().getAirlineCode() : "6E";
        String airlineName = (schedule.getFlight() != null && schedule.getFlight().getAirline() != null)
                ? schedule.getFlight().getAirline().getAirlineName() : "SkyTech Airline";
        String aircraftModel = (schedule.getFlight() != null && schedule.getFlight().getAircraftModel() != null)
                ? schedule.getFlight().getAircraftModel() : "Airbus A320neo";

        com.skytech.model.CabinLayout cabinLayout = seatMapService.getCabinLayout(scheduleId, airlineCode, travelClass, aircraftModel, airlineName);
        List<Seat> seats = seatMapService.getSeatMapForSchedule(scheduleId, airlineCode);

        java.math.BigDecimal perPassengerFare = schedule.getPriceForClass(travelClass);
        com.skytech.service.FareCalculationService.FareSummary initialFare =
                com.skytech.service.FareCalculationService.calculateFare(perPassengerFare, passengers, null);

        request.setAttribute("schedule", schedule);
        request.setAttribute("cabinLayout", cabinLayout);
        request.setAttribute("seats", seats);
        request.setAttribute("passengers", passengers);
        request.setAttribute("travelClass", travelClass);
        request.setAttribute("aircraftModel", aircraftModel);
        request.setAttribute("airlineName", airlineName);
        request.setAttribute("perPassengerFare", perPassengerFare);
        request.setAttribute("baseFareTotal", initialFare.getBaseFareTotal());
        request.setAttribute("initialTaxes", initialFare.getTaxesAndFees());
        request.setAttribute("initialGrandTotal", initialFare.getGrandTotal());
        request.setAttribute("fareSummary", initialFare);
        String preSelectedSeatsParam = request.getParameter("selectedSeats");
        request.setAttribute("preSelectedSeatsParam", preSelectedSeatsParam != null ? preSelectedSeatsParam : "");

        request.setAttribute("airlineCode", airlineCode);
        request.setAttribute("selectedDepartureDate", selectedDate != null ? selectedDate.toString() : (schedule.getFlightDate() != null ? schedule.getFlightDate().toLocalDate().toString() : ""));
        request.setAttribute("pageTitle", "Select Seats &bull; " + schedule.getFlight().getFlightNumber() + " - SkyTech");

        request.getRequestDispatcher("/WEB-INF/views/flight/seat-selection.jsp").forward(request, response);
    }
}
