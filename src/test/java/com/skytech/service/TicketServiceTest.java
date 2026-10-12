package com.skytech.service;

import com.skytech.model.Booking;
import com.skytech.model.Passenger;
import com.skytech.model.Ticket;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
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
}
