package com.skytech.airlines.booking.dao;

import com.skytech.airlines.booking.model.Booking;
import com.skytech.airlines.booking.model.BookingStatus;
import com.skytech.airlines.booking.model.Passenger;
import com.skytech.airlines.booking.model.SeatAllocation;
import com.skytech.airlines.booking.model.Payment;
import com.skytech.airlines.booking.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class BookingDAO {
    private static final Logger LOGGER = Logger.getLogger(BookingDAO.class.getName());

    private final PassengerDAO passengerDAO = new PassengerDAO();
    private final SeatAllocationDAO seatAllocationDAO = new SeatAllocationDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    public boolean pnrExists(String pnr) {
        if (pnr == null) return false;
        String sql = "SELECT 1 FROM bookings WHERE pnr = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, pnr);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Notice checking PNR: " + pnr, e);
            return false;
        }
    }

    public Long save(Booking b, Connection conn) throws SQLException {
        String sql = "INSERT INTO bookings (pnr, user_id, flight_id, booking_status, base_fare, seat_fees, " +
                     "tax_amount, total_amount, contact_email, contact_phone) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, b.getPnr());
            if (b.getUserId() != null) ps.setLong(2, b.getUserId());
            else ps.setNull(2, Types.BIGINT);
            ps.setLong(3, b.getFlightId());
            ps.setString(4, b.getBookingStatus() != null ? b.getBookingStatus().name() : "PENDING");
            ps.setBigDecimal(5, b.getBaseFare());
            ps.setBigDecimal(6, b.getSeatFees());
            ps.setBigDecimal(7, b.getTaxAmount());
            ps.setBigDecimal(8, b.getTotalAmount());
            ps.setString(9, b.getContactEmail());
            ps.setString(10, b.getContactPhone());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    b.setBookingId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public Booking findByPnr(String pnr) {
        if (pnr == null) return null;
        String sql = "SELECT booking_id, pnr, user_id, flight_id, booking_date, booking_status, base_fare, " +
                     "seat_fees, tax_amount, total_amount, contact_email, contact_phone, created_at FROM bookings WHERE pnr = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, pnr.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Booking b = mapRow(rs);
                    hydrateAssociations(b);
                    return b;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Notice finding booking by PNR: " + pnr, e);
        }
        return null;
    }

    public List<Booking> findByUserId(Long userId) {
        List<Booking> list = new ArrayList<>();
        if (userId == null) return list;
        String sql = "SELECT booking_id, pnr, user_id, flight_id, booking_date, booking_status, base_fare, " +
                     "seat_fees, tax_amount, total_amount, contact_email, contact_phone, created_at FROM bookings WHERE user_id = ? ORDER BY booking_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking b = mapRow(rs);
                    hydrateAssociations(b);
                    list.add(b);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Notice finding bookings for user: " + userId, e);
        }
        return list;
    }

    public List<Booking> findAllBookings() {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT booking_id, pnr, user_id, flight_id, booking_date, booking_status, base_fare, " +
                     "seat_fees, tax_amount, total_amount, contact_email, contact_phone, created_at FROM bookings ORDER BY booking_date DESC LIMIT 100";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Booking b = mapRow(rs);
                hydrateAssociations(b);
                list.add(b);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Notice finding all bookings: " + e.getMessage());
        }
        return list;
    }

    public boolean updateBookingStatus(Long bookingId, BookingStatus newStatus) {
        String sql = "UPDATE bookings SET booking_status = ? WHERE booking_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus.name());
            ps.setLong(2, bookingId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Notice updating status: " + e.getMessage());
            return false;
        }
    }

    public boolean updateBookingStatus(Long bookingId, BookingStatus newStatus, Connection conn) throws SQLException {
        String sql = "UPDATE bookings SET booking_status = ? WHERE booking_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus.name());
            ps.setLong(2, bookingId);
            return ps.executeUpdate() > 0;
        }
    }

    private Booking mapRow(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setBookingId(rs.getLong("booking_id"));
        b.setPnr(rs.getString("pnr"));
        long uid = rs.getLong("user_id");
        if (!rs.wasNull()) b.setUserId(uid);
        b.setFlightId(rs.getLong("flight_id"));
        Timestamp bd = rs.getTimestamp("booking_date");
        if (bd != null) b.setBookingDate(bd.toLocalDateTime());
        String st = rs.getString("booking_status");
        if (st != null) {
            try { b.setBookingStatus(BookingStatus.valueOf(st)); } catch (Exception ignored) {}
        }
        b.setBaseFare(rs.getBigDecimal("base_fare"));
        b.setSeatFees(rs.getBigDecimal("seat_fees"));
        b.setTaxAmount(rs.getBigDecimal("tax_amount"));
        b.setTotalAmount(rs.getBigDecimal("total_amount"));
        b.setContactEmail(rs.getString("contact_email"));
        b.setContactPhone(rs.getString("contact_phone"));
        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) b.setCreatedAt(cat.toLocalDateTime());
        return b;
    }

    private void hydrateAssociations(Booking b) {
        if (b == null || b.getBookingId() == null) return;
        b.setPassengers(passengerDAO.findByBookingId(b.getBookingId()));
        b.setSeatAllocations(seatAllocationDAO.findByBookingId(b.getBookingId()));
        b.setPayment(paymentDAO.findByBookingId(b.getBookingId()));
    }
}
