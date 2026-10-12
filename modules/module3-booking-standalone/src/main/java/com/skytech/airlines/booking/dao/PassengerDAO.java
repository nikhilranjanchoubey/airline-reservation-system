package com.skytech.airlines.booking.dao;

import com.skytech.airlines.booking.model.Passenger;
import com.skytech.airlines.booking.model.PassengerType;
import com.skytech.airlines.booking.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PassengerDAO {
    private static final Logger LOGGER = Logger.getLogger(PassengerDAO.class.getName());

    public Long save(Passenger p, Connection conn) throws SQLException {
        String sql = "INSERT INTO passengers (booking_id, first_name, last_name, date_of_birth, gender, " +
                     "passenger_type, passport_or_id, nationality, seat_number) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (p.getBookingId() != null) ps.setLong(1, p.getBookingId());
            else ps.setNull(1, Types.BIGINT);
            ps.setString(2, p.getFirstName());
            ps.setString(3, p.getLastName());
            ps.setDate(4, Date.valueOf(p.getDateOfBirth()));
            ps.setString(5, p.getGender());
            ps.setString(6, p.getPassengerType() != null ? p.getPassengerType().name() : "ADULT");
            ps.setString(7, p.getPassportOrId());
            ps.setString(8, p.getNationality());
            ps.setString(9, p.getSeatNumber());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    p.setPassengerId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public List<Passenger> findByBookingId(Long bookingId) {
        List<Passenger> list = new ArrayList<>();
        String sql = "SELECT passenger_id, booking_id, first_name, last_name, date_of_birth, gender, " +
                     "passenger_type, passport_or_id, nationality, seat_number FROM passengers WHERE booking_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Passenger p = new Passenger();
                    p.setPassengerId(rs.getLong("passenger_id"));
                    p.setBookingId(rs.getLong("booking_id"));
                    p.setFirstName(rs.getString("first_name"));
                    p.setLastName(rs.getString("last_name"));
                    Date d = rs.getDate("date_of_birth");
                    if (d != null) p.setDateOfBirth(d.toLocalDate());
                    p.setGender(rs.getString("gender"));
                    String typeStr = rs.getString("passenger_type");
                    if (typeStr != null) {
                        try { p.setPassengerType(PassengerType.valueOf(typeStr)); } catch (Exception ignored) {}
                    }
                    p.setPassportOrId(rs.getString("passport_or_id"));
                    p.setNationality(rs.getString("nationality"));
                    p.setSeatNumber(rs.getString("seat_number"));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Notice finding passengers for booking: " + bookingId, e);
        }
        return list;
    }
}
