package com.airline.util;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

class ValidationUtilTest {

    @Test
    void testIsValidEmail() {
        assertTrue(ValidationUtil.isValidEmail("john.doe@example.com"));
        assertTrue(ValidationUtil.isValidEmail("alice+tag@sub.domain.org"));
        assertFalse(ValidationUtil.isValidEmail("plainaddress"));
        assertFalse(ValidationUtil.isValidEmail("@missingusername.com"));
        assertFalse(ValidationUtil.isValidEmail("missingdomain@.com"));
        assertFalse(ValidationUtil.isValidEmail(""));
        assertFalse(ValidationUtil.isValidEmail(null));
    }

    @Test
    void testIsValidPassword() {
        // Strong password with uppercase, lowercase, digit, and special char (>= 8 chars)
        assertTrue(ValidationUtil.isValidPassword("Flight@2026"));
        assertTrue(ValidationUtil.isValidPassword("Admin#1234"));

        // Too short (< 8)
        assertFalse(ValidationUtil.isValidPassword("P@ss1"));
        // No uppercase
        assertFalse(ValidationUtil.isValidPassword("flight@2026"));
        // No lowercase
        assertFalse(ValidationUtil.isValidPassword("FLIGHT@2026"));
        // No digit
        assertFalse(ValidationUtil.isValidPassword("Flight@Sky"));
        // No special character
        assertFalse(ValidationUtil.isValidPassword("Flight2026"));
        // Null
        assertFalse(ValidationUtil.isValidPassword(null));
    }

    @Test
    void testIsValidName() {
        assertTrue(ValidationUtil.isValidName("John"));
        assertTrue(ValidationUtil.isValidName("Mary-Jane"));
        assertTrue(ValidationUtil.isValidName("O'Connor"));
        assertFalse(ValidationUtil.isValidName("J")); // too short
        assertFalse(ValidationUtil.isValidName("John123")); // contains numbers
        assertFalse(ValidationUtil.isValidName(null));
    }

    @Test
    void testIsValidPhone() {
        assertTrue(ValidationUtil.isValidPhone("+1234567890"));
        assertTrue(ValidationUtil.isValidPhone("9876543210"));
        assertTrue(ValidationUtil.isValidPhone("+91 98765-43210"));
        assertFalse(ValidationUtil.isValidPhone("123")); // too short
        assertFalse(ValidationUtil.isValidPhone("abcd1234ef"));
        assertFalse(ValidationUtil.isValidPhone(null));
    }

    @Test
    void testIsValidPassport() {
        assertTrue(ValidationUtil.isValidPassport("A12345678"));
        assertTrue(ValidationUtil.isValidPassport("")); // Optional
        assertTrue(ValidationUtil.isValidPassport(null)); // Optional
        assertFalse(ValidationUtil.isValidPassport("AB")); // too short if provided
    }

    @Test
    void testIsValidDateOfBirth() {
        assertTrue(ValidationUtil.isValidDateOfBirth(LocalDate.of(1995, 5, 20)));
        assertFalse(ValidationUtil.isValidDateOfBirth(LocalDate.now().plusDays(1))); // future date
        assertFalse(ValidationUtil.isValidDateOfBirth(LocalDate.of(1800, 1, 1))); // > 120 years
        assertFalse(ValidationUtil.isValidDateOfBirth(null));
    }
}
