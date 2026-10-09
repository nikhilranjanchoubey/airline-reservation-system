package com.skytech.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * Represents a flight schedule / inventory instance for a specific date.
 */
public class FlightSchedule implements Serializable {

    private static final long serialVersionUID = 1L;

    private int scheduleId;
    private int flightId;
    private Flight flight;
    private Date flightDate;
    private BigDecimal basePrice;
    private BigDecimal economyPrice;
    private BigDecimal premiumEconomyPrice;
    private BigDecimal businessPrice;
    private BigDecimal firstClassPrice;
    private int availableSeats;
    private int totalSeats;
    private String status;

    public FlightSchedule() {
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public int getFlightId() {
        return flightId;
    }

    public void setFlightId(int flightId) {
        this.flightId = flightId;
    }

    public Flight getFlight() {
        return flight;
    }

    public void setFlight(Flight flight) {
        this.flight = flight;
    }

    public Date getFlightDate() {
        return flightDate;
    }

    public void setFlightDate(Date flightDate) {
        this.flightDate = flightDate;
    }

    public BigDecimal getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(BigDecimal basePrice) {
        this.basePrice = basePrice;
    }

    public BigDecimal getEconomyPrice() {
        return economyPrice;
    }

    public void setEconomyPrice(BigDecimal economyPrice) {
        this.economyPrice = economyPrice;
    }

    public BigDecimal getPremiumEconomyPrice() {
        return premiumEconomyPrice;
    }

    public void setPremiumEconomyPrice(BigDecimal premiumEconomyPrice) {
        this.premiumEconomyPrice = premiumEconomyPrice;
    }

    public BigDecimal getBusinessPrice() {
        return businessPrice;
    }

    public void setBusinessPrice(BigDecimal businessPrice) {
        this.businessPrice = businessPrice;
    }

    public BigDecimal getFirstClassPrice() {
        return firstClassPrice;
    }

    public void setFirstClassPrice(BigDecimal firstClassPrice) {
        this.firstClassPrice = firstClassPrice;
    }

    public int getAvailableSeats() {
        return availableSeats;
    }

    public void setAvailableSeats(int availableSeats) {
        this.availableSeats = availableSeats;
    }

    public int getTotalSeats() {
        return totalSeats;
    }

    public void setTotalSeats(int totalSeats) {
        this.totalSeats = totalSeats;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    /**
     * Resolves the fare for a specified travel class. Defaults to economy price.
     */
    public BigDecimal getPriceForClass(String travelClass) {
        if (travelClass == null) {
            return economyPrice != null ? economyPrice : basePrice;
        }
        switch (travelClass.trim().toLowerCase()) {
            case "premium economy":
            case "premiumeconomy":
                return premiumEconomyPrice != null ? premiumEconomyPrice : (economyPrice != null ? economyPrice : basePrice);
            case "business":
                return businessPrice != null ? businessPrice : (economyPrice != null ? economyPrice : basePrice);
            case "first class":
            case "firstclass":
                return firstClassPrice != null ? firstClassPrice : (economyPrice != null ? economyPrice : basePrice);
            case "economy":
            default:
                return economyPrice != null ? economyPrice : basePrice;
        }
    }

    public LocalDate getDepartureLocalDate() {
        return flightDate != null ? flightDate.toLocalDate() : null;
    }

    public String getFormattedFlightDate() {
        if (flightDate == null) return "";
        LocalDate ld = flightDate.toLocalDate();
        return ld.format(DateTimeFormatter.ofPattern("dd MMM uuuu", java.util.Locale.ENGLISH));
    }

    public String getFlightDayOfWeek() {
        if (flightDate == null) return "";
        return flightDate.toLocalDate().getDayOfWeek().getDisplayName(java.time.format.TextStyle.FULL, java.util.Locale.ENGLISH);
    }

    public LocalDate getArrivalDate() {
        if (flightDate == null) return null;
        LocalDate depDate = flightDate.toLocalDate();
        if (flight != null && flight.getDepartureTime() != null && flight.getArrivalTime() != null) {
            java.time.LocalTime depTime = flight.getDepartureTime().toLocalTime();
            java.time.LocalTime arrTime = flight.getArrivalTime().toLocalTime();
            if (arrTime.isBefore(depTime)) {
                return depDate.plusDays(1);
            }
        }
        return depDate;
    }

    public String getFormattedArrivalDate() {
        LocalDate arr = getArrivalDate();
        if (arr == null) return "";
        return arr.format(DateTimeFormatter.ofPattern("dd MMM uuuu", java.util.Locale.ENGLISH));
    }

    public String getArrivalDayOfWeek() {
        LocalDate arr = getArrivalDate();
        if (arr == null) return "";
        return arr.getDayOfWeek().getDisplayName(java.time.format.TextStyle.FULL, java.util.Locale.ENGLISH);
    }

    public String getSeatsBadgeClass() {
        if (availableSeats > 10) {
            return "bg-success-subtle text-success border border-success-subtle";
        } else if (availableSeats > 3) {
            return "bg-warning-subtle text-warning-emphasis border border-warning-subtle";
        } else {
            return "bg-danger-subtle text-danger border border-danger-subtle";
        }
    }

    public String getSeatsAvailabilityText() {
        if (live) {
            return "Estimated availability";
        }
        if (availableSeats > 10) {
            return availableSeats + " seats available";
        } else if (availableSeats > 1) {
            return availableSeats + " seats left";
        } else if (availableSeats == 1) {
            return "Only 1 seat left!";
        } else {
            return "Sold out";
        }
    }

    private String departureTerminal;
    private String arrivalTerminal;
    private String baggageBelt;
    private String revisedDepartureTime;
    private String revisedArrivalTime;
    private boolean live = false;
    private boolean estimatedFare = true;
    private String fareNote = "Estimated fare for demonstration";

    public String getDepartureTerminal() {
        if (departureTerminal != null && !departureTerminal.trim().isEmpty()) return departureTerminal;
        if (flight != null && flight.getDepartureTerminal() != null && !flight.getDepartureTerminal().trim().isEmpty()) {
            return flight.getDepartureTerminal();
        }
        return "Not available";
    }

    public void setDepartureTerminal(String departureTerminal) {
        this.departureTerminal = departureTerminal;
    }

    public String getArrivalTerminal() {
        if (arrivalTerminal != null && !arrivalTerminal.trim().isEmpty()) return arrivalTerminal;
        if (flight != null && flight.getArrivalTerminal() != null && !flight.getArrivalTerminal().trim().isEmpty()) {
            return flight.getArrivalTerminal();
        }
        return "Not available";
    }

    public void setArrivalTerminal(String arrivalTerminal) {
        this.arrivalTerminal = arrivalTerminal;
    }

    public String getBaggageBelt() {
        if (baggageBelt != null) return baggageBelt;
        if (flight != null) return flight.getBaggageBelt();
        return null;
    }

    public void setBaggageBelt(String baggageBelt) {
        this.baggageBelt = baggageBelt;
    }

    public String getRevisedDepartureTime() {
        return revisedDepartureTime;
    }

    public void setRevisedDepartureTime(String revisedDepartureTime) {
        this.revisedDepartureTime = revisedDepartureTime;
    }

    public String getRevisedArrivalTime() {
        return revisedArrivalTime;
    }

    public void setRevisedArrivalTime(String revisedArrivalTime) {
        this.revisedArrivalTime = revisedArrivalTime;
    }

    public boolean isLive() {
        return live;
    }

    public void setLive(boolean live) {
        this.live = live;
    }

    public boolean isEstimatedFare() {
        return estimatedFare;
    }

    public void setEstimatedFare(boolean estimatedFare) {
        this.estimatedFare = estimatedFare;
    }

    public String getFareNote() {
        return fareNote;
    }

    public void setFareNote(String fareNote) {
        this.fareNote = fareNote;
    }
}
