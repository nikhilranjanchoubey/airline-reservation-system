package com.skytech.service;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Encapsulates conversational slot-filling state for flight search.
 * Preserves collected flight parameters across multiple conversation turns.
 */
public class AiConversationState implements Serializable {

    private static final long serialVersionUID = 1L;

    private String originCode;
    private String originCity;
    private String originName;

    private String destCode;
    private String destCity;
    private String destName;

    private LocalDate departureDate;
    private LocalDate returnDate;
    private String tripType = "one-way";
    private int passengers = 1;
    private String travelClass = "Economy";
    private BigDecimal maxBudget;
    private boolean directOnly = false;
    private String awaitingField; // "origin", "destination", "date", null

    private String activeIntent; // "CHEAPEST", "SEARCH", "STATUS", "BOOKING", null
    private boolean cheapestRequested = false;
    private String flightNumber;

    private List<AiChatService.FlightCard> lastFlights = new ArrayList<>();
    private LocalDate lastSearchDate;

    public AiConversationState() {
    }

    public boolean isReadyForSearch() {
        return originCode != null && !originCode.trim().isEmpty()
                && destCode != null && !destCode.trim().isEmpty()
                && departureDate != null;
    }

    public void clear() {
        this.originCode = null;
        this.originCity = null;
        this.originName = null;
        this.destCode = null;
        this.destCity = null;
        this.destName = null;
        this.departureDate = null;
        this.returnDate = null;
        this.tripType = "one-way";
        this.passengers = 1;
        this.travelClass = "Economy";
        this.maxBudget = null;
        this.directOnly = false;
        this.awaitingField = null;
        this.activeIntent = null;
        this.cheapestRequested = false;
        this.flightNumber = null;
        this.lastFlights.clear();
        this.lastSearchDate = null;
    }

    public String getOriginCode() {
        return originCode;
    }

    public void setOrigin(String code, String city, String name) {
        this.originCode = code;
        this.originCity = city;
        this.originName = name;
    }

    public String getOriginCity() {
        return originCity;
    }

    public String getOriginName() {
        return originName;
    }

    public String getOriginAirportName() {
        return originName;
    }

    public String getDestCode() {
        return destCode;
    }

    public void setDestination(String code, String city, String name) {
        this.destCode = code;
        this.destCity = city;
        this.destName = name;
    }

    public String getDestCity() {
        return destCity;
    }

    public String getDestName() {
        return destName;
    }

    public String getDestAirportName() {
        return destName;
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

    public String getTripType() {
        return tripType;
    }

    public void setTripType(String tripType) {
        this.tripType = tripType;
    }

    public int getPassengers() {
        return Math.max(1, passengers);
    }

    public void setPassengers(int passengers) {
        this.passengers = Math.max(1, passengers);
    }

    public String getTravelClass() {
        return travelClass != null ? travelClass : "Economy";
    }

    public void setTravelClass(String travelClass) {
        this.travelClass = travelClass;
    }

    public BigDecimal getMaxBudget() {
        return maxBudget;
    }

    public void setMaxBudget(BigDecimal maxBudget) {
        this.maxBudget = maxBudget;
    }

    public boolean isDirectOnly() {
        return directOnly;
    }

    public void setDirectOnly(boolean directOnly) {
        this.directOnly = directOnly;
    }

    public String getAwaitingField() {
        return awaitingField;
    }

    public void setAwaitingField(String awaitingField) {
        this.awaitingField = awaitingField;
    }

    public List<AiChatService.FlightCard> getLastFlights() {
        return lastFlights;
    }

    public void setLastFlights(List<AiChatService.FlightCard> lastFlights) {
        this.lastFlights = lastFlights != null ? new ArrayList<>(lastFlights) : new ArrayList<>();
    }

    public LocalDate getLastSearchDate() {
        return lastSearchDate;
    }

    public void setLastSearchDate(LocalDate lastSearchDate) {
        this.lastSearchDate = lastSearchDate;
    }

    public String getActiveIntent() {
        return activeIntent;
    }

    public void setActiveIntent(String activeIntent) {
        this.activeIntent = activeIntent;
    }

    public boolean isCheapestRequested() {
        return cheapestRequested;
    }

    public void setCheapestRequested(boolean cheapestRequested) {
        this.cheapestRequested = cheapestRequested;
    }

    public String getFlightNumber() {
        return flightNumber;
    }

    public void setFlightNumber(String flightNumber) {
        this.flightNumber = flightNumber;
    }
}
