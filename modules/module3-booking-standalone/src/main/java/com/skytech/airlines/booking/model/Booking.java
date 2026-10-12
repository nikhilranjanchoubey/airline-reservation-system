package com.skytech.airlines.booking.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * Core Booking header entity containing PNR, totals, passenger roster, and payment reference.
 */
public class Booking implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long bookingId;
    private String pnr;
    private Long userId;
    private Long flightId;
    private LocalDateTime bookingDate = LocalDateTime.now();
    private BookingStatus bookingStatus = BookingStatus.PENDING;
    private BigDecimal baseFare = BigDecimal.ZERO;
    private BigDecimal seatFees = BigDecimal.ZERO;
    private BigDecimal taxAmount = BigDecimal.ZERO;
    private BigDecimal totalAmount = BigDecimal.ZERO;
    private String contactEmail;
    private String contactPhone;
    private LocalDateTime createdAt = LocalDateTime.now();

    // Associated entities
    private List<Passenger> passengers = new ArrayList<>();
    private List<SeatAllocation> seatAllocations = new ArrayList<>();
    private Payment payment;

    public Booking() {}

    public Booking(String pnr, Long userId, Long flightId, String contactEmail, String contactPhone) {
        this.pnr = pnr;
        this.userId = userId;
        this.flightId = flightId;
        this.contactEmail = contactEmail;
        this.contactPhone = contactPhone;
    }

    public String getAllocatedSeatNumbersDisplay() {
        if (passengers != null && !passengers.isEmpty()) {
            List<String> seats = new ArrayList<>();
            for (Passenger p : passengers) {
                if (p.getSeatNumber() != null && !p.getSeatNumber().trim().isEmpty()) {
                    seats.add(p.getSeatNumber());
                }
            }
            if (!seats.isEmpty()) {
                return String.join(", ", seats);
            }
        }
        if (seatAllocations != null && !seatAllocations.isEmpty()) {
            List<String> seats = new ArrayList<>();
            for (SeatAllocation sa : seatAllocations) {
                if (sa.getSeatNumber() != null) {
                    seats.add(sa.getSeatNumber());
                }
            }
            return String.join(", ", seats);
        }
        return "None Selected";
    }

    public String getFormattedBookingDate() {
        if (bookingDate == null) return "";
        return bookingDate.format(DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm"));
    }

    // Getters and Setters
    public Long getBookingId() { return bookingId; }
    public void setBookingId(Long bookingId) { this.bookingId = bookingId; }

    public String getPnr() { return pnr; }
    public void setPnr(String pnr) { this.pnr = pnr; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Long getFlightId() { return flightId; }
    public void setFlightId(Long flightId) { this.flightId = flightId; }

    public LocalDateTime getBookingDate() { return bookingDate; }
    public void setBookingDate(LocalDateTime bookingDate) { this.bookingDate = bookingDate; }

    public BookingStatus getBookingStatus() { return bookingStatus; }
    public void setBookingStatus(BookingStatus bookingStatus) { this.bookingStatus = bookingStatus; }

    public BigDecimal getBaseFare() { return baseFare; }
    public void setBaseFare(BigDecimal baseFare) { this.baseFare = baseFare; }

    public BigDecimal getSeatFees() { return seatFees; }
    public void setSeatFees(BigDecimal seatFees) { this.seatFees = seatFees; }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getContactEmail() { return contactEmail; }
    public void setContactEmail(String contactEmail) { this.contactEmail = contactEmail; }

    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<Passenger> getPassengers() { return passengers; }
    public void setPassengers(List<Passenger> passengers) { this.passengers = passengers; }

    public List<SeatAllocation> getSeatAllocations() { return seatAllocations; }
    public void setSeatAllocations(List<SeatAllocation> seatAllocations) { this.seatAllocations = seatAllocations; }

    public Payment getPayment() { return payment; }
    public void setPayment(Payment payment) { this.payment = payment; }
}
