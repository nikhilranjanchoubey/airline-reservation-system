package com.skytech.service;

import com.skytech.dao.AirportDao;
import com.skytech.dao.SearchHistoryDao;
import com.skytech.integration.FlightProvider;
import com.skytech.integration.reefapi.ReefApiFlightProvider;
import com.skytech.model.Airport;
import com.skytech.model.FlightSchedule;
import com.skytech.model.FlightSearchRequest;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

/**
 * Service layer coordinating flight search business logic, validations, ReefAPI live integration, and search history.
 */
public class FlightSearchService {

    public static final ZoneId APP_ZONE_ID = ZoneId.of("Asia/Kolkata");
    private static final Logger LOGGER = Logger.getLogger(FlightSearchService.class.getName());

    private final AirportDao airportDao;
    private final FlightProvider flightProvider;
    private final SearchHistoryDao searchHistoryDao;

    public FlightSearchService() {
        this.airportDao = new AirportDao();
        this.flightProvider = new ReefApiFlightProvider();
        this.searchHistoryDao = new SearchHistoryDao();
    }

    public FlightSearchService(AirportDao airportDao, FlightProvider flightProvider) {
        this.airportDao = airportDao;
        this.flightProvider = flightProvider;
        this.searchHistoryDao = new SearchHistoryDao();
    }

    /**
     * Safely logs flight search query into MySQL without blocking on database disruptions.
     */
    public void recordSearchHistory(FlightSearchRequest request, String provider) {
        try {
            searchHistoryDao.saveSearch(request, provider);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to record flight search history: " + e.getMessage());
        }
    }

    /**
     * Retrieves all airports for dropdown lists.
     */
    public List<Airport> getAllAirports() {
        return airportDao.getAllAirports();
    }

    /**
     * Finds matching airports by city, airport name, or IATA code.
     */
    public List<Airport> searchAirports(String query) {
        List<Airport> all = getAllAirports();
        if (query == null || query.trim().isEmpty()) {
            return all;
        }
        String q = query.trim().toLowerCase();
        return all.stream()
                .filter(a -> a.getAirportCode().toLowerCase().contains(q)
                        || a.getCity().toLowerCase().contains(q)
                        || a.getAirportName().toLowerCase().contains(q))
                .collect(Collectors.toList());
    }

    /**
     * Resolves an airport by code.
     */
    public Airport getAirportByCode(String code) {
        return airportDao.getAirportByCode(code);
    }

    /**
     * Validates search inputs server-side.
     */
    public List<String> validateSearchCriteria(String source, String destination, String departureDateStr,
                                                String tripType, String returnDateStr, int passengers) {
        return validateSearchCriteria(source, destination, departureDateStr, tripType, returnDateStr, passengers, 0, 0);
    }

    public List<String> validateSearchCriteria(String source, String destination, String departureDateStr,
                                                String tripType, String returnDateStr, int adults, int children, int infants) {
        List<String> errors = new ArrayList<>();

        if (source == null || source.trim().isEmpty()) {
            errors.add("Departure airport is required.");
        }
        if (destination == null || destination.trim().isEmpty()) {
            errors.add("Arrival airport is required.");
        }
        if (source != null && destination != null && source.trim().equalsIgnoreCase(destination.trim())) {
            errors.add("Departure and arrival airports cannot be the same.");
        }

        LocalDate today = LocalDate.now(APP_ZONE_ID);
        LocalDate departureDate = null;
        if (departureDateStr == null || departureDateStr.trim().isEmpty()) {
            errors.add("Departure date is required.");
        } else {
            try {
                departureDate = LocalDate.parse(departureDateStr.trim());
                if (departureDate.isBefore(today)) {
                    errors.add("Please select today or a future date.");
                }
            } catch (DateTimeParseException e) {
                errors.add("Invalid departure date format. Please use YYYY-MM-DD.");
            }
        }

        if ("round-trip".equalsIgnoreCase(tripType)) {
            if (returnDateStr == null || returnDateStr.trim().isEmpty()) {
                errors.add("Return date is required for round trip.");
            } else {
                try {
                    LocalDate returnDate = LocalDate.parse(returnDateStr.trim());
                    if (returnDate.isBefore(today)) {
                        errors.add("Please select today or a future date.");
                    } else if (departureDate != null && returnDate.isBefore(departureDate)) {
                        errors.add("Return date must be on or after the departure date.");
                    }
                } catch (DateTimeParseException e) {
                    errors.add("Invalid return date format. Please use YYYY-MM-DD.");
                }
            }
        }

        if (adults < 1) {
            errors.add("At least 1 adult passenger is required.");
        }
        if (infants > adults) {
            errors.add("Number of infants cannot exceed the number of adult passengers.");
        }
        int totalPassengers = adults + children + infants;
        if (totalPassengers < 1) {
            errors.add("Passenger count must be at least 1.");
        } else if (totalPassengers > 9) {
            errors.add("Maximum 9 passengers permitted per booking search.");
        }

        return errors;
    }

    /**
     * Validates Multi-City itinerary legs.
     */
    public List<String> validateMultiCityCriteria(List<com.skytech.model.RouteSegment> segments, int passengers) {
        List<String> errors = new java.util.ArrayList<>();

        if (segments == null || segments.size() < 2) {
            errors.add("Multi-City travel requires at least 2 flight segments.");
            return errors;
        }

        if (segments.size() > 5) {
            errors.add("Multi-City itinerary cannot exceed 5 flight segments.");
        }

        LocalDate today = LocalDate.now(APP_ZONE_ID);
        LocalDate previousDate = today;

        for (int i = 0; i < segments.size(); i++) {
            com.skytech.model.RouteSegment seg = segments.get(i);
            int segNum = i + 1;

            if (seg.getSourceCode() == null || seg.getSourceCode().trim().isEmpty()) {
                errors.add("Flight " + segNum + ": Departure airport is required.");
            }
            if (seg.getDestinationCode() == null || seg.getDestinationCode().trim().isEmpty()) {
                errors.add("Flight " + segNum + ": Arrival airport is required.");
            }
            if (seg.getSourceCode() != null && seg.getDestinationCode() != null
                    && seg.getSourceCode().trim().equalsIgnoreCase(seg.getDestinationCode().trim())) {
                errors.add("Flight " + segNum + ": Departure and arrival airports cannot be the same.");
            }

            if (seg.getDepartureDate() == null) {
                errors.add("Flight " + segNum + ": Departure date is required.");
            } else {
                if (seg.getDepartureDate().isBefore(today)) {
                    errors.add("Flight " + segNum + ": Please select today or a future date.");
                } else if (i > 0 && seg.getDepartureDate().isBefore(previousDate)) {
                    errors.add("Flight " + segNum + " date cannot be before Flight " + i + " date.");
                }
                previousDate = seg.getDepartureDate();
            }
        }

        if (passengers < 1) {
            errors.add("Passenger count must be at least 1.");
        } else if (passengers > 9) {
            errors.add("Maximum 9 passengers permitted per booking search.");
        }

        return errors;
    }

    /**
     * Searches flights using configured provider (ReefAPI or Local Database).
     */
    public List<FlightSchedule> searchFlights(String sourceCode, String destinationCode,
                                              LocalDate departureDate, int passengers, String travelClass) throws Exception {
        return flightProvider.searchFlights(sourceCode, destinationCode, departureDate, passengers, travelClass);
    }

    /**
     * Searches flights with round-trip and passenger breakdown support.
     */
    public List<FlightSchedule> searchFlights(String sourceCode, String destinationCode,
                                              LocalDate departureDate, LocalDate returnDate,
                                              int adults, int children, int infants,
                                              String travelClass, String tripType) throws Exception {
        return flightProvider.searchFlights(sourceCode, destinationCode, departureDate, returnDate,
                adults, children, infants, travelClass, tripType);
    }

    /**
     * Retrieves specific flight schedule details.
     */
    public FlightSchedule getFlightDetails(int scheduleId) throws Exception {
        return flightProvider.getFlightDetails(scheduleId);
    }

    /**
     * Retrieves specific flight schedule details preserving the selected flight date.
     */
    public FlightSchedule getFlightDetails(int scheduleId, LocalDate targetDate) throws Exception {
        return flightProvider.getFlightDetails(scheduleId, targetDate);
    }

    /**
     * Resolves flight schedule details by verifying route, flight number, and date.
     */
    public FlightSchedule getFlightDetailsByRouteAndFlightNumber(String flightNumber, String source, String destination, LocalDate departureDate) {
        if (flightNumber == null || flightNumber.trim().isEmpty()) {
            return null;
        }
        LocalDate targetDate = (departureDate != null) ? departureDate : LocalDate.now(APP_ZONE_ID);

        // 1. Check ReefAPI live feed cache
        if (flightProvider instanceof ReefApiFlightProvider) {
            FlightSchedule liveFs = ((ReefApiFlightProvider) flightProvider).getFlightByRouteAndNumber(flightNumber, source, destination, targetDate);
            if (liveFs != null) {
                return liveFs;
            }
        }

        // 2. Check general flight number lookup
        FlightSchedule byNum = getFlightByFlightNumber(flightNumber, targetDate);
        if (byNum != null) {
            if (source == null || byNum.getFlight() == null || byNum.getFlight().getSourceAirport() == null
                    || source.trim().equalsIgnoreCase(byNum.getFlight().getSourceAirport().getAirportCode())) {
                return byNum;
            }
        }

        return null;
    }

    /**
     * Finds a flight schedule by flight number and date for flight tracking.
     */
    public FlightSchedule getFlightByFlightNumber(String flightNumber, LocalDate flightDate) {
        if (flightNumber == null || flightNumber.trim().isEmpty()) {
            return null;
        }
        LocalDate targetDate = (flightDate != null) ? flightDate : LocalDate.now(APP_ZONE_ID);
        if (flightProvider instanceof ReefApiFlightProvider) {
            FlightSchedule liveFs = ((ReefApiFlightProvider) flightProvider).getFlightByFlightNumber(flightNumber, targetDate);
            if (liveFs != null) {
                return liveFs;
            }
        }
        com.skytech.dao.FlightScheduleDao dao = new com.skytech.dao.FlightScheduleDao();
        List<FlightSchedule> all = dao.buildAllDemoSchedules(targetDate);
        String cleanQuery = flightNumber.trim().replaceAll("\\s+", "").toUpperCase();
        for (FlightSchedule fs : all) {
            if (fs.getFlight() != null && fs.getFlight().getFlightNumber() != null) {
                String cleanNum = fs.getFlight().getFlightNumber().replaceAll("\\s+", "").toUpperCase();
                if (cleanNum.equalsIgnoreCase(cleanQuery)) {
                    return fs;
                }
            }
        }
        return !all.isEmpty() ? all.get(0) : null;
    }

    /**
     * Inner specification representing supported featured routes.
     */
    private static class FeaturedRouteConfig {
        final String src;
        final String dst;
        final String srcCity;
        final String dstCity;
        final String defaultTag;
        final String localImage;
        final String altText;

        FeaturedRouteConfig(String src, String dst, String srcCity, String dstCity,
                            String defaultTag, String localImage, String altText) {
            this.src = src;
            this.dst = dst;
            this.srcCity = srcCity;
            this.dstCity = dstCity;
            this.defaultTag = defaultTag;
            this.localImage = localImage;
            this.altText = altText;
        }
    }

    private static final List<FeaturedRouteConfig> FEATURED_ROUTES = java.util.Arrays.asList(
        new FeaturedRouteConfig("JAI", "DEL", "Jaipur", "Delhi", "Popular Route",
                "assets/images/destinations/delhi.jpg", "India Gate landmark in Delhi"),
        new FeaturedRouteConfig("DEL", "BOM", "Delhi", "Mumbai", "Business Route",
                "assets/images/destinations/mumbai.jpg", "Gateway of India in Mumbai"),
        new FeaturedRouteConfig("BOM", "BLR", "Mumbai", "Bengaluru", "Business Route",
                "assets/images/destinations/bengaluru.jpg", "Vidhana Soudha in Bengaluru"),
        new FeaturedRouteConfig("DEL", "GOI", "Delhi", "Goa", "Holiday Route",
                "assets/images/destinations/goa.jpg", "Goa beach shoreline and coastal palms"),
        new FeaturedRouteConfig("BLR", "HYD", "Bengaluru", "Hyderabad", "Popular Route",
                "assets/images/destinations/hyderabad.jpg", "Historic Charminar in Hyderabad"),
        new FeaturedRouteConfig("MAA", "BOM", "Chennai", "Mumbai", "Popular Route",
                "assets/images/destinations/mumbai.jpg", "Marine Drive skyline in Mumbai")
    );

    /**
     * Returns featured route deals for today with deterministic Daily Shuffle rotation.
     */
    public List<com.skytech.model.PopularRouteDeal> getPopularRouteDeals() {
        return getPopularRouteDeals(LocalDate.now(APP_ZONE_ID));
    }

    /**
     * Dynamically calculates featured route deals from active flight inventory.
     * Uses local catalog/database inventory to prevent exhausting user RapidAPI quota on homepage visits.
     */
    public List<com.skytech.model.PopularRouteDeal> getPopularRouteDeals(LocalDate rotationDate) {
        List<com.skytech.model.PopularRouteDeal> deals = new ArrayList<>();
        LocalDate baseDate = (rotationDate != null ? rotationDate : LocalDate.now(APP_ZONE_ID));
        LocalDate searchDate = baseDate.plusDays(2);

        if (FEATURED_ROUTES.isEmpty()) {
            return deals;
        }

        // Deterministic Daily Shuffle index based on calendar day (remains constant throughout the day)
        long epochDay = baseDate.toEpochDay();
        int dailyIndex = (int) (Math.abs(epochDay) % FEATURED_ROUTES.size());

        // Build list: Daily Shuffle featured first, followed by the remaining routes
        List<FeaturedRouteConfig> orderedRoutes = new ArrayList<>();
        orderedRoutes.add(FEATURED_ROUTES.get(dailyIndex));
        for (int i = 0; i < FEATURED_ROUTES.size(); i++) {
            if (i != dailyIndex) {
                orderedRoutes.add(FEATURED_ROUTES.get(i));
            }
        }

        com.skytech.integration.DatabaseFlightProvider localCatalogProvider = new com.skytech.integration.DatabaseFlightProvider();

        for (int idx = 0; idx < orderedRoutes.size(); idx++) {
            FeaturedRouteConfig cfg = orderedRoutes.get(idx);
            boolean isDaily = (idx == 0);
            String tag = isDaily ? "Daily Shuffle" : cfg.defaultTag;

            java.math.BigDecimal lowestPrice = null;
            String duration = "1h 45m";
            String stops = "Non-stop";
            java.util.Set<String> airlineSet = new java.util.LinkedHashSet<>();

            try {
                // Query local catalog so homepage does not burn external RapidAPI rate limits
                List<FlightSchedule> flights = localCatalogProvider.searchFlights(cfg.src, cfg.dst, searchDate, 1, "Economy");
                if (flights != null && !flights.isEmpty()) {
                    for (FlightSchedule fs : flights) {
                        java.math.BigDecimal p = fs.getPriceForClass("Economy");
                        if (lowestPrice == null || (p != null && p.compareTo(lowestPrice) < 0)) {
                            lowestPrice = p;
                            if (fs.getFlight() != null) {
                                duration = fs.getFlight().getFormattedDuration();
                                stops = fs.getFlight().getStopsDescription();
                            }
                        }
                        if (fs.getFlight() != null && fs.getFlight().getAirline() != null) {
                            airlineSet.add(fs.getFlight().getAirline().getAirlineName());
                        }
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.FINE, "Could not resolve dynamic pricing for " + cfg.src + " -> " + cfg.dst, e);
            }

            String airlines = airlineSet.isEmpty() ? "IndiGo • Air India • Akasa Air" : String.join(" • ", airlineSet);

            deals.add(new com.skytech.model.PopularRouteDeal(
                cfg.src, cfg.dst, cfg.srcCity, cfg.dstCity, airlines, lowestPrice, duration, stops,
                cfg.localImage, cfg.altText, tag, isDaily, searchDate
            ));
        }

        return deals;
    }

    public FlightProvider getActiveProvider() {
        return flightProvider;
    }
}
