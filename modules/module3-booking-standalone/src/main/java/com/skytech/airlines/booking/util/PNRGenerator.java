package com.skytech.airlines.booking.util;

import java.security.SecureRandom;

/**
 * 6-character alphanumeric PNR generator with unambiguous charset.
 */
public class PNRGenerator {

    private static final String CHARSET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
    private static final int PNR_LENGTH = 6;
    private final SecureRandom random = new SecureRandom();

    public String generateRawCode() {
        StringBuilder sb = new StringBuilder(PNR_LENGTH);
        for (int i = 0; i < PNR_LENGTH; i++) {
            int idx = random.nextInt(CHARSET.length());
            sb.append(CHARSET.charAt(idx));
        }
        return sb.toString();
    }
}
