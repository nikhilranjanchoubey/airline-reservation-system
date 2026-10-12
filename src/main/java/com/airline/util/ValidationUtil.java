package com.airline.util;

import java.time.LocalDate;
import java.time.Period;
import java.util.regex.Pattern;

/**
 * Utility class providing comprehensive server-side validation rules.
 */
public final class ValidationUtil {

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$"
    );

    // Password: Min 8 chars, at least 1 uppercase, 1 lowercase, 1 number, 1 special character
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
            "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&_#^~])[A-Za-z\\d@$!%*?&_#^~]{8,64}$"
    );

    // Name: 2-50 characters, letters, spaces, hyphens, apostrophes
    private static final Pattern NAME_PATTERN = Pattern.compile(
            "^[A-Za-z\\s'-]{2,50}$"
    );

    // Phone: Optional + prefix, 7 to 15 digits
    private static final Pattern PHONE_PATTERN = Pattern.compile(
            "^\\+?[0-9]{7,15}$"
    );

    // Passport: 6 to 20 alphanumeric characters
    private static final Pattern PASSPORT_PATTERN = Pattern.compile(
            "^[A-Za-z0-9]{6,20}$"
    );

    private ValidationUtil() {
    }

    public static boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty() || email.length() > 100) {
            return false;
        }
        return EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    public static boolean isValidPassword(String password) {
        if (password == null || password.length() < 8 || password.length() > 64) {
            return false;
        }
        return PASSWORD_PATTERN.matcher(password).matches();
    }

    public static boolean isValidName(String name) {
        if (name == null || name.trim().isEmpty()) {
            return false;
        }
        return NAME_PATTERN.matcher(name.trim()).matches();
    }

    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }
        // Remove spaces and hyphens before validating
        String cleaned = phone.replaceAll("[\\s-]", "");
        return PHONE_PATTERN.matcher(cleaned).matches();
    }

    public static boolean isValidPassport(String passport) {
        if (passport == null || passport.trim().isEmpty()) {
            return true; // Optional field
        }
        return PASSPORT_PATTERN.matcher(passport.trim()).matches();
    }

    public static boolean isValidDateOfBirth(LocalDate dob) {
        if (dob == null) {
            return false;
        }
        LocalDate today = LocalDate.now();
        if (dob.isAfter(today)) {
            return false;
        }
        int age = Period.between(dob, today).getYears();
        return age >= 0 && age <= 120;
    }

    public static String clean(String input) {
        return input == null ? "" : input.trim();
    }
}
