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
 * Data Access Object for Admin Payment Transactions Management:
 * provides transaction search, status filtering, gateway reconciliation views, and pagination.
 */
public class AdminPaymentDao {

    private static final Logger LOGGER = Logger.getLogger(AdminPaymentDao.class.getName());

    public List<Map<String, Object>> searchPayments(String search, String status, String fromDate, String toDate,
                                                    int page, int pageSize) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.id, p.booking_id, p.payment_reference, p.amount, p.currency, " +
                "p.payment_method, p.status, p.paid_at, p.created_at, " +
                "p.razorpay_order_id, p.razorpay_payment_id, p.razorpay_signature, " +
                "b.booking_reference, b.pnr, b.flight_number, b.contact_email " +
                "FROM payments p " +
                "LEFT JOIN bookings b ON p.booking_id = b.id " +
                "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(COALESCE(p.payment_reference, '')) LIKE ? " +
                       " OR LOWER(COALESCE(p.razorpay_payment_id, '')) LIKE ? " +
                       " OR LOWER(COALESCE(p.razorpay_order_id, '')) LIKE ? " +
                       " OR LOWER(COALESCE(b.booking_reference, '')) LIKE ? " +
                       " OR LOWER(COALESCE(b.pnr, '')) LIKE ? " +
                       " OR LOWER(COALESCE(b.contact_email, '')) LIKE ?) ");
            String q = "%" + search.trim().toLowerCase() + "%";
            for (int i = 0; i < 6; i++) {
                params.add(q);
            }
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND p.status = ? ");
            params.add(status.trim().toUpperCase());
        }

        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND DATE(p.created_at) >= ? ");
            params.add(Date.valueOf(fromDate.trim()));
        }

        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND DATE(p.created_at) <= ? ");
            params.add(Date.valueOf(toDate.trim()));
        }

        sql.append(" ORDER BY p.created_at DESC LIMIT ? OFFSET ?");
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
                    map.put("bookingId", rs.getLong("booking_id"));
                    map.put("paymentReference", rs.getString("payment_reference"));
                    map.put("amount", rs.getBigDecimal("amount"));
                    map.put("currency", rs.getString("currency"));
                    map.put("paymentMethod", rs.getString("payment_method"));
                    map.put("status", rs.getString("status"));
                    map.put("paidAt", rs.getTimestamp("paid_at"));
                    map.put("createdAt", rs.getTimestamp("created_at"));
                    map.put("razorpayOrderId", rs.getString("razorpay_order_id"));
                    map.put("razorpayPaymentId", rs.getString("razorpay_payment_id"));
                    map.put("bookingReference", rs.getString("booking_reference"));
                    map.put("pnr", rs.getString("pnr"));
                    map.put("flightNumber", rs.getString("flight_number"));
                    map.put("contactEmail", rs.getString("contact_email"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to search payment transactions: " + e.getMessage(), e);
        }
        return list;
    }

    public int countPayments(String search, String status, String fromDate, String toDate) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM payments p " +
                "LEFT JOIN bookings b ON p.booking_id = b.id " +
                "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(COALESCE(p.payment_reference, '')) LIKE ? " +
                       " OR LOWER(COALESCE(p.razorpay_payment_id, '')) LIKE ? " +
                       " OR LOWER(COALESCE(p.razorpay_order_id, '')) LIKE ? " +
                       " OR LOWER(COALESCE(b.booking_reference, '')) LIKE ? " +
                       " OR LOWER(COALESCE(b.pnr, '')) LIKE ? " +
                       " OR LOWER(COALESCE(b.contact_email, '')) LIKE ?) ");
            String q = "%" + search.trim().toLowerCase() + "%";
            for (int i = 0; i < 6; i++) {
                params.add(q);
            }
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND p.status = ? ");
            params.add(status.trim().toUpperCase());
        }

        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND DATE(p.created_at) >= ? ");
            params.add(Date.valueOf(fromDate.trim()));
        }

        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND DATE(p.created_at) <= ? ");
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
            LOGGER.log(Level.SEVERE, "Failed to count payments: " + e.getMessage(), e);
        }
        return 0;
    }
}
