package com.skytech.airlines.booking;

import com.skytech.airlines.booking.exception.InvalidPassengerException;
import com.skytech.airlines.booking.model.Passenger;
import com.skytech.airlines.booking.model.PassengerType;
import com.skytech.airlines.booking.service.PassengerService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class PassengerValidationTest {

    private PassengerService passengerService;

    @BeforeEach
    void setUp() {
        passengerService = new PassengerService();
    }

    @Test
    @DisplayName("Should accept valid passenger list with adult and correct contact details")
    void testValidPassengerList() {
        List<Passenger> passengers = new ArrayList<>();
        passengers.add(new Passenger("Rajesh", "Sharma", LocalDate.of(1985, 5, 20),
                "MALE", PassengerType.ADULT, "P9876543", "Indian"));

        assertDoesNotThrow(() -> {
            passengerService.validatePassengerList(passengers, "rajesh@example.com", "+919876543210");
        });
    }

    @Test
    @DisplayName("Should reject empty passenger list")
    void testEmptyList() {
        assertThrows(InvalidPassengerException.class, () -> {
            passengerService.validatePassengerList(new ArrayList<>(), "test@example.com", "+919876543210");
        });
    }

    @Test
    @DisplayName("Should reject child without adult companion")
    void testChildWithoutAdult() {
        List<Passenger> passengers = new ArrayList<>();
        passengers.add(new Passenger("Aarav", "Sharma", LocalDate.of(2018, 5, 20),
                "MALE", PassengerType.CHILD, "", "Indian"));

        InvalidPassengerException ex = assertThrows(InvalidPassengerException.class, () -> {
            passengerService.validatePassengerList(passengers, "test@example.com", "+919876543210");
        });
        assertTrue(ex.getMessage().contains("adult"));
    }
}
