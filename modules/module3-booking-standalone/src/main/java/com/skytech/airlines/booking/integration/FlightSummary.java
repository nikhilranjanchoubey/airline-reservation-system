package com.skytech.airlines.booking.integration;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Data transfer object encapsulating flight schedule & pricing provided by Module 2.
 */
public class FlightSummary implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long flightId;
    private String flightNumber;
    private String airlineName = "SKYTECH AIRLINES";
    private String aircraftModel = "Airbus A320neo";
    private String originAirportCode;
    private String originCity;
    private String destAirportCode;
    private String destCity;
    private LocalDateTime departureTime;
    private LocalDateTime arrivalTime;
    private int durationMinutes;
    private BigDecimal baseFare;
    private int totalSeats = 180;
    private int availableSeats = 180;
    private String captainName = "Capt. Rajesh Sharma";
    private String flightStatus = "SCHEDULED";
    private int frequentFlyerMiles = 750;
    private String frequentFlyerTier = "Silver Tier";
    private String frequentFlyerPerks = "1.0x Base Miles &bull; Priority Boarding";

    public FlightSummary() {}

    public FlightSummary(Long flightId, String flightNumber, String originAirportCode, String originCity,
                         String destAirportCode, String destCity, LocalDateTime departureTime,
                         LocalDateTime arrivalTime, int durationMinutes, BigDecimal baseFare) {
        this.flightId = flightId;
        this.flightNumber = flightNumber;
        this.originAirportCode = originAirportCode;
        this.originCity = originCity;
        this.destAirportCode = destAirportCode;
        this.destCity = destCity;
        this.departureTime = departureTime;
        this.arrivalTime = arrivalTime;
        this.durationMinutes = durationMinutes;
        this.baseFare = baseFare;
    }

    public FlightSummary(Long flightId, String flightNumber, String aircraftModel,
                         String originAirportCode, String originCity,
                         String destAirportCode, String destCity,
                         LocalDateTime departureTime, LocalDateTime arrivalTime,
                         int durationMinutes, BigDecimal baseFare,
                         int totalSeats, int availableSeats) {
        this.flightId = flightId;
        this.flightNumber = flightNumber;
        this.airlineName = "SKYTECH AIRLINES";
        this.aircraftModel = aircraftModel;
        this.originAirportCode = originAirportCode;
        this.originCity = originCity;
        this.destAirportCode = destAirportCode;
        this.destCity = destCity;
        this.departureTime = departureTime;
        this.arrivalTime = arrivalTime;
        this.durationMinutes = durationMinutes;
        this.baseFare = baseFare;
        this.totalSeats = totalSeats;
        this.availableSeats = availableSeats;
        this.flightStatus = "SCHEDULED";
        this.captainName = "Capt. Rajesh Sharma";
    }

    public FlightSummary(Long flightId, String flightNumber, String aircraftModel,
                         String originAirportCode, String originCity,
                         String destAirportCode, String destCity,
                         LocalDateTime departureTime, LocalDateTime arrivalTime,
                         int durationMinutes, BigDecimal baseFare,
                         int totalSeats, int availableSeats, String captainName) {
        this.flightId = flightId;
        this.flightNumber = flightNumber;
        this.airlineName = "SKYTECH AIRLINES";
        this.aircraftModel = aircraftModel;
        this.originAirportCode = originAirportCode;
        this.originCity = originCity;
        this.destAirportCode = destAirportCode;
        this.destCity = destCity;
        this.departureTime = departureTime;
        this.arrivalTime = arrivalTime;
        this.durationMinutes = durationMinutes;
        this.baseFare = baseFare;
        this.totalSeats = totalSeats;
        this.availableSeats = availableSeats;
        this.flightStatus = "SCHEDULED";
        this.captainName = captainName;
    }

    public FlightSummary(Long flightId, String flightNumber, String aircraftModel,
                         String originAirportCode, String originCity,
                         String destAirportCode, String destCity,
                         LocalDateTime departureTime, LocalDateTime arrivalTime,
                         int durationMinutes, BigDecimal baseFare,
                         int totalSeats, int availableSeats, String captainName,
                         int frequentFlyerMiles, String frequentFlyerTier, String frequentFlyerPerks) {
        this.flightId = flightId;
        this.flightNumber = flightNumber;
        this.airlineName = "SKYTECH AIRLINES";
        this.aircraftModel = aircraftModel;
        this.originAirportCode = originAirportCode;
        this.originCity = originCity;
        this.destAirportCode = destAirportCode;
        this.destCity = destCity;
        this.departureTime = departureTime;
        this.arrivalTime = arrivalTime;
        this.durationMinutes = durationMinutes;
        this.baseFare = baseFare;
        this.totalSeats = totalSeats;
        this.availableSeats = availableSeats;
        this.flightStatus = "SCHEDULED";
        this.captainName = captainName;
        this.frequentFlyerMiles = frequentFlyerMiles;
        this.frequentFlyerTier = frequentFlyerTier;
        this.frequentFlyerPerks = frequentFlyerPerks;
    }

    public int getOccupancyPercentage() {
        if (totalSeats <= 0) return 0;
        int occupied = totalSeats - availableSeats;
        return Math.min(100, Math.max(0, (occupied * 100) / totalSeats));
    }

    public String getFormattedDeparture() {
        if (departureTime == null) return "";
        return departureTime.format(DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm"));
    }

    public String getFormattedArrival() {
        if (arrivalTime == null) return "";
        return arrivalTime.format(DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm"));
    }

    public String getFormattedDuration() {
        int h = durationMinutes / 60;
        int m = durationMinutes % 60;
        return h + "h " + m + "m";
    }

    // Getters and Setters
    public Long getFlightId() { return flightId; }
    public void setFlightId(Long flightId) { this.flightId = flightId; }

    public String getFlightNumber() { return flightNumber; }
    public void setFlightNumber(String flightNumber) { this.flightNumber = flightNumber; }

    public String getAirlineName() { return airlineName; }
    public void setAirlineName(String airlineName) { this.airlineName = airlineName; }

    public String getAircraftModel() { return aircraftModel; }
    public void setAircraftModel(String aircraftModel) { this.aircraftModel = aircraftModel; }

    public String getOriginAirportCode() { return originAirportCode; }
    public void setOriginAirportCode(String originAirportCode) { this.originAirportCode = originAirportCode; }

    public String getOriginCity() { return originCity; }
    public void setOriginCity(String originCity) { this.originCity = originCity; }

    public String getDestAirportCode() { return destAirportCode; }
    public void setDestAirportCode(String destAirportCode) { this.destAirportCode = destAirportCode; }

    public String getDestCity() { return destCity; }
    public void setDestCity(String destCity) { this.destCity = destCity; }

    public LocalDateTime getDepartureTime() { return departureTime; }
    public void setDepartureTime(LocalDateTime departureTime) { this.departureTime = departureTime; }

    public LocalDateTime getArrivalTime() { return arrivalTime; }
    public void setArrivalTime(LocalDateTime arrivalTime) { this.arrivalTime = arrivalTime; }

    public int getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(int durationMinutes) { this.durationMinutes = durationMinutes; }

    public BigDecimal getBaseFare() { return baseFare; }
    public void setBaseFare(BigDecimal baseFare) { this.baseFare = baseFare; }

    public int getTotalSeats() { return totalSeats; }
    public void setTotalSeats(int totalSeats) { this.totalSeats = totalSeats; }

    public int getAvailableSeats() { return availableSeats; }
    public void setAvailableSeats(int availableSeats) { this.availableSeats = availableSeats; }

    public String getFlightStatus() { return flightStatus; }
    public void setFlightStatus(String flightStatus) { this.flightStatus = flightStatus; }

    public String getCaptainName() { return captainName != null ? captainName : "Capt. Rajesh Sharma"; }
    public void setCaptainName(String captainName) { this.captainName = captainName; }

    public int getFrequentFlyerMiles() { return frequentFlyerMiles; }
    public void setFrequentFlyerMiles(int frequentFlyerMiles) { this.frequentFlyerMiles = frequentFlyerMiles; }

    public String getFrequentFlyerTier() { return frequentFlyerTier != null ? frequentFlyerTier : "Silver Tier"; }
    public void setFrequentFlyerTier(String frequentFlyerTier) { this.frequentFlyerTier = frequentFlyerTier; }

    public String getFrequentFlyerPerks() { return frequentFlyerPerks != null ? frequentFlyerPerks : "1.0x Base Miles &bull; Priority Boarding"; }
    public void setFrequentFlyerPerks(String frequentFlyerPerks) { this.frequentFlyerPerks = frequentFlyerPerks; }
}
