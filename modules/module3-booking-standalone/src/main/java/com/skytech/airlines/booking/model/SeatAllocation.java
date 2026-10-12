package com.skytech.airlines.booking.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Record of seat hold / assignment against a flight instance.
 */
public class SeatAllocation implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long allocationId;
    private Long bookingId;
    private Long passengerId;
    private Long flightId;
    private String seatNumber;
    private SeatClass seatClass = SeatClass.ECONOMY;
    private BigDecimal seatPrice = BigDecimal.ZERO;
    private String allocationStatus = "HELD"; // 'HELD', 'ALLOCATED', 'RELEASED', 'EXPIRED'
    private LocalDateTime allocatedAt = LocalDateTime.now();

    public SeatAllocation() {}

    public SeatAllocation(Long bookingId, Long passengerId, Long flightId, String seatNumber, 
                          SeatClass seatClass, BigDecimal seatPrice, String allocationStatus) {
        this.bookingId = bookingId;
        this.passengerId = passengerId;
        this.flightId = flightId;
        this.seatNumber = seatNumber;
        this.seatClass = seatClass;
        this.seatPrice = seatPrice != null ? seatPrice : BigDecimal.ZERO;
        this.allocationStatus = allocationStatus;
    }

    public Long getAllocationId() { return allocationId; }
    public void setAllocationId(Long allocationId) { this.allocationId = allocationId; }

    public Long getBookingId() { return bookingId; }
    public void setBookingId(Long bookingId) { this.bookingId = bookingId; }

    public Long getPassengerId() { return passengerId; }
    public void setPassengerId(Long passengerId) { this.passengerId = passengerId; }

    public Long getFlightId() { return flightId; }
    public void setFlightId(Long flightId) { this.flightId = flightId; }

    public String getSeatNumber() { return seatNumber; }
    public void setSeatNumber(String seatNumber) { this.seatNumber = seatNumber; }

    public SeatClass getSeatClass() { return seatClass; }
    public void setSeatClass(SeatClass seatClass) { this.seatClass = seatClass; }

    public BigDecimal getSeatPrice() { return seatPrice; }
    public void setSeatPrice(BigDecimal seatPrice) { this.seatPrice = seatPrice; }

    public String getAllocationStatus() { return allocationStatus; }
    public void setAllocationStatus(String allocationStatus) { this.allocationStatus = allocationStatus; }

    public LocalDateTime getAllocatedAt() { return allocatedAt; }
    public void setAllocatedAt(LocalDateTime allocatedAt) { this.allocatedAt = allocatedAt; }
}
