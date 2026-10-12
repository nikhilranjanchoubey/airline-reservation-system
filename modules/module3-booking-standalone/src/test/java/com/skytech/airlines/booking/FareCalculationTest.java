package com.skytech.airlines.booking;

import com.skytech.airlines.booking.model.*;
import com.skytech.airlines.booking.util.FareCalculator;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Collections;

import static org.junit.jupiter.api.Assertions.*;

class FareCalculationTest {

    @Test
    @DisplayName("Should calculate exact fare with adult, child, seat fees, and 12% tax")
    void testFareCalculation() {
        BigDecimal baseFlightFare = new BigDecimal("4500.00");
        Passenger adult = new Passenger("Rajesh", "Sharma", LocalDate.of(1985, 5, 20), "MALE", PassengerType.ADULT, "", "Indian");
        Passenger child = new Passenger("Aarav", "Sharma", LocalDate.of(2018, 8, 15), "MALE", PassengerType.CHILD, "", "Indian");

        SeatAllocation sa1 = new SeatAllocation(1L, 1L, 101L, "1A", SeatClass.BUSINESS, new BigDecimal("1500.00"), "HELD");
        SeatAllocation sa2 = new SeatAllocation(1L, 2L, 101L, "12A", SeatClass.PREMIUM_ECONOMY, new BigDecimal("500.00"), "HELD");

        FareBreakdown fare = FareCalculator.calculateFare(baseFlightFare, Arrays.asList(adult, child), Arrays.asList(sa1, sa2));

        assertEquals(new BigDecimal("7875.00"), fare.getBaseFare());
        assertEquals(new BigDecimal("2000.00"), fare.getSeatFees());
        assertEquals(new BigDecimal("1185.00"), fare.getTaxAmount());
        assertEquals(new BigDecimal("11060.00"), fare.getTotalAmount());
    }

    @Test
    @DisplayName("Should convert INR to exact minor unit paise")
    void testPaiseConversion() {
        assertEquals(450000L, FareCalculator.toPaise(new BigDecimal("4500.00")));
        assertEquals(1344050L, FareCalculator.toPaise(new BigDecimal("13440.50")));
    }
}
