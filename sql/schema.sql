-- ==========================================================
-- Airline Reservation System - Database Schema
-- Module: Authentication & User Management
-- Compatible with MySQL 8.0+
-- ==========================================================

CREATE DATABASE IF NOT EXISTS airline_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE airline_db;

-- ----------------------------------------------------------
-- Table: users
-- Stores both passengers and administrators
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    google_id VARCHAR(255) NULL UNIQUE,
    password_hash VARCHAR(256) NULL,
    salt VARCHAR(64) NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NULL,
    passport_number VARCHAR(30) NULL,
    date_of_birth DATE NULL,
    role ENUM('PASSENGER', 'ADMIN') NOT NULL DEFAULT 'PASSENGER',
    status ENUM('ACTIVE', 'SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_email (email),
    INDEX idx_user_google_id (google_id),
    INDEX idx_user_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------
-- Migration Script for Existing Databases:
-- Run the following statements if upgrading an existing DB:
--
-- ALTER TABLE users ADD COLUMN google_id VARCHAR(255) NULL UNIQUE AFTER email;
-- ALTER TABLE users MODIFY COLUMN password_hash VARCHAR(256) NULL;
-- ALTER TABLE users MODIFY COLUMN salt VARCHAR(64) NULL;
-- ALTER TABLE users MODIFY COLUMN phone VARCHAR(20) NULL;
-- ----------------------------------------------------------

-- ----------------------------------------------------------
-- Seed Data: Initial Administrator and Passenger Accounts
-- 
-- 1. Administrator Account:
--    Email:    admin@airline.com
--    Password: Admin@12345
--    Role:     ADMIN
--
-- 2. Test Passenger Account:
--    Email:    passenger@airline.com
--    Password: Passenger@12345
--    Role:     PASSENGER
-- ----------------------------------------------------------

INSERT INTO users (email, password_hash, salt, first_name, last_name, phone, passport_number, date_of_birth, role, status)
VALUES 
(
    'admin@airline.com',
    'cb81638176dd740c00f49106b5cf8fd91ba4c0bb172948a60b7adb08cd21d712',
    'a1b2c3d4e5f60718293a4b5c6d7e8f90',
    'System',
    'Administrator',
    '+18005550199',
    'ADM99988877',
    '1985-01-01',
    'ADMIN',
    'ACTIVE'
),
(
    'passenger@airline.com',
    '3d3f6b2232fc7a3382161bdf3545eefc3551117b4817cd1cca9db22980425eb7',
    'f1e2d3c4b5a69788796a5b4c3d2e1f00',
    'John',
    'Doe',
    '+15551234567',
    'P12345678',
    '1995-05-15',
    'PASSENGER',
    'ACTIVE'
)
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;
