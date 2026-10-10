package com.skytech.integration.reefapi;

import com.skytech.api.ApiException;
import com.skytech.api.ReefApiClient;
import com.skytech.integration.DatabaseFlightProvider;
import com.skytech.integration.FlightProvider;
import com.skytech.model.FlightSchedule;
import com.skytech.util.AppConfig;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.logging.Logger;

/**
 * Primary FlightProvider integrating with ReefAPI Flights API (https://api.reefapi.com/flights/v1/search_flights).
 * Provides live real-time flight itineraries, carrier schedules, and real pricing.
 */
public class ReefApiFlightProvider implements FlightProvider {

    private static final Logger LOGGER = Logger.getLogger(ReefApiFlightProvider.class.getName());

    private final ReefApiClient reefApiClient;
    private final DatabaseFlightProvider databaseFallbackProvider;
    private boolean lastSearchWasLive = false;

    public ReefApiFlightProvider() {
        this.reefApiClient = new ReefApiClient();
        this.databaseFallbackProvider = new DatabaseFlightProvider();
    }

    public ReefApiFlightProvider(ReefApiClient reefApiClient, DatabaseFlightProvider databaseFallbackProvider) {
        this.reefApiClient = reefApiClient;
        this.databaseFallbackProvider = databaseFallbackProvider;
    }

    @Override
    public List<FlightSchedule> searchFlights(String origin, String destination, LocalDate departureDate,
                                              int passengers, String travelClass) throws Exception {
        return searchFlights(origin, destination, departureDate, null, passengers, 0, 0, travelClass, "one-way");
    }

    @Override
    public List<FlightSchedule> searchFlights(String origin, String destination, LocalDate departureDate,
                                              LocalDate returnDate, int adults, int children, int infants,
                                              String travelClass, String tripType) throws Exception {

        if (origin == null || destination == null || departureDate == null) {
            return Collections.emptyList();
        }

        String originCode = origin.trim().toUpperCase();
        String destCode = destination.trim().toUpperCase();

        if (originCode.equals(destCode)) {
            return Collections.emptyList();
        }

        // When ReefAPI is configured, execute live search via ReefAPI
        if (AppConfig.isReefApiConfigured()) {
            LOGGER.info(String.format("[REEFAPI PROVIDER] Querying live ReefAPI for %s -> %s on %s (Trip: %s)",
                    originCode, destCode, departureDate, tripType));

            // Any ApiException (401, 402, 429, 400, 500) will bubble up cleanly
            List<FlightSchedule> liveFlights = reefApiClient.searchFlights(
                    originCode, destCode, departureDate, returnDate, adults, children, infants, travelClass, tripType);

            lastSearchWasLive = true;
            LOGGER.info(String.format("[REEFAPI PROVIDER] Live query returned %d verified flights for %s -> %s",
                    liveFlights.size(), originCode, destCode));
            return liveFlights;
        }

        // Only when ReefAPI key is not configured, inform administrator or query local demo database
        LOGGER.info(String.format("[REEFAPI PROVIDER] ReefAPI not configured. Querying local database inventory for %s -> %s",
                originCode, destCode));
        lastSearchWasLive = false;
        List<FlightSchedule> dbFlights = databaseFallbackProvider.searchFlights(
                originCode, destCode, departureDate, Math.max(1, adults + children + infants), travelClass);
        return dbFlights != null ? dbFlights : Collections.emptyList();
    }

    @Override
    public FlightSchedule getFlightDetails(int scheduleId) throws Exception {
        FlightSchedule fs = reefApiClient.getFlightDetails(scheduleId);
        if (fs != null) {
            return fs;
        }
        return databaseFallbackProvider.getFlightDetails(scheduleId);
    }

    @Override
    public FlightSchedule getFlightDetails(int scheduleId, LocalDate targetDate) throws Exception {
        FlightSchedule fs = reefApiClient.getFlightDetails(scheduleId);
        if (fs != null) {
            if (targetDate != null && fs.getFlightDate() == null) {
                fs.setFlightDate(java.sql.Date.valueOf(targetDate));
            }
            return fs;
        }
        return databaseFallbackProvider.getFlightDetails(scheduleId, targetDate);
    }

    public FlightSchedule getFlightByFlightNumber(String flightNumber, LocalDate date) {
        FlightSchedule fs = reefApiClient.getFlightByFlightNumber(flightNumber, date);
        if (fs != null) {
            return fs;
        }
        return null;
    }

    public FlightSchedule getFlightByRouteAndNumber(String flightNumber, String source, String destination, LocalDate date) {
        FlightSchedule fs = reefApiClient.getFlightByRouteAndNumber(flightNumber, source, destination, date);
        if (fs != null) {
            return fs;
        }
        return null;
    }

    @Override
    public String getProviderName() {
        return lastSearchWasLive ? "ReefAPI Live Flights" : "Local Database Inventory";
    }

    @Override
    public boolean isLive() {
        return lastSearchWasLive;
    }

    public ReefApiClient getReefApiClient() {
        return reefApiClient;
    }
}
