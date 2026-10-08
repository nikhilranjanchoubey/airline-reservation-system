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
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller servlet handling Flight Search queries and results view rendering.
 */
@WebServlet(name = "FlightSearchController", urlPatterns = {"/search-flights"})
public class FlightSearchController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(FlightSearchController.class.getName());

    private FlightSearchService flightSearchService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.flightSearchService = new FlightSearchService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Populate airports for dropdown selectors
        List<Airport> airports = flightSearchService.getAllAirports();
        request.setAttribute("airports", airports);

        String source = request.getParameter("source");
        String destination = request.getParameter("destination");
        String departureDateStr = request.getParameter("departureDate");

        String tripType = request.getParameter("tripType");
        String segSource1 = request.getParameter("segSource_1");

        // If no search query parameters were submitted, show the clean search form page
        if (source == null && destination == null && departureDateStr == null && segSource1 == null) {
            request.setAttribute("pageTitle", "Search Flights - SkyTech");
            request.setAttribute("tripType", "one-way");
            request.setAttribute("adults", 1);
            request.setAttribute("children", 0);
            request.setAttribute("infants", 0);
            request.setAttribute("passengers", 1);
            request.setAttribute("travelClass", "Economy");
            request.setAttribute("minDate", LocalDate.now().toString());
            request.getRequestDispatcher("/WEB-INF/views/flight/flight-search.jsp").forward(request, response);
            return;
        }

        // Handle search query
        processFlightSearch(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward POST submissions directly to search processor
        doGet(request, response);
    }

    private void processFlightSearch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String source = request.getParameter("source");
        String destination = request.getParameter("destination");
        String departureDateStr = request.getParameter("departureDate");
        String tripType = request.getParameter("tripType");
        if (tripType == null || tripType.trim().isEmpty()) {
            tripType = "one-way";
        }
        String returnDateStr = request.getParameter("returnDate");
        if ("one-way".equalsIgnoreCase(tripType) || "multi-city".equalsIgnoreCase(tripType)) {
            returnDateStr = null;
        }

        int adults = parseInteger(request.getParameter("adults"), 1);
        int children = parseInteger(request.getParameter("children"), 0);
        int infants = parseInteger(request.getParameter("infants"), 0);
        int passengers = Math.max(1, adults + children + infants);

        String travelClass = request.getParameter("travelClass");
        if (travelClass == null || travelClass.trim().isEmpty()) {
            travelClass = "Economy";
        }

        // Multi-City segments parsing if applicable
        List<com.skytech.model.RouteSegment> multiSegments = new java.util.ArrayList<>();
        if ("multi-city".equalsIgnoreCase(tripType)) {
            int segCount = parseInteger(request.getParameter("segmentCount"), 0);
            if (segCount < 2) {
                // Check if at least segSource_1 and segSource_2 exist
                segCount = 2;
                while (request.getParameter("segSource_" + (segCount + 1)) != null && segCount < 5) {
                    segCount++;
                }
            }

            for (int i = 1; i <= segCount; i++) {
                String segSrc = request.getParameter("segSource_" + i);
                String segDst = request.getParameter("segDest_" + i);
                String segDateStr = request.getParameter("segDate_" + i);
                LocalDate segDate = null;
                if (segDateStr != null && !segDateStr.trim().isEmpty()) {
                    try {
                        segDate = LocalDate.parse(segDateStr.trim());
                    } catch (java.time.format.DateTimeParseException ignored) {}
                }
                com.skytech.model.RouteSegment seg = new com.skytech.model.RouteSegment(i, segSrc, segDst, segDate);
                if (segSrc != null) seg.setSourceAirport(flightSearchService.getAirportByCode(segSrc));
                if (segDst != null) seg.setDestinationAirport(flightSearchService.getAirportByCode(segDst));
                multiSegments.add(seg);
            }

            // Sync leg 1 as primary search route
            if (!multiSegments.isEmpty()) {
                source = multiSegments.get(0).getSourceCode();
                destination = multiSegments.get(0).getDestinationCode();
                if (multiSegments.get(0).getDepartureDate() != null) {
                    departureDateStr = multiSegments.get(0).getDepartureDate().toString();
                }
            }
        }

        // Keep form state for user convenience
        request.setAttribute("selectedSource", source);
        request.setAttribute("selectedDestination", destination);
        request.setAttribute("selectedDepartureDate", departureDateStr);
        request.setAttribute("tripType", tripType);
        request.setAttribute("selectedReturnDate", returnDateStr);
        request.setAttribute("adults", adults);
        request.setAttribute("children", children);
        request.setAttribute("infants", infants);
        request.setAttribute("passengers", passengers);
        request.setAttribute("travelClass", travelClass);
        request.setAttribute("minDate", LocalDate.now().toString());
        request.setAttribute("multiSegments", multiSegments);

        // Server-side validation
        List<String> validationErrors;
        if ("multi-city".equalsIgnoreCase(tripType)) {
            validationErrors = flightSearchService.validateMultiCityCriteria(multiSegments, passengers);
        } else {
            validationErrors = flightSearchService.validateSearchCriteria(
                    source, destination, departureDateStr, tripType, returnDateStr, adults, children, infants);
        }

        if (!validationErrors.isEmpty()) {
            request.setAttribute("validationErrors", validationErrors);
            request.setAttribute("pageTitle", "Search Flights - SkyTech");
            request.getRequestDispatcher("/WEB-INF/views/flight/flight-search.jsp").forward(request, response);
            return;
        }

        // Execute search using active provider (Amadeus or Local Database)
        LocalDate departureDate = LocalDate.parse(departureDateStr.trim());
        List<FlightSchedule> flights = null;
        String dbError = null;

        try {
            flights = flightSearchService.searchFlights(source, destination, departureDate, passengers, travelClass);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Flight search error querying flight provider", e);
            dbError = "Unable to connect to the database. Please verify MySQL is running and local credentials in src/main/resources/db.properties are configured.";
        }

        Airport sourceAirport = flightSearchService.getAirportByCode(source);
        Airport destinationAirport = flightSearchService.getAirportByCode(destination);

        request.setAttribute("pageTitle", "Flight Results - SkyTech");
        request.setAttribute("flights", flights);
        request.setAttribute("flightCount", flights != null ? flights.size() : 0);
        request.setAttribute("sourceAirport", sourceAirport);
        request.setAttribute("destinationAirport", destinationAirport);
        request.setAttribute("dbError", dbError);
        request.setAttribute("isLiveProvider", flightSearchService.getActiveProvider().isLive());
        request.setAttribute("providerName", flightSearchService.getActiveProvider().getProviderName());

        request.getRequestDispatcher("/WEB-INF/views/flight/flight-results.jsp").forward(request, response);
    }

    private int parseInteger(String val, int defaultVal) {
        if (val == null || val.trim().isEmpty()) {
            return defaultVal;
        }
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            return defaultVal;
        }
    }
}
