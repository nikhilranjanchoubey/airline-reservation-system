package com.skytech.dao;

import com.skytech.util.DBConnectionUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Admin Reservations & Booking Registry:
 * supports dynamic searching, status filters, passenger manifest loading, and ticket lookups.
 */
public class AdminBookingDao {

    private static final Logger LOGGER = Logger.getLogger(AdminBookingDao.class.getName());

    public List<Map<String, Object>> searchBookings(String search, String status, String flightNumber,
                                                    String fromDate, String toDate, int page, int pageSize) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT b.id, b.booking_reference, b.pnr, b.user_id, b.flight_number, " +
                "b.origin_code, b.destination_code, b.departure_date, b.travel_class, " +
                "b.seat_numbers, b.contact_email, b.contact_phone, b.status, b.total_amount, " +
                "b.currency, b.created_at, " +
                "(SELECT COUNT(*) FROM passengers p WHERE p.booking_id = b.id) AS passenger_count, " +
                "(SELECT p.first_name FROM passengers p WHERE p.booking_id = b.id ORDER BY p.id ASC LIMIT 1) AS primary_first_name, " +
                "(SELECT p.last_name FROM passengers p WHERE p.booking_id = b.id ORDER BY p.id ASC LIMIT 1) AS primary_last_name, " +
                "(SELECT pay.status FROM payments pay WHERE pay.booking_id = b.id ORDER BY pay.id DESC LIMIT 1) AS payment_status, " +
                "(SELECT pay.razorpay_payment_id FROM payments pay WHERE pay.booking_id = b.id ORDER BY pay.id DESC LIMIT 1) AS razorpay_payment_id " +
                "FROM bookings b WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(b.booking_reference) LIKE ? OR LOWER(COALESCE(b.pnr, '')) LIKE ? OR LOWER(b.contact_email) LIKE ?) ");
            String q = "%" + search.trim().toLowerCase() + "%";
            params.add(q);
            params.add(q);
            params.add(q);
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND b.status = ? ");
            params.add(status.trim().toUpperCase());
        }

        if (flightNumber != null && !flightNumber.trim().isEmpty() && !"ALL".equalsIgnoreCase(flightNumber)) {
            sql.append(" AND b.flight_number = ? ");
            params.add(flightNumber.trim().toUpperCase());
        }

        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND b.departure_date >= ? ");
            params.add(Date.valueOf(fromDate.trim()));
        }

        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND b.departure_date <= ? ");
            params.add(Date.valueOf(toDate.trim()));
        }

        sql.append(" ORDER BY b.created_at DESC LIMIT ? OFFSET ?");
        int offset = Math.max(0, (page - 1) * pageSize);
        params.add(pageSize);
        params.add(offset);

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getLong("id"));
                    map.put("bookingReference", rs.getString("booking_reference"));
                    map.put("pnr", rs.getString("pnr"));
                    map.put("userId", rs.getObject("user_id"));
                    map.put("flightNumber", rs.getString("flight_number"));
                    map.put("originCode", rs.getString("origin_code"));
                    map.put("destCode", rs.getString("destination_code"));
                    map.put("departureDate", rs.getDate("departure_date"));
                    map.put("travelClass", rs.getString("travel_class"));
                    map.put("seatNumbers", rs.getString("seat_numbers"));
                    map.put("contactEmail", rs.getString("contact_email"));
                    map.put("contactPhone", rs.getString("contact_phone"));
                    map.put("status", rs.getString("status"));
                    map.put("totalAmount", rs.getBigDecimal("total_amount"));
                    map.put("currency", rs.getString("currency"));
                    map.put("createdAt", rs.getTimestamp("created_at"));
                    map.put("passengerCount", rs.getInt("passenger_count"));

                    String first = rs.getString("primary_first_name");
                    String last = rs.getString("primary_last_name");
                    String fullName = (first != null ? first : "") + (last != null ? " " + last : "");
                    map.put("passengerName", fullName.trim().isEmpty() ? "Passenger" : fullName.trim());

                    map.put("paymentStatus", rs.getString("payment_status"));
                    map.put("razorpayPaymentId", rs.getString("razorpay_payment_id"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to search bookings: " + e.getMessage(), e);
        }
        return list;
    }

    public int countBookings(String search, String status, String flightNumber, String fromDate, String toDate) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM bookings b WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(b.booking_reference) LIKE ? OR LOWER(COALESCE(b.pnr, '')) LIKE ? OR LOWER(b.contact_email) LIKE ?) ");
            String q = "%" + search.trim().toLowerCase() + "%";
            params.add(q);
            params.add(q);
            params.add(q);
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND b.status = ? ");
            params.add(status.trim().toUpperCase());
        }

        if (flightNumber != null && !flightNumber.trim().isEmpty() && !"ALL".equalsIgnoreCase(flightNumber)) {
            sql.append(" AND b.flight_number = ? ");
            params.add(flightNumber.trim().toUpperCase());
        }

        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND b.departure_date >= ? ");
            params.add(Date.valueOf(fromDate.trim()));
        }

        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND b.departure_date <= ? ");
            params.add(Date.valueOf(toDate.trim()));
        }

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to count bookings: " + e.getMessage(), e);
        }
        return 0;
    }

    public Map<String, Object> getBookingFullDetails(long bookingId) {
        Map<String, Object> details = new HashMap<>();
        String bSql = "SELECT b.*, u.first_name AS user_first, u.last_name AS user_last, u.email AS user_email " +
                      "FROM bookings b LEFT JOIN users u ON b.user_id = u.user_id WHERE b.id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(bSql)) {
            ps.setLong(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    details.put("id", rs.getLong("id"));
                    details.put("bookingReference", rs.getString("booking_reference"));
                    details.put("pnr", rs.getString("pnr"));
                    details.put("flightNumber", rs.getString("flight_number"));
                    details.put("originCode", rs.getString("origin_code"));
                    details.put("destCode", rs.getString("destination_code"));
                    details.put("departureDate", rs.getDate("departure_date"));
                    details.put("travelClass", rs.getString("travel_class"));
                    details.put("seatNumbers", rs.getString("seat_numbers"));
                    details.put("contactEmail", rs.getString("contact_email"));
                    details.put("contactPhone", rs.getString("contact_phone"));
                    details.put("status", rs.getString("status"));
                    details.put("totalAmount", rs.getBigDecimal("total_amount"));
                    details.put("currency", rs.getString("currency"));
                    details.put("createdAt", rs.getTimestamp("created_at"));
                    details.put("userFirst", rs.getString("user_first"));
                    details.put("userLast", rs.getString("user_last"));
                    details.put("userEmail", rs.getString("user_email"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load booking: " + e.getMessage(), e);
        }

        if (details.isEmpty()) return null;

        // Load passengers manifest
        List<Map<String, Object>> passengers = new ArrayList<>();
        String pSql = "SELECT id, first_name, last_name, date_of_birth, gender, nationality, passenger_type, seat_number, ticket_number " +
                      "FROM passengers WHERE booking_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(pSql)) {
            ps.setLong(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> p = new HashMap<>();
                    p.put("id", rs.getLong("id"));
                    p.put("firstName", rs.getString("first_name"));
                    p.put("lastName", rs.getString("last_name"));
                    p.put("dateOfBirth", rs.getDate("date_of_birth"));
                    p.put("gender", rs.getString("gender"));
                    p.put("nationality", rs.getString("nationality"));
                    p.put("passengerType", rs.getString("passenger_type"));
                    p.put("seatNumber", rs.getString("seat_number"));
                    p.put("ticketNumber", rs.getString("ticket_number"));
                    passengers.add(p);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load passengers for booking: " + e.getMessage(), e);
        }
        details.put("passengers", passengers);

        // Load payment record
        String paySql = "SELECT * FROM payments WHERE booking_id = ? ORDER BY id DESC LIMIT 1";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(paySql)) {
            ps.setLong(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> pay = new HashMap<>();
                    pay.put("id", rs.getLong("id"));
                    pay.put("paymentReference", rs.getString("payment_reference"));
                    pay.put("amount", rs.getBigDecimal("amount"));
                    pay.put("currency", rs.getString("currency"));
                    pay.put("paymentMethod", rs.getString("payment_method"));
                    pay.put("status", rs.getString("status"));
                    pay.put("razorpayOrderId", rs.getString("razorpay_order_id"));
                    pay.put("razorpayPaymentId", rs.getString("razorpay_payment_id"));
                    pay.put("paidAt", rs.getTimestamp("paid_at"));
                    details.put("payment", pay);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load payment for booking: " + e.getMessage(), e);
        }

        return details;
    }
}
