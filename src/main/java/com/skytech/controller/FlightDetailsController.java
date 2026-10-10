package com.skytech.controller;

import com.skytech.model.Airport;
import com.skytech.model.FlightSchedule;
import com.skytech.service.FlightSearchService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller servlet displaying full flight details, baggage information, and fare breakdown.
 */
@WebServlet(name = "FlightDetailsController", urlPatterns = {"/flight-details"})
public class FlightDetailsController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(FlightDetailsController.class.getName());

    private FlightSearchService flightSearchService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.flightSearchService = new FlightSearchService();
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

        String source = request.getParameter("source");
        String destination = request.getParameter("destination");
        String tripType = request.getParameter("tripType");
        String returnDate = request.getParameter("returnDate");
        int adults = 1;
        int children = 0;
        int infants = 0;
        try {
            if (request.getParameter("adults") != null) adults = Math.max(1, Integer.parseInt(request.getParameter("adults").trim()));
            if (request.getParameter("children") != null) children = Math.max(0, Integer.parseInt(request.getParameter("children").trim()));
            if (request.getParameter("infants") != null) infants = Math.max(0, Integer.parseInt(request.getParameter("infants").trim()));
        } catch (NumberFormatException ignored) {}

        FlightSchedule schedule = null;
        String dbError = null;

        try {
            schedule = flightSearchService.getFlightDetails(scheduleId, selectedDate);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve flight details for ID: " + scheduleId, e);
            dbError = "Unable to retrieve flight details from inventory.";
        }

        String flightNumberParam = request.getParameter("flightNumber");
        if (schedule == null && flightNumberParam != null && !flightNumberParam.trim().isEmpty()) {
            schedule = flightSearchService.getFlightDetailsByRouteAndFlightNumber(flightNumberParam, source, destination, selectedDate);
        }

        // Verify route integrity
        if (schedule != null && schedule.getFlight() != null) {
            Airport srcA = schedule.getFlight().getSourceAirport();
            Airport dstA = schedule.getFlight().getDestinationAirport();
            if (source != null && !source.trim().isEmpty() && srcA != null && !source.trim().equalsIgnoreCase(srcA.getAirportCode())) {
                LOGGER.warning(String.format("[FLIGHT DETAILS] Origin airport mismatch: expected %s, found %s for flight %s",
                        source, srcA.getAirportCode(), schedule.getFlight().getFlightNumber()));
            }
            if (destination != null && !destination.trim().isEmpty() && dstA != null && !destination.trim().equalsIgnoreCase(dstA.getAirportCode())) {
                LOGGER.warning(String.format("[FLIGHT DETAILS] Destination airport mismatch: expected %s, found %s for flight %s",
                        destination, dstA.getAirportCode(), schedule.getFlight().getFlightNumber()));
            }
        }

        if (schedule == null && dbError == null) {
            request.setAttribute("errorMessage", "The requested flight schedule could not be found or has expired.");
        } else if (schedule != null) {
            if (selectedDate != null) {
                schedule.setFlightDate(java.sql.Date.valueOf(selectedDate));
            }
            BigDecimal perPassengerFare = schedule.getPriceForClass(travelClass);
            com.skytech.service.FareCalculationService.FareSummary fareSummary =
                    com.skytech.service.FareCalculationService.calculateFare(perPassengerFare, passengers, null);

            request.setAttribute("schedule", schedule);
            request.setAttribute("travelClass", travelClass);
            request.setAttribute("passengers", passengers);
            request.setAttribute("adults", adults);
            request.setAttribute("children", children);
            request.setAttribute("infants", infants);
            request.setAttribute("perPassengerFare", perPassengerFare);
            request.setAttribute("baseTotal", fareSummary.getBaseFareTotal());
            request.setAttribute("taxesAndFees", fareSummary.getTaxesAndFees());
            request.setAttribute("grandTotal", fareSummary.getGrandTotal());
            request.setAttribute("fareSummary", fareSummary);
            request.setAttribute("selectedSource", source);
            request.setAttribute("selectedDestination", destination);
            request.setAttribute("tripType", tripType);
            request.setAttribute("selectedReturnDate", returnDate);
            request.setAttribute("selectedDepartureDate", selectedDate != null ? selectedDate.toString() : (schedule.getFlightDate() != null ? schedule.getFlightDate().toLocalDate().toString() : ""));
        }

        request.setAttribute("dbError", dbError);
        request.setAttribute("pageTitle", schedule != null 
                ? schedule.getFlight().getFlightNumber() + " Details - SkyTech" 
                : "Flight Details - SkyTech");

        request.getRequestDispatcher("/WEB-INF/views/flight/flight-details.jsp").forward(request, response);
    }
}
