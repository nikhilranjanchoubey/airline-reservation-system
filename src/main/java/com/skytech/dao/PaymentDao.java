package com.skytech.dao;

import com.skytech.model.Payment;
import com.skytech.util.DBConnectionUtil;

import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for payment transactions.
 */
public class PaymentDao {

    private static final Logger LOGGER = Logger.getLogger(PaymentDao.class.getName());

    public boolean createPayment(Payment payment) {
        String sql = "INSERT INTO payments (booking_id, payment_reference, amount, currency, " +
                "payment_method, status, razorpay_order_id, razorpay_payment_id, razorpay_signature) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, payment.getBookingId());
            ps.setString(2, payment.getPaymentReference());
            ps.setBigDecimal(3, payment.getAmount());
            ps.setString(4, payment.getCurrency() != null ? payment.getCurrency() : "INR");
            ps.setString(5, payment.getPaymentMethod() != null ? payment.getPaymentMethod() : "RAZORPAY");
            ps.setString(6, payment.getStatus() != null ? payment.getStatus() : "PENDING");
            ps.setString(7, payment.getRazorpayOrderId());
            ps.setString(8, payment.getRazorpayPaymentId());
            ps.setString(9, payment.getRazorpaySignature());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        payment.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to create payment record: " + e.getMessage(), e);
        }
        return false;
    }

    public Payment getPaymentByBookingId(long bookingId) {
        String sql = "SELECT * FROM payments WHERE booking_id = ? ORDER BY id DESC LIMIT 1";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapPayment(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve payment by booking ID: " + e.getMessage(), e);
        }
        return null;
    }

    public Payment getPaymentByRazorpayOrderId(String orderId) {
        String sql = "SELECT * FROM payments WHERE razorpay_order_id = ? ORDER BY id DESC LIMIT 1";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapPayment(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve payment by Razorpay order ID: " + e.getMessage(), e);
        }
        return null;
    }

    public boolean updatePaymentSuccess(long paymentId, String paymentRef, String razorpayPaymentId,
                                         String signature, String paymentMethod) {
        String sql = "UPDATE payments SET status = 'SUCCESS', payment_reference = ?, " +
                "razorpay_payment_id = ?, razorpay_signature = ?, payment_method = ?, " +
                "paid_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, paymentRef);
            ps.setString(2, razorpayPaymentId);
            ps.setString(3, signature);
            ps.setString(4, paymentMethod != null ? paymentMethod : "RAZORPAY");
            ps.setLong(5, paymentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to mark payment success: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean updatePaymentFailed(long paymentId, String paymentRef) {
        String sql = "UPDATE payments SET status = 'FAILED', payment_reference = ? WHERE id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, paymentRef);
            ps.setLong(2, paymentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to mark payment failed: " + e.getMessage(), e);
            return false;
        }
    }

    private Payment mapPayment(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setId(rs.getLong("id"));
        p.setBookingId(rs.getLong("booking_id"));
        p.setPaymentReference(rs.getString("payment_reference"));
        p.setAmount(rs.getBigDecimal("amount"));
        p.setCurrency(rs.getString("currency"));
        p.setPaymentMethod(rs.getString("payment_method"));
        p.setStatus(rs.getString("status"));
        p.setRazorpayOrderId(rs.getString("razorpay_order_id"));
        p.setRazorpayPaymentId(rs.getString("razorpay_payment_id"));
        p.setRazorpaySignature(rs.getString("razorpay_signature"));
        p.setPaidAt(rs.getTimestamp("paid_at"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        return p;
    }
}
