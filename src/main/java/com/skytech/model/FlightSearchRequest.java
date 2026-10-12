package com.skytech.model;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * Encapsulates flight search query parameters and user preferences.
 */
public class FlightSearchRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    private String origin;
    private String destination;
    private LocalDate departureDate;
    private LocalDate returnDate;
    private int adults = 1;
    private int children = 0;
    private int infants = 0;
    private String cabinClass = "Economy";
    private String tripType = "one-way";
    private Long userId;

    public FlightSearchRequest() {
    }

    public FlightSearchRequest(String origin, String destination, LocalDate departureDate) {
        this.origin = origin;
        this.destination = destination;
        this.departureDate = departureDate;
    }

    public String getOrigin() {
        return origin;
    }

    public void setOrigin(String origin) {
        this.origin = origin;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public LocalDate getDepartureDate() {
        return departureDate;
    }

    public void setDepartureDate(LocalDate departureDate) {
        this.departureDate = departureDate;
    }

    public LocalDate getReturnDate() {
        return returnDate;
    }

    public void setReturnDate(LocalDate returnDate) {
        this.returnDate = returnDate;
    }

    public int getAdults() {
        return adults;
    }

    public void setAdults(int adults) {
        this.adults = adults;
    }

    public int getChildren() {
        return children;
    }

    public void setChildren(int children) {
        this.children = children;
    }

    public int getInfants() {
        return infants;
    }

    public void setInfants(int infants) {
        this.infants = infants;
    }

    public int getTotalPassengers() {
        return Math.max(1, adults + children + infants);
    }

    public String getCabinClass() {
        return cabinClass;
    }

    public void setCabinClass(String cabinClass) {
        this.cabinClass = cabinClass;
    }

    public String getTripType() {
        return tripType;
    }

    public void setTripType(String tripType) {
        this.tripType = tripType;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }
}
