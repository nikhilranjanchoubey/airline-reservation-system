package com.skytech.model;

import java.io.Serializable;
import java.sql.Time;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * Represents a flight route entity.
 */
public class Flight implements Serializable {

    private static final long serialVersionUID = 1L;

    private int flightId;
    private String flightNumber;
    private int airlineId;
    private Airline airline;
    private int sourceAirportId;
    private Airport sourceAirport;
    private int destinationAirportId;
    private Airport destinationAirport;
    private Time departureTime;
    private Time arrivalTime;
    private int durationMinutes;
    private int stops;
    private String aircraftModel;

    public Flight() {
    }

    public int getFlightId() {
        return flightId;
    }

    public void setFlightId(int flightId) {
        this.flightId = flightId;
    }

    public String getFlightNumber() {
        return flightNumber;
    }

    public void setFlightNumber(String flightNumber) {
        this.flightNumber = flightNumber;
    }

    public int getAirlineId() {
        return airlineId;
    }

    public void setAirlineId(int airlineId) {
        this.airlineId = airlineId;
    }

    public Airline getAirline() {
        return airline;
    }

    public void setAirline(Airline airline) {
        this.airline = airline;
    }

    public int getSourceAirportId() {
        return sourceAirportId;
    }

    public void setSourceAirportId(int sourceAirportId) {
        this.sourceAirportId = sourceAirportId;
    }

    public Airport getSourceAirport() {
        return sourceAirport;
    }

    public void setSourceAirport(Airport sourceAirport) {
        this.sourceAirport = sourceAirport;
    }

    public int getDestinationAirportId() {
        return destinationAirportId;
    }

    public void setDestinationAirportId(int destinationAirportId) {
        this.destinationAirportId = destinationAirportId;
    }

    public Airport getDestinationAirport() {
        return destinationAirport;
    }

    public void setDestinationAirport(Airport destinationAirport) {
        this.destinationAirport = destinationAirport;
    }

    public Time getDepartureTime() {
        return departureTime;
    }

    public void setDepartureTime(Time departureTime) {
        this.departureTime = departureTime;
    }

    public Time getArrivalTime() {
        return arrivalTime;
    }

    public void setArrivalTime(Time arrivalTime) {
        this.arrivalTime = arrivalTime;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }

    public void setDurationMinutes(int durationMinutes) {
        this.durationMinutes = durationMinutes;
    }

    public int getStops() {
        return stops;
    }

    public void setStops(int stops) {
        this.stops = stops;
    }

    public String getAircraftModel() {
        return aircraftModel;
    }

    public void setAircraftModel(String aircraftModel) {
        this.aircraftModel = aircraftModel;
    }

    // Helper formatting methods for JSP views
    public String getFormattedDepartureTime() {
        if (departureTime == null) return "";
        LocalTime lt = departureTime.toLocalTime();
        return lt.format(DateTimeFormatter.ofPattern("HH:mm"));
    }

    public String getFormattedArrivalTime() {
        if (arrivalTime == null) return "";
        LocalTime lt = arrivalTime.toLocalTime();
        return lt.format(DateTimeFormatter.ofPattern("HH:mm"));
    }

    public String getFormattedDuration() {
        int hours = durationMinutes / 60;
        int mins = durationMinutes % 60;
        if (hours > 0 && mins > 0) {
            return hours + "h " + String.format("%02dm", mins);
        } else if (hours > 0) {
            return hours + "h";
        } else {
            return mins + "m";
        }
    }

    public String getStopsDescription() {
        if (stops == 0) {
            return "Non-stop";
        } else if (stops == 1) {
            return "1 stop";
        } else {
            return stops + " stops";
        }
    }

    private String departureTerminal;
    private String arrivalTerminal;
    private String baggageBelt;
    private String status;

    public String getDepartureTerminal() {
        return departureTerminal != null ? departureTerminal : (sourceAirport != null ? sourceAirport.getTerminal() : "Terminal 1");
    }

    public void setDepartureTerminal(String departureTerminal) {
        this.departureTerminal = departureTerminal;
    }

    public String getArrivalTerminal() {
        return arrivalTerminal != null ? arrivalTerminal : (destinationAirport != null ? destinationAirport.getTerminal() : "Terminal 1");
    }

    public void setArrivalTerminal(String arrivalTerminal) {
        this.arrivalTerminal = arrivalTerminal;
    }

    public String getBaggageBelt() {
        return baggageBelt;
    }

    public void setBaggageBelt(String baggageBelt) {
        this.baggageBelt = baggageBelt;
    }

    public String getStatus() {
        return status != null ? status : "Scheduled";
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
