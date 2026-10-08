package com.skytech.integration.amadeus;

import com.skytech.integration.DatabaseFlightProvider;
import com.skytech.integration.FlightProvider;
import com.skytech.model.FlightSchedule;

import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Composite flight provider that uses Amadeus Live APIs when configured,
 * and automatically falls back to the database provider on network/credential error.
 */
public class AmadeusFlightProvider implements FlightProvider {

    private static final Logger LOGGER = Logger.getLogger(AmadeusFlightProvider.class.getName());

    private final AmadeusFlightService amadeusFlightService;
    private final DatabaseFlightProvider databaseFallbackProvider;
    private boolean lastSearchWasLive = false;

    public AmadeusFlightProvider() {
        this.amadeusFlightService = new AmadeusFlightService();
        this.databaseFallbackProvider = new DatabaseFlightProvider();
    }

    @Override
    public List<FlightSchedule> searchFlights(String origin, String destination, LocalDate departureDate,
                                              int passengers, String travelClass) throws Exception {
        if (AmadeusConfig.isEnabled()) {
            try {
                LOGGER.info("Executing flight search via Amadeus Live API...");
                List<FlightSchedule> liveResults = amadeusFlightService.searchFlightOffers(
                        origin, destination, departureDate, passengers, travelClass);

                if (liveResults != null && !liveResults.isEmpty()) {
                    lastSearchWasLive = true;
                    return liveResults;
                }
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Amadeus API execution error. Gracefully falling back to database: " + e.getMessage());
            }
        }

        lastSearchWasLive = false;
        return databaseFallbackProvider.searchFlights(origin, destination, departureDate, passengers, travelClass);
    }

    @Override
    public FlightSchedule getFlightDetails(int scheduleId) throws Exception {
        return databaseFallbackProvider.getFlightDetails(scheduleId);
    }

    @Override
    public String getProviderName() {
        return lastSearchWasLive ? "Amadeus Live Flight API" : "Verified Local Inventory";
    }

    @Override
    public boolean isLive() {
        return lastSearchWasLive;
    }
}
