package com.airline.model;

/**
 * Enumeration representing user roles within the Airline Reservation System.
 */
public enum Role {
    PASSENGER,
    ADMIN;

    public static Role fromString(String roleStr) {
        if (roleStr == null) {
            return PASSENGER;
        }
        try {
            return Role.valueOf(roleStr.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return PASSENGER;
        }
    }
}
