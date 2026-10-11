package com.skytech.model;

import java.io.Serializable;

/**
 * Represents an airline entity.
 */
public class Airline implements Serializable {

    private static final long serialVersionUID = 1L;

    private int airlineId;
    private String airlineCode;
    private String airlineName;
    private String logoIcon;

    public Airline() {
    }

    public Airline(int airlineId, String airlineCode, String airlineName, String logoIcon) {
        this.airlineId = airlineId;
        this.airlineCode = airlineCode;
        this.airlineName = airlineName;
        this.logoIcon = logoIcon;
    }

    public int getAirlineId() {
        return airlineId;
    }

    public void setAirlineId(int airlineId) {
        this.airlineId = airlineId;
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

    public String getLogoIcon() {
        return logoIcon;
    }

    public void setLogoIcon(String logoIcon) {
        this.logoIcon = logoIcon;
    }
}
