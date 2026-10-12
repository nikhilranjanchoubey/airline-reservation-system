package com.airline.dao;

import com.airline.model.AdminAuditLog;
import com.skytech.util.DBConnectionUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for recording and retrieving administrative audit events.
 */
public class AdminAuditDao {

    private static final Logger LOGGER = Logger.getLogger(AdminAuditDao.class.getName());

    public boolean logAction(int adminUserId, String adminName, String action,
                             String affectedRecordType, String affectedRecordId,
                             String details, String status) {
        String sql = "INSERT INTO admin_audit_logs (admin_user_id, admin_name, action, " +
                     "affected_record_type, affected_record_id, details, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, adminUserId);
            ps.setString(2, adminName);
            ps.setString(3, action);
            ps.setString(4, affectedRecordType);
            ps.setString(5, affectedRecordId != null ? affectedRecordId : "N/A");
            ps.setString(6, details);
            ps.setString(7, status != null ? status : "SUCCESS");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to record admin audit log: " + e.getMessage(), e);
            return false;
        }
    }

    public List<AdminAuditLog> getRecentLogs(int limit) {
        List<AdminAuditLog> list = new ArrayList<>();
        String sql = "SELECT log_id, admin_user_id, admin_name, action, affected_record_type, " +
                     "affected_record_id, details, status, created_at " +
                     "FROM admin_audit_logs ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit > 0 ? limit : 50);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AdminAuditLog log = new AdminAuditLog();
                    log.setLogId(rs.getLong("log_id"));
                    log.setAdminUserId(rs.getInt("admin_user_id"));
                    log.setAdminName(rs.getString("admin_name"));
                    log.setAction(rs.getString("action"));
                    log.setAffectedRecordType(rs.getString("affected_record_type"));
                    log.setAffectedRecordId(rs.getString("affected_record_id"));
                    log.setDetails(rs.getString("details"));
                    log.setStatus(rs.getString("status"));
                    log.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(log);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to fetch admin audit logs: " + e.getMessage(), e);
        }
        return list;
    }
}
