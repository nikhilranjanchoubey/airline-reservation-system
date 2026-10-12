package com.airline.model;

import java.sql.Timestamp;

/**
 * Model representing an administrative action logged in the audit trail.
 */
public class AdminAuditLog {
    private long logId;
    private int adminUserId;
    private String adminName;
    private String action;
    private String affectedRecordType;
    private String affectedRecordId;
    private String details;
    private String status;
    private Timestamp createdAt;

    public AdminAuditLog() {
    }

    public AdminAuditLog(int adminUserId, String adminName, String action, String affectedRecordType,
                         String affectedRecordId, String details, String status) {
        this.adminUserId = adminUserId;
        this.adminName = adminName;
        this.action = action;
        this.affectedRecordType = affectedRecordType;
        this.affectedRecordId = affectedRecordId;
        this.details = details;
        this.status = status;
    }

    public long getLogId() {
        return logId;
    }

    public void setLogId(long logId) {
        this.logId = logId;
    }

    public int getAdminUserId() {
        return adminUserId;
    }

    public void setAdminUserId(int adminUserId) {
        this.adminUserId = adminUserId;
    }

    public String getAdminName() {
        return adminName;
    }

    public void setAdminName(String adminName) {
        this.adminName = adminName;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getAffectedRecordType() {
        return affectedRecordType;
    }

    public void setAffectedRecordType(String affectedRecordType) {
        this.affectedRecordType = affectedRecordType;
    }

    public String getAffectedRecordId() {
        return affectedRecordId;
    }

    public void setAffectedRecordId(String affectedRecordId) {
        this.affectedRecordId = affectedRecordId;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
