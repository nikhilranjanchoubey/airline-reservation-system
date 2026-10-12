package com.skytech.airlines.booking;

import com.skytech.airlines.booking.dao.SeatAllocationDAO;
import com.skytech.airlines.booking.exception.SeatUnavailableException;
import com.skytech.airlines.booking.model.Seat;
import com.skytech.airlines.booking.model.SeatClass;
import com.skytech.airlines.booking.service.SeatAllocationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class SeatAllocationTest {

    private StubSeatAllocationDAO stubDAO;
    private SeatAllocationService seatAllocationService;

    static class StubSeatAllocationDAO extends SeatAllocationDAO {
        List<String> occupied = new ArrayList<>();
        @Override
        public List<String> getOccupiedSeatNumbers(Long flightId) {
            return occupied;
        }
    }

    @BeforeEach
    void setUp() {
        stubDAO = new StubSeatAllocationDAO();
        seatAllocationService = new SeatAllocationService(stubDAO);
    }

    @Test
    @DisplayName("Should generate complete 180 seats cabin layout")
    void testCabinLayout() {
        stubDAO.occupied = Collections.emptyList();
        List<Seat> seats = seatAllocationService.getCabinSeatMap(101L);
        assertNotNull(seats);
        assertEquals(180, seats.size());
    }

    @Test
    @DisplayName("Should categorize business seats and pricing correctly")
    void testBusinessSeats() {
        assertEquals(SeatClass.BUSINESS, seatAllocationService.getClassForSeat("1A"));
        assertTrue(seatAllocationService.getFeeForSeat("1A").compareTo(BigDecimal.ZERO) > 0);
    }

    @Test
    @DisplayName("Should categorize economy seats with zero fee")
    void testEconomySeats() {
        assertEquals(SeatClass.ECONOMY, seatAllocationService.getClassForSeat("4A"));
        assertEquals(BigDecimal.ZERO, seatAllocationService.getFeeForSeat("4A"));
    }

    @Test
    @DisplayName("Should reject duplicate seat assignments")
    void testDuplicateSeats() {
        assertThrows(SeatUnavailableException.class, () -> {
            seatAllocationService.validateSeatSelections(101L, Arrays.asList("1A", "1A"), 2);
        });
    }

    @Test
    @DisplayName("Should reject already occupied seats")
    void testOccupiedSeat() {
        stubDAO.occupied = Collections.singletonList("12A");
        assertThrows(SeatUnavailableException.class, () -> {
            seatAllocationService.validateSeatSelections(101L, Collections.singletonList("12A"), 1);
        });
    }
}
