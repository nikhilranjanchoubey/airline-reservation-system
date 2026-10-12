package com.skytech.dao;

import com.skytech.util.DBConnectionUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Admin Passenger Management:
 * provides filtered search, pagination, booking history aggregation,
 * and secure profile inspection.
 */
public class AdminPassengerDao {

    private static final Logger LOGGER = Logger.getLogger(AdminPassengerDao.class.getName());

    public List<Map<String, Object>> getPassengers(String search, String status, String role, int page, int pageSize) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT u.user_id, u.first_name, u.last_name, u.email, u.phone, u.passport_number, " +
                "u.date_of_birth, u.role, u.status, u.created_at, " +
                "(SELECT COUNT(*) FROM bookings b WHERE b.user_id = u.user_id) AS total_bookings, " +
                "(SELECT COUNT(*) FROM bookings b WHERE b.user_id = u.user_id AND b.status = 'CONFIRMED') AS confirmed_bookings, " +
                "(SELECT COALESCE(SUM(b.total_amount), 0) FROM bookings b WHERE b.user_id = u.user_id AND b.status = 'CONFIRMED') AS total_spent " +
                "FROM users u WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(u.first_name) LIKE ? OR LOWER(u.last_name) LIKE ? OR LOWER(u.email) LIKE ? OR LOWER(u.phone) LIKE ?) ");
            String q = "%" + search.trim().toLowerCase() + "%";
            params.add(q);
            params.add(q);
            params.add(q);
            params.add(q);
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND u.status = ? ");
            params.add(status.trim().toUpperCase());
        }
        if (role != null && !role.trim().isEmpty() && !"ALL".equalsIgnoreCase(role)) {
            sql.append(" AND u.role = ? ");
            params.add(role.trim().toUpperCase());
        }

        sql.append(" ORDER BY u.created_at DESC LIMIT ? OFFSET ?");
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
                    map.put("userId", rs.getInt("user_id"));
                    map.put("firstName", rs.getString("first_name"));
                    map.put("lastName", rs.getString("last_name"));
                    map.put("email", rs.getString("email"));
                    map.put("phone", rs.getString("phone"));

                    // Mask sensitive passport number (e.g., P*****78)
                    String rawPassport = rs.getString("passport_number");
                    map.put("passportNumber", maskPassport(rawPassport));

                    map.put("dateOfBirth", rs.getDate("date_of_birth"));
                    map.put("role", rs.getString("role"));
                    map.put("status", rs.getString("status"));
                    map.put("createdAt", rs.getTimestamp("created_at"));
                    map.put("totalBookings", rs.getInt("total_bookings"));
                    map.put("confirmedBookings", rs.getInt("confirmed_bookings"));
                    map.put("totalSpent", rs.getBigDecimal("total_spent"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to query passengers: " + e.getMessage(), e);
        }
        return list;
    }

    public int countPassengers(String search, String status, String role) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users u WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(u.first_name) LIKE ? OR LOWER(u.last_name) LIKE ? OR LOWER(u.email) LIKE ? OR LOWER(u.phone) LIKE ?) ");
            String q = "%" + search.trim().toLowerCase() + "%";
            params.add(q);
            params.add(q);
            params.add(q);
            params.add(q);
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND u.status = ? ");
            params.add(status.trim().toUpperCase());
        }
        if (role != null && !role.trim().isEmpty() && !"ALL".equalsIgnoreCase(role)) {
            sql.append(" AND u.role = ? ");
            params.add(role.trim().toUpperCase());
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
            LOGGER.log(Level.SEVERE, "Failed to count passengers: " + e.getMessage(), e);
        }
        return 0;
    }

    public Map<String, Object> getPassengerDetails(int userId) {
        Map<String, Object> details = null;
        String sql = "SELECT user_id, first_name, last_name, email, phone, passport_number, " +
                     "date_of_birth, role, status, created_at FROM users WHERE user_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    details = new HashMap<>();
                    details.put("userId", rs.getInt("user_id"));
                    details.put("firstName", rs.getString("first_name"));
                    details.put("lastName", rs.getString("last_name"));
                    details.put("email", rs.getString("email"));
                    details.put("phone", rs.getString("phone"));
                    details.put("passportNumber", maskPassport(rs.getString("passport_number")));
                    details.put("dateOfBirth", rs.getDate("date_of_birth"));
                    details.put("role", rs.getString("role"));
                    details.put("status", rs.getString("status"));
                    details.put("createdAt", rs.getTimestamp("created_at"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get passenger details: " + e.getMessage(), e);
        }
        return details;
    }

    public boolean updateStatus(int userId, String newStatus) {
        String sql = "UPDATE users SET status = ? WHERE user_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update user status: " + e.getMessage(), e);
            return false;
        }
    }

    private String maskPassport(String passport) {
        if (passport == null || passport.trim().isEmpty()) {
            return "Not Provided";
        }
        String p = passport.trim();
        if (p.length() <= 3) {
            return "***";
        }
        // Show first char and last 2 chars, mask middle
        char first = p.charAt(0);
        String last2 = p.substring(p.length() - 2);
        return first + "*****" + last2;
    }
}
