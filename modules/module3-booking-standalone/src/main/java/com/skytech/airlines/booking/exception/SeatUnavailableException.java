package com.skytech.airlines.booking.exception;

public class SeatUnavailableException extends BookingException {
    private static final long serialVersionUID = 1L;
    public SeatUnavailableException(String message) { super(message); }
}
