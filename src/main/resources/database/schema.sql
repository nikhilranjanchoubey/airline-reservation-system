-- ==============================================================================
-- Project: SkyTech - Airline Reservation System
-- Shared Database Initialization & Module Schema Script
-- Target Database: MySQL 8.x
-- ==============================================================================

-- 1. Create database with UTF-8 character encoding
CREATE DATABASE IF NOT EXISTS skytech_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE skytech_db;

-- ==============================================================================
-- MODULE 1: Authentication & User Management (Mohammed Sahil)
-- ==============================================================================

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
    profile_photo VARCHAR(255) NULL,
    role ENUM('PASSENGER', 'ADMIN') NOT NULL DEFAULT 'PASSENGER',
    status ENUM('ACTIVE', 'SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_email (email),
    INDEX idx_user_google_id (google_id),
    INDEX idx_user_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Demonstration Seed Accounts:
-- 1. Administrator: admin@airline.com / Admin@12345
-- 2. Passenger: passenger@airline.com / Passenger@12345
INSERT INTO users (email, password_hash, salt, first_name, last_name, phone, passport_number, date_of_birth, role, status)
VALUES 
(
    'admin@airline.com',
    'cb81638176dd740c00f49106b5cf8fd91ba4c0bb172948a60b7adb08cd21d712',
    'a1b2c3d4e5f60718293a4b5c6d7e8f90',
    'Team',
    'SkyTech',
    '+91 9876543210',
    'ADM99988877',
    '1985-01-01',
    'ADMIN',
    'ACTIVE'
),
(
    'passenger@airline.com',
    '3d3f6b2232fc7a3382161bdf3545eefc3551117b4817cd1cca9db22980425eb7',
    'f1e2d3c4b5a69788796a5b4c3d2e1f00',
    'Ramesh',
    'Kumar',
    '+91 999 777 8888',
    'P99887766',
    '1993-08-20',
    'PASSENGER',
    'ACTIVE'
)
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;



-- ==============================================================================
-- MODULE 2: Flight Search & Availability (Nikhil Ranjan Choubey)
-- ==============================================================================

-- 2.1 Airports Table
CREATE TABLE IF NOT EXISTS airports (
    airport_id INT AUTO_INCREMENT PRIMARY KEY,
    airport_code VARCHAR(3) NOT NULL UNIQUE,
    airport_name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'India',
    terminal VARCHAR(50) DEFAULT 'Terminal 1',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2.2 Airlines Table
CREATE TABLE IF NOT EXISTS airlines (
    airline_id INT AUTO_INCREMENT PRIMARY KEY,
    airline_code VARCHAR(10) NOT NULL UNIQUE,
    airline_name VARCHAR(100) NOT NULL,
    logo_icon VARCHAR(50) DEFAULT 'bi-airplane-fill',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2.3 Flights Master Table
CREATE TABLE IF NOT EXISTS flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(20) NOT NULL UNIQUE,
    airline_id INT NOT NULL,
    source_airport_id INT NOT NULL,
    destination_airport_id INT NOT NULL,
    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    duration_minutes INT NOT NULL,
    stops INT NOT NULL DEFAULT 0,
    aircraft_model VARCHAR(100) DEFAULT 'Airbus A320neo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_flights_airline FOREIGN KEY (airline_id) REFERENCES airlines(airline_id) ON DELETE CASCADE,
    CONSTRAINT fk_flights_source FOREIGN KEY (source_airport_id) REFERENCES airports(airport_id) ON DELETE CASCADE,
    CONSTRAINT fk_flights_dest FOREIGN KEY (destination_airport_id) REFERENCES airports(airport_id) ON DELETE CASCADE,
    INDEX idx_flights_route (source_airport_id, destination_airport_id)
) ENGINE=InnoDB;

-- 2.4 Flight Schedules / Inventory Table
CREATE TABLE IF NOT EXISTS flight_schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    flight_date DATE NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL,
    economy_price DECIMAL(10, 2) NOT NULL,
    premium_economy_price DECIMAL(10, 2) NOT NULL,
    business_price DECIMAL(10, 2) NOT NULL,
    first_class_price DECIMAL(10, 2) NOT NULL,
    available_seats INT NOT NULL DEFAULT 60,
    total_seats INT NOT NULL DEFAULT 180,
    status VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_schedules_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE,
    CONSTRAINT uq_flight_date UNIQUE (flight_id, flight_date),
    INDEX idx_schedules_date (flight_date),
    INDEX idx_schedules_search (flight_id, flight_date, available_seats)
) ENGINE=InnoDB;

-- Indexes for performance

-- ==============================================================================
-- MODULE 2 SEED DATA (Realistic Indian Domestic Routes & Test Flights)
-- ==============================================================================

-- Seed Airports
INSERT INTO airports (airport_code, airport_name, city, country, terminal) VALUES
('JAI', 'Jaipur International Airport', 'Jaipur', 'India', 'Terminal 2'),
('DEL', 'Indira Gandhi International Airport', 'Delhi', 'India', 'Terminal 3'),
('BOM', 'Chhatrapati Shivaji Maharaj International Airport', 'Mumbai', 'India', 'Terminal 2'),
('BLR', 'Kempegowda International Airport', 'Bengaluru', 'India', 'Terminal 1'),
('HYD', 'Rajiv Gandhi International Airport', 'Hyderabad', 'India', 'Main Terminal'),
('CCU', 'Netaji Subhash Chandra Bose International Airport', 'Kolkata', 'India', 'Terminal 2'),
('MAA', 'Chennai International Airport', 'Chennai', 'India', 'Terminal 1'),
('AMD', 'Sardar Vallabhbhai Patel International Airport', 'Ahmedabad', 'India', 'Terminal 1'),
('PNQ', 'Pune Airport', 'Pune', 'India', 'Main Terminal'),
('GOI', 'Dabolim Airport', 'Goa', 'India', 'Terminal 1')
ON DUPLICATE KEY UPDATE airport_name=VALUES(airport_name);

-- Seed Airlines
INSERT INTO airlines (airline_code, airline_name, logo_icon) VALUES
('6E', 'IndiGo', 'bi-airplane-fill'),
('AI', 'Air India', 'bi-airplane-engines-fill'),
('SG', 'SpiceJet', 'bi-send-fill'),
('UK', 'Vistara', 'bi-airplane-fill'),
('QP', 'Akasa Air', 'bi-airplane-engines-fill')
ON DUPLICATE KEY UPDATE airline_name=VALUES(airline_name);

-- Seed Flights (Routes)
-- JAI (1), DEL (2), BOM (3), BLR (4)
INSERT INTO flights (flight_number, airline_id, source_airport_id, destination_airport_id, departure_time, arrival_time, duration_minutes, stops, aircraft_model) VALUES
-- Jaipur to Delhi
('6E-204', (SELECT airline_id FROM airlines WHERE airline_code = '6E'), (SELECT airport_id FROM airports WHERE airport_code = 'JAI'), (SELECT airport_id FROM airports WHERE airport_code = 'DEL'), '06:15:00', '08:20:00', 125, 0, 'Airbus A320neo'),
('AI-491', (SELECT airline_id FROM airlines WHERE airline_code = 'AI'), (SELECT airport_id FROM airports WHERE airport_code = 'JAI'), (SELECT airport_id FROM airports WHERE airport_code = 'DEL'), '09:45:00', '11:55:00', 130, 0, 'Airbus A321'),
('6E-512', (SELECT airline_id FROM airlines WHERE airline_code = '6E'), (SELECT airport_id FROM airports WHERE airport_code = 'JAI'), (SELECT airport_id FROM airports WHERE airport_code = 'DEL'), '17:30:00', '19:40:00', 130, 0, 'Airbus A320neo'),
('UK-702', (SELECT airline_id FROM airlines WHERE airline_code = 'UK'), (SELECT airport_id FROM airports WHERE airport_code = 'JAI'), (SELECT airport_id FROM airports WHERE airport_code = 'DEL'), '20:10:00', '22:15:00', 125, 0, 'Boeing 737-800'),

-- Delhi to Jaipur (Return route)
('6E-205', (SELECT airline_id FROM airlines WHERE airline_code = '6E'), (SELECT airport_id FROM airports WHERE airport_code = 'DEL'), (SELECT airport_id FROM airports WHERE airport_code = 'JAI'), '07:00:00', '09:05:00', 125, 0, 'Airbus A320neo'),
('AI-492', (SELECT airline_id FROM airlines WHERE airline_code = 'AI'), (SELECT airport_id FROM airports WHERE airport_code = 'DEL'), (SELECT airport_id FROM airports WHERE airport_code = 'JAI'), '14:20:00', '16:30:00', 130, 0, 'Airbus A321'),

-- Delhi to Mumbai
('6E-621', (SELECT airline_id FROM airlines WHERE airline_code = '6E'), (SELECT airport_id FROM airports WHERE airport_code = 'DEL'), (SELECT airport_id FROM airports WHERE airport_code = 'BOM'), '10:30:00', '12:45:00', 135, 0, 'Boeing 737 MAX'),
('AI-805', (SELECT airline_id FROM airlines WHERE airline_code = 'AI'), (SELECT airport_id FROM airports WHERE airport_code = 'DEL'), (SELECT airport_id FROM airports WHERE airport_code = 'BOM'), '06:00:00', '08:15:00', 135, 0, 'Boeing 787-8 Dreamliner'),
('UK-975', (SELECT airline_id FROM airlines WHERE airline_code = 'UK'), (SELECT airport_id FROM airports WHERE airport_code = 'DEL'), (SELECT airport_id FROM airports WHERE airport_code = 'BOM'), '18:15:00', '20:30:00', 135, 0, 'Airbus A321neo'),

-- Mumbai to Bengaluru
('AI-302', (SELECT airline_id FROM airlines WHERE airline_code = 'AI'), (SELECT airport_id FROM airports WHERE airport_code = 'BOM'), (SELECT airport_id FROM airports WHERE airport_code = 'BLR'), '14:20:00', '16:05:00', 105, 0, 'Airbus A320neo'),
('6E-442', (SELECT airline_id FROM airlines WHERE airline_code = '6E'), (SELECT airport_id FROM airports WHERE airport_code = 'BOM'), (SELECT airport_id FROM airports WHERE airport_code = 'BLR'), '08:45:00', '10:30:00', 105, 0, 'Airbus A320neo'),
('QP-112', (SELECT airline_id FROM airlines WHERE airline_code = 'QP'), (SELECT airport_id FROM airports WHERE airport_code = 'BOM'), (SELECT airport_id FROM airports WHERE airport_code = 'BLR'), '19:10:00', '20:55:00', 105, 0, 'Boeing 737 MAX 8'),

-- Delhi to Goa
('6E-531', (SELECT airline_id FROM airlines WHERE airline_code = '6E'), (SELECT airport_id FROM airports WHERE airport_code = 'DEL'), (SELECT airport_id FROM airports WHERE airport_code = 'GOI'), '11:15:00', '13:50:00', 155, 0, 'Airbus A320neo'),
('AI-860', (SELECT airline_id FROM airlines WHERE airline_code = 'AI'), (SELECT airport_id FROM airports WHERE airport_code = 'DEL'), (SELECT airport_id FROM airports WHERE airport_code = 'GOI'), '14:00:00', '16:40:00', 160, 0, 'Airbus A321'),

-- Bengaluru to Hyderabad
('6E-651', (SELECT airline_id FROM airlines WHERE airline_code = '6E'), (SELECT airport_id FROM airports WHERE airport_code = 'BLR'), (SELECT airport_id FROM airports WHERE airport_code = 'HYD'), '07:15:00', '08:30:00', 75, 0, 'Airbus A320neo'),
('QP-1301', (SELECT airline_id FROM airlines WHERE airline_code = 'QP'), (SELECT airport_id FROM airports WHERE airport_code = 'BLR'), (SELECT airport_id FROM airports WHERE airport_code = 'HYD'), '16:30:00', '17:45:00', 75, 0, 'Boeing 737 MAX 8')
ON DUPLICATE KEY UPDATE departure_time=VALUES(departure_time);

-- Seed Schedules for current test dates and next 30 days
-- Schedules generated dynamically relative to CURDATE() so testing always succeeds:
INSERT IGNORE INTO flight_schedules (flight_id, flight_date, base_price, economy_price, premium_economy_price, business_price, first_class_price, available_seats, total_seats, status)
SELECT 
    f.flight_id,
    d.dt AS flight_date,
    CASE 
        WHEN f.flight_number = '6E-204' THEN 4299.00
        WHEN f.flight_number = 'AI-491' THEN 5120.00
        WHEN f.flight_number = '6E-512' THEN 3899.00
        WHEN f.flight_number = 'UK-702' THEN 5850.00
        WHEN f.flight_number = '6E-205' THEN 4299.00
        WHEN f.flight_number = 'AI-492' THEN 5120.00
        WHEN f.flight_number = '6E-621' THEN 5499.00
        WHEN f.flight_number = 'AI-805' THEN 6200.00
        WHEN f.flight_number = 'UK-975' THEN 6890.00
        WHEN f.flight_number = 'AI-302' THEN 6120.00
        WHEN f.flight_number = '6E-442' THEN 4750.00
        WHEN f.flight_number = 'QP-112' THEN 4300.00
        WHEN f.flight_number = '6E-531' THEN 4890.00
        WHEN f.flight_number = 'AI-860' THEN 5650.00
        WHEN f.flight_number = '6E-651' THEN 3490.00
        WHEN f.flight_number = 'QP-1301' THEN 3190.00
        ELSE 4500.00
    END AS base_price,
    CASE 
        WHEN f.flight_number = '6E-204' THEN 4299.00
        WHEN f.flight_number = 'AI-491' THEN 5120.00
        WHEN f.flight_number = '6E-512' THEN 3899.00
        WHEN f.flight_number = 'UK-702' THEN 5850.00
        WHEN f.flight_number = '6E-205' THEN 4299.00
        WHEN f.flight_number = 'AI-492' THEN 5120.00
        WHEN f.flight_number = '6E-621' THEN 5499.00
        WHEN f.flight_number = 'AI-805' THEN 6200.00
        WHEN f.flight_number = 'UK-975' THEN 6890.00
        WHEN f.flight_number = 'AI-302' THEN 6120.00
        WHEN f.flight_number = '6E-442' THEN 4750.00
        WHEN f.flight_number = 'QP-112' THEN 4300.00
        WHEN f.flight_number = '6E-531' THEN 4890.00
        WHEN f.flight_number = 'AI-860' THEN 5650.00
        WHEN f.flight_number = '6E-651' THEN 3490.00
        WHEN f.flight_number = 'QP-1301' THEN 3190.00
        ELSE 4500.00
    END AS economy_price,
    ROUND(CASE WHEN f.flight_number = '6E-204' THEN 4299.00 ELSE 5000.00 END * 1.35, 2) AS premium_economy_price,
    ROUND(CASE WHEN f.flight_number = '6E-204' THEN 4299.00 ELSE 5000.00 END * 2.20, 2) AS business_price,
    ROUND(CASE WHEN f.flight_number = '6E-204' THEN 4299.00 ELSE 5000.00 END * 3.50, 2) AS first_class_price,
    CASE 
        WHEN f.flight_number = '6E-204' THEN 28
        WHEN f.flight_number = 'AI-491' THEN 16
        WHEN f.flight_number = '6E-621' THEN 21
        WHEN f.flight_number = 'AI-302' THEN 34
        WHEN f.flight_number = 'UK-702' THEN 4
        ELSE 42
    END AS available_seats,
    180 AS total_seats,
    'SCHEDULED' AS status
FROM flights f
CROSS JOIN (
    SELECT CURDATE() AS dt
    UNION ALL SELECT CURDATE() + INTERVAL 1 DAY
    UNION ALL SELECT CURDATE() + INTERVAL 2 DAY
    UNION ALL SELECT CURDATE() + INTERVAL 3 DAY
    UNION ALL SELECT CURDATE() + INTERVAL 5 DAY
    UNION ALL SELECT CURDATE() + INTERVAL 7 DAY
    UNION ALL SELECT CURDATE() + INTERVAL 8 DAY
    UNION ALL SELECT CURDATE() + INTERVAL 10 DAY
    UNION ALL SELECT CURDATE() + INTERVAL 14 DAY
    UNION ALL SELECT '2026-10-15'
    UNION ALL SELECT '2026-10-18'
    UNION ALL SELECT '2026-10-20'
) d;

-- 2.5 Aircraft Master Table
CREATE TABLE IF NOT EXISTS aircraft (
    aircraft_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL UNIQUE,
    manufacturer VARCHAR(50) NOT NULL,
    total_rows INT NOT NULL DEFAULT 30,
    seats_per_row INT NOT NULL DEFAULT 6,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2.6 Aircraft Seats Master Table (Cabin Layout)
CREATE TABLE IF NOT EXISTS aircraft_seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    aircraft_id INT NOT NULL,
    seat_number VARCHAR(5) NOT NULL,
    `row_number` INT NOT NULL,
    column_letter CHAR(1) NOT NULL,
    seat_type VARCHAR(20) NOT NULL DEFAULT 'STANDARD',
    premium_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_seat_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id) ON DELETE CASCADE,
    CONSTRAINT uq_aircraft_seat UNIQUE (aircraft_id, seat_number)
) ENGINE=InnoDB;

-- 2.7 Flight Schedule Seat Inventory (Dynamic Booking Availability)
CREATE TABLE IF NOT EXISTS flight_seat_inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    schedule_id INT NOT NULL,
    seat_id INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    CONSTRAINT fk_inv_schedule FOREIGN KEY (schedule_id) REFERENCES flight_schedules(schedule_id) ON DELETE CASCADE,
    CONSTRAINT fk_inv_seat FOREIGN KEY (seat_id) REFERENCES aircraft_seats(seat_id) ON DELETE CASCADE,
    CONSTRAINT uq_schedule_seat UNIQUE (schedule_id, seat_id)
) ENGINE=InnoDB;

-- Seed Aircraft
INSERT INTO aircraft (model_name, manufacturer, total_rows, seats_per_row) VALUES
('Airbus A320neo', 'Airbus', 20, 6),
('Boeing 737-800', 'Boeing', 20, 6)
ON DUPLICATE KEY UPDATE manufacturer=VALUES(manufacturer);

-- Seed Aircraft Seats for Airbus A320neo (Rows 1 to 20, Cols A, B, C, D, E, F)
-- Row 1: Premium / Extra Legroom (fee 500)
-- Row 12: Exit Row / Extra Legroom (fee 350)
-- Other Rows: Window (A, F), Aisle (C, D), Middle (B, E)
INSERT IGNORE INTO aircraft_seats (aircraft_id, seat_number, `row_number`, column_letter, seat_type, premium_fee)
SELECT 
    (SELECT aircraft_id FROM aircraft WHERE model_name = 'Airbus A320neo') AS aircraft_id,
    CONCAT(r.num, c.col) AS seat_number,
    r.num AS `row_number`,
    c.col AS column_letter,
    CASE 
        WHEN r.num = 1 THEN 'EXTRA_LEGROOM'
        WHEN r.num = 12 THEN 'EXIT_ROW'
        WHEN c.col IN ('A', 'F') THEN 'WINDOW'
        WHEN c.col IN ('C', 'D') THEN 'AISLE'
        ELSE 'MIDDLE'
    END AS seat_type,
    CASE 
        WHEN r.num = 1 THEN 500.00
        WHEN r.num = 12 THEN 350.00
        WHEN c.col IN ('A', 'F') THEN 150.00
        ELSE 0.00
    END AS premium_fee
FROM (
    SELECT 1 AS num UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
    UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
) r
CROSS JOIN (
    SELECT 'A' AS col UNION ALL SELECT 'B' UNION ALL SELECT 'C'
    UNION ALL SELECT 'D' UNION ALL SELECT 'E' UNION ALL SELECT 'F'
) c
;

-- Seed some occupied and blocked seats for first few schedules
INSERT IGNORE INTO flight_seat_inventory (schedule_id, seat_id, status)
SELECT 
    s.schedule_id,
    s_seat.seat_id,
    CASE 
        WHEN s_seat.seat_number IN ('1A', '2B', '3C', '4D', '5E', '6F', '12A', '12B') THEN 'OCCUPIED'
        WHEN s_seat.seat_number IN ('1F', '13A') THEN 'BLOCKED'
        ELSE 'AVAILABLE'
    END AS status
FROM (SELECT schedule_id FROM flight_schedules LIMIT 10) s
CROSS JOIN (SELECT seat_id, seat_number FROM aircraft_seats WHERE aircraft_id = (SELECT aircraft_id FROM aircraft WHERE model_name = 'Airbus A320neo') LIMIT 60) s_seat
;

-- 2.8 Flight Search History Table (Module 2 Search Logs)
CREATE TABLE IF NOT EXISTS flight_searches (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NULL,
    origin_code CHAR(3) NOT NULL,
    destination_code CHAR(3) NOT NULL,
    departure_date DATE NOT NULL,
    return_date DATE NULL,
    adults INT DEFAULT 1,
    children INT DEFAULT 0,
    infants INT DEFAULT 0,
    cabin_class VARCHAR(30) DEFAULT 'ECONOMY',
    provider VARCHAR(50) NULL,
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_searches_user (user_id),
    INDEX idx_searches_date (searched_at)
) ENGINE=InnoDB;


-- ==============================================================================
-- MODULE 3: Booking & Passenger Management
-- ==============================================================================

CREATE TABLE IF NOT EXISTS bookings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_reference VARCHAR(20) NOT NULL UNIQUE,
    user_id BIGINT NULL,
    schedule_id INT NULL,
    flight_number VARCHAR(20) NULL,
    travel_class VARCHAR(30) DEFAULT 'Economy',
    seat_numbers VARCHAR(100) NULL,
    contact_email VARCHAR(100) NULL,
    contact_phone VARCHAR(20) NULL,
    pnr VARCHAR(20) NULL,
    provider VARCHAR(50) DEFAULT 'LOCAL_CATALOG',
    provider_order_id VARCHAR(150) NULL,
    origin_code CHAR(3) NOT NULL,
    destination_code CHAR(3) NOT NULL,
    departure_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING_PAYMENT',
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    currency CHAR(3) DEFAULT 'INR',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_bookings_user (user_id),
    INDEX idx_bookings_pnr (pnr),
    INDEX idx_bookings_status (status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS passengers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NULL,
    date_of_birth DATE NULL,
    gender VARCHAR(20) NULL,
    passport_number VARCHAR(50) NULL,
    nationality VARCHAR(50) NULL,
    passenger_type ENUM('ADULT', 'CHILD', 'INFANT') DEFAULT 'ADULT',
    seat_number VARCHAR(10) NULL,
    ticket_number VARCHAR(50) NULL,
    CONSTRAINT fk_passengers_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    INDEX idx_passengers_booking (booking_id)
) ENGINE=InnoDB;

-- ==============================================================================
-- MODULE 4: Payments & Ticketing
-- ==============================================================================

CREATE TABLE IF NOT EXISTS payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    payment_reference VARCHAR(100) NULL,
    amount DECIMAL(12, 2) NOT NULL,
    currency CHAR(3) DEFAULT 'INR',
    payment_method VARCHAR(50) NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    razorpay_order_id VARCHAR(150) NULL,
    razorpay_payment_id VARCHAR(150) NULL,
    razorpay_signature VARCHAR(255) NULL,
    paid_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    INDEX idx_payments_order (razorpay_order_id),
    INDEX idx_payments_booking (booking_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tickets (
    ticket_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    passenger_id BIGINT NOT NULL,
    ticket_number VARCHAR(50) NOT NULL UNIQUE,
    pnr VARCHAR(20) NOT NULL,
    flight_number VARCHAR(20) NOT NULL,
    origin_code CHAR(3) NOT NULL,
    destination_code CHAR(3) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    seat_number VARCHAR(10) NULL,
    cabin_class VARCHAR(30) DEFAULT 'Economy',
    passenger_name VARCHAR(150) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED',
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tickets_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    INDEX idx_tickets_pnr (pnr),
    INDEX idx_tickets_booking (booking_id)
) ENGINE=InnoDB;

-- ==============================================================================
-- MODULE 5: Cancellations & Refund Management
-- ==============================================================================

CREATE TABLE IF NOT EXISTS cancellations (
    cancellation_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    pnr VARCHAR(20) NOT NULL,
    cancellation_reason VARCHAR(255) NULL,
    cancellation_fee DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    refund_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    refund_status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    refund_reference VARCHAR(150) NULL,
    cancelled_by_user_id BIGINT NULL,
    cancelled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cancellations_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    INDEX idx_cancellations_pnr (pnr)
) ENGINE=InnoDB;

-- ==============================================================================
-- MODULE 6: Admin Operations Audit Logging
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


-- ==============================================================================
-- PRODUCTION DATA RECOVERY: Restored Bookings, Passengers & History
-- ==============================================================================

INSERT IGNORE INTO bookings VALUES (1,'SKYT-96HXS4',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','CANCELLED',8780.80,'INR','2026-10-12 12:04:21',1,'UK-975','Economy','12A','passenger@airline.com','+15551234567','4QZZN6'),(2,'SKYT-9BZUL4',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','CANCELLED',8780.80,'INR','2026-10-12 12:04:57',1,'UK-975','Economy','12A','passenger@airline.com','+15551234567','C6JADZ'),(3,'SKYT-LK4NRB',2,'LOCAL_CATALOG',NULL,'JAI','DEL','2026-10-12','CONFIRMED',6143.20,'INR','2026-10-12 12:10:39',10001,'6E 2376','Economy',NULL,'passenger@airline.com','+15551234567','SSKCUT'),(4,'SKYT-NU2G5U',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','PENDING_PAYMENT',8780.80,'INR','2026-10-12 12:33:18',1,'UK-975','Economy','12A','passenger@airline.com','+15551234567',NULL),(5,'SKYT-XD3QS6',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','CANCELLED',8780.80,'INR','2026-10-12 12:34:31',1,'UK-975','Economy','12A','passenger@airline.com','+15551234567','CFMESS'),(6,'SKYT-TFM4KT',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','PENDING_PAYMENT',7716.80,'INR','2026-10-12 12:35:02',1,'UK-975','Economy','14B','passenger@airline.com','+919876543210',NULL),(7,'SKYT-QBBXMF',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','PENDING_PAYMENT',7716.80,'INR','2026-10-12 12:35:43',1,'UK-975','Economy','14B','passenger@airline.com','+919876543210',NULL),(8,'SKYT-KBBKAE',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','CONFIRMED',7716.80,'INR','2026-10-12 12:35:43',1,'UK-975','Economy','14B','passenger@airline.com','+919876543210','ZMFEXS'),(9,'SKYT-8TRL8H',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','CANCELLED',8780.80,'INR','2026-10-12 12:35:56',1,'UK-975','Economy','12A','passenger@airline.com','+15551234567','5N8VVK'),(10,'SKYT-M4MRR7',2,'LOCAL_CATALOG',NULL,'JAI','DEL','2026-10-12','PENDING_PAYMENT',41093.92,'INR','2026-10-12 12:37:25',10002,'AI 9123','Economy',NULL,'passenger@airline.com','+15551234567',NULL),(11,'SKYT-RVXF4A',2,'LOCAL_CATALOG',NULL,'JAI','DEL','2026-10-12','PENDING_PAYMENT',40032.16,'INR','2026-10-12 12:46:39',10001,'AI 9123','Economy',NULL,'passenger@airline.com','+15551234567',NULL),(12,'SKYT-5CKBUQ',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','CONFIRMED',7884.80,'INR','2026-10-12 12:46:57',1,'UK-975','Economy','16C','passenger@airline.com','+919876543210','LHC2GP'),(13,'SKYT-BDCFAZ',2,'LOCAL_CATALOG',NULL,'JAI','DEL','2026-10-12','PENDING_PAYMENT',40424.16,'INR','2026-10-12 12:48:17',10001,'AI 9123','Economy','4D','passenger@airline.com','+15551234567',NULL),(14,'SKYT-LX7ULG',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','PENDING_PAYMENT',7884.80,'INR','2026-10-12 12:56:33',1,'UK-975','Economy','18D','passenger@airline.com','+919876543210',NULL),(15,'SKYT-65X2Q8',1,'LOCAL_CATALOG',NULL,'DEL','GOI','2026-10-12','CONFIRMED',9494.24,'INR','2026-10-12 12:56:51',10001,'IX 1235','Economy',NULL,'admin@airline.com','+18005550199','4XQFT5'),(16,'SKYT-STF3HA',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','PENDING_PAYMENT',7716.80,'INR','2026-10-12 12:59:05',1,'UK-975','Economy',NULL,'passenger@airline.com','+919876543210',NULL),(17,'SKYT-EFFN64',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','CONFIRMED',7716.80,'INR','2026-10-12 12:59:49',1,'UK-975','Economy',NULL,'passenger@airline.com','+919876543210','L4DVHN'),(18,'SKYT-DENHWR',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','CANCELLED',8780.80,'INR','2026-10-12 13:00:00',1,'UK-975','Economy','12A','passenger@airline.com','+15551234567','66QAJP'),(19,'SKYT-GN4RR7',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','PENDING_PAYMENT',7716.80,'INR','2026-10-12 13:17:38',1,'UK-975','Economy',NULL,'passenger@airline.com','+919876543210',NULL),(20,'SKYT-4DYPM5',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','CONFIRMED',7716.80,'INR','2026-10-12 13:17:50',1,'UK-975','Economy',NULL,'passenger@airline.com','+919876543210','NKHTZS'),(21,'SKYT-UTQZ9V',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','PENDING_PAYMENT',7716.80,'INR','2026-10-12 13:40:33',1,'UK-975','Economy',NULL,'passenger@airline.com','+919876543210',NULL),(22,'SKYT-CMHVZV',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','PENDING_PAYMENT',7716.80,'INR','2026-10-12 13:54:56',1,'UK-975','Economy',NULL,'passenger@airline.com','+919876543210',NULL),(23,'SKYT-X48ECB',2,'LOCAL_CATALOG',NULL,'DEL','BOM','2026-10-12','PENDING_PAYMENT',7716.80,'INR','2026-10-12 14:00:42',1,'UK-975','Economy',NULL,'passenger@airline.com','+919876543210',NULL),(24,'SKYT-8KEPBH',2,'LOCAL_CATALOG',NULL,'JAI','DEL','2026-10-13','PENDING_PAYMENT',5361.44,'INR','2026-10-12 17:13:18',10081,'AI 1844','Economy',NULL,'passenger@airline.com','+91 999 777 8888',NULL),(25,'SKYT-UBQZFU',2,'LOCAL_CATALOG',NULL,'JAI','DEL','2026-10-13','CONFIRMED',5361.44,'INR','2026-10-12 20:38:39',10001,'AI 1844','Economy',NULL,'passenger@airline.com','+91 999 777 8888','LY5NQQ'),(26,'SKYT-JMP3EU',2,'LOCAL_CATALOG',NULL,'JAI','DEL','2026-10-13','CONFIRMED',5361.44,'INR','2026-10-12 21:22:22',10001,'AI 1844','Economy',NULL,'passenger@airline.com','+91 999 777 8888','X2XHN8'),(27,'SKYT-B8GV5B',2,'LOCAL_CATALOG',NULL,'JAI','DEL','2026-10-13','PENDING_PAYMENT',5979.68,'INR','2026-10-13 04:50:07',10001,'6E 6492','Economy',NULL,'passenger@airline.com','+91 999 777 8888',NULL),(28,'SKYT-W44728',2,'LOCAL_CATALOG',NULL,'JAI','DEL','2026-10-13','CONFIRMED',5979.68,'INR','2026-10-13 04:50:13',10001,'6E 6492','Economy',NULL,'passenger@airline.com','+91 999 777 8888','XA6J84'),(29,'SKYT-2SBY4T',2,'LOCAL_CATALOG',NULL,'JAI','CCU','2026-10-13','PENDING_PAYMENT',204986.88,'INR','2026-10-13 08:44:53',10008,'AI 9123','Economy','4D','passenger@airline.com','+91 999 777 8888',NULL),(30,'SKYT-WWXHMT',2,'LOCAL_CATALOG',NULL,'JAI','CCU','2026-10-13','PENDING_PAYMENT',204986.88,'INR','2026-10-13 08:45:01',10008,'AI 9123','Economy','4D','passenger@airline.com','+91 999 777 8888',NULL),(31,'SKYT-8MRXL8',2,'LOCAL_CATALOG',NULL,'JAI','DEL','2026-10-13','CONFIRMED',5951.68,'INR','2026-10-13 09:03:07',10001,'6E 2376','Economy',NULL,'passenger@airline.com','+91 999 777 8888','5Q5JS8'),(32,'SKYT-U53NPN',1,'LOCAL_CATALOG',NULL,'JAI','DEL','2026-10-13','PENDING_PAYMENT',6142.08,'INR','2026-10-13 09:17:28',10011,'6E 2376','Economy',NULL,'admin@airline.com','+91 9876543210',NULL),(33,'SKYT-2BUF2G',2,'LOCAL_CATALOG',NULL,'JAI','DEL','2026-10-13','PENDING_PAYMENT',6142.08,'INR','2026-10-13 09:21:25',10011,'6E 2376','Economy',NULL,'passenger@airline.com','+91 999 777 8888',NULL);

INSERT IGNORE INTO passengers VALUES (1,1,'John','Doe','1995-05-15','MALE','P12345678','Indian','ADULT','12A','098-1-001'),(2,2,'John','Doe','1995-05-15','MALE','P12345678','Indian','ADULT','12A','098-2-001'),(3,3,'John','Doe','1995-05-15','MALE','P12345678','Indian','ADULT',NULL,'098-3-001'),(4,4,'John','Doe','1995-05-15','MALE','P12345678','Indian','ADULT','12A',NULL),(5,5,'John','Doe','1995-05-15','MALE','P12345678','Indian','ADULT','12A','098-5-001'),(6,6,'Test','Passenger','1992-08-20','MALE','P98765432','Indian','ADULT','14B',NULL),(7,7,'Test','Passenger','1992-08-20','MALE','P98765432','Indian','ADULT','14B',NULL),(8,8,'Test','Passenger','1992-08-20','MALE','P98765432','Indian','ADULT','14B','098-8-001'),(9,9,'John','Doe','1995-05-15','MALE','P12345678','Indian','ADULT','12A','098-9-001'),(10,10,'John','Doe','1995-05-15','MALE','P12345678','Indian','ADULT',NULL,NULL),(11,11,'John','Doe','1995-05-15','MALE','P12345678','Indian','ADULT',NULL,NULL),(12,12,'Rahul','Sharma','1995-04-12','MALE','P54321678','Indian','ADULT','16C','098-12-001'),(13,13,'John','Doe','1995-05-15','MALE','P12345678','Indian','ADULT','4D',NULL),(14,14,'Rahul','Sharma','1995-04-12','MALE','P54321678','Indian','ADULT','18D',NULL),(15,15,'System','Administrator','1985-01-01','MALE','ADM99988877','Indian','ADULT',NULL,'098-15-001'),(16,16,'Rahul','Sharma','1995-04-12','MALE','P9454321','Indian','ADULT',NULL,NULL),(17,17,'Aarav','Patel','1990-01-01','MALE','P89957','Indian','ADULT',NULL,'098-17-001'),(18,18,'John','Doe','1995-05-15','MALE','P12345678','Indian','ADULT','12A','098-18-001'),(19,19,'Rahul','Sharma','1995-04-12','MALE','P584321','Indian','ADULT',NULL,NULL),(20,20,'Aarav','Patel','1990-01-01','MALE','P70228','Indian','ADULT',NULL,'098-20-001'),(21,21,'Rahul','Sharma','1995-04-12','MALE','P4334321','Indian','ADULT',NULL,NULL),(22,22,'Rahul','Sharma','1995-04-12','MALE','P2964321','Indian','ADULT',NULL,NULL),(23,23,'Rahul','Sharma','1995-04-12','MALE','P6424321','Indian','ADULT',NULL,NULL),(24,24,'Ramesh','Kumar','1993-08-20','MALE','P99887766','Indian','ADULT',NULL,NULL),(25,25,'Ramesh','Kumar','1993-08-20','MALE','P99887766','Indian','ADULT',NULL,'098-25-001'),(26,26,'Ramesh','Kumar','1993-08-20','MALE','P99887766','Indian','ADULT',NULL,'098-26-001'),(27,27,'Ramesh','Kumar','1993-08-20','MALE','P99887766','Indian','ADULT',NULL,NULL),(28,28,'Ramesh','Kumar','1993-08-20','MALE','P99887766','Indian','ADULT',NULL,'098-28-001'),(29,29,'Ramesh','Kumar','1993-08-20','MALE','P99887766','Indian','ADULT','4D',NULL),(30,30,'Ramesh','Kumar','1993-08-20','MALE','P99887766','Indian','ADULT','4D',NULL),(31,31,'Ramesh','Kumar','1993-08-20','MALE','P99887766','Indian','ADULT',NULL,'098-31-001'),(32,32,'Team','SkyTech','1985-01-01','MALE','ADM99988877','Indian','ADULT',NULL,NULL),(33,33,'Ramesh','Kumar','1993-08-20','MALE','P99887766','Indian','ADULT',NULL,NULL);

INSERT IGNORE INTO payments VALUES (1,1,'REF_1791806661205',8780.80,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 12:04:21','order_sim_SKYT96HXS4_1791806661201',NULL,NULL),(2,1,'REF_4QZZN6',8780.80,'INR','RAZORPAY','SUCCESS','2026-10-12 12:04:21','2026-10-12 12:04:21','order_sim_SKYT96HXS4_1791806661331','pay_sim_1_999','sim_sig_verified_1'),(3,2,'REF_1791806697100',8780.80,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 12:04:57','order_sim_SKYT9BZUL4_1791806697100',NULL,NULL),(4,2,'REF_C6JADZ',8780.80,'INR','RAZORPAY','SUCCESS','2026-10-12 12:04:57','2026-10-12 12:04:57','order_sim_SKYT9BZUL4_1791806697135','pay_sim_2_999','sim_sig_verified_2'),(5,3,'REF_SSKCUT',6143.20,'INR','RAZORPAY','SUCCESS','2026-10-12 12:10:48','2026-10-12 12:10:39','order_sim_SKYTLK4NRB_1791807039630','pay_sim_order_sim_SKYTLK4NRB_1791807039630','sim_sig_verified_SKYT-LK4NRB'),(6,4,'REF_1791808398420',8780.80,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 12:33:18','order_sim_SKYTNU2G5U_1791808398413',NULL,NULL),(7,5,'REF_CFMESS',8780.80,'INR','RAZORPAY','SUCCESS','2026-10-12 12:34:31','2026-10-12 12:34:31','order_sim_SKYTXD3QS6_1791808471765','pay_sim_5_999','sim_sig_verified_5'),(8,6,'CANCELLED_BY_USER',7716.80,'INR','RAZORPAY','FAILED',NULL,'2026-10-12 12:35:02','order_sim_SKYTTFM4KT_1791808502604',NULL,NULL),(9,6,'REF_1791808502682',7716.80,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 12:35:02','order_sim_SKYTTFM4KT_1791808502682',NULL,NULL),(10,7,'CANCELLED_BY_USER',7716.80,'INR','RAZORPAY','FAILED',NULL,'2026-10-12 12:35:43','order_sim_SKYTQBBXMF_1791808543169',NULL,NULL),(11,7,'REF_1791808543233',7716.80,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 12:35:43','order_sim_SKYTQBBXMF_1791808543233',NULL,NULL),(12,8,'REF_ZMFEXS',7716.80,'INR','RAZORPAY','SUCCESS','2026-10-12 12:35:43','2026-10-12 12:35:43','order_sim_SKYTKBBKAE_1791808543305','pay_test_8_valid','sim_sig_verified_8'),(13,9,'REF_5N8VVK',8780.80,'INR','RAZORPAY','SUCCESS','2026-10-12 12:35:56','2026-10-12 12:35:56','order_sim_SKYT8TRL8H_1791808556590','pay_sim_9_999','sim_sig_verified_9'),(14,10,'REF_1791808645752',41093.92,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 12:37:25','order_sim_SKYTM4MRR7_1791808645745',NULL,NULL),(15,11,'REF_1791809199803',40032.16,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 12:46:39','order_Tn0B01akCnCEqa',NULL,NULL),(16,12,'REF_LHC2GP',7884.80,'INR','RAZORPAY','SUCCESS','2026-10-12 12:47:16','2026-10-12 12:46:57','order_Tn0BJgk5IuShNK','pay_test_live_verify_123','d06aba04b3042d3b899388376566945a094d7af3fdf50e848c63c3fa62d63c02'),(17,13,'REF_1791809297405',40424.16,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 12:48:17','order_Tn0Cibbvf6qLC0',NULL,NULL),(18,14,'REF_1791809793569',7884.80,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 12:56:33','order_Tn0LS9C3WLAkGB',NULL,NULL),(19,15,'REF_4XQFT5',9494.24,'INR','RAZORPAY','SUCCESS','2026-10-12 12:58:49','2026-10-12 12:56:51','order_Tn0LmAJSKpVzuH','pay_Tn0NTnxQu7RAva','db8ea9e9fcdc656a212db2f19f84c7e831b7b64ea2dccbfb1950eafd9f8e93e8'),(20,16,'REF_1791809945744',7716.80,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 12:59:05','order_Tn0O8HNhyYfzA5',NULL,NULL),(21,17,'REF_L4DVHN',7716.80,'INR','RAZORPAY','SUCCESS','2026-10-12 12:59:50','2026-10-12 12:59:50','order_Tn0Ov3lQiWN86H','pay_test_Tn0Ov3lQiWN86H','b6b5fe9a0aeff40b71fd5c3ad1a1ea87d0a8b72566101e55bb1d66e105e6bb1e'),(22,18,'REF_66QAJP',8780.80,'INR','RAZORPAY','SUCCESS','2026-10-12 13:00:01','2026-10-12 13:00:01','order_Tn0P6mDox01N80','pay_test_18_789','cfe98f62614dce83b45d33dbd6e92b54b877824d5b3647eada24f9e6fc5fcc6e'),(23,19,'REF_1791811059330',7716.80,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 13:17:39','order_Tn0hjocwDZI81C',NULL,NULL),(24,20,'REF_NKHTZS',7716.80,'INR','RAZORPAY','SUCCESS','2026-10-12 13:17:50','2026-10-12 13:17:50','order_Tn0hvwdM4Qxp9S','pay_test_Tn0hvwdM4Qxp9S','e61674d1d34b8cc5d7a6f1b4be80cb69c01730d0d1f534fa085695ea10bc0c9a'),(25,21,'REF_1791812434081',7716.80,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 13:40:34','order_Tn15wS87j5lnfV',NULL,NULL),(26,22,'REF_1791813296824',7716.80,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 13:54:56','order_Tn1L8CGCAY9nnd',NULL,NULL),(27,23,'REF_1791813642880',7716.80,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 14:00:42','order_Tn1RDvd5TiX2hf',NULL,NULL),(28,24,'REF_1791825199063',5361.44,'INR','RAZORPAY','PENDING',NULL,'2026-10-12 17:13:19','order_Tn4ifwrcs42kjz',NULL,NULL),(29,25,'REF_LY5NQQ',5361.44,'INR','RAZORPAY','SUCCESS','2026-10-12 20:39:39','2026-10-12 20:38:40','order_Tn8Db7OEMKuOVh','pay_Tn8EIRJvxRIxeA','faa07ad092d4c93c08085772982eebdb2e0b19507d1e9dd4ea531a7c60b02acc'),(30,26,'REF_X2XHN8',5361.44,'INR','RAZORPAY','SUCCESS','2026-10-12 21:23:12','2026-10-12 21:22:22','order_Tn8xm7CZ5pZdoK','pay_Tn8yHJfy3lz7tz','6d0ffa515c87471c42593f914a24757920af5340f339aa05878df06fdadd278f'),(31,27,'REF_1791867020719',5979.68,'INR','RAZORPAY','PENDING',NULL,'2026-10-13 04:50:20','order_TnGaxMJqqGZFus',NULL,NULL),(32,28,'REF_XA6J84',5979.68,'INR','RAZORPAY','SUCCESS','2026-10-13 04:53:02','2026-10-13 04:50:24','order_TnGb1HSzSVVAk0','pay_TnGd9yKwfRLvOc','33b7c8c544afa514f38c6a2ee4b0468eed5d27340dc126915a6a20b2721873d3'),(33,31,'REF_5Q5JS8',5951.68,'INR','RAZORPAY','SUCCESS','2026-10-13 09:05:06','2026-10-13 09:03:07','order_TnKtzIsD1i6lbj','pay_TnKvgnsAfby4xO','e0429b607b75083b2025c2c8c30aa354d95dd9f69f52a220f7caaaa8d7ed5c68'),(34,32,'REF_1791883048658',6142.08,'INR','RAZORPAY','PENDING',NULL,'2026-10-13 09:17:28','order_TnL98yG79GMJeG',NULL,NULL),(35,33,'REF_1791883286410',6142.08,'INR','RAZORPAY','PENDING',NULL,'2026-10-13 09:21:26','order_TnLDKQNVplC79t',NULL,NULL);

INSERT IGNORE INTO tickets VALUES (1,1,1,'098-1-001','4QZZN6','UK-975','DEL','BOM','2026-10-12 10:00:00','2026-10-12 12:00:00','12A','Economy','John Doe','CANCELLED','2026-10-12 12:04:21'),(2,2,2,'098-2-001','C6JADZ','UK-975','DEL','BOM','2026-10-12 10:00:00','2026-10-12 12:00:00','12A','Economy','John Doe','CANCELLED','2026-10-12 12:04:57'),(3,3,3,'098-3-001','SSKCUT','6E 2376','JAI','DEL','2026-10-12 10:00:00','2026-10-12 12:00:00',NULL,'Economy','John Doe','CONFIRMED','2026-10-12 12:10:48'),(4,5,5,'098-5-001','CFMESS','UK-975','DEL','BOM','2026-10-12 10:00:00','2026-10-12 12:00:00','12A','Economy','John Doe','CANCELLED','2026-10-12 12:34:31'),(5,8,8,'098-8-001','ZMFEXS','UK-975','DEL','BOM','2026-10-12 10:00:00','2026-10-12 12:00:00','14B','Economy','Test Passenger','CONFIRMED','2026-10-12 12:35:43'),(6,9,9,'098-9-001','5N8VVK','UK-975','DEL','BOM','2026-10-12 10:00:00','2026-10-12 12:00:00','12A','Economy','John Doe','CANCELLED','2026-10-12 12:35:56'),(7,12,12,'098-12-001','LHC2GP','UK-975','DEL','BOM','2026-10-12 10:00:00','2026-10-12 12:00:00','16C','Economy','Rahul Sharma','CONFIRMED','2026-10-12 12:47:16'),(8,15,15,'098-15-001','4XQFT5','IX 1235','DEL','GOI','2026-10-12 10:00:00','2026-10-12 12:00:00',NULL,'Economy','System Administrator','CONFIRMED','2026-10-12 12:58:49'),(9,17,17,'098-17-001','L4DVHN','UK-975','DEL','BOM','2026-10-12 10:00:00','2026-10-12 12:00:00',NULL,'Economy','Aarav Patel','CONFIRMED','2026-10-12 12:59:50'),(10,18,18,'098-18-001','66QAJP','UK-975','DEL','BOM','2026-10-12 10:00:00','2026-10-12 12:00:00','12A','Economy','John Doe','CANCELLED','2026-10-12 13:00:01'),(11,20,20,'098-20-001','NKHTZS','UK-975','DEL','BOM','2026-10-12 10:00:00','2026-10-12 12:00:00',NULL,'Economy','Aarav Patel','CONFIRMED','2026-10-12 13:17:50'),(12,25,25,'098-25-001','LY5NQQ','AI 1844','JAI','DEL','2026-10-13 10:00:00','2026-10-13 12:00:00',NULL,'Economy','Ramesh Kumar','CONFIRMED','2026-10-12 20:39:39'),(13,26,26,'098-26-001','X2XHN8','AI 1844','JAI','DEL','2026-10-13 10:00:00','2026-10-13 12:00:00',NULL,'Economy','Ramesh Kumar','CONFIRMED','2026-10-12 21:23:12'),(14,28,28,'098-28-001','XA6J84','6E 6492','JAI','DEL','2026-10-13 10:00:00','2026-10-13 12:00:00',NULL,'Economy','Ramesh Kumar','CONFIRMED','2026-10-13 04:53:02'),(15,31,31,'098-31-001','5Q5JS8','6E 2376','JAI','DEL','2026-10-13 10:00:00','2026-10-13 12:00:00',NULL,'Economy','Ramesh Kumar','CONFIRMED','2026-10-13 09:05:06');

INSERT IGNORE INTO cancellations VALUES (1,1,'4QZZN6','College demonstration verification',1000.00,7780.80,'COMPLETED','REF_RFND_1791806662021',2,'2026-10-12 12:04:22'),(2,2,'C6JADZ','College demonstration verification',1000.00,7780.80,'COMPLETED','REF_RFND_1791806697333',2,'2026-10-12 12:04:57'),(3,5,'CFMESS','College demonstration verification',1000.00,7780.80,'RECORDED_ACADEMIC_REFUND','SIM_RFND_1791808473174',2,'2026-10-12 12:34:33'),(4,9,'5N8VVK','College demonstration verification',1000.00,7780.80,'RECORDED_ACADEMIC_REFUND','SIM_RFND_1791808556853',2,'2026-10-12 12:35:56'),(5,18,'66QAJP','College demonstration verification',1000.00,7780.80,'REFUND_PENDING','PENDING_GATEWAY_RECONCILIATION',2,'2026-10-12 13:00:03');

INSERT IGNORE INTO admin_audit_logs VALUES (1,1,'System Administrator','CREATE_FLIGHT','FLIGHT','ST-1655','Scheduled flight ST-1655 for date 2026-11-20','SUCCESS','2026-10-12 19:00:55'),(2,1,'System Administrator','CREATE_AIRPORT','AIRPORT','T66','Added airport T66 (TestCity)','SUCCESS','2026-10-12 19:00:56'),(3,1,'System Administrator','UPDATE_ADMIN_PROFILE','USER','1','Updated administrator name to System Administrator (Phone: +18005550199)','SUCCESS','2026-10-12 20:52:25'),(4,1,'System Administrator','UPDATE_ADMIN_PROFILE','USER','1','Updated administrator name to Team SkyTech (Phone: +91 9876543210)','SUCCESS','2026-10-12 21:06:49'),(5,1,'Team SkyTech','UPDATE_STATUS','FLIGHT_SCHEDULE','128','Updated schedule status to DELAYED','SUCCESS','2026-10-13 04:54:04');
