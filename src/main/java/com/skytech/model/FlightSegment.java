package com.skytech.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/**
 * Represents an individual flight segment/leg within an itinerary (from ReefAPI).
 */
public class FlightSegment implements Serializable {

    private static final long serialVersionUID = 1L;

    private String carrier;
    private String carrierCode;
    private String flightNumber;
    private String operatingCarrier;
    private String fromCode;
    private String fromName;
    private String fromCity;
    private String toCode;
    private String toName;
    private String toCity;
    private String departureIso;
    private String arrivalIso;
    private int durationSeconds;

    public FlightSegment() {
    }

    public String getCarrier() {
        return carrier;
    }

    public void setCarrier(String carrier) {
        this.carrier = carrier;
    }

    public String getCarrierCode() {
        return carrierCode;
    }

    public void setCarrierCode(String carrierCode) {
        this.carrierCode = carrierCode;
    }

    public String getFlightNumber() {
        return flightNumber;
    }

    public void setFlightNumber(String flightNumber) {
        this.flightNumber = flightNumber;
    }

    public String getOperatingCarrier() {
        return operatingCarrier;
    }

    public void setOperatingCarrier(String operatingCarrier) {
        this.operatingCarrier = operatingCarrier;
    }

    public String getFromCode() {
        return fromCode;
    }

    public String getOrigin() {
        return fromCode;
    }

    public void setFromCode(String fromCode) {
        this.fromCode = fromCode;
    }

    public String getFromName() {
        return fromName;
    }

    public void setFromName(String fromName) {
        this.fromName = fromName;
    }

    public String getFromCity() {
        return fromCity;
    }

    public void setFromCity(String fromCity) {
        this.fromCity = fromCity;
    }

    public String getToCode() {
        return toCode;
    }

    public String getDestination() {
        return toCode;
    }

    public void setToCode(String toCode) {
        this.toCode = toCode;
    }

    public String getToName() {
        return toName;
    }

    public void setToName(String toName) {
        this.toName = toName;
    }

    public String getToCity() {
        return toCity;
    }

    public void setToCity(String toCity) {
        this.toCity = toCity;
    }

    public String getDepartureIso() {
        return departureIso;
    }

    public void setDepartureIso(String departureIso) {
        this.departureIso = departureIso;
    }

    public String getArrivalIso() {
        return arrivalIso;
    }

    public void setArrivalIso(String arrivalIso) {
        this.arrivalIso = arrivalIso;
    }

    public int getDurationSeconds() {
        return durationSeconds;
    }

    public void setDurationSeconds(int durationSeconds) {
        this.durationSeconds = durationSeconds;
    }

    public String getFormattedDepartureTime() {
        if (departureIso == null || departureIso.isEmpty()) return "";
        try {
            LocalDateTime ldt = LocalDateTime.parse(departureIso);
            return ldt.format(DateTimeFormatter.ofPattern("HH:mm", Locale.ENGLISH));
        } catch (Exception e) {
            if (departureIso.length() >= 16) {
                return departureIso.substring(11, 16);
            }
            return departureIso;
        }
    }

    public String getFormattedArrivalTime() {
        if (arrivalIso == null || arrivalIso.isEmpty()) return "";
        try {
            LocalDateTime ldt = LocalDateTime.parse(arrivalIso);
            return ldt.format(DateTimeFormatter.ofPattern("HH:mm", Locale.ENGLISH));
        } catch (Exception e) {
            if (arrivalIso.length() >= 16) {
                return arrivalIso.substring(11, 16);
            }
            return arrivalIso;
        }
    }

    public String getFormattedDuration() {
        int totalMinutes = durationSeconds / 60;
        int hours = totalMinutes / 60;
        int mins = totalMinutes % 60;
        if (hours > 0 && mins > 0) {
            return hours + "h " + String.format("%02dm", mins);
        } else if (hours > 0) {
            return hours + "h";
        } else {
            return mins + "m";
        }
    }
}
