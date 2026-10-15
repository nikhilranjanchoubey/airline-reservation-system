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
    CONSTRAINT fk_flights_dest FOREIGN KEY (destination_airport_id) REFERENCES airports(airport_id) ON DELETE CASCADE
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
    CONSTRAINT uq_flight_date UNIQUE (flight_id, flight_date)
) ENGINE=InnoDB;

-- Indexes for performance
CREATE INDEX idx_flights_route ON flights(source_airport_id, destination_airport_id);
CREATE INDEX idx_schedules_date ON flight_schedules(flight_date);
CREATE INDEX idx_schedules_search ON flight_schedules(flight_id, flight_date, available_seats);

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
INSERT INTO flight_schedules (flight_id, flight_date, base_price, economy_price, premiumEconomy_price, business_price, first_class_price, available_seats, total_seats, status)
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
) d
ON DUPLICATE KEY UPDATE available_seats=VALUES(available_seats);

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
    row_number INT NOT NULL,
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
INSERT INTO aircraft_seats (aircraft_id, seat_number, row_number, column_letter, seat_type, premium_fee)
SELECT 
    (SELECT aircraft_id FROM aircraft WHERE model_name = 'Airbus A320neo') AS aircraft_id,
    CONCAT(r.num, c.col) AS seat_number,
    r.num AS row_number,
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
ON DUPLICATE KEY UPDATE seat_type=VALUES(seat_type);

-- Seed some occupied and blocked seats for first few schedules
INSERT INTO flight_seat_inventory (schedule_id, seat_id, status)
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
ON DUPLICATE KEY UPDATE status=VALUES(status);

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

