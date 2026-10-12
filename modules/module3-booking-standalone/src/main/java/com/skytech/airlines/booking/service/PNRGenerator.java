package com.skytech.airlines.booking.service;

import com.skytech.airlines.booking.dao.BookingDAO;
import com.skytech.airlines.booking.exception.DuplicatePNRException;

import java.security.SecureRandom;
import java.util.logging.Logger;

/**
 * Service-level PNR generator with database collision retry handling.
 */
public class PNRGenerator {
    private static final Logger LOGGER = Logger.getLogger(PNRGenerator.class.getName());
    private static final String CHARSET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
    private static final int PNR_LENGTH = 6;
    private static final int MAX_COLLISION_RETRIES = 5;

    private final SecureRandom random = new SecureRandom();

    public String generateRawCode() {
        StringBuilder sb = new StringBuilder(PNR_LENGTH);
        for (int i = 0; i < PNR_LENGTH; i++) {
            int idx = random.nextInt(CHARSET.length());
            sb.append(CHARSET.charAt(idx));
        }
        return sb.toString();
    }

    public String generateUniquePNR(BookingDAO bookingDAO) throws DuplicatePNRException {
        for (int attempt = 1; attempt <= MAX_COLLISION_RETRIES; attempt++) {
            String candidate = generateRawCode();
            if (bookingDAO == null || !bookingDAO.pnrExists(candidate)) {
                return candidate;
            }
            LOGGER.warning("PNR collision on attempt #" + attempt + " for: " + candidate + " - Retrying.");
        }
        throw new DuplicatePNRException("Failed to generate unique PNR after " + MAX_COLLISION_RETRIES + " retries.");
    }
}
