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
     * Provider display name (e.g., "Amadeus Live API" or "Database Inventory").
     */
    String getProviderName();

    /**
     * Returns true if provider is an active live API, false if local database.
     */
    boolean isLive();
}
