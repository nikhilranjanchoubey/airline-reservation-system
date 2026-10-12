package com.skytech.airlines.booking.model;

/**
 * Lifecycle state of a payment transaction.
 */
public enum PaymentStatus {
    PENDING,
    SUCCESS,
    FAILED,
    REFUNDED
}
