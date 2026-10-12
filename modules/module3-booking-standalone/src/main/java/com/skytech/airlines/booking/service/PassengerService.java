package com.skytech.airlines.booking.service;

import com.skytech.airlines.booking.dao.PassengerDAO;
import com.skytech.airlines.booking.exception.InvalidPassengerException;
import com.skytech.airlines.booking.model.Passenger;
import com.skytech.airlines.booking.util.ValidationUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

/**
 * Service managing passenger profile validation and persistence.
 */
public class PassengerService {
    private final PassengerDAO passengerDAO;

    public PassengerService() {
        this(new PassengerDAO());
    }

    public PassengerService(PassengerDAO passengerDAO) {
        this.passengerDAO = passengerDAO;
    }

    public void validatePassengerList(List<Passenger> passengers, String contactEmail, String contactPhone)
            throws InvalidPassengerException {
        ValidationUtil.validatePassengerList(passengers, contactEmail, contactPhone);
    }

    public void savePassengersForBooking(Long bookingId, List<Passenger> passengers, Connection conn)
            throws SQLException {
        if (passengers == null || bookingId == null) return;
        for (Passenger p : passengers) {
            p.setBookingId(bookingId);
            passengerDAO.save(p, conn);
        }
    }
}
