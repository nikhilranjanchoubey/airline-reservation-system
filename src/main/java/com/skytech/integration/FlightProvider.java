package com.skytech.integration;

import com.skytech.model.FlightSchedule;

import java.time.LocalDate;
import java.util.List;

/**
 * Common abstraction for flight search providers (e.g. Local Database, Amadeus API).
 */
public interface FlightProvider {

    /**
     * Searches available flights matching the given criteria.
     */
    List<FlightSchedule> searchFlights(String origin, String destination, LocalDate departureDate,
                                       int passengers, String travelClass) throws Exception;

    /**
     * Retrieves specific flight schedule details.
     */
    FlightSchedule getFlightDetails(int scheduleId) throws Exception;

    /**
     * Retrieves flight schedule details preserving the selected flight date.
     */
    default FlightSchedule getFlightDetails(int scheduleId, LocalDate targetDate) throws Exception {
        FlightSchedule fs = getFlightDetails(scheduleId);
        if (fs != null && targetDate != null) {
            fs.setFlightDate(java.sql.Date.valueOf(targetDate));
        }
        return fs;
    }

    /**
     * Provider display name (e.g., "Amadeus Live API" or "Database Inventory").
     */
    String getProviderName();

    /**
     * Returns true if provider is an active live API, false if local database.
     */
    boolean isLive();
}
