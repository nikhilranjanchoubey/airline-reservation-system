package com.skytech.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Represents a single row across the aircraft fuselage, containing left,
 * optional center, and right seat clusters, plus wing and exit row indicators.
 */
public class CabinRow implements Serializable {

    private static final long serialVersionUID = 1L;

    private int rowNumber;
    private boolean exitRow;
    private boolean wingRow;
    private String sectionTitle;
    private List<Seat> leftSeats = new ArrayList<>();
    private List<Seat> centerSeats = new ArrayList<>();
    private List<Seat> rightSeats = new ArrayList<>();

    public CabinRow() {
    }

    public CabinRow(int rowNumber, boolean exitRow, boolean wingRow) {
        this.rowNumber = rowNumber;
        this.exitRow = exitRow;
        this.wingRow = wingRow;
    }

    public int getRowNumber() {
        return rowNumber;
    }

    public void setRowNumber(int rowNumber) {
        this.rowNumber = rowNumber;
    }

    public boolean isExitRow() {
        return exitRow;
    }

    public void setExitRow(boolean exitRow) {
        this.exitRow = exitRow;
    }

    public boolean isWingRow() {
        return wingRow;
    }

    public void setWingRow(boolean wingRow) {
        this.wingRow = wingRow;
    }

    public String getSectionTitle() {
        return sectionTitle;
    }

    public void setSectionTitle(String sectionTitle) {
        this.sectionTitle = sectionTitle;
    }

    public List<Seat> getLeftSeats() {
        return leftSeats;
    }

    public void setLeftSeats(List<Seat> leftSeats) {
        this.leftSeats = leftSeats != null ? leftSeats : new ArrayList<>();
    }

    public List<Seat> getCenterSeats() {
        return centerSeats;
    }

    public void setCenterSeats(List<Seat> centerSeats) {
        this.centerSeats = centerSeats != null ? centerSeats : new ArrayList<>();
    }

    public List<Seat> getRightSeats() {
        return rightSeats;
    }

    public void setRightSeats(List<Seat> rightSeats) {
        this.rightSeats = rightSeats != null ? rightSeats : new ArrayList<>();
    }

    public boolean hasCenterSeats() {
        return centerSeats != null && !centerSeats.isEmpty();
    }
}
