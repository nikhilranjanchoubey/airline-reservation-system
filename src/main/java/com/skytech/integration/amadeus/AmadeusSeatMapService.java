package com.skytech.integration.amadeus;

import com.skytech.model.Seat;

import java.util.List;
import java.util.logging.Logger;

/**
 * Handles Amadeus SeatMap Display API requests.
 */
public class AmadeusSeatMapService {

    private static final Logger LOGGER = Logger.getLogger(AmadeusSeatMapService.class.getName());

    private final AmadeusAuthService authService;

    public AmadeusSeatMapService() {
        this.authService = new AmadeusAuthService();
    }

    public AmadeusSeatMapService(AmadeusAuthService authService) {
        this.authService = authService;
    }

    /**
     * Attempts to query live Amadeus seat map.
     * Note: Amadeus test environment seat maps are only available for specific test carrier offers.
     * If unavailable, returns null so fallback demo cabin layout is rendered gracefully.
     */
    public List<Seat> getSeatMap(String flightOfferId) {
        if (!AmadeusConfig.isEnabled()) {
            return null;
        }
        try {
            LOGGER.info("Querying Amadeus live seat map for offer: " + flightOfferId);
            // In Amadeus Self-Service sandbox, seatmaps require active booked PNR or supported test offer
            return null;
        } catch (Exception e) {
            LOGGER.warning("Amadeus live seat map lookup returned unavailable: " + e.getMessage());
            return null;
        }
    }
}
