package com.skytech.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Represents an individual passenger seat inside an aircraft cabin.
 */
public class Seat implements Serializable {

    private static final long serialVersionUID = 1L;

    private int seatId;
    private int aircraftId;
    private String seatNumber;
    private int rowNumber;
    private String columnLetter;
    private String seatType; // WINDOW, MIDDLE, AISLE, EXTRA_LEGROOM, EXIT_ROW
    private BigDecimal premiumFee;
    private String status;   // AVAILABLE, OCCUPIED, BLOCKED, SELECTED

    public Seat() {
        this.premiumFee = BigDecimal.ZERO;
        this.status = "AVAILABLE";
    }

    public Seat(int seatId, String seatNumber, int rowNumber, String columnLetter,
                String seatType, BigDecimal premiumFee, String status) {
        this.seatId = seatId;
        this.seatNumber = seatNumber;
        this.rowNumber = rowNumber;
        this.columnLetter = columnLetter;
        this.seatType = seatType;
        this.premiumFee = premiumFee != null ? premiumFee : BigDecimal.ZERO;
        this.status = status != null ? status : "AVAILABLE";
    }

    public int getSeatId() {
        return seatId;
    }

    public void setSeatId(int seatId) {
        this.seatId = seatId;
    }

    public int getAircraftId() {
        return aircraftId;
    }

    public void setAircraftId(int aircraftId) {
        this.aircraftId = aircraftId;
    }

    public String getSeatNumber() {
        return seatNumber;
    }

    public void setSeatNumber(String seatNumber) {
        this.seatNumber = seatNumber;
    }

    public int getRowNumber() {
        return rowNumber;
    }

    public void setRowNumber(int rowNumber) {
        this.rowNumber = rowNumber;
    }

    public String getColumnLetter() {
        return columnLetter;
    }

    public void setColumnLetter(String columnLetter) {
        this.columnLetter = columnLetter;
    }

    public String getSeatType() {
        return seatType;
    }

    public void setSeatType(String seatType) {
        this.seatType = seatType;
    }

    public BigDecimal getPremiumFee() {
        return premiumFee;
    }

    public void setPremiumFee(BigDecimal premiumFee) {
        this.premiumFee = premiumFee;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isAvailable() {
        return "AVAILABLE".equalsIgnoreCase(status);
    }

    public boolean isOccupied() {
        return "OCCUPIED".equalsIgnoreCase(status);
    }

    public boolean isBlocked() {
        return "BLOCKED".equalsIgnoreCase(status);
    }

    public boolean isExtraLegroom() {
        return "EXTRA_LEGROOM".equalsIgnoreCase(seatType) || "EXIT_ROW".equalsIgnoreCase(seatType);
    }

    public String getCssClass() {
        if (isOccupied()) return "seat-occupied";
        if (isBlocked()) return "seat-blocked";
        if (isExtraLegroom()) return "seat-available seat-extra-legroom";
        return "seat-available";
    }
}
