package com.skytech.airlines.booking.exception;

public class FlightNotFoundException extends BookingException {
    private static final long serialVersionUID = 1L;
    public FlightNotFoundException(String message) { super(message); }
}
