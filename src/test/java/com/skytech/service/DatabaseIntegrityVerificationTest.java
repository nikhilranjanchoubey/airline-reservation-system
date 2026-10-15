package com.skytech.service;

import com.airline.init.DatabaseInitializer;
import com.airline.model.Role;
import com.airline.model.User;
import com.skytech.dao.BookingDao;
import com.skytech.dao.SeatDao;
import com.skytech.dao.TicketDao;
import com.skytech.model.Booking;
import com.skytech.model.Flight;
import com.skytech.model.FlightSchedule;
import com.skytech.model.Passenger;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

public class DatabaseIntegrityVerificationTest {

    @Test
    public void testSchemaHasCorrectColumnNameInFileAndClasspath() throws Exception {
        // 1. Verify filesystem copy
        Path schemaPath = Path.of("database", "schema.sql");
        assertTrue(Files.exists(schemaPath), "database/schema.sql must exist");
        String schemaContent = Files.readString(schemaPath, StandardCharsets.UTF_8);

        assertFalse(schemaContent.contains("premiumEconomy_price"),
                "database/schema.sql must not contain misspelled 'premiumEconomy_price'");
        assertTrue(schemaContent.contains("premium_economy_price"),
                "database/schema.sql must contain correct column name 'premium_economy_price'");

        // 2. Verify classpath copy
        try (InputStream in = getClass().getClassLoader().getResourceAsStream("database/schema.sql")) {
            assertNotNull(in, "Classpath database/schema.sql must exist");
            String cpContent = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            assertFalse(cpContent.contains("premiumEconomy_price"),
                    "Classpath database/schema.sql must not contain 'premiumEconomy_price'");
            assertTrue(cpContent.contains("premium_economy_price"),
                    "Classpath database/schema.sql must contain 'premium_economy_price'");
        }
    }

    @Test
    public void testAllRequiredTablesDefinedInSchema() throws Exception {
        String schema = Files.readString(Path.of("database", "schema.sql"), StandardCharsets.UTF_8);

        List<String> requiredTables = Arrays.asList(DatabaseInitializer.REQUIRED_TABLES);
        assertEquals(15, requiredTables.size(), "Must require exactly 15 master tables");

        for (String table : requiredTables) {
            String pattern = "CREATE TABLE IF NOT EXISTS " + table;
            assertTrue(schema.contains(pattern), "Schema must define table: " + table);
        }
    }

    @Test
    public void testBookingServiceAssignsProviderBeforePersistence() throws Exception {
        BookingDao bookingDao = mock(BookingDao.class);
        SeatDao seatDao = mock(SeatDao.class);
        TicketDao ticketDao = mock(TicketDao.class);
        FlightSearchService flightSearchService = mock(FlightSearchService.class);

        FlightSchedule schedule = new FlightSchedule();
        schedule.setScheduleId(1);
        schedule.setFlightDate(java.sql.Date.valueOf(LocalDate.now()));
        schedule.setEconomyPrice(new BigDecimal("4000.00"));
        Flight flight = new Flight();
        flight.setFlightNumber("6E-204");
        com.skytech.model.Airport src = new com.skytech.model.Airport();
        src.setAirportCode("DEL");
        flight.setSourceAirport(src);
        com.skytech.model.Airport dest = new com.skytech.model.Airport();
        dest.setAirportCode("BOM");
        flight.setDestinationAirport(dest);
        schedule.setFlight(flight);

        when(flightSearchService.getFlightDetails(1, null)).thenReturn(schedule);
        when(bookingDao.createBooking(any(Booking.class), anyList())).thenReturn(true);

        BookingService service = new BookingService(bookingDao, seatDao, ticketDao, null, null, flightSearchService);

        User user = new User();
        user.setUserId(2);
        user.setEmail("passenger@airline.com");
        user.setRole(Role.PASSENGER);

        List<Passenger> passengers = new ArrayList<>();
        Passenger p = new Passenger();
        p.setFirstName("Ramesh");
        p.setLastName("Kumar");
        passengers.add(p);

        Booking booking = service.createPendingBooking(user, 1, "Economy", passengers, null, "passenger@airline.com", "+91 999 777 8888");

        assertNotNull(booking);
        assertEquals("LOCAL_CATALOG", booking.getProvider(), "Booking must explicitly have provider set to LOCAL_CATALOG");

        ArgumentCaptor<Booking> captor = ArgumentCaptor.forClass(Booking.class);
        verify(bookingDao).createBooking(captor.capture(), anyList());
        assertEquals("LOCAL_CATALOG", captor.getValue().getProvider(), "Persisted booking must have LOCAL_CATALOG provider");
    }

    @Test
    public void testRameshKumarInDatabaseInitializerDemoAccount() {
        assertEquals("passenger@airline.com", DatabaseInitializer.DEMO_PASSENGER_EMAIL);
        assertEquals("Passenger@12345", DatabaseInitializer.DEMO_PASSENGER_PASS);
        assertNotNull(DatabaseInitializer.DEMO_PASSENGER_SALT);
    }
}
