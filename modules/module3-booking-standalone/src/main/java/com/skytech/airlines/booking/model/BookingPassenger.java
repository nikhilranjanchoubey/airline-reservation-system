package com.skytech.airlines.booking.model;

import java.io.Serializable;

/**
 * Junction entity linking booking to passenger with seat number and status.
 */
public class BookingPassenger implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long bookingPassengerId;
    private Long bookingId;
    private Long passengerId;
    private String seatNumber;
    private String passengerStatus = "CONFIRMED";

    public BookingPassenger() {}

    public BookingPassenger(Long bookingId, Long passengerId, String seatNumber) {
        this.bookingId = bookingId;
        this.passengerId = passengerId;
        this.seatNumber = seatNumber;
    }

    public Long getBookingPassengerId() { return bookingPassengerId; }
    public void setBookingPassengerId(Long bookingPassengerId) { this.bookingPassengerId = bookingPassengerId; }

    public Long getBookingId() { return bookingId; }
    public void setBookingId(Long bookingId) { this.bookingId = bookingId; }

    public Long getPassengerId() { return passengerId; }
    public void setPassengerId(Long passengerId) { this.passengerId = passengerId; }

    public String getSeatNumber() { return seatNumber; }
    public void setSeatNumber(String seatNumber) { this.seatNumber = seatNumber; }

    public String getPassengerStatus() { return passengerStatus; }
    public void setPassengerStatus(String passengerStatus) { this.passengerStatus = passengerStatus; }
}
