package com.skytech.airlines.booking.util;

import com.skytech.airlines.booking.exception.InvalidPassengerException;
import com.skytech.airlines.booking.model.Passenger;
import com.skytech.airlines.booking.model.PassengerType;

import java.time.LocalDate;
import java.time.Period;
import java.util.List;
import java.util.regex.Pattern;

/**
 * =============================================================================
 * SKYTECH AIRLINES — Module 3: Booking & Passenger Management
 * Validation Utility Class
 * =============================================================================
 *
 * Centralized server-side validation utility for passenger details, contact information,
 * identification documents, seat formatting, and PNR patterns.
 * 
 * Enforces strict input validation to prevent injection, corrupted records,
 * and business rule violations (e.g., minimum passenger count, adult requirement,
 * age consistency per passenger type).
 */
public final class ValidationUtil {

    private static final Pattern NAME_PATTERN = Pattern.compile("^[a-zA-Z\\s\\-'.]{2,50}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^\\+?[0-9\\s\\-]{8,20}$");
    private static final Pattern PNR_PATTERN = Pattern.compile("^[2-9A-HJ-NP-Z]{6}$");
    private static final Pattern SEAT_PATTERN = Pattern.compile("^([1-9]|[1-2][0-9]|30)[A-F]$");
    private static final Pattern DOC_PATTERN = Pattern.compile("^[a-zA-Z0-9\\s\\-]{3,30}$");

    private ValidationUtil() {
        // Utility class; prevent instantiation
    }

    /**
     * Validates a person's first or last name.
     * Must contain 2 to 50 characters, letters, spaces, hyphens, or apostrophes only.
     */
    public static boolean isValidName(String name) {
        if (name == null) return false;
        String trimmed = name.trim();
        return NAME_PATTERN.matcher(trimmed).matches();
    }

    /**
     * Validates an email address against standard RFC format.
     */
    public static boolean isValidEmail(String email) {
        if (email == null) return false;
        String trimmed = email.trim();
        return EMAIL_PATTERN.matcher(trimmed).matches();
    }

    /**
     * Validates a phone or mobile number (E.164 or domestic formats, 8-20 characters).
     */
    public static boolean isValidPhone(String phone) {
        if (phone == null) return false;
        String trimmed = phone.trim();
        return PHONE_PATTERN.matcher(trimmed).matches();
    }

    /**
     * Validates a 6-character PNR code against unambiguous base-32 charset.
     */
    public static boolean isValidPNR(String pnr) {
        if (pnr == null) return false;
        String trimmed = pnr.trim().toUpperCase();
        return PNR_PATTERN.matcher(trimmed).matches();
    }

    /**
     * Validates an aircraft seat number (Rows 1 to 30, Columns A to F).
     */
    public static boolean isValidSeatNumber(String seatNumber) {
        if (seatNumber == null) return false;
        String trimmed = seatNumber.trim().toUpperCase();
        return SEAT_PATTERN.matcher(trimmed).matches();
    }

    /**
     * Validates a government ID / passport number format.
     */
    public static boolean isValidDocumentNumber(String docNumber) {
        if (docNumber == null || docNumber.trim().isEmpty()) return true; // Optional for domestic flights
        return DOC_PATTERN.matcher(docNumber.trim()).matches();
    }

    /**
     * Calculates age from date of birth relative to today.
     */
    public static int calculateAge(LocalDate dateOfBirth) {
        if (dateOfBirth == null) return -1;
        return Period.between(dateOfBirth, LocalDate.now()).getYears();
    }

    /**
     * Validates that date of birth matches the declared PassengerType.
     * - ADULT: Age >= 12
     * - CHILD: Age between 2 and 11
     * - INFANT: Age under 2
     */
    public static boolean isAgeConsistentWithType(LocalDate dateOfBirth, PassengerType type) {
        if (dateOfBirth == null || type == null) return false;
        int age = calculateAge(dateOfBirth);
        if (age < 0) return false;

        return switch (type) {
            case ADULT -> age >= 12;
            case CHILD -> age >= 2 && age < 12;
            case INFANT -> age < 2;
        };
    }

    /**
     * Comprehensive validation of a single passenger entity.
     * Throws InvalidPassengerException with clear diagnostic message on failure.
     */
    public static void validatePassenger(Passenger passenger, int index) throws InvalidPassengerException {
        if (passenger == null) {
            throw new InvalidPassengerException("Passenger #" + (index + 1) + " cannot be null.");
        }

        if (!isValidName(passenger.getFirstName())) {
            throw new InvalidPassengerException("Passenger #" + (index + 1) + " first name must be between 2 and 50 characters (letters only).");
        }

        if (!isValidName(passenger.getLastName())) {
            throw new InvalidPassengerException("Passenger #" + (index + 1) + " last name must be between 2 and 50 characters (letters only).");
        }

        LocalDate dob = passenger.getDateOfBirth();
        if (dob == null) {
            throw new InvalidPassengerException("Passenger #" + (index + 1) + " date of birth is required.");
        }

        if (dob.isAfter(LocalDate.now())) {
            throw new InvalidPassengerException("Passenger #" + (index + 1) + " date of birth cannot be in the future.");
        }

        if (passenger.getPassengerType() == null) {
            passenger.setPassengerType(PassengerType.ADULT);
        }

        int age = calculateAge(dob);
        if (passenger.getPassengerType() == PassengerType.ADULT && age < 12) {
            throw new InvalidPassengerException("Passenger #" + (index + 1) + " is designated as ADULT, but age is under 12 (" + age + " yrs).");
        }

        if (passenger.getPassengerType() == PassengerType.CHILD && (age < 2 || age >= 12)) {
            throw new InvalidPassengerException("Passenger #" + (index + 1) + " is designated as CHILD, but age must be between 2 and 11 (" + age + " yrs).");
        }

        if (passenger.getPassengerType() == PassengerType.INFANT && age >= 2) {
            throw new InvalidPassengerException("Passenger #" + (index + 1) + " is designated as INFANT, but age must be under 2 (" + age + " yrs).");
        }

        if (passenger.getGender() == null || passenger.getGender().trim().isEmpty()) {
            throw new InvalidPassengerException("Passenger #" + (index + 1) + " gender must be selected.");
        }

        if (passenger.getPassportOrId() != null && !passenger.getPassportOrId().trim().isEmpty()) {
            if (!isValidDocumentNumber(passenger.getPassportOrId())) {
                throw new InvalidPassengerException("Passenger #" + (index + 1) + " ID/Passport contains invalid characters.");
            }
        }
    }

    /**
     * Validates an entire list of passengers along with booking contact details.
     * Enforces mandatory adult rule (at least one ADULT per flight reservation).
     */
    public static void validatePassengerList(List<Passenger> passengers, String contactEmail, String contactPhone)
            throws InvalidPassengerException {

        if (passengers == null || passengers.isEmpty()) {
            throw new InvalidPassengerException("At least one passenger must be provided.");
        }

        if (passengers.size() > 9) {
            throw new InvalidPassengerException("Maximum 9 passengers permitted per single booking.");
        }

        boolean hasAdult = false;
        for (int i = 0; i < passengers.size(); i++) {
            Passenger p = passengers.get(i);
            validatePassenger(p, i);
            if (p.getPassengerType() == PassengerType.ADULT) {
                hasAdult = true;
            }
        }

        if (!hasAdult) {
            throw new InvalidPassengerException("At least one adult (age 12+) passenger is required for booking.");
        }

        if (!isValidEmail(contactEmail)) {
            throw new InvalidPassengerException("A valid primary contact email address is required.");
        }

        if (!isValidPhone(contactPhone)) {
            throw new InvalidPassengerException("A valid primary contact phone number is required.");
        }
    }
}
