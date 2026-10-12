package com.skytech.airlines.booking.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Seat representation on the aircraft cabin layout.
 */
public class Seat implements Serializable {
    private static final long serialVersionUID = 1L;

    private String seatNumber; // e.g. "12A"
    private int rowNumber;
    private char columnLetter;
    private SeatClass seatClass;
    private BigDecimal priceSurcharge = BigDecimal.ZERO;
    private boolean available = true;
    private boolean held = false;

    public Seat() {}

    public Seat(String seatNumber, int rowNumber, char columnLetter, SeatClass seatClass, BigDecimal priceSurcharge) {
        this.seatNumber = seatNumber;
        this.rowNumber = rowNumber;
        this.columnLetter = columnLetter;
        this.seatClass = seatClass;
        this.priceSurcharge = priceSurcharge != null ? priceSurcharge : BigDecimal.ZERO;
    }

    public String getSeatNumber() { return seatNumber; }
    public void setSeatNumber(String seatNumber) { this.seatNumber = seatNumber; }

    public int getRowNumber() { return rowNumber; }
    public void setRowNumber(int rowNumber) { this.rowNumber = rowNumber; }

    public char getColumnLetter() { return columnLetter; }
    public void setColumnLetter(char columnLetter) { this.columnLetter = columnLetter; }

    public SeatClass getSeatClass() { return seatClass; }
    public void setSeatClass(SeatClass seatClass) { this.seatClass = seatClass; }

    public BigDecimal getPriceSurcharge() { return priceSurcharge; }
    public void setPriceSurcharge(BigDecimal priceSurcharge) { this.priceSurcharge = priceSurcharge; }

    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }

    public boolean isHeld() { return held; }
    public void setHeld(boolean held) { this.held = held; }
}
