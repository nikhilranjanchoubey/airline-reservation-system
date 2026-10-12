package com.skytech.airlines.booking;

import com.skytech.airlines.booking.service.PNRGenerator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.HashSet;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

class PNRGeneratorTest {

    private PNRGenerator pnrGenerator;

    @BeforeEach
    void setUp() {
        pnrGenerator = new PNRGenerator();
    }

    @Test
    @DisplayName("Should generate PNR code with exact length 6 and unambiguous characters")
    void testPNRFormatAndLength() {
        String pnr = pnrGenerator.generateRawCode();
        assertNotNull(pnr);
        assertEquals(6, pnr.length());
        assertTrue(pnr.matches("^[2-9A-HJ-NP-Z]{6}$"), "PNR must contain only base-32 characters");
    }

    @Test
    @DisplayName("Should generate unique PNRs with high entropy")
    void testEntropyAndUniqueness() {
        Set<String> set = new HashSet<>();
        for (int i = 0; i < 50; i++) {
            set.add(pnrGenerator.generateRawCode());
        }
        assertEquals(50, set.size(), "All 50 generated PNRs must be unique");
    }
}
