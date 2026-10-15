package com.skytech.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Encapsulates the entire aircraft cabin layout, including seating configuration (3-3, 2-2, 3-3-3),
 * rows, emergency exits, wing span rows, and metadata.
 */
public class CabinLayout implements Serializable {

    private static final long serialVersionUID = 1L;

    private String aircraftModel;
    private String airlineCode;
    private String airlineName;
    private String travelClass;
    private int totalRows;
    private int seatsPerRow;
    private boolean twinAisle;
    private List<String> leftColumns = new ArrayList<>();
    private List<String> centerColumns = new ArrayList<>();
    private List<String> rightColumns = new ArrayList<>();
    private List<Integer> exitRows = new ArrayList<>();
    private int wingStartRow;
    private int wingEndRow;
    private List<CabinRow> rows = new ArrayList<>();
    private int totalSeatCount;
    private int availableSeatCount;

    public CabinLayout() {
    }

    public String getAircraftModel() {
        return aircraftModel;
    }

    public void setAircraftModel(String aircraftModel) {
        this.aircraftModel = aircraftModel;
    }

    public String getAirlineCode() {
        return airlineCode;
    }

    public void setAirlineCode(String airlineCode) {
        this.airlineCode = airlineCode;
    }

    public String getAirlineName() {
        return airlineName;
    }

    public void setAirlineName(String airlineName) {
        this.airlineName = airlineName;
    }

    public String getTravelClass() {
        return travelClass;
    }

    public void setTravelClass(String travelClass) {
        this.travelClass = travelClass;
    }

    public int getTotalRows() {
        return totalRows;
    }

    public void setTotalRows(int totalRows) {
        this.totalRows = totalRows;
    }

    public int getSeatsPerRow() {
        return seatsPerRow;
    }

    public void setSeatsPerRow(int seatsPerRow) {
        this.seatsPerRow = seatsPerRow;
    }

    public boolean isTwinAisle() {
        return twinAisle;
    }

    public void setTwinAisle(boolean twinAisle) {
        this.twinAisle = twinAisle;
    }

    public List<String> getLeftColumns() {
        return leftColumns;
    }

    public void setLeftColumns(List<String> leftColumns) {
        this.leftColumns = leftColumns != null ? leftColumns : new ArrayList<>();
    }

    public List<String> getCenterColumns() {
        return centerColumns;
    }

    public void setCenterColumns(List<String> centerColumns) {
        this.centerColumns = centerColumns != null ? centerColumns : new ArrayList<>();
    }

    public List<String> getRightColumns() {
        return rightColumns;
    }

    public void setRightColumns(List<String> rightColumns) {
        this.rightColumns = rightColumns != null ? rightColumns : new ArrayList<>();
    }

    public List<Integer> getExitRows() {
        return exitRows;
    }

    public void setExitRows(List<Integer> exitRows) {
        this.exitRows = exitRows != null ? exitRows : new ArrayList<>();
    }

    public int getWingStartRow() {
        return wingStartRow;
    }

    public void setWingStartRow(int wingStartRow) {
        this.wingStartRow = wingStartRow;
    }

    public int getWingEndRow() {
        return wingEndRow;
    }

    public void setWingEndRow(int wingEndRow) {
        this.wingEndRow = wingEndRow;
    }

    public List<CabinRow> getRows() {
        return rows;
    }

    public void setRows(List<CabinRow> rows) {
        this.rows = rows != null ? rows : new ArrayList<>();
    }

    public int getTotalSeatCount() {
        return totalSeatCount;
    }

    public void setTotalSeatCount(int totalSeatCount) {
        this.totalSeatCount = totalSeatCount;
    }

    public int getAvailableSeatCount() {
        return availableSeatCount;
    }

    public void setAvailableSeatCount(int availableSeatCount) {
        this.availableSeatCount = availableSeatCount;
    }
}
