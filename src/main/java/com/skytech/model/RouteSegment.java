package com.skytech.model;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * Represents a single flight leg within a Multi-City itinerary.
 */
public class RouteSegment implements Serializable {

    private static final long serialVersionUID = 1L;

    private int segmentNumber;
    private String sourceCode;
    private String destinationCode;
    private Airport sourceAirport;
    private Airport destinationAirport;
    private LocalDate departureDate;

    public RouteSegment() {
    }

    public RouteSegment(int segmentNumber, String sourceCode, String destinationCode, LocalDate departureDate) {
        this.segmentNumber = segmentNumber;
        this.sourceCode = sourceCode;
        this.destinationCode = destinationCode;
        this.departureDate = departureDate;
    }

    public int getSegmentNumber() {
        return segmentNumber;
    }

    public void setSegmentNumber(int segmentNumber) {
        this.segmentNumber = segmentNumber;
    }

    public String getSourceCode() {
        return sourceCode;
    }

    public void setSourceCode(String sourceCode) {
        this.sourceCode = sourceCode;
    }

    public String getDestinationCode() {
        return destinationCode;
    }

    public void setDestinationCode(String destinationCode) {
        this.destinationCode = destinationCode;
    }

    public Airport getSourceAirport() {
        return sourceAirport;
    }

    public void setSourceAirport(Airport sourceAirport) {
        this.sourceAirport = sourceAirport;
    }

    public Airport getDestinationAirport() {
        return destinationAirport;
    }

    public void setDestinationAirport(Airport destinationAirport) {
        this.destinationAirport = destinationAirport;
    }

    public LocalDate getDepartureDate() {
        return departureDate;
    }

    public void setDepartureDate(LocalDate departureDate) {
        this.departureDate = departureDate;
    }
}
