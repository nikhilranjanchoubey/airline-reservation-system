package com.skytech.airlines.booking.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Authoritative financial calculation breakdown for a booking.
 */
public class FareBreakdown implements Serializable {
    private static final long serialVersionUID = 1L;

    private BigDecimal baseFare = BigDecimal.ZERO;
    private BigDecimal seatFees = BigDecimal.ZERO;
    private BigDecimal taxAmount = BigDecimal.ZERO;
    private BigDecimal totalAmount = BigDecimal.ZERO;
    private String currency = "INR";

    public FareBreakdown() {}

    public FareBreakdown(BigDecimal baseFare, BigDecimal seatFees, BigDecimal taxAmount, BigDecimal totalAmount) {
        this.baseFare = baseFare.setScale(2, RoundingMode.HALF_UP);
        this.seatFees = seatFees.setScale(2, RoundingMode.HALF_UP);
        this.taxAmount = taxAmount.setScale(2, RoundingMode.HALF_UP);
        this.totalAmount = totalAmount.setScale(2, RoundingMode.HALF_UP);
    }

    public long getAmountInPaise() {
        return totalAmount.multiply(new BigDecimal(100)).setScale(0, RoundingMode.HALF_UP).longValue();
    }

    public BigDecimal getBaseFare() { return baseFare; }
    public void setBaseFare(BigDecimal baseFare) { this.baseFare = baseFare; }

    public BigDecimal getSeatFees() { return seatFees; }
    public void setSeatFees(BigDecimal seatFees) { this.seatFees = seatFees; }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
}
