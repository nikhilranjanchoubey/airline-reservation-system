package com.skytech.airlines.booking.util;

import com.skytech.airlines.booking.config.AppConfig;
import com.skytech.airlines.booking.model.FareBreakdown;
import com.skytech.airlines.booking.model.Passenger;
import com.skytech.airlines.booking.model.PassengerType;
import com.skytech.airlines.booking.model.Seat;
import com.skytech.airlines.booking.model.SeatAllocation;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/**
 * Authoritative server-side fare calculation utility.
 * Enforces exact financial arithmetic (BigDecimal) and never trusts client-sent values.
 */
public final class FareCalculator {

    private FareCalculator() {}

    /**
     * Calculates base airfare multiplier based on passenger category:
     * - ADULT: 100%
     * - CHILD: 75%
     * - INFANT: 10%
     */
    public static BigDecimal getMultiplierForType(PassengerType type) {
        if (type == null) return BigDecimal.ONE;
        return switch (type) {
            case ADULT -> BigDecimal.ONE;
            case CHILD -> new BigDecimal("0.75");
            case INFANT -> new BigDecimal("0.10");
        };
    }

    /**
     * Calculates comprehensive fare breakdown given flight base fare, passenger list, and seat allocations.
     */
    public static FareBreakdown calculateFare(BigDecimal flightBaseFare, List<Passenger> passengers, List<SeatAllocation> seatAllocations) {
        if (flightBaseFare == null || flightBaseFare.compareTo(BigDecimal.ZERO) <= 0) {
            flightBaseFare = new BigDecimal("4500.00");
        }

        BigDecimal totalBaseFare = BigDecimal.ZERO;
        if (passengers != null && !passengers.isEmpty()) {
            for (Passenger p : passengers) {
                BigDecimal multiplier = getMultiplierForType(p.getPassengerType());
                BigDecimal pFare = flightBaseFare.multiply(multiplier).setScale(2, RoundingMode.HALF_UP);
                totalBaseFare = totalBaseFare.add(pFare);
            }
        } else {
            totalBaseFare = flightBaseFare;
        }

        BigDecimal totalSeatFees = BigDecimal.ZERO;
        if (seatAllocations != null && !seatAllocations.isEmpty()) {
            for (SeatAllocation sa : seatAllocations) {
                if (sa.getSeatPrice() != null) {
                    totalSeatFees = totalSeatFees.add(sa.getSeatPrice());
                }
            }
        }

        BigDecimal taxableAmount = totalBaseFare.add(totalSeatFees);
        BigDecimal taxRate = AppConfig.getTaxRate();
        BigDecimal taxAmount = taxableAmount.multiply(taxRate).setScale(2, RoundingMode.HALF_UP);
        BigDecimal totalAmount = taxableAmount.add(taxAmount).setScale(2, RoundingMode.HALF_UP);

        return new FareBreakdown(totalBaseFare, totalSeatFees, taxAmount, totalAmount);
    }

    /**
     * Converts INR rupees to paise for Razorpay integration with exact precision.
     */
    public static long toPaise(BigDecimal amount) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Amount must be positive.");
        }
        return amount.multiply(new BigDecimal(100)).setScale(0, RoundingMode.HALF_UP).longValue();
    }
}
