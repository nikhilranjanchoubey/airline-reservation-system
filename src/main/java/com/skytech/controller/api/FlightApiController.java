package com.skytech.controller.api;

import com.google.gson.Gson;
import com.skytech.api.ApiException;
import com.skytech.model.Airport;
import com.skytech.model.FlightSchedule;
import com.skytech.service.FlightSearchService;
import com.skytech.util.JsonUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * REST API Controller for Flight Search, Autocomplete, and Flight Details:
 *   - GET /api/flights/search
 *   - GET /api/flights/details
 *
 * Reuses existing FlightSearchService, ReefApiFlightProvider, and database caches.
 */
@WebServlet(name = "FlightApiController", urlPatterns = {
        "/api/flights/search",
        "/api/flights/details"
})
public class FlightApiController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(FlightApiController.class.getName());
    private static final ZoneId APP_ZONE_ID = ZoneId.of("Asia/Kolkata");
    private final Gson gson = JsonUtil.getGson();
    private FlightSearchService flightSearchService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.flightSearchService = new FlightSearchService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        if ("/api/flights/search".equalsIgnoreCase(path)) {
            handleFlightSearch(request, response);
        } else if ("/api/flights/details".equalsIgnoreCase(path)) {
            handleFlightDetails(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void handleFlightSearch(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String source = request.getParameter("source");
        if (source == null || source.trim().isEmpty()) source = request.getParameter("origin");
        String destination = request.getParameter("destination");
        if (destination == null || destination.trim().isEmpty()) destination = request.getParameter("dest");

        String departureDateStr = request.getParameter("departureDate");
        String returnDateStr = request.getParameter("returnDate");
        String tripType = request.getParameter("tripType");
        if (tripType == null || tripType.trim().isEmpty()) tripType = "one-way";

        int adults = parseInteger(request.getParameter("adults"), 1);
        int children = parseInteger(request.getParameter("children"), 0);
        int infants = parseInteger(request.getParameter("infants"), 0);

        String travelClass = request.getParameter("travelClass");
        if (travelClass == null || travelClass.trim().isEmpty()) travelClass = "Economy";

        // Validate
        List<String> errors = flightSearchService.validateSearchCriteria(
                source, destination, departureDateStr, tripType, returnDateStr, adults, children, infants);

        if (!errors.isEmpty()) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, String.join("; ", errors));
            return;
        }

        LocalDate departureDate = LocalDate.parse(departureDateStr.trim());
        LocalDate returnDate = null;
        if (returnDateStr != null && !returnDateStr.trim().isEmpty() && "round-trip".equalsIgnoreCase(tripType)) {
            try {
                returnDate = LocalDate.parse(returnDateStr.trim());
            } catch (Exception ignored) {}
        }

        try {
            List<FlightSchedule> flights = flightSearchService.searchFlights(
                    source.trim().toUpperCase(),
                    destination.trim().toUpperCase(),
                    departureDate,
                    returnDate,
                    adults,
                    children,
                    infants,
                    travelClass,
                    tripType
            );

            Airport sourceAirport = flightSearchService.getAirportByCode(source.trim().toUpperCase());
            Airport destAirport = flightSearchService.getAirportByCode(destination.trim().toUpperCase());

            Map<String, Object> resp = new LinkedHashMap<>();
            resp.put("success", true);
            resp.put("count", flights.size());
            resp.put("sourceAirport", sourceAirport);
            resp.put("destinationAirport", destAirport);
            resp.put("departureDate", departureDateStr);
            resp.put("returnDate", returnDateStr);
            resp.put("tripType", tripType);
            resp.put("travelClass", travelClass);
            resp.put("passengers", adults + children + infants);
            resp.put("flights", flights);

            writeJsonResponse(response, HttpServletResponse.SC_OK, resp);

        } catch (ApiException ae) {
            LOGGER.log(Level.WARNING, "ReefAPI flight search error: " + ae.getMessage());
            writeError(response, HttpServletResponse.SC_BAD_GATEWAY, "Flight provider error: " + ae.getMessage());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected flight search error: " + e.getMessage(), e);
            writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to complete flight search: " + e.getMessage());
        }
    }

    private void handleFlightDetails(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) idParam = request.getParameter("scheduleId");

        if (idParam == null || idParam.trim().isEmpty()) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Missing flight schedule id parameter.");
            return;
        }

        int scheduleId;
        try {
            scheduleId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid schedule id.");
            return;
        }

        try {
            LocalDate depDate = null;
            String depDateParam = request.getParameter("departureDate");
            if (depDateParam != null && !depDateParam.trim().isEmpty()) {
                try {
                    depDate = LocalDate.parse(depDateParam.trim());
                } catch (Exception ignored) {}
            }

            FlightSchedule schedule = flightSearchService.getFlightDetails(scheduleId, depDate);
            if (schedule == null) {
                writeError(response, HttpServletResponse.SC_NOT_FOUND, "Flight schedule not found.");
                return;
            }

            Map<String, Object> resp = new LinkedHashMap<>();
            resp.put("success", true);
            resp.put("schedule", schedule);

            writeJsonResponse(response, HttpServletResponse.SC_OK, resp);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading flight details: " + e.getMessage(), e);
            writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error retrieving flight details: " + e.getMessage());
        }
    }

    private int parseInteger(String val, int fallback) {
        if (val == null || val.trim().isEmpty()) return fallback;
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private void writeJsonResponse(HttpServletResponse response, int status, Object data) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        try (PrintWriter out = response.getWriter()) {
            out.print(gson.toJson(data));
            out.flush();
        }
    }

    private void writeError(HttpServletResponse response, int status, String message) throws IOException {
        Map<String, Object> err = new LinkedHashMap<>();
        err.put("success", false);
        err.put("error", message);
        writeJsonResponse(response, status, err);
    }
}
