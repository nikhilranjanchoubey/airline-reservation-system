package com.skytech.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Represents a flight reservation in the SkyTech Airline Reservation System.
 */
public class Booking implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private String bookingReference;
    private Long userId;
    private Integer scheduleId;
    private String flightNumber;
    private String travelClass;
    private String seatNumbers;
    private String contactEmail;
    private String contactPhone;
    private String pnr;
    private String provider;
    private String providerOrderId;
    private String originCode;
    private String destinationCode;
    private LocalDate departureDate;
    private String status; // PENDING_PAYMENT, CONFIRMED, PAYMENT_FAILED, CANCELLED, REFUND_PENDING, REFUNDED
    private BigDecimal totalAmount;
    private String currency;
    private Timestamp createdAt;

    // Associated navigation objects
    private List<Passenger> passengers = new ArrayList<>();
    private FlightSchedule schedule;
    private Payment payment;
    private List<Ticket> tickets = new ArrayList<>();
    private Cancellation cancellation;

    public Booking() {
        this.currency = "INR";
        this.status = "PENDING_PAYMENT";
        this.provider = "LOCAL_CATALOG";
        this.travelClass = "Economy";
        this.totalAmount = BigDecimal.ZERO;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getBookingReference() {
        return bookingReference;
    }

    public void setBookingReference(String bookingReference) {
        this.bookingReference = bookingReference;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Integer getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(Integer scheduleId) {
        this.scheduleId = scheduleId;
    }

    public String getFlightNumber() {
        return flightNumber;
    }

    public void setFlightNumber(String flightNumber) {
        this.flightNumber = flightNumber;
    }

    public String getTravelClass() {
        return travelClass;
    }

    public void setTravelClass(String travelClass) {
        this.travelClass = travelClass;
    }

    public String getSeatNumbers() {
        return seatNumbers;
    }

    public void setSeatNumbers(String seatNumbers) {
        this.seatNumbers = seatNumbers;
    }

    public String getContactEmail() {
        return contactEmail;
    }

    public void setContactEmail(String contactEmail) {
        this.contactEmail = contactEmail;
    }

    public String getContactPhone() {
        return contactPhone;
    }

    public void setContactPhone(String contactPhone) {
        this.contactPhone = contactPhone;
    }

    public String getPnr() {
        return pnr;
    }

    public void setPnr(String pnr) {
        this.pnr = pnr;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getProviderOrderId() {
        return providerOrderId;
    }

    public void setProviderOrderId(String providerOrderId) {
        this.providerOrderId = providerOrderId;
    }

    public String getOriginCode() {
        return originCode;
    }

    public void setOriginCode(String originCode) {
        this.originCode = originCode;
    }

    public String getDestinationCode() {
        return destinationCode;
    }

    public void setDestinationCode(String destinationCode) {
        this.destinationCode = destinationCode;
    }

    public LocalDate getDepartureDate() {
        return departureDate;
    }

    public void setDepartureDate(LocalDate departureDate) {
        this.departureDate = departureDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<Passenger> getPassengers() {
        return passengers;
    }

    public void setPassengers(List<Passenger> passengers) {
        this.passengers = passengers != null ? passengers : new ArrayList<>();
    }

    public void addPassenger(Passenger passenger) {
        if (passenger != null) {
            this.passengers.add(passenger);
        }
    }

    public FlightSchedule getSchedule() {
        return schedule;
    }

    public void setSchedule(FlightSchedule schedule) {
        this.schedule = schedule;
    }

    public Payment getPayment() {
        return payment;
    }

    public void setPayment(Payment payment) {
        this.payment = payment;
    }

    public List<Ticket> getTickets() {
        return tickets;
    }

    public void setTickets(List<Ticket> tickets) {
        this.tickets = tickets != null ? tickets : new ArrayList<>();
    }

    public void addTicket(Ticket ticket) {
        if (ticket != null) {
            this.tickets.add(ticket);
        }
    }

    public Cancellation getCancellation() {
        return cancellation;
    }

    public void setCancellation(Cancellation cancellation) {
        this.cancellation = cancellation;
    }

    public boolean isConfirmed() {
        return "CONFIRMED".equalsIgnoreCase(status);
    }

    public boolean isCancelled() {
        return "CANCELLED".equalsIgnoreCase(status) || "REFUNDED".equalsIgnoreCase(status);
    }

    public boolean isPending() {
        return "PENDING".equalsIgnoreCase(status) || "PENDING_PAYMENT".equalsIgnoreCase(status);
    }
}
