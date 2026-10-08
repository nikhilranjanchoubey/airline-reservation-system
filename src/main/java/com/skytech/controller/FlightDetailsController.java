package com.skytech.controller;

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

        FlightSchedule schedule = null;
        String dbError = null;

        try {
            schedule = flightSearchService.getFlightDetails(scheduleId);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve flight details for ID: " + scheduleId, e);
            dbError = "Unable to connect to the database to retrieve flight details.";
        }

        if (schedule == null && dbError == null) {
            request.setAttribute("errorMessage", "The requested flight schedule could not be found.");
        } else if (schedule != null) {
            BigDecimal perPassengerFare = schedule.getPriceForClass(travelClass);
            BigDecimal baseTotal = perPassengerFare.multiply(BigDecimal.valueOf(passengers));
            BigDecimal taxesAndFees = baseTotal.multiply(BigDecimal.valueOf(0.12)).setScale(2, RoundingMode.HALF_UP);
            BigDecimal grandTotal = baseTotal.add(taxesAndFees);

            request.setAttribute("schedule", schedule);
            request.setAttribute("travelClass", travelClass);
            request.setAttribute("passengers", passengers);
            request.setAttribute("perPassengerFare", perPassengerFare);
            request.setAttribute("baseTotal", baseTotal);
            request.setAttribute("taxesAndFees", taxesAndFees);
            request.setAttribute("grandTotal", grandTotal);
        }

        request.setAttribute("dbError", dbError);
        request.setAttribute("pageTitle", schedule != null 
                ? schedule.getFlight().getFlightNumber() + " Details - SkyTech" 
                : "Flight Details - SkyTech");

        request.getRequestDispatcher("/WEB-INF/views/flight/flight-details.jsp").forward(request, response);
    }
}
