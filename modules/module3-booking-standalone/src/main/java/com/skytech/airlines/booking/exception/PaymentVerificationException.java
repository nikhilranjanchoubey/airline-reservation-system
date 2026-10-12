package com.skytech.airlines.booking.exception;

public class PaymentVerificationException extends BookingException {
    private static final long serialVersionUID = 1L;
    public PaymentVerificationException(String message) { super(message); }
    public PaymentVerificationException(String message, Throwable cause) { super(message, cause); }
}
