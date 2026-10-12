package com.skytech.airlines.booking.exception;

public class ConcurrentBookingException extends BookingException {
    private static final long serialVersionUID = 1L;
    public ConcurrentBookingException(String message) { super(message); }
    public ConcurrentBookingException(String message, Throwable cause) { super(message, cause); }
}
