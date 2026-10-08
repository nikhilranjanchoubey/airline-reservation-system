package com.skytech.service;

import com.skytech.dao.AirportDao;
import com.skytech.integration.FlightProvider;
import com.skytech.integration.amadeus.AmadeusFlightProvider;
import com.skytech.model.Airport;
import com.skytech.model.FlightSchedule;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

/**
 * Service layer coordinating flight search business logic, validations, and provider routing.
 */
public class FlightSearchService {

    private static final Logger LOGGER = Logger.getLogger(FlightSearchService.class.getName());

    private final AirportDao airportDao;
    private final FlightProvider flightProvider;

    public FlightSearchService() {
        this.airportDao = new AirportDao();
        this.flightProvider = new AmadeusFlightProvider();
    }

    public FlightSearchService(AirportDao airportDao, FlightProvider flightProvider) {
        this.airportDao = airportDao;
        this.flightProvider = flightProvider;
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

        LocalDate departureDate = null;
        if (departureDateStr == null || departureDateStr.trim().isEmpty()) {
            errors.add("Departure date is required.");
        } else {
            try {
                departureDate = LocalDate.parse(departureDateStr.trim());
                if (departureDate.isBefore(LocalDate.now())) {
                    errors.add("Departure date cannot be in the past.");
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
                    if (departureDate != null && returnDate.isBefore(departureDate)) {
                        errors.add("Return date cannot be before departure date.");
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

        LocalDate previousDate = null;

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
                if (seg.getDepartureDate().isBefore(LocalDate.now())) {
                    errors.add("Flight " + segNum + ": Departure date cannot be in the past.");
                }
                if (previousDate != null && seg.getDepartureDate().isBefore(previousDate)) {
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
     * Searches flights using configured provider (Amadeus or Local Database).
     */
    public List<FlightSchedule> searchFlights(String sourceCode, String destinationCode,
                                              LocalDate departureDate, int passengers, String travelClass) throws Exception {
        return flightProvider.searchFlights(sourceCode, destinationCode, departureDate, passengers, travelClass);
    }

    /**
     * Retrieves specific flight schedule details.
     */
    public FlightSchedule getFlightDetails(int scheduleId) throws Exception {
        return flightProvider.getFlightDetails(scheduleId);
    }

    /**
     * Dynamically calculates featured route deals from active flight inventory.
     * Guaranteed single source of truth for homepage pricing.
     */
    public List<com.skytech.model.PopularRouteDeal> getPopularRouteDeals() {
        List<com.skytech.model.PopularRouteDeal> deals = new ArrayList<>();
        LocalDate searchDate = LocalDate.now().plusDays(2);

        String[][] routes = {
            {"JAI", "DEL", "Jaipur", "Delhi", "High Frequency", "https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=600&q=80"},
            {"DEL", "BOM", "Delhi", "Mumbai", "Top Business Corridor", "https://images.unsplash.com/photo-1570168007204-dfb528c6958f?auto=format&fit=crop&w=600&q=80"},
            {"BOM", "BLR", "Mumbai", "Bengaluru", "Silicon Corridor", "https://images.unsplash.com/photo-1596176530529-78163a4f7af2?auto=format&fit=crop&w=600&q=80"},
            {"DEL", "GOI", "Delhi", "Goa", "Holiday Getaway", "https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=600&q=80"},
            {"BLR", "HYD", "Bengaluru", "Hyderabad", "Daily Shuttle", "https://images.unsplash.com/photo-1605335198270-4f5144ca84ce?auto=format&fit=crop&w=600&q=80"},
            {"MAA", "BOM", "Chennai", "Mumbai", "Coastal Connector", "https://images.unsplash.com/photo-1582510003544-4d00b7f74220?auto=format&fit=crop&w=600&q=80"}
        };

        for (String[] r : routes) {
            String src = r[0];
            String dst = r[1];
            String srcCity = r[2];
            String dstCity = r[3];
            String tag = r[4];
            String img = r[5];

            java.math.BigDecimal lowestPrice = null;
            String duration = "1h 45m";
            String stops = "Non-stop";
            java.util.Set<String> airlineSet = new java.util.LinkedHashSet<>();

            try {
                List<FlightSchedule> flights = searchFlights(src, dst, searchDate, 1, "Economy");
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
                LOGGER.log(Level.FINE, "Could not resolve dynamic pricing for " + src + " -> " + dst, e);
            }

            String airlines = airlineSet.isEmpty() ? "IndiGo • Air India • Akasa Air" : String.join(" • ", airlineSet);

            deals.add(new com.skytech.model.PopularRouteDeal(
                src, dst, srcCity, dstCity, airlines, lowestPrice, duration, stops, img, tag, searchDate
            ));
        }

        return deals;
    }

    public FlightProvider getActiveProvider() {
        return flightProvider;
    }
}
