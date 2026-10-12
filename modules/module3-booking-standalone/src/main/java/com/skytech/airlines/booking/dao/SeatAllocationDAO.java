package com.skytech.airlines.booking.dao;

import com.skytech.airlines.booking.model.SeatAllocation;
import com.skytech.airlines.booking.model.SeatClass;
import com.skytech.airlines.booking.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class SeatAllocationDAO {
    private static final Logger LOGGER = Logger.getLogger(SeatAllocationDAO.class.getName());

    public void allocateSeat(SeatAllocation sa, Connection conn) throws SQLException {
        String sql = "INSERT INTO seat_allocations (booking_id, passenger_id, flight_id, seat_number, " +
                     "seat_class, seat_price, allocation_status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, sa.getBookingId());
            if (sa.getPassengerId() != null) ps.setLong(2, sa.getPassengerId());
            else ps.setNull(2, Types.BIGINT);
            ps.setLong(3, sa.getFlightId());
            ps.setString(4, sa.getSeatNumber());
            ps.setString(5, sa.getSeatClass() != null ? sa.getSeatClass().name() : "ECONOMY");
            ps.setBigDecimal(6, sa.getSeatPrice());
            ps.setString(7, sa.getAllocationStatus() != null ? sa.getAllocationStatus() : "HELD");
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    sa.setAllocationId(rs.getLong(1));
                }
            }
        }
    }

    public List<String> getOccupiedSeatNumbers(Long flightId) {
        List<String> list = new ArrayList<>();
        if (flightId == null) return list;

        String sql = "SELECT seat_number FROM seat_allocations WHERE flight_id = ? AND allocation_status IN ('HELD', 'ALLOCATED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, flightId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getString("seat_number"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Notice querying occupied seats for flight: " + flightId, e);
        }
        return list;
    }

    public List<SeatAllocation> findByBookingId(Long bookingId) {
        List<SeatAllocation> list = new ArrayList<>();
        String sql = "SELECT allocation_id, booking_id, passenger_id, flight_id, seat_number, " +
                     "seat_class, seat_price, allocation_status, allocated_at FROM seat_allocations WHERE booking_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SeatAllocation sa = new SeatAllocation();
                    sa.setAllocationId(rs.getLong("allocation_id"));
                    sa.setBookingId(rs.getLong("booking_id"));
                    sa.setPassengerId(rs.getLong("passenger_id"));
                    sa.setFlightId(rs.getLong("flight_id"));
                    sa.setSeatNumber(rs.getString("seat_number"));
                    String sc = rs.getString("seat_class");
                    if (sc != null) {
                        try { sa.setSeatClass(SeatClass.valueOf(sc)); } catch (Exception ignored) {}
                    }
                    sa.setSeatPrice(rs.getBigDecimal("seat_price"));
                    sa.setAllocationStatus(rs.getString("allocation_status"));
                    Timestamp ts = rs.getTimestamp("allocated_at");
                    if (ts != null) sa.setAllocatedAt(ts.toLocalDateTime());
                    list.add(sa);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Notice finding seat allocations: " + bookingId, e);
        }
        return list;
    }

    public boolean updateStatusForBooking(Long bookingId, String newStatus, Connection conn) throws SQLException {
        String sql = "UPDATE seat_allocations SET allocation_status = ? WHERE booking_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setLong(2, bookingId);
            return ps.executeUpdate() > 0;
        }
    }
}
