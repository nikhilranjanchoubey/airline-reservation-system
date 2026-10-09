package com.skytech.service;

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Collections;
import java.util.List;

/**
 * Centralized fare calculation engine enforcing consistent pricing, tax, and ancillary rules.
 *
 * Rule:
 * Base Fare (perPassengerFare × passengers)
 * + Seat Fees (sum of individual seat selections)
 * + Airport Taxes & GST (12% applied to total fare & ancillaries)
 * = Total Payable
 */
public class FareCalculationService {

    public static final BigDecimal GST_AND_TAX_RATE = new BigDecimal("0.12");

    public static class FareSummary implements Serializable {
        private static final long serialVersionUID = 1L;

        private final int passengers;
        private final BigDecimal perPassengerBaseFare;
        private final BigDecimal baseFareTotal;
        private final List<BigDecimal> seatFees;
        private final BigDecimal totalSeatFees;
        private final BigDecimal taxesAndFees;
        private final BigDecimal grandTotal;
        private final String fareDisclaimer;
        private final String seatDisclaimer;

        public FareSummary(int passengers, BigDecimal perPassengerBaseFare,
                           BigDecimal baseFareTotal, List<BigDecimal> seatFees,
                           BigDecimal totalSeatFees, BigDecimal taxesAndFees, BigDecimal grandTotal) {
            this.passengers = passengers;
            this.perPassengerBaseFare = perPassengerBaseFare;
            this.baseFareTotal = baseFareTotal;
            this.seatFees = seatFees != null ? seatFees : Collections.emptyList();
            this.totalSeatFees = totalSeatFees;
            this.taxesAndFees = taxesAndFees;
            this.grandTotal = grandTotal;
            this.fareDisclaimer = "Estimated fare for demonstration — live ticket pricing is not available from the flight data provider";
            this.seatDisclaimer = "Demonstration seat fee — live airline ancillary pricing is not available from the flight data provider";
        }

        public int getPassengers() { return passengers; }
        public BigDecimal getPerPassengerBaseFare() { return perPassengerBaseFare; }
        public BigDecimal getBaseFareTotal() { return baseFareTotal; }
        public List<BigDecimal> getSeatFees() { return seatFees; }
        public BigDecimal getTotalSeatFees() { return totalSeatFees; }
        public BigDecimal getTaxesAndFees() { return taxesAndFees; }
        public BigDecimal getGrandTotal() { return grandTotal; }
        public String getFareDisclaimer() { return fareDisclaimer; }
        public String getSeatDisclaimer() { return seatDisclaimer; }
    }

    /**
     * Calculates mathematically sound fare summary.
     */
    public static FareSummary calculateFare(BigDecimal perPassengerFare, int passengers, List<BigDecimal> seatFees) {
        if (perPassengerFare == null) perPassengerFare = BigDecimal.ZERO;
        int pax = Math.max(1, passengers);

        BigDecimal baseTotal = perPassengerFare.multiply(BigDecimal.valueOf(pax));

        BigDecimal seatTotal = BigDecimal.ZERO;
        if (seatFees != null) {
            for (BigDecimal fee : seatFees) {
                if (fee != null && fee.compareTo(BigDecimal.ZERO) > 0) {
                    seatTotal = seatTotal.add(fee);
                }
            }
        }

        BigDecimal taxableAmount = baseTotal.add(seatTotal);
        BigDecimal taxes = taxableAmount.multiply(GST_AND_TAX_RATE).setScale(2, RoundingMode.HALF_UP);
        BigDecimal grandTotal = taxableAmount.add(taxes);

        return new FareSummary(pax, perPassengerFare, baseTotal, seatFees, seatTotal, taxes, grandTotal);
    }
}
