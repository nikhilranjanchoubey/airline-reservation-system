package com.skytech.controller;

import com.skytech.model.FlightSchedule;
import com.skytech.model.Seat;
import com.skytech.service.FlightSearchService;
import com.skytech.service.SeatMapService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
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

        FlightSchedule schedule = null;
        try {
            schedule = flightSearchService.getFlightDetails(scheduleId);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error retrieving schedule for seat selection: " + e.getMessage());
        }

        if (schedule == null) {
            response.sendRedirect(request.getContextPath() + "/search-flights");
            return;
        }

        List<Seat> seats = seatMapService.getSeatMapForSchedule(scheduleId);

        java.math.BigDecimal perPassengerFare = schedule.getPriceForClass(travelClass);
        java.math.BigDecimal baseFareTotal = perPassengerFare.multiply(java.math.BigDecimal.valueOf(passengers));
        java.math.BigDecimal initialTaxes = baseFareTotal.multiply(java.math.BigDecimal.valueOf(0.12)).setScale(2, java.math.RoundingMode.HALF_UP);
        java.math.BigDecimal initialGrandTotal = baseFareTotal.add(initialTaxes);

        request.setAttribute("schedule", schedule);
        request.setAttribute("seats", seats);
        request.setAttribute("passengers", passengers);
        request.setAttribute("travelClass", travelClass);
        request.setAttribute("perPassengerFare", perPassengerFare);
        request.setAttribute("baseFareTotal", baseFareTotal);
        request.setAttribute("initialTaxes", initialTaxes);
        request.setAttribute("initialGrandTotal", initialGrandTotal);
        request.setAttribute("pageTitle", "Select Seats &bull; " + schedule.getFlight().getFlightNumber() + " - SkyTech");

        request.getRequestDispatcher("/WEB-INF/views/flight/seat-selection.jsp").forward(request, response);
    }
}
