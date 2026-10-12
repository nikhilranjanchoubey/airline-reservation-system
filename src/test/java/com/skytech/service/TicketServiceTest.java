package com.skytech.service;

import com.skytech.model.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

class TicketServiceTest {

    private TicketService ticketService;

    @BeforeEach
    void setUp() {
        ticketService = new TicketService();
    }

    @Test
    void testGenerateTicketPdfProducesValidPdfBytes() {
        Booking booking = new Booking();
        booking.setId(101L);
        booking.setPnr("SK7890");
        booking.setBookingReference("SKYT-ABC123");
        booking.setFlightNumber("6E-204");
        booking.setOriginCode("DEL");
        booking.setDestinationCode("BOM");
        booking.setDepartureDate(LocalDate.now().plusDays(5));
        booking.setTravelClass("Economy");
        booking.setStatus("CONFIRMED");
        booking.setTotalAmount(new BigDecimal("4815.00"));
        booking.setContactEmail("passenger@airline.com");
        booking.setContactPhone("+919876543210");
        booking.setSeatNumbers("12A");

        Passenger passenger = new Passenger("John", "Doe", "ADULT", "12A");
        passenger.setId(1L);
        passenger.setTicketNumber("098-101-001");
        booking.addPassenger(passenger);

        Ticket ticket = new Ticket();
        ticket.setBookingId(101L);
        ticket.setPassengerId(1L);
        ticket.setTicketNumber("098-101-001");
        ticket.setPnr("SK7890");
        ticket.setFlightNumber("6E-204");
        ticket.setOriginCode("DEL");
        ticket.setDestinationCode("BOM");
        ticket.setDepartureTime(LocalDateTime.now().plusDays(5).withHour(10).withMinute(0));
        ticket.setArrivalTime(LocalDateTime.now().plusDays(5).withHour(12).withMinute(15));
        ticket.setSeatNumber("12A");
        ticket.setCabinClass("Economy");
        ticket.setPassengerName("John Doe");
        ticket.setStatus("CONFIRMED");
        booking.addTicket(ticket);

        byte[] pdfBytes = ticketService.generateTicketPdf(booking, ticket);

        assertNotNull(pdfBytes, "PDF byte array should not be null");
        assertTrue(pdfBytes.length > 500, "PDF should have substantive byte content");

        // Verify PDF Magic Bytes (%PDF-)
        String header = new String(pdfBytes, 0, 5);
        assertEquals("%PDF-", header, "PDF output must start with standard PDF header '%PDF-'");
    }

    @Test
    void testGenerateTicketPdfNullBooking() {
        byte[] pdfBytes = ticketService.generateTicketPdf(null, null);
        assertNotNull(pdfBytes);
        assertEquals(0, pdfBytes.length);
    }

    @Test
    void testGenerateTicketPdfWithMinimalFieldsDoesNotThrow() {
        Booking booking = new Booking();
        booking.setId(999L);
        booking.setStatus("CONFIRMED");
        booking.setTotalAmount(new BigDecimal("2500.00"));

        byte[] pdfBytes = ticketService.generateTicketPdf(booking, null);
        assertNotNull(pdfBytes);
        assertTrue(pdfBytes.length > 500);
        String header = new String(pdfBytes, 0, 5);
        assertEquals("%PDF-", header);
    }

    @Test
    void testGenerateTicketPdfWithEnrichedScheduleAndMultiplePassengers() {
        Booking booking = new Booking();
        booking.setId(205L);
        booking.setPnr("SKY9988");
        booking.setBookingReference("SKYT-XYZ789");
        booking.setOriginCode("DEL");
        booking.setDestinationCode("BLR");
        booking.setTravelClass("Business");
        booking.setStatus("CONFIRMED");
        booking.setTotalAmount(new BigDecimal("18500.00"));
        booking.setContactEmail("executive@skytech.com");
        booking.setContactPhone("+919811223344");
        booking.setSeatNumbers("2A, 2B");

        // Enriched schedule
        FlightSchedule schedule = new FlightSchedule();
        schedule.setScheduleId(55);
        schedule.setFlightDate(Date.valueOf(LocalDate.now().plusDays(3)));

        Flight flight = new Flight();
        flight.setFlightNumber("SK-408");
        flight.setDurationMinutes(165);
        flight.setAircraftModel("Boeing 737 MAX 8");
        flight.setDepartureTime(Time.valueOf("09:30:00"));
        flight.setArrivalTime(Time.valueOf("12:15:00"));

        Airport src = new Airport();
        src.setAirportCode("DEL");
        src.setCity("New Delhi");
        src.setAirportName("Indira Gandhi International Airport");
        flight.setSourceAirport(src);

        Airport dest = new Airport();
        dest.setAirportCode("BLR");
        dest.setCity("Bengaluru");
        dest.setAirportName("Kempegowda International Airport");
        flight.setDestinationAirport(dest);

        schedule.setFlight(flight);
        booking.setSchedule(schedule);

        // Passengers with long names
        Passenger p1 = new Passenger("Dr. Alexander Christopher", "Montgomery-Smith", "ADULT", "2A");
        p1.setTicketNumber("098-205-001");
        Passenger p2 = new Passenger("Elizabeth Catherine", "Montgomery-Smith", "ADULT", "2B");
        p2.setTicketNumber("098-205-002");
        booking.addPassenger(p1);
        booking.addPassenger(p2);

        // Payment
        Payment payment = new Payment();
        payment.setPaymentMethod("Credit Card (Razorpay)");
        payment.setRazorpayPaymentId("pay_MockLive98765");
        payment.setStatus("CAPTURED");
        booking.setPayment(payment);

        byte[] pdfBytes = ticketService.generateTicketPdf(booking, null);
        assertNotNull(pdfBytes);
        assertTrue(pdfBytes.length > 1000);
        String header = new String(pdfBytes, 0, 5);
        assertEquals("%PDF-", header);
    }
}
