package com.skytech.airlines.booking;

import com.skytech.airlines.booking.dao.BookingDAO;
import com.skytech.airlines.booking.exception.BookingException;
import com.skytech.airlines.booking.model.Booking;
import com.skytech.airlines.booking.model.BookingStatus;
import com.skytech.airlines.booking.model.Passenger;
import com.skytech.airlines.booking.model.PassengerType;
import com.skytech.airlines.booking.service.BookingService;
import com.skytech.airlines.booking.service.PNRGenerator;
import com.skytech.airlines.booking.service.PassengerService;
import com.skytech.airlines.booking.service.SeatAllocationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Collections;

import static org.junit.jupiter.api.Assertions.*;

class BookingServiceTransactionTest {

    private BookingService bookingService;

    static class StubBookingDAO extends BookingDAO {
        @Override
        public boolean pnrExists(String pnr) { return false; }
    }

    static class StubPNRGenerator extends PNRGenerator {
        @Override
        public String generateUniquePNR(BookingDAO dao) { return "SKTEST"; }
    }

    @BeforeEach
    void setUp() {
        bookingService = new BookingService(new StubBookingDAO(), new PassengerService(), new SeatAllocationService(), new StubPNRGenerator());
    }

    @Test
    @DisplayName("Should create pending booking entity with authoritative fare and PNR")
    void testCreatePendingBooking() throws BookingException {
        Passenger p = new Passenger("Rajesh", "Sharma", LocalDate.of(1985, 5, 20), "MALE", PassengerType.ADULT, "", "Indian");

        Booking b = bookingService.createPendingBooking(
                1L, 101L, Collections.singletonList(p), Collections.singletonList("4A"),
                new BigDecimal("4500.00"), "test@example.com", "+919876543210"
        );

        assertNotNull(b);
        assertEquals("SKTEST", b.getPnr());
        assertEquals(BookingStatus.PENDING, b.getBookingStatus());
        assertEquals(new BigDecimal("5040.00"), b.getTotalAmount()); // 4500 + 12% tax = 5040.00
    }
}
