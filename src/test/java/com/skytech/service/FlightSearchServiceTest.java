package com.skytech.service;

import com.skytech.dao.AirportDao;
import com.skytech.integration.FlightProvider;
import com.skytech.model.Airport;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class FlightSearchServiceTest {

    static class StubAirportDao extends AirportDao {
        private final List<Airport> airports;

        public StubAirportDao(List<Airport> airports) {
            this.airports = airports;
        }

        @Override
        public List<Airport> getAllAirports() {
            return airports;
        }

        @Override
        public Airport getAirportByCode(String code) {
            return airports.stream()
                    .filter(a -> a.getAirportCode().equalsIgnoreCase(code))
                    .findFirst()
                    .orElse(null);
        }
    }

    @Mock
    private FlightProvider flightProvider;

    private StubAirportDao airportDao;
    private FlightSearchService flightSearchService;

    @BeforeEach
    void setUp() {
        Airport a1 = new Airport("DEL", "Indira Gandhi International Airport", "New Delhi", "India", "T3");
        Airport a2 = new Airport("BOM", "Chhatrapati Shivaji Maharaj International Airport", "Mumbai", "India", "T2");
        airportDao = new StubAirportDao(new ArrayList<>(Arrays.asList(a1, a2)));
        flightSearchService = new FlightSearchService(airportDao, flightProvider);
    }

    @Test
    void testValidSearchCriteria() {
        LocalDate tomorrow = LocalDate.now().plusDays(1);
        List<String> errors = flightSearchService.validateSearchCriteria(
                "DEL", "BOM", tomorrow.toString(), "one-way", null, 1, 0, 0);
        assertTrue(errors.isEmpty(), "Valid search criteria should produce 0 errors");
    }

    @Test
    void testSameSourceAndDestinationRejected() {
        LocalDate tomorrow = LocalDate.now().plusDays(1);
        List<String> errors = flightSearchService.validateSearchCriteria(
                "DEL", "DEL", tomorrow.toString(), "one-way", null, 1, 0, 0);
        assertFalse(errors.isEmpty());
        assertTrue(errors.contains("Departure and arrival airports cannot be the same."));
    }

    @Test
    void testMissingRequiredParameters() {
        List<String> errors = flightSearchService.validateSearchCriteria(
                null, "", "", "one-way", null, 0, 0, 0);
        assertFalse(errors.isEmpty());
        assertTrue(errors.contains("Departure airport is required."));
        assertTrue(errors.contains("Arrival airport is required."));
        assertTrue(errors.contains("Departure date is required."));
        assertTrue(errors.contains("At least 1 adult passenger is required."));
    }

    @Test
    void testPastDepartureDateRejected() {
        LocalDate yesterday = LocalDate.now().minusDays(1);
        List<String> errors = flightSearchService.validateSearchCriteria(
                "DEL", "BOM", yesterday.toString(), "one-way", null, 1, 0, 0);
        assertFalse(errors.isEmpty());
        assertTrue(errors.contains("Please select today or a future date."));
    }

    @Test
    void testRoundTripReturnBeforeDepartureRejected() {
        LocalDate dep = LocalDate.now().plusDays(5);
        LocalDate ret = LocalDate.now().plusDays(2);
        List<String> errors = flightSearchService.validateSearchCriteria(
                "DEL", "BOM", dep.toString(), "round-trip", ret.toString(), 1, 0, 0);
        assertFalse(errors.isEmpty());
        assertTrue(errors.contains("Return date must be on or after the departure date."));
    }

    @Test
    void testInfantsExceedingAdultsRejected() {
        LocalDate dep = LocalDate.now().plusDays(3);
        List<String> errors = flightSearchService.validateSearchCriteria(
                "DEL", "BOM", dep.toString(), "one-way", null, 1, 0, 2);
        assertFalse(errors.isEmpty());
        assertTrue(errors.contains("Number of infants cannot exceed the number of adult passengers."));
    }

    @Test
    void testSearchAirportsMatching() {
        List<Airport> results = flightSearchService.searchAirports("Delhi");
        assertEquals(1, results.size());
        assertEquals("DEL", results.get(0).getAirportCode());
    }
}
