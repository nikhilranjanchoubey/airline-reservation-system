package com.skytech.service;

import com.airline.model.Role;
import com.airline.model.User;
import com.skytech.dao.*;
import com.skytech.model.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BookingServiceTest {

    @Mock
    private BookingDao bookingDao;

    @Mock
    private SeatDao seatDao;

    @Mock
    private TicketDao ticketDao;

    @Mock
    private CancellationDao cancellationDao;

    @Mock
    private PaymentDao paymentDao;

    @Mock
    private FlightSearchService flightSearchService;

    private BookingService bookingService;

    @BeforeEach
    void setUp() {
        bookingService = new BookingService(bookingDao, seatDao, ticketDao, cancellationDao, paymentDao, flightSearchService);
    }

    @Test
    void testCreatePendingBookingRequiresUser() {
        assertThrows(IllegalStateException.class, () ->
                bookingService.createPendingBooking(null, 1, "Economy",
                        Collections.singletonList(new Passenger("John", "Doe", "ADULT", "1A")),
                        null, "john@example.com", "1234567890"));
    }

    @Test
    void testCreatePendingBookingCalculatesAuthoritativeFare() throws Exception {
        User user = new User();

        user.setUserId(10);
        user.setEmail("passenger@airline.com");
        user.setPhone("+15551234567");

        FlightSchedule schedule = new FlightSchedule();
        schedule.setScheduleId(1);
        schedule.setEconomyPrice(new BigDecimal("4000.00"));
        schedule.setFlightDate(Date.valueOf(LocalDate.now().plusDays(3)));

        Flight flight = new Flight();
        flight.setFlightNumber("6E-204");
        flight.setSourceAirport(new Airport(1, "JAI", "Jaipur Airport", "Jaipur", "India", "T1"));
        flight.setDestinationAirport(new Airport(2, "DEL", "Delhi Airport", "Delhi", "India", "T3"));
        flight.setAirline(new Airline(1, "6E", "IndiGo", "bi-airplane"));
        schedule.setFlight(flight);


        when(flightSearchService.getFlightDetails(eq(1), any())).thenReturn(schedule);
        when(bookingDao.createBooking(any(Booking.class), anyList())).thenAnswer(inv -> {
            Booking b = inv.getArgument(0);
            b.setId(55L);
            return true;
        });

        List<Passenger> passengers = new ArrayList<>();
        passengers.add(new Passenger("John", "Doe", "ADULT", null));

        Booking booking = bookingService.createPendingBooking(
                user, 1, "Economy", passengers, null, "passenger@airline.com", "+15551234567"
        );

        assertNotNull(booking);
        assertEquals(55L, booking.getId());
        assertEquals("PENDING_PAYMENT", booking.getStatus());
        // Base fare 4000 + 12% GST (480) = 4480.00
        assertEquals(new BigDecimal("4480.00"), booking.getTotalAmount());
        assertTrue(booking.getBookingReference().startsWith("SKYT-"));
    }

    @Test
    void testCancelBookingAppliesAcademicPolicy() {
        User user = new User();
        user.setUserId(10);
        user.setRole(Role.PASSENGER);

        Booking booking = new Booking();
        booking.setId(88L);
        booking.setUserId(10L);
        booking.setStatus("CONFIRMED");
        booking.setPnr("SK1234");
        booking.setTotalAmount(new BigDecimal("6000.00"));
        booking.addPassenger(new Passenger("John", "Doe", "ADULT", "1A"));

        when(bookingDao.getBookingById(88L)).thenReturn(booking);
        when(bookingDao.updateBookingStatus(88L, "CANCELLED")).thenReturn(true);
        when(ticketDao.updateTicketsStatusForBooking(88L, "CANCELLED")).thenReturn(true);
        when(cancellationDao.recordCancellation(any(Cancellation.class))).thenReturn(true);

        boolean success = bookingService.cancelBooking(88L, "College demonstration testing", user);

        assertTrue(success);
        verify(bookingDao).updateBookingStatus(88L, "CANCELLED");
        verify(ticketDao).updateTicketsStatusForBooking(88L, "CANCELLED");
        verify(cancellationDao).recordCancellation(argThat(c ->
                c.getBookingId() == 88L &&
                c.getCancellationFee().compareTo(BigDecimal.ZERO) > 0 &&
                c.getRefundAmount().compareTo(BigDecimal.ZERO) > 0
        ));
    }
}
