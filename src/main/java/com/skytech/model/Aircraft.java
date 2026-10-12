package com.skytech.model;

import java.io.Serializable;

/**
 * Represents an aircraft model.
 */
public class Aircraft implements Serializable {

    private static final long serialVersionUID = 1L;

    private int aircraftId;
    private String modelName;
    private String manufacturer;
    private int totalRows;
    private int seatsPerRow;

    public Aircraft() {
    }

    public Aircraft(int aircraftId, String modelName, String manufacturer, int totalRows, int seatsPerRow) {
        this.aircraftId = aircraftId;
        this.modelName = modelName;
        this.manufacturer = manufacturer;
        this.totalRows = totalRows;
        this.seatsPerRow = seatsPerRow;
    }

    public int getAircraftId() {
        return aircraftId;
    }

    public void setAircraftId(int aircraftId) {
        this.aircraftId = aircraftId;
    }

    public String getModelName() {
        return modelName;
    }

    public void setModelName(String modelName) {
        this.modelName = modelName;
    }

    public String getManufacturer() {
        return manufacturer;
    }

    public void setManufacturer(String manufacturer) {
        this.manufacturer = manufacturer;
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

    public int getTotalCapacity() {
        return totalRows * seatsPerRow;
    }
}
