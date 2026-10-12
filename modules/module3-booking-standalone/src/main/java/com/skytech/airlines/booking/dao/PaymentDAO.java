package com.skytech.airlines.booking.dao;

import com.skytech.airlines.booking.model.Payment;
import com.skytech.airlines.booking.model.PaymentStatus;
import com.skytech.airlines.booking.util.DBConnection;

import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PaymentDAO {
    private static final Logger LOGGER = Logger.getLogger(PaymentDAO.class.getName());

    public Long save(Payment p, Connection conn) throws SQLException {
        String sql = "INSERT INTO payments (booking_id, payment_reference, razorpay_order_id, razorpay_payment_id, " +
                     "razorpay_signature, payment_method, amount, currency, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, p.getBookingId());
            ps.setString(2, p.getPaymentReference());
            ps.setString(3, p.getRazorpayOrderId());
            ps.setString(4, p.getRazorpayPaymentId());
            ps.setString(5, p.getRazorpaySignature());
            ps.setString(6, p.getPaymentMethod() != null ? p.getPaymentMethod() : "RAZORPAY");
            ps.setBigDecimal(7, p.getAmount());
            ps.setString(8, p.getCurrency() != null ? p.getCurrency() : "INR");
            ps.setString(9, p.getPaymentStatus() != null ? p.getPaymentStatus().name() : "PENDING");
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    p.setPaymentId(id);
                    return id;
                }
            }
        }
        return null;
    }

    public Payment findByBookingId(Long bookingId) {
        String sql = "SELECT payment_id, booking_id, payment_reference, razorpay_order_id, razorpay_payment_id, " +
                     "razorpay_signature, payment_method, amount, currency, payment_status, payment_date FROM payments WHERE booking_id = ? ORDER BY payment_id DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Payment p = new Payment();
                    p.setPaymentId(rs.getLong("payment_id"));
                    p.setBookingId(rs.getLong("booking_id"));
                    p.setPaymentReference(rs.getString("payment_reference"));
                    p.setRazorpayOrderId(rs.getString("razorpay_order_id"));
                    p.setRazorpayPaymentId(rs.getString("razorpay_payment_id"));
                    p.setRazorpaySignature(rs.getString("razorpay_signature"));
                    p.setPaymentMethod(rs.getString("payment_method"));
                    p.setAmount(rs.getBigDecimal("amount"));
                    p.setCurrency(rs.getString("currency"));
                    String st = rs.getString("payment_status");
                    if (st != null) {
                        try { p.setPaymentStatus(PaymentStatus.valueOf(st)); } catch (Exception ignored) {}
                    }
                    Timestamp ts = rs.getTimestamp("payment_date");
                    if (ts != null) p.setPaymentDate(ts.toLocalDateTime());
                    return p;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Notice finding payment for booking: " + bookingId, e);
        }
        return null;
    }

    public boolean updatePaymentSuccess(Long bookingId, String razorpayPaymentId, String razorpaySignature, Connection conn) throws SQLException {
        String sql = "UPDATE payments SET razorpay_payment_id = ?, razorpay_signature = ?, payment_status = 'SUCCESS' WHERE booking_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, razorpayPaymentId);
            ps.setString(2, razorpaySignature);
            ps.setLong(3, bookingId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updatePaymentStatus(Long bookingId, PaymentStatus status, Connection conn) throws SQLException {
        String sql = "UPDATE payments SET payment_status = ? WHERE booking_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            ps.setLong(2, bookingId);
            return ps.executeUpdate() > 0;
        }
    }
}
