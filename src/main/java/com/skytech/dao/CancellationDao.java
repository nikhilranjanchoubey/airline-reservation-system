package com.skytech.dao;

import com.skytech.model.Cancellation;
import com.skytech.util.DBConnectionUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for flight booking cancellations and refund tracking.
 */
public class CancellationDao {

    private static final Logger LOGGER = Logger.getLogger(CancellationDao.class.getName());

    public boolean recordCancellation(Cancellation cancellation) {
        String sql = "INSERT INTO cancellations (booking_id, pnr, cancellation_reason, cancellation_fee, " +
                "refund_amount, refund_status, refund_reference, cancelled_by_user_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, cancellation.getBookingId());
            ps.setString(2, cancellation.getPnr());
            ps.setString(3, cancellation.getCancellationReason());
            ps.setBigDecimal(4, cancellation.getCancellationFee());
            ps.setBigDecimal(5, cancellation.getRefundAmount());
            ps.setString(6, cancellation.getRefundStatus() != null ? cancellation.getRefundStatus() : "PENDING");
            ps.setString(7, cancellation.getRefundReference());
            if (cancellation.getCancelledByUserId() != null) {
                ps.setLong(8, cancellation.getCancelledByUserId());
            } else {
                ps.setNull(8, Types.BIGINT);
            }

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        cancellation.setCancellationId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to record cancellation: " + e.getMessage(), e);
        }
        return false;
    }

    public Cancellation getCancellationByBookingId(long bookingId) {
        String sql = "SELECT * FROM cancellations WHERE booking_id = ? ORDER BY cancellation_id DESC LIMIT 1";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCancellation(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve cancellation by booking ID: " + e.getMessage(), e);
        }
        return null;
    }

    public Cancellation getCancellationByPnr(String pnr) {
        String sql = "SELECT * FROM cancellations WHERE UPPER(pnr) = ? ORDER BY cancellation_id DESC LIMIT 1";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, pnr.toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCancellation(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve cancellation by PNR: " + e.getMessage(), e);
        }
        return null;
    }

    public List<Cancellation> getAllCancellations() {
        List<Cancellation> list = new ArrayList<>();
        String sql = "SELECT * FROM cancellations ORDER BY cancelled_at DESC";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapCancellation(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve all cancellations: " + e.getMessage(), e);
        }
        return list;
    }

    private Cancellation mapCancellation(ResultSet rs) throws SQLException {
        Cancellation c = new Cancellation();
        c.setCancellationId(rs.getLong("cancellation_id"));
        c.setBookingId(rs.getLong("booking_id"));
        c.setPnr(rs.getString("pnr"));
        c.setCancellationReason(rs.getString("cancellation_reason"));
        c.setCancellationFee(rs.getBigDecimal("cancellation_fee"));
        c.setRefundAmount(rs.getBigDecimal("refund_amount"));
        c.setRefundStatus(rs.getString("refund_status"));
        c.setRefundReference(rs.getString("refund_reference"));
        long uId = rs.getLong("cancelled_by_user_id");
        if (!rs.wasNull()) c.setCancelledByUserId(uId);
        c.setCancelledAt(rs.getTimestamp("cancelled_at"));
        return c;
    }
}
