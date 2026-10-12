package com.skytech.airlines.booking.exception;

public class DuplicatePNRException extends BookingException {
    private static final long serialVersionUID = 1L;
    public DuplicatePNRException(String message) { super(message); }
}
