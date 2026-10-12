package com.skytech.dao;

import com.airline.dao.AdminAuditDao;
import com.skytech.util.DBConnectionUtil;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Admin Cancellation & Refund Management:
 * provides cancellation inspection, filterable history, and atomic transactional cancellation execution.
 */
public class AdminCancellationDao {

    private static final Logger LOGGER = Logger.getLogger(AdminCancellationDao.class.getName());
    private final AdminAuditDao auditDao = new AdminAuditDao();

    public List<Map<String, Object>> searchCancellations(String search, String refundStatus, String fromDate, String toDate,
                                                         int page, int pageSize) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT c.cancellation_id, c.booking_id, c.pnr, c.cancellation_reason, " +
                "c.cancellation_fee, c.refund_amount, c.refund_status, c.refund_reference, " +
                "c.cancelled_by_user_id, c.cancelled_at, " +
                "b.booking_reference, b.flight_number, b.origin_code, b.destination_code, " +
                "b.departure_date, b.total_amount, b.contact_email " +
                "FROM cancellations c " +
                "LEFT JOIN bookings b ON c.booking_id = b.id " +
                "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(COALESCE(c.pnr, '')) LIKE ? " +
                       " OR LOWER(COALESCE(b.booking_reference, '')) LIKE ? " +
                       " OR LOWER(COALESCE(b.contact_email, '')) LIKE ? " +
                       " OR LOWER(COALESCE(b.flight_number, '')) LIKE ? " +
                       " OR LOWER(COALESCE(c.refund_reference, '')) LIKE ?) ");
            String q = "%" + search.trim().toLowerCase() + "%";
            for (int i = 0; i < 5; i++) {
                params.add(q);
            }
        }

        if (refundStatus != null && !refundStatus.trim().isEmpty() && !"ALL".equalsIgnoreCase(refundStatus)) {
            sql.append(" AND c.refund_status = ? ");
            params.add(refundStatus.trim().toUpperCase());
        }

        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND DATE(c.cancelled_at) >= ? ");
            params.add(Date.valueOf(fromDate.trim()));
        }

        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND DATE(c.cancelled_at) <= ? ");
            params.add(Date.valueOf(toDate.trim()));
        }

        sql.append(" ORDER BY c.cancelled_at DESC LIMIT ? OFFSET ?");
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
                    map.put("cancellationId", rs.getLong("cancellation_id"));
                    map.put("bookingId", rs.getLong("booking_id"));
                    map.put("pnr", rs.getString("pnr"));
                    map.put("cancellationReason", rs.getString("cancellation_reason"));
                    map.put("cancellationFee", rs.getBigDecimal("cancellation_fee"));
                    map.put("refundAmount", rs.getBigDecimal("refund_amount"));
                    map.put("refundStatus", rs.getString("refund_status"));
                    map.put("refundReference", rs.getString("refund_reference"));
                    map.put("cancelledByUserId", rs.getObject("cancelled_by_user_id"));
                    map.put("cancelledAt", rs.getTimestamp("cancelled_at"));
                    map.put("bookingReference", rs.getString("booking_reference"));
                    map.put("flightNumber", rs.getString("flight_number"));
                    map.put("originCode", rs.getString("origin_code"));
                    map.put("destCode", rs.getString("destination_code"));
                    map.put("departureDate", rs.getDate("departure_date"));
                    map.put("totalAmount", rs.getBigDecimal("total_amount"));
                    map.put("contactEmail", rs.getString("contact_email"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to search cancellations: " + e.getMessage(), e);
        }
        return list;
    }

    public int countCancellations(String search, String refundStatus, String fromDate, String toDate) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM cancellations c " +
                "LEFT JOIN bookings b ON c.booking_id = b.id " +
                "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(COALESCE(c.pnr, '')) LIKE ? " +
                       " OR LOWER(COALESCE(b.booking_reference, '')) LIKE ? " +
                       " OR LOWER(COALESCE(b.contact_email, '')) LIKE ? " +
                       " OR LOWER(COALESCE(b.flight_number, '')) LIKE ? " +
                       " OR LOWER(COALESCE(c.refund_reference, '')) LIKE ?) ");
            String q = "%" + search.trim().toLowerCase() + "%";
            for (int i = 0; i < 5; i++) {
                params.add(q);
            }
        }

        if (refundStatus != null && !refundStatus.trim().isEmpty() && !"ALL".equalsIgnoreCase(refundStatus)) {
            sql.append(" AND c.refund_status = ? ");
            params.add(refundStatus.trim().toUpperCase());
        }

        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND DATE(c.cancelled_at) >= ? ");
            params.add(Date.valueOf(fromDate.trim()));
        }

        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND DATE(c.cancelled_at) <= ? ");
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
            LOGGER.log(Level.SEVERE, "Failed to count cancellations: " + e.getMessage(), e);
        }
        return 0;
    }

    /**
     * Atomically executes cancellation for a booking, releasing seat inventory exactly once
     * and recording refund & audit logs.
     */
    public boolean processAdminCancellation(long bookingId, String reason, int adminUserId, String adminName) {
        String selectBookingSql = "SELECT b.id, b.pnr, b.booking_reference, b.status, b.schedule_id, b.total_amount, " +
                                  "(SELECT COUNT(*) FROM passengers p WHERE p.booking_id = b.id) AS passenger_count " +
                                  "FROM bookings b WHERE b.id = ? FOR UPDATE";

        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            conn.setAutoCommit(false);

            String pnr = null;
            String currentStatus = null;
            Integer scheduleId = null;
            BigDecimal totalAmount = BigDecimal.ZERO;
            int passengerCount = 1;

            try (PreparedStatement ps = conn.prepareStatement(selectBookingSql)) {
                ps.setLong(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    currentStatus = rs.getString("status");
                    pnr = rs.getString("pnr");
                    if (pnr == null || pnr.isBlank()) pnr = rs.getString("booking_reference");
                    scheduleId = (Integer) rs.getObject("schedule_id");
                    totalAmount = rs.getBigDecimal("total_amount");
                    passengerCount = Math.max(1, rs.getInt("passenger_count"));
                }
            }

            // If already cancelled, do not cancel or release seats again!
            if ("CANCELLED".equalsIgnoreCase(currentStatus)) {
                conn.rollback();
                return false;
            }

            // 1. Update booking status
            try (PreparedStatement ps = conn.prepareStatement("UPDATE bookings SET status = 'CANCELLED' WHERE id = ?")) {
                ps.setLong(1, bookingId);
                ps.executeUpdate();
            }

            // 2. Update tickets status
            try (PreparedStatement ps = conn.prepareStatement("UPDATE tickets SET status = 'CANCELLED' WHERE booking_id = ?")) {
                ps.setLong(1, bookingId);
                ps.executeUpdate();
            }

            // 3. Release seat inventory if confirmed previously and schedule is present
            if (scheduleId != null && "CONFIRMED".equalsIgnoreCase(currentStatus)) {
                String seatRelSql = "UPDATE flight_schedules SET available_seats = LEAST(total_seats, available_seats + ?) " +
                                    "WHERE schedule_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(seatRelSql)) {
                    ps.setInt(1, passengerCount);
                    ps.setInt(2, scheduleId);
                    ps.executeUpdate();
                }

                // Also release seats in aircraft_seats/flight_seat_inventory if exists
                String unreserveSeatsSql = "UPDATE flight_seat_inventory SET is_reserved = 0, is_booked = 0, booking_id = NULL " +
                                           "WHERE schedule_id = ? AND booking_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(unreserveSeatsSql)) {
                    ps.setInt(1, scheduleId);
                    ps.setLong(2, bookingId);
                    ps.executeUpdate();
                } catch (SQLException ignored) {
                    // Non-fatal if table not populated
                }
            }

            // 4. Calculate standard refund
            BigDecimal pctFee = totalAmount.multiply(new BigDecimal("0.25"));
            BigDecimal capFee = new BigDecimal(1000 * passengerCount);
            BigDecimal cancellationFee = pctFee.min(capFee).setScale(2, RoundingMode.HALF_UP);
            BigDecimal refundAmount = totalAmount.subtract(cancellationFee).max(BigDecimal.ZERO);
            String refundRef = "ADM_RFND_" + System.currentTimeMillis();

            // 5. Insert into cancellations
            String insertCancelSql = "INSERT INTO cancellations (booking_id, pnr, cancellation_reason, " +
                                     "cancellation_fee, refund_amount, refund_status, refund_reference, cancelled_by_user_id) " +
                                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertCancelSql)) {
                ps.setLong(1, bookingId);
                ps.setString(2, pnr != null ? pnr : "N/A");
                ps.setString(3, reason != null ? reason : "Administrative cancellation by " + adminName);
                ps.setBigDecimal(4, cancellationFee);
                ps.setBigDecimal(5, refundAmount);
                ps.setString(6, "REFUND_PENDING");
                ps.setString(7, refundRef);
                ps.setLong(8, adminUserId);
                ps.executeUpdate();
            }

            conn.commit();

            // 6. Record in audit log
            auditDao.logAction(adminUserId, adminName, "BOOKING_CANCELLED", "BOOKING", String.valueOf(bookingId),
                    "Cancelled booking " + pnr + ". Released " + passengerCount + " seats. Refund ref: " + refundRef, "SUCCESS");

            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            LOGGER.log(Level.SEVERE, "Failed to process admin cancellation: " + e.getMessage(), e);
            auditDao.logAction(adminUserId, adminName, "BOOKING_CANCELLED", "BOOKING", String.valueOf(bookingId),
                    "Failed to cancel booking: " + e.getMessage(), "FAILED");
            return false;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }
    }
}
