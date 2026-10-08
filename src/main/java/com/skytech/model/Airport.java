package com.skytech.model;

import java.io.Serializable;

/**
 * Represents an airport entity.
 */
public class Airport implements Serializable {

    private static final long serialVersionUID = 1L;

    private int airportId;
    private String airportCode;
    private String airportName;
    private String city;
    private String country;
    private String terminal;

    public Airport() {
    }

    public Airport(int airportId, String airportCode, String airportName, String city, String country, String terminal) {
        this.airportId = airportId;
        this.airportCode = airportCode;
        this.airportName = airportName;
        this.city = city;
        this.country = country;
        this.terminal = terminal;
    }

    public int getAirportId() {
        return airportId;
    }

    public void setAirportId(int airportId) {
        this.airportId = airportId;
    }

    public String getAirportCode() {
        return airportCode;
    }

    public void setAirportCode(String airportCode) {
        this.airportCode = airportCode;
    }

    public String getAirportName() {
        return airportName;
    }

    public void setAirportName(String airportName) {
        this.airportName = airportName;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getTerminal() {
        return terminal;
    }

    public void setTerminal(String terminal) {
        this.terminal = terminal;
    }

    /**
     * Formats display string for dropdowns e.g. "Jaipur (JAI) - Jaipur International Airport"
     */
    public String getDisplayName() {
        return city + " (" + airportCode + ") - " + airportName;
    }
}
