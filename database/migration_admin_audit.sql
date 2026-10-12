-- ==============================================================================
-- SkyTech - Airline Reservation System
-- Migration: Admin Audit Logs Table
-- ==============================================================================

CREATE TABLE IF NOT EXISTS admin_audit_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    admin_user_id INT NOT NULL,
    admin_name VARCHAR(100) NULL,
    action VARCHAR(100) NOT NULL,
    affected_record_type VARCHAR(50) NOT NULL,
    affected_record_id VARCHAR(50) NOT NULL,
    details TEXT NULL,
    status ENUM('SUCCESS', 'FAILED') NOT NULL DEFAULT 'SUCCESS',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_audit_admin (admin_user_id),
    INDEX idx_audit_type (affected_record_type),
    INDEX idx_audit_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
