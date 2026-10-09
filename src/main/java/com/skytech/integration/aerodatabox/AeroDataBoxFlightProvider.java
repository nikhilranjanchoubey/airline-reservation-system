package com.skytech.integration.aerodatabox;

import com.skytech.api.AeroDataBoxClient;
import com.skytech.api.ApiException;
import com.skytech.integration.DatabaseFlightProvider;
import com.skytech.integration.FlightProvider;
import com.skytech.model.FlightSchedule;
import com.skytech.util.AppConfig;

import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Primary FlightProvider integrating with AeroDataBox API via RapidAPI.
 * Provides live flight schedules and flight status directly from airline FIDS departures.
 */
public class AeroDataBoxFlightProvider implements FlightProvider {

    private static final Logger LOGGER = Logger.getLogger(AeroDataBoxFlightProvider.class.getName());

    private final AeroDataBoxClient aeroDataBoxClient;
    private final DatabaseFlightProvider databaseFallbackProvider;
    private boolean lastSearchWasLive = false;

    public AeroDataBoxFlightProvider() {
        this.aeroDataBoxClient = new AeroDataBoxClient();
        this.databaseFallbackProvider = new DatabaseFlightProvider();
    }

    public AeroDataBoxFlightProvider(AeroDataBoxClient aeroDataBoxClient, DatabaseFlightProvider databaseFallbackProvider) {
        this.aeroDataBoxClient = aeroDataBoxClient;
        this.databaseFallbackProvider = databaseFallbackProvider;
    }

    @Override
    public List<FlightSchedule> searchFlights(String origin, String destination, LocalDate departureDate,
                                              int passengers, String travelClass) throws Exception {

        if (AppConfig.isRapidApiConfigured()) {
            try {
                LOGGER.info("Executing live flight search via AeroDataBox API (" + origin + " -> " + destination + " on " + departureDate + ")");
                List<FlightSchedule> liveFlights = aeroDataBoxClient.searchFlights(origin, destination, departureDate);
                
                // Strictly filter results to ensure every displayed flight matches the requested route
                List<FlightSchedule> verifiedLive = new java.util.ArrayList<>();
                if (liveFlights != null) {
                    for (FlightSchedule fs : liveFlights) {
                        if (fs.getFlight() != null 
                                && fs.getFlight().getSourceAirport() != null 
                                && origin.trim().equalsIgnoreCase(fs.getFlight().getSourceAirport().getAirportCode())
                                && fs.getFlight().getDestinationAirport() != null
                                && destination.trim().equalsIgnoreCase(fs.getFlight().getDestinationAirport().getAirportCode())) {
                            verifiedLive.add(fs);
                        }
                    }
                }

                if (!verifiedLive.isEmpty()) {
                    lastSearchWasLive = true;
                    return verifiedLive;
                }

                // If live feed returns no matching flights for this route/date, query verified database inventory
                LOGGER.info("Live feed returned 0 flights for route " + origin + " -> " + destination + ". Querying local database inventory.");
                List<FlightSchedule> fallback = databaseFallbackProvider.searchFlights(origin, destination, departureDate, passengers, travelClass);
                lastSearchWasLive = false;
                return fallback != null ? fallback : java.util.Collections.emptyList();

            } catch (ApiException e) {
                LOGGER.log(Level.WARNING, "AeroDataBox API communication error: " + e.getMessage());
                // Fallback to local verified database inventory when live provider encounters an error or rate limit
                try {
                    List<FlightSchedule> fallback = databaseFallbackProvider.searchFlights(origin, destination, departureDate, passengers, travelClass);
                    lastSearchWasLive = false;
                    return fallback != null ? fallback : java.util.Collections.emptyList();
                } catch (Exception ex) {
                    LOGGER.log(Level.WARNING, "Fallback database query failed: " + ex.getMessage());
                    throw e; // Bubble API error if fallback database also experienced an operational failure
                }
            }
        }

        // If RapidAPI is not configured, query local verified inventory
        LOGGER.info("RapidAPI not configured. Querying local database inventory.");
        lastSearchWasLive = false;
        return databaseFallbackProvider.searchFlights(origin, destination, departureDate, passengers, travelClass);
    }

    @Override
    public FlightSchedule getFlightDetails(int scheduleId) throws Exception {
        FlightSchedule fs = aeroDataBoxClient.getFlightDetails(scheduleId);
        if (fs != null) {
            return fs;
        }
        return databaseFallbackProvider.getFlightDetails(scheduleId);
    }

    @Override
    public FlightSchedule getFlightDetails(int scheduleId, LocalDate targetDate) throws Exception {
        FlightSchedule fs = aeroDataBoxClient.getFlightDetails(scheduleId);
        if (fs != null) {
            if (targetDate != null && fs.getFlightDate() == null) {
                fs.setFlightDate(java.sql.Date.valueOf(targetDate));
            }
            return fs;
        }
        return databaseFallbackProvider.getFlightDetails(scheduleId, targetDate);
    }

    public FlightSchedule getFlightByFlightNumber(String flightNumber, LocalDate date) {
        return aeroDataBoxClient.getFlightByFlightNumber(flightNumber, date);
    }

    @Override
    public String getProviderName() {
        return lastSearchWasLive ? "Live Flight Feed" : "Verified Local Inventory";
    }

    @Override
    public boolean isLive() {
        return lastSearchWasLive;
    }
}
