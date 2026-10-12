package com.skytech.airlines.booking.service;

import com.skytech.airlines.booking.dao.SeatAllocationDAO;
import com.skytech.airlines.booking.exception.SeatUnavailableException;
import com.skytech.airlines.booking.model.Seat;
import com.skytech.airlines.booking.model.SeatAllocation;
import com.skytech.airlines.booking.model.SeatClass;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;

/**
 * Service managing aircraft cabin layout, seat pricing surcharges, and conflict guards.
 */
public class SeatAllocationService {

    private final SeatAllocationDAO seatAllocationDAO;

    public SeatAllocationService() {
        this(new SeatAllocationDAO());
    }

    public SeatAllocationService(SeatAllocationDAO seatAllocationDAO) {
        this.seatAllocationDAO = seatAllocationDAO;
    }

    public List<Seat> getCabinSeatMap(Long flightId) {
        List<Seat> seats = new ArrayList<>(180);
        List<String> occupied = (flightId != null) ? seatAllocationDAO.getOccupiedSeatNumbers(flightId) : Collections.emptyList();
        Set<String> occupiedSet = new HashSet<>(occupied);

        char[] cols = {'A', 'B', 'C', 'D', 'E', 'F'};

        for (int row = 1; row <= 30; row++) {
            SeatClass sClass;
            BigDecimal surcharge;

            if (row <= 3) {
                sClass = SeatClass.BUSINESS;
                surcharge = new BigDecimal("1500.00");
            } else if (row >= 12 && row <= 14) {
                sClass = SeatClass.PREMIUM_ECONOMY;
                surcharge = new BigDecimal("500.00");
            } else {
                sClass = SeatClass.ECONOMY;
                surcharge = BigDecimal.ZERO;
            }

            for (char col : cols) {
                String seatNum = row + String.valueOf(col);
                Seat seat = new Seat(seatNum, row, col, sClass, surcharge);
                if (occupiedSet.contains(seatNum)) {
                    seat.setAvailable(false);
                    seat.setHeld(true);
                } else {
                    seat.setAvailable(true);
                    seat.setHeld(false);
                }
                seats.add(seat);
            }
        }
        return seats;
    }

    public SeatClass getClassForSeat(String seatNumber) {
        if (seatNumber == null || seatNumber.length() < 2) return SeatClass.ECONOMY;
        try {
            int row = Integer.parseInt(seatNumber.substring(0, seatNumber.length() - 1));
            if (row <= 3) return SeatClass.BUSINESS;
            if (row >= 12 && row <= 14) return SeatClass.PREMIUM_ECONOMY;
            return SeatClass.ECONOMY;
        } catch (NumberFormatException e) {
            return SeatClass.ECONOMY;
        }
    }

    public BigDecimal getFeeForSeat(String seatNumber) {
        SeatClass sc = getClassForSeat(seatNumber);
        return switch (sc) {
            case BUSINESS -> new BigDecimal("1500.00");
            case PREMIUM_ECONOMY -> new BigDecimal("500.00");
            case ECONOMY -> BigDecimal.ZERO;
        };
    }

    public void validateSeatSelections(Long flightId, List<String> selectedSeats, int expectedPassengerCount)
            throws SeatUnavailableException {
        if (selectedSeats == null || selectedSeats.size() != expectedPassengerCount) {
            throw new SeatUnavailableException("Seat count (" + (selectedSeats != null ? selectedSeats.size() : 0) +
                    ") does not match passenger count (" + expectedPassengerCount + ").");
        }

        Set<String> uniqueSeats = new HashSet<>(selectedSeats);
        if (uniqueSeats.size() != selectedSeats.size()) {
            throw new SeatUnavailableException("Duplicate seat assignments detected in request.");
        }

        List<String> occupied = (flightId != null) ? seatAllocationDAO.getOccupiedSeatNumbers(flightId) : Collections.emptyList();
        for (String seat : selectedSeats) {
            if (occupied.contains(seat)) {
                throw new SeatUnavailableException("Seat " + seat + " is no longer available. Please choose another seat.");
            }
        }
    }

    public void allocateSeatsForBooking(Long bookingId, Long flightId, List<String> seatNumbers, Connection conn)
            throws SQLException, SeatUnavailableException {
        if (seatNumbers == null || bookingId == null) return;

        for (String seatNum : seatNumbers) {
            SeatClass sc = getClassForSeat(seatNum);
            BigDecimal fee = getFeeForSeat(seatNum);
            SeatAllocation sa = new SeatAllocation(bookingId, null, flightId, seatNum, sc, fee, "HELD");
            seatAllocationDAO.allocateSeat(sa, conn);
        }
    }
}
