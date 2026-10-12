package com.skytech.dao;

import com.skytech.model.Booking;
import com.skytech.model.Passenger;
import com.skytech.util.DBConnectionUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for flight bookings and reservations.
 */
public class BookingDao {

    private static final Logger LOGGER = Logger.getLogger(BookingDao.class.getName());

    /**
     * Creates a new pending booking with associated passenger records inside a transaction.
     */
    public boolean createBooking(Booking booking, List<Passenger> passengers) {
        String insertBookingSql = "INSERT INTO bookings (booking_reference, user_id, schedule_id, flight_number, " +
                "travel_class, seat_numbers, contact_email, contact_phone, pnr, provider, origin_code, " +
                "destination_code, departure_date, status, total_amount, currency) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String insertPassengerSql = "INSERT INTO passengers (booking_id, first_name, last_name, " +
                "date_of_birth, gender, passport_number, nationality, passenger_type, seat_number) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(insertBookingSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, booking.getBookingReference());
                if (booking.getUserId() != null) {
                    ps.setLong(2, booking.getUserId());
                } else {
                    ps.setNull(2, Types.BIGINT);
                }
                if (booking.getScheduleId() != null) {
                    ps.setInt(3, booking.getScheduleId());
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                ps.setString(4, booking.getFlightNumber());
                ps.setString(5, booking.getTravelClass());
                ps.setString(6, booking.getSeatNumbers());
                ps.setString(7, booking.getContactEmail());
                ps.setString(8, booking.getContactPhone());
                ps.setString(9, booking.getPnr());
                ps.setString(10, booking.getProvider());
                ps.setString(11, booking.getOriginCode());
                ps.setString(12, booking.getDestinationCode());
                ps.setDate(13, booking.getDepartureDate() != null ? Date.valueOf(booking.getDepartureDate()) : Date.valueOf(LocalDate.now()));
                ps.setString(14, booking.getStatus());
                ps.setBigDecimal(15, booking.getTotalAmount() != null ? booking.getTotalAmount() : BigDecimal.ZERO);
                ps.setString(16, booking.getCurrency() != null ? booking.getCurrency() : "INR");

                int affected = ps.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    return false;
                }

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        booking.setId(rs.getLong(1));
                    }
                }
            }

            if (passengers != null && !passengers.isEmpty()) {
                try (PreparedStatement psPass = conn.prepareStatement(insertPassengerSql, Statement.RETURN_GENERATED_KEYS)) {
                    for (Passenger p : passengers) {
                        psPass.setLong(1, booking.getId());
                        psPass.setString(2, p.getFirstName());
                        psPass.setString(3, p.getLastName());
                        if (p.getDateOfBirth() != null) {
                            psPass.setDate(4, Date.valueOf(p.getDateOfBirth()));
                        } else {
                            psPass.setNull(4, Types.DATE);
                        }
                        psPass.setString(5, p.getGender());
                        psPass.setString(6, p.getPassportNumber());
                        psPass.setString(7, p.getNationality());
                        psPass.setString(8, p.getPassengerType() != null ? p.getPassengerType() : "ADULT");
                        psPass.setString(9, p.getSeatNumber());
                        psPass.addBatch();
                    }
                    psPass.executeBatch();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to create booking transactionally: " + e.getMessage(), e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback failed: " + ex.getMessage(), ex);
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    /**
     * Finds a booking by its primary ID and populates passengers.
     */
    public Booking getBookingById(long id) {
        String sql = "SELECT * FROM bookings WHERE id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Booking booking = mapBooking(rs);
                    booking.setPassengers(getPassengersByBookingId(booking.getId()));
                    return booking;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve booking by id [" + id + "]: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Finds a booking by its booking reference or PNR.
     */
    public Booking getBookingByReferenceOrPnr(String refOrPnr) {
        if (refOrPnr == null || refOrPnr.trim().isEmpty()) return null;
        String trimmed = refOrPnr.trim().toUpperCase();
        String sql = "SELECT * FROM bookings WHERE UPPER(booking_reference) = ? OR UPPER(pnr) = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trimmed);
            ps.setString(2, trimmed);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Booking booking = mapBooking(rs);
                    booking.setPassengers(getPassengersByBookingId(booking.getId()));
                    return booking;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve booking by ref/pnr [" + refOrPnr + "]: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Retrieves all bookings for a specific user ID.
     */
    public List<Booking> getBookingsByUserId(long userId) {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT * FROM bookings WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking b = mapBooking(rs);
                    b.setPassengers(getPassengersByBookingId(b.getId()));
                    list.add(b);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve bookings for user [" + userId + "]: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Retrieves all bookings across the platform for administrative oversight.
     */
    public List<Booking> getAllBookings() {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT * FROM bookings ORDER BY created_at DESC";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Booking b = mapBooking(rs);
                b.setPassengers(getPassengersByBookingId(b.getId()));
                list.add(b);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve all bookings: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Updates the status of a booking.
     */
    public boolean updateBookingStatus(long id, String status) {
        String sql = "UPDATE bookings SET status = ? WHERE id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update booking status: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Confirms a booking with its generated PNR and updates status to CONFIRMED.
     */
    public boolean confirmBooking(long id, String pnr) {
        String sql = "UPDATE bookings SET status = 'CONFIRMED', pnr = ? WHERE id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, pnr);
            ps.setLong(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to confirm booking: " + e.getMessage(), e);
            return false;
        }
    }

    public List<Passenger> getPassengersByBookingId(long bookingId) {
        List<Passenger> list = new ArrayList<>();
        String sql = "SELECT * FROM passengers WHERE booking_id = ? ORDER BY id ASC";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Passenger p = new Passenger();
                    p.setId(rs.getLong("id"));
                    p.setBookingId(rs.getLong("booking_id"));
                    p.setFirstName(rs.getString("first_name"));
                    p.setLastName(rs.getString("last_name"));
                    Date dob = rs.getDate("date_of_birth");
                    if (dob != null) p.setDateOfBirth(dob.toLocalDate());
                    p.setGender(rs.getString("gender"));
                    p.setPassportNumber(rs.getString("passport_number"));
                    p.setNationality(rs.getString("nationality"));
                    p.setPassengerType(rs.getString("passenger_type"));
                    p.setSeatNumber(rs.getString("seat_number"));
                    p.setTicketNumber(rs.getString("ticket_number"));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve passengers for booking [" + bookingId + "]: " + e.getMessage(), e);
        }
        return list;
    }

    // Analytics / Metrics for Admin Dashboard

    public int countTotalBookings() {
        return getCount("SELECT COUNT(*) FROM bookings");
    }

    public int countConfirmedBookings() {
        return getCount("SELECT COUNT(*) FROM bookings WHERE status = 'CONFIRMED'");
    }

    public int countPendingBookings() {
        return getCount("SELECT COUNT(*) FROM bookings WHERE status IN ('PENDING', 'PENDING_PAYMENT')");
    }

    public int countCancelledBookings() {
        return getCount("SELECT COUNT(*) FROM bookings WHERE status IN ('CANCELLED', 'REFUNDED')");
    }

    public BigDecimal calculateTotalRevenue() {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) FROM bookings WHERE status = 'CONFIRMED'";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to calculate verified revenue: " + e.getMessage(), e);
        }
        return BigDecimal.ZERO;
    }

    private int getCount(String sql) {
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to execute count query: " + e.getMessage(), e);
        }
        return 0;
    }

    private Booking mapBooking(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setId(rs.getLong("id"));
        b.setBookingReference(rs.getString("booking_reference"));
        long uId = rs.getLong("user_id");
        if (!rs.wasNull()) b.setUserId(uId);
        int sId = rs.getInt("schedule_id");
        if (!rs.wasNull()) b.setScheduleId(sId);
        b.setFlightNumber(rs.getString("flight_number"));
        b.setTravelClass(rs.getString("travel_class"));
        b.setSeatNumbers(rs.getString("seat_numbers"));
        b.setContactEmail(rs.getString("contact_email"));
        b.setContactPhone(rs.getString("contact_phone"));
        b.setPnr(rs.getString("pnr"));
        b.setProvider(rs.getString("provider"));
        b.setProviderOrderId(rs.getString("provider_order_id"));
        b.setOriginCode(rs.getString("origin_code"));
        b.setDestinationCode(rs.getString("destination_code"));
        Date dDate = rs.getDate("departure_date");
        if (dDate != null) b.setDepartureDate(dDate.toLocalDate());
        b.setStatus(rs.getString("status"));
        b.setTotalAmount(rs.getBigDecimal("total_amount"));
        b.setCurrency(rs.getString("currency"));
        b.setCreatedAt(rs.getTimestamp("created_at"));
        return b;
    }
}
