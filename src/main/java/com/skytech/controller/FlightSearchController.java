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
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.List;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller servlet handling Flight Search queries and results view rendering.
 */
@WebServlet(name = "FlightSearchController", urlPatterns = {"/search-flights"})
public class FlightSearchController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final ZoneId APP_ZONE_ID = ZoneId.of("Asia/Kolkata");
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

        String modifyParam = request.getParameter("modify");
        String editParam = request.getParameter("edit");
        String actionParam = request.getParameter("action");
        boolean isModify = "true".equalsIgnoreCase(modifyParam)
                        || "true".equalsIgnoreCase(editParam)
                        || "modify".equalsIgnoreCase(actionParam);

        // If user requested to modify the search OR no search query parameters were submitted, show the search form
        if (isModify || (source == null && destination == null && departureDateStr == null && segSource1 == null)) {
            LocalDate today = LocalDate.now(APP_ZONE_ID);
            request.setAttribute("pageTitle", isModify ? "Modify Flight Search - SkyTech" : "Search Flights - SkyTech");

            String effectiveTripType = (tripType != null && !tripType.trim().isEmpty()) ? tripType.trim() : "one-way";
            request.setAttribute("tripType", effectiveTripType);

            request.setAttribute("selectedSource", source != null ? source.trim() : null);
            request.setAttribute("selectedDestination", destination != null ? destination.trim() : null);

            Airport sourceAirport = (source != null && !source.trim().isEmpty()) ? flightSearchService.getAirportByCode(source.trim()) : null;
            Airport destAirport = (destination != null && !destination.trim().isEmpty()) ? flightSearchService.getAirportByCode(destination.trim()) : null;
            request.setAttribute("sourceAirport", sourceAirport);
            request.setAttribute("destAirport", destAirport);

            request.setAttribute("selectedDepartureDate", departureDateStr != null ? departureDateStr.trim() : null);
            String returnDateStr = request.getParameter("returnDate");
            request.setAttribute("selectedReturnDate", returnDateStr != null ? returnDateStr.trim() : null);

            if (departureDateStr != null && !departureDateStr.trim().isEmpty()) {
                try {
                    LocalDate dep = LocalDate.parse(departureDateStr.trim());
                    request.setAttribute("formattedDepartureDate", dep.format(DateTimeFormatter.ofPattern("dd MMM uuuu", Locale.ENGLISH)));
                    request.setAttribute("departureDayOfWeek", dep.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.ENGLISH));
                } catch (Exception ignored) {}
            }

            if (returnDateStr != null && !returnDateStr.trim().isEmpty()) {
                try {
                    LocalDate ret = LocalDate.parse(returnDateStr.trim());
                    request.setAttribute("formattedReturnDate", ret.format(DateTimeFormatter.ofPattern("dd MMM uuuu", Locale.ENGLISH)));
                    request.setAttribute("returnDayOfWeek", ret.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.ENGLISH));
                } catch (Exception ignored) {}
            }

            int adults = parseInteger(request.getParameter("adults"), 1);
            int children = parseInteger(request.getParameter("children"), 0);
            int infants = parseInteger(request.getParameter("infants"), 0);
            int passengers = Math.max(1, adults + children + infants);

            request.setAttribute("adults", adults);
            request.setAttribute("children", children);
            request.setAttribute("infants", infants);
            request.setAttribute("passengers", passengers);

            String travelClass = request.getParameter("travelClass");
            if (travelClass == null || travelClass.trim().isEmpty()) {
                travelClass = "Economy";
            }
            request.setAttribute("travelClass", travelClass);

            request.setAttribute("minDate", today.toString());
            request.setAttribute("todayDate", today.toString());
            request.setAttribute("today", today.toString());
            request.setAttribute("todayFormatted", today.format(DateTimeFormatter.ofPattern("dd MMM uuuu", Locale.ENGLISH)));
            request.setAttribute("todayDayOfWeek", today.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.ENGLISH));
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

        LocalDate today = LocalDate.now(APP_ZONE_ID);
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
        request.setAttribute("minDate", today.toString());
        request.setAttribute("todayDate", today.toString());
        request.setAttribute("today", today.toString());
        request.setAttribute("todayFormatted", today.format(DateTimeFormatter.ofPattern("dd MMM uuuu", Locale.ENGLISH)));
        request.setAttribute("todayDayOfWeek", today.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.ENGLISH));
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
        String formattedDepartureDate = departureDate.format(DateTimeFormatter.ofPattern("dd MMM uuuu", Locale.ENGLISH));
        String departureDayOfWeek = departureDate.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.ENGLISH);
        request.setAttribute("formattedDepartureDate", formattedDepartureDate);
        request.setAttribute("departureDayOfWeek", departureDayOfWeek);

        if (returnDateStr != null && !returnDateStr.trim().isEmpty()) {
            try {
                LocalDate returnDate = LocalDate.parse(returnDateStr.trim());
                request.setAttribute("formattedReturnDate", returnDate.format(DateTimeFormatter.ofPattern("dd MMM uuuu", Locale.ENGLISH)));
                request.setAttribute("returnDayOfWeek", returnDate.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.ENGLISH));
            } catch (Exception ignored) {}
        }

        List<FlightSchedule> flights = null;
        String apiError = null;
        String dbError = null;

        com.skytech.model.FlightSearchRequest searchReq = new com.skytech.model.FlightSearchRequest();
        searchReq.setOrigin(source);
        searchReq.setDestination(destination);
        searchReq.setDepartureDate(departureDate);
        if (returnDateStr != null && !returnDateStr.trim().isEmpty()) {
            try {
                searchReq.setReturnDate(LocalDate.parse(returnDateStr.trim()));
            } catch (Exception ignored) {}
        }
        searchReq.setAdults(adults);
        searchReq.setChildren(children);
        searchReq.setInfants(infants);
        searchReq.setCabinClass(travelClass);
        searchReq.setTripType(tripType);

        Object sessionUserId = request.getSession().getAttribute("userId");
        if (sessionUserId instanceof Long) {
            searchReq.setUserId((Long) sessionUserId);
        } else if (sessionUserId instanceof Integer) {
            searchReq.setUserId(((Integer) sessionUserId).longValue());
        }

        String apiErrorCategory = null;
        int apiStatusCode = 0;

        LocalDate parsedReturnDate = null;
        if (returnDateStr != null && !returnDateStr.trim().isEmpty() && "round-trip".equalsIgnoreCase(tripType)) {
            try {
                parsedReturnDate = LocalDate.parse(returnDateStr.trim());
            } catch (Exception ignored) {}
        }

        try {
            flights = flightSearchService.searchFlights(source, destination, departureDate, parsedReturnDate,
                    adults, children, infants, travelClass, tripType);
        } catch (com.skytech.api.ApiException ae) {
            LOGGER.log(Level.WARNING, String.format("[SEARCH CONTROLLER] Flight provider API error (Status: %d, Category: %s): %s",
                    ae.getStatusCode(), ae.getCategory(), ae.getMessage()));
            apiError = ae.getUserFriendlyMessage();
            apiErrorCategory = ae.getCategory().name();
            apiStatusCode = ae.getStatusCode();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[SEARCH CONTROLLER] General error querying flight provider", e);
            apiError = "We couldn't retrieve flights for this route right now. Please try again.";
            apiErrorCategory = "GENERAL";
        }

        if (flights != null) {
            apiError = null; // Clean search result succeeded (either with results or 0 matching flights)
            apiErrorCategory = null;
        }

        // Asynchronously/fail-soft record search query in MySQL
        try {
            flightSearchService.recordSearchHistory(searchReq, flightSearchService.getActiveProvider().getProviderName());
        } catch (Exception e) {
            LOGGER.log(Level.FINE, "Search history recording skipped on DB error", e);
        }

        Airport sourceAirport = flightSearchService.getAirportByCode(source);
        Airport destinationAirport = flightSearchService.getAirportByCode(destination);

        // Compute available airlines and actual price range from result set
        java.util.Map<String, String> availableAirlines = new java.util.LinkedHashMap<>();
        double minPrice = Double.MAX_VALUE;
        double maxPrice = 0.0;
        if (flights != null) {
            for (com.skytech.model.FlightSchedule fs : flights) {
                if (fs.getFlight() != null && fs.getFlight().getAirline() != null) {
                    availableAirlines.put(fs.getFlight().getAirline().getAirlineCode(), fs.getFlight().getAirline().getAirlineName());
                }
                java.math.BigDecimal pBd = fs.getPriceForClass(travelClass);
                if (pBd != null) {
                    double p = pBd.doubleValue();
                    if (p > 0) {
                        if (p < minPrice) minPrice = p;
                        if (p > maxPrice) maxPrice = p;
                    }
                }
            }
        }
        if (maxPrice == 0.0) {
            minPrice = 2000;
            maxPrice = 15000;
        }

        int minFilter = (int) (Math.floor(minPrice / 100.0) * 100);
        int maxFilter = (int) (Math.ceil(maxPrice / 100.0) * 100);
        if (maxFilter <= minFilter) {
            maxFilter = minFilter + 500;
        }

        request.setAttribute("pageTitle", "Flight Results - SkyTech");
        request.setAttribute("flights", flights);
        request.setAttribute("flightCount", flights != null ? flights.size() : 0);
        request.setAttribute("sourceAirport", sourceAirport);
        request.setAttribute("destinationAirport", destinationAirport);
        request.setAttribute("availableAirlines", availableAirlines);
        request.setAttribute("minFilterPrice", minFilter);
        request.setAttribute("maxFilterPrice", maxFilter);
        request.setAttribute("apiError", apiError);
        request.setAttribute("apiErrorCategory", apiErrorCategory);
        request.setAttribute("apiStatusCode", apiStatusCode);
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
