-- =============================================================================
-- SKYTECH AIRLINES - MODULE 3: BOOKING & PASSENGER MANAGEMENT
-- Database Schema Definition (MySQL 8.0+ / 8.4 LTS)
-- File: database/schema.sql
-- =============================================================================
-- Notice on Architecture and Team Boundary Ownership:
--
-- 1. Tables OWNED by Module 3:
--    - bookings (Header record, PNR, totals, contact)
--    - passengers (Traveler demographics and documents)
--    - booking_passengers (Junction association with seat & status)
--    - seat_allocations (Flight cabin seat reservation lock & duplicate guard)
--    - payments (Payment transactions, Razorpay gateway identifiers, audit)
--
-- 2. Tables OWNED by Other Modules (Included here as development mocks for standalone execution):
--    - shared_users_dev_mock (Owned by Module 1: Authentication & User Management)
--    - shared_flights_dev_mock (Owned by Module 2: Flight Search & Module 5: Admin Management)
--
-- During team integration:
-- - The foreign keys in 'bookings' and 'seat_allocations' will point to the shared
--   'users' and 'flights' tables provided by the team without altering Module 3 tables.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS skytech_airlines_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE skytech_airlines_db;

-- Safely drop existing tables in reverse dependency order for clean recreation
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS seat_allocations;
DROP TABLE IF EXISTS booking_passengers;
DROP TABLE IF EXISTS passengers;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS shared_flights_dev_mock;
DROP TABLE IF EXISTS shared_users_dev_mock;

-- -----------------------------------------------------------------------------
-- SECTION 1: SHARED DEVELOPMENT MOCK TABLES (Owned by Modules 1, 2, & 5)
-- -----------------------------------------------------------------------------

-- MOCK TABLE: Users (Module 1 Reference)
CREATE TABLE shared_users_dev_mock (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    role VARCHAR(20) DEFAULT 'PASSENGER',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- MOCK TABLE: Flights (Modules 2 & 5 Reference)
CREATE TABLE shared_flights_dev_mock (
    flight_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(20) NOT NULL UNIQUE,
    airline_name VARCHAR(100) NOT NULL DEFAULT 'SKYTECH AIRLINES',
    aircraft_model VARCHAR(50) DEFAULT 'Airbus A320neo',
    origin_airport_code VARCHAR(10) NOT NULL,
    origin_city VARCHAR(100) NOT NULL,
    dest_airport_code VARCHAR(10) NOT NULL,
    dest_city VARCHAR(100) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    duration_minutes INT NOT NULL,
    base_fare DECIMAL(10, 2) NOT NULL,
    total_seats INT NOT NULL DEFAULT 180,
    available_seats INT NOT NULL DEFAULT 180,
    captain_name VARCHAR(100) NOT NULL DEFAULT 'Capt. Rajesh Sharma',
    frequent_flyer_miles INT NOT NULL DEFAULT 750,
    frequent_flyer_tier VARCHAR(100) NOT NULL DEFAULT 'Silver Tier',
    frequent_flyer_perks VARCHAR(255) NOT NULL DEFAULT '1.0x Base Miles &bull; Priority Boarding',
    flight_status VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED'
) ENGINE=InnoDB;


-- -----------------------------------------------------------------------------
-- SECTION 2: MODULE 3 OWNED TABLES (Booking & Passenger Management)
-- -----------------------------------------------------------------------------

-- TABLE 1: bookings
CREATE TABLE bookings (
    booking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pnr VARCHAR(10) NOT NULL,
    user_id BIGINT NULL, -- Nullable to support Guest / Unregistered passenger bookings
    flight_id BIGINT NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED', -- 'PENDING', 'CONFIRMED', 'CANCELLED'
    base_fare DECIMAL(10, 2) NOT NULL,
    seat_fees DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL,
    contact_email VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Uniqueness constraint on PNR (6-character alphanumeric identifier)
    CONSTRAINT uq_bookings_pnr UNIQUE (pnr),

    CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) 
        REFERENCES shared_users_dev_mock (user_id) ON DELETE SET NULL,
    CONSTRAINT fk_bookings_flight FOREIGN KEY (flight_id) 
        REFERENCES shared_flights_dev_mock (flight_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_bookings_pnr ON bookings (pnr);
CREATE INDEX idx_bookings_user_id ON bookings (user_id);
CREATE INDEX idx_bookings_flight_id ON bookings (flight_id);
CREATE INDEX idx_bookings_date ON bookings (booking_date);
CREATE INDEX idx_bookings_status ON bookings (booking_status);


-- TABLE 2: passengers
CREATE TABLE passengers (
    passenger_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL, -- 'MALE', 'FEMALE', 'OTHER'
    passenger_type VARCHAR(20) NOT NULL DEFAULT 'ADULT', -- 'ADULT', 'CHILD', 'INFANT'
    passport_or_id VARCHAR(50),
    nationality VARCHAR(50) DEFAULT 'Indian',
    seat_number VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_passengers_booking FOREIGN KEY (booking_id) 
        REFERENCES bookings (booking_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_passengers_booking_id ON passengers (booking_id);
CREATE INDEX idx_passengers_name ON passengers (last_name, first_name);


-- TABLE 3: booking_passengers
CREATE TABLE booking_passengers (
    booking_passenger_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    passenger_id BIGINT NOT NULL,
    seat_number VARCHAR(10),
    passenger_status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED', -- 'CONFIRMED', 'CHECKED_IN', 'CANCELLED'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_booking_passenger UNIQUE (booking_id, passenger_id),
    CONSTRAINT fk_bp_booking FOREIGN KEY (booking_id) 
        REFERENCES bookings (booking_id) ON DELETE CASCADE,
    CONSTRAINT fk_bp_passenger FOREIGN KEY (passenger_id) 
        REFERENCES passengers (passenger_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_bp_booking_id ON booking_passengers (booking_id);
CREATE INDEX idx_bp_passenger_id ON booking_passengers (passenger_id);


-- TABLE 4: seat_allocations
CREATE TABLE seat_allocations (
    allocation_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    passenger_id BIGINT NULL,
    flight_id BIGINT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_class VARCHAR(20) NOT NULL DEFAULT 'ECONOMY', -- 'BUSINESS', 'PREMIUM_ECONOMY', 'ECONOMY'
    seat_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    allocation_status VARCHAR(20) NOT NULL DEFAULT 'HELD', -- 'HELD', 'ALLOCATED', 'RELEASED', 'EXPIRED'
    allocated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_flight_seat_active UNIQUE (flight_id, seat_number, allocation_status),
    
    CONSTRAINT fk_allocations_booking FOREIGN KEY (booking_id) 
        REFERENCES bookings (booking_id) ON DELETE CASCADE,
    CONSTRAINT fk_allocations_passenger FOREIGN KEY (passenger_id) 
        REFERENCES passengers (passenger_id) ON DELETE CASCADE,
    CONSTRAINT fk_allocations_flight FOREIGN KEY (flight_id) 
        REFERENCES shared_flights_dev_mock (flight_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_allocations_flight_seat ON seat_allocations (flight_id, seat_number);
CREATE INDEX idx_allocations_booking_id ON seat_allocations (booking_id);


-- TABLE 5: payments
CREATE TABLE payments (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    payment_reference VARCHAR(64) NOT NULL UNIQUE,
    razorpay_order_id VARCHAR(100) NULL,
    razorpay_payment_id VARCHAR(100) NULL,
    razorpay_signature VARCHAR(255) NULL,
    payment_method VARCHAR(30) NOT NULL DEFAULT 'ONLINE', -- 'RAZORPAY', 'CARD', 'UPI', 'NETBANKING'
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    payment_status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS', -- 'PENDING', 'SUCCESS', 'FAILED', 'REFUNDED'
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) 
        REFERENCES bookings (booking_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_payments_booking_id ON payments (booking_id);
CREATE INDEX idx_payments_reference ON payments (payment_reference);
CREATE INDEX idx_payments_razorpay_order ON payments (razorpay_order_id);
CREATE INDEX idx_payments_status ON payments (payment_status);


-- -----------------------------------------------------------------------------
-- SECTION 3: DEVELOPMENT SEED DATA
-- -----------------------------------------------------------------------------

-- 1. Seed Mock Users
INSERT INTO shared_users_dev_mock (user_id, full_name, email, phone, role) 
VALUES (1, 'Rajesh Sharma', 'rajesh.sharma@example.com', '+91 9876543210', 'PASSENGER');

INSERT INTO shared_users_dev_mock (user_id, full_name, email, phone, role) 
VALUES (2, 'Priya Nair', 'priya.nair@example.com', '+91 9811223344', 'PASSENGER');

-- 2. Seed Mock Flights
INSERT INTO shared_flights_dev_mock (
    flight_id, flight_number, airline_name, aircraft_model,
    origin_airport_code, origin_city, dest_airport_code, dest_city,
    departure_time, arrival_time, duration_minutes, base_fare, total_seats, available_seats, captain_name,
    frequent_flyer_miles, frequent_flyer_tier, frequent_flyer_perks, flight_status
) VALUES (
    101, 'SK-701', 'SKYTECH AIRLINES', 'Airbus A320neo',
    'DEL', 'New Delhi (DEL)', 'BOM', 'Mumbai (BOM)',
    DATE_ADD(NOW(), INTERVAL 3 DAY), DATE_ADD(NOW(), INTERVAL '3 DAY 2 HOUR 15 MINUTE'),
    135, 4500.00, 180, 142, 'Capt. Rajesh Sharma',
    710, 'Silver Tier', '1.0x Base Miles &bull; Complimentary Beverage', 'SCHEDULED'
);

INSERT INTO shared_flights_dev_mock (
    flight_id, flight_number, airline_name, aircraft_model,
    origin_airport_code, origin_city, dest_airport_code, dest_city,
    departure_time, arrival_time, duration_minutes, base_fare, total_seats, available_seats, captain_name,
    frequent_flyer_miles, frequent_flyer_tier, frequent_flyer_perks, flight_status
) VALUES (
    102, 'SK-304', 'SKYTECH AIRLINES', 'Boeing 737-800',
    'BLR', 'Bengaluru (BLR)', 'DEL', 'New Delhi (DEL)',
    DATE_ADD(NOW(), INTERVAL 3 DAY), DATE_ADD(NOW(), INTERVAL '3 DAY 2 HOUR 45 MINUTE'),
    165, 5200.00, 180, 86, 'Capt. Ananya Roy',
    1060, 'Gold Privilege', '1.25x Bonus Miles &bull; Priority Check-in', 'SCHEDULED'
);

INSERT INTO shared_flights_dev_mock (
    flight_id, flight_number, airline_name, aircraft_model,
    origin_airport_code, origin_city, dest_airport_code, dest_city,
    departure_time, arrival_time, duration_minutes, base_fare, total_seats, available_seats, captain_name,
    frequent_flyer_miles, frequent_flyer_tier, frequent_flyer_perks, flight_status
) VALUES (
    103, 'SK-902', 'SKYTECH AIRLINES', 'Boeing 787-9 Dreamliner',
    'BOM', 'Mumbai (BOM)', 'DXB', 'Dubai Intl (DXB)',
    DATE_ADD(NOW(), INTERVAL 4 DAY), DATE_ADD(NOW(), INTERVAL '4 DAY 3 HOUR 30 MINUTE'),
    210, 12500.00, 240, 118, 'Capt. Vikramaditya Rathore',
    1200, 'Platinum Elite', '1.5x Bonus Miles &bull; Dubai Lounge Access', 'SCHEDULED'
);

INSERT INTO shared_flights_dev_mock (
    flight_id, flight_number, airline_name, aircraft_model,
    origin_airport_code, origin_city, dest_airport_code, dest_city,
    departure_time, arrival_time, duration_minutes, base_fare, total_seats, available_seats, captain_name,
    frequent_flyer_miles, frequent_flyer_tier, frequent_flyer_perks, flight_status
) VALUES (
    104, 'SK-415', 'SKYTECH AIRLINES', 'Airbus A320neo',
    'BOM', 'Mumbai (BOM)', 'GOI', 'Goa Dabolim (GOI)',
    DATE_ADD(NOW(), INTERVAL 3 DAY), DATE_ADD(NOW(), INTERVAL '3 DAY 1 HOUR 15 MINUTE'),
    75, 3200.00, 180, 64, 'Capt. Sameer Kulkarni',
    430, 'Silver Tier', '1.0x Base Miles &bull; Quick Baggage Drop', 'SCHEDULED'
);

INSERT INTO shared_flights_dev_mock (
    flight_id, flight_number, airline_name, aircraft_model,
    origin_airport_code, origin_city, dest_airport_code, dest_city,
    departure_time, arrival_time, duration_minutes, base_fare, total_seats, available_seats, captain_name,
    frequent_flyer_miles, frequent_flyer_tier, frequent_flyer_perks, flight_status
) VALUES (
    105, 'SK-528', 'SKYTECH AIRLINES', 'Airbus A321neo',
    'DEL', 'New Delhi (DEL)', 'BLR', 'Bengaluru (BLR)',
    DATE_ADD(NOW(), INTERVAL 4 DAY), DATE_ADD(NOW(), INTERVAL '4 DAY 2 HOUR 50 MINUTE'),
    170, 5400.00, 220, 175, 'Capt. Neha Singhania',
    1060, 'Gold Privilege', '1.25x Bonus Miles &bull; Free Standard Seat Selection', 'SCHEDULED'
);

INSERT INTO shared_flights_dev_mock (
    flight_id, flight_number, airline_name, aircraft_model,
    origin_airport_code, origin_city, dest_airport_code, dest_city,
    departure_time, arrival_time, duration_minutes, base_fare, total_seats, available_seats, captain_name,
    frequent_flyer_miles, frequent_flyer_tier, frequent_flyer_perks, flight_status
) VALUES (
    106, 'SK-612', 'SKYTECH AIRLINES', 'Boeing 737-800',
    'CCU', 'Kolkata (CCU)', 'BOM', 'Mumbai (BOM)',
    DATE_ADD(NOW(), INTERVAL 4 DAY), DATE_ADD(NOW(), INTERVAL '4 DAY 2 HOUR 50 MINUTE'),
    170, 4800.00, 180, 92, 'Capt. Sourav Mukherjee',
    1020, 'Silver Tier', '1.0x Base Miles &bull; Extra 5kg Baggage', 'SCHEDULED'
);

INSERT INTO shared_flights_dev_mock (
    flight_id, flight_number, airline_name, aircraft_model,
    origin_airport_code, origin_city, dest_airport_code, dest_city,
    departure_time, arrival_time, duration_minutes, base_fare, total_seats, available_seats, captain_name,
    frequent_flyer_miles, frequent_flyer_tier, frequent_flyer_perks, flight_status
) VALUES (
    107, 'SK-220', 'SKYTECH AIRLINES', 'Airbus A320neo',
    'HYD', 'Hyderabad (HYD)', 'DEL', 'New Delhi (DEL)',
    DATE_ADD(NOW(), INTERVAL 5 DAY), DATE_ADD(NOW(), INTERVAL '5 DAY 2 HOUR 15 MINUTE'),
    135, 4650.00, 180, 128, 'Capt. Arjun Varma',
    780, 'Gold Privilege', '1.25x Bonus Miles &bull; Express Baggage Delivery', 'SCHEDULED'
);

INSERT INTO shared_flights_dev_mock (
    flight_id, flight_number, airline_name, aircraft_model,
    origin_airport_code, origin_city, dest_airport_code, dest_city,
    departure_time, arrival_time, duration_minutes, base_fare, total_seats, available_seats, captain_name,
    frequent_flyer_miles, frequent_flyer_tier, frequent_flyer_perks, flight_status
) VALUES (
    108, 'SK-880', 'SKYTECH AIRLINES', 'Boeing 787-9 Dreamliner',
    'MAA', 'Chennai (MAA)', 'SIN', 'Singapore Changi (SIN)',
    DATE_ADD(NOW(), INTERVAL 5 DAY), DATE_ADD(NOW(), INTERVAL '6 DAY 0 HOUR 45 MINUTE'),
    240, 14800.00, 240, 74, 'Capt. Meenakshi Sundaram',
    1820, 'Platinum Elite', '1.5x Bonus Miles &bull; Changi Lounge &bull; Fast-Track Boarding', 'SCHEDULED'
);

INSERT INTO shared_flights_dev_mock (
    flight_id, flight_number, airline_name, aircraft_model,
    origin_airport_code, origin_city, dest_airport_code, dest_city,
    departure_time, arrival_time, duration_minutes, base_fare, total_seats, available_seats, captain_name,
    frequent_flyer_miles, frequent_flyer_tier, frequent_flyer_perks, flight_status
) VALUES (
    109, 'SK-114', 'SKYTECH AIRLINES', 'Airbus A350-900',
    'DEL', 'New Delhi (DEL)', 'LHR', 'London Heathrow (LHR)',
    DATE_ADD(NOW(), INTERVAL 6 DAY), DATE_ADD(NOW(), INTERVAL '6 DAY 9 HOUR 20 MINUTE'),
    560, 38500.00, 300, 153, 'Capt. Harpreet Singh Brar',
    4180, 'Diamond Executive', '2.0x Double Miles &bull; Heathrow VIP Lounge &bull; +15kg Baggage', 'SCHEDULED'
);

INSERT INTO shared_flights_dev_mock (
    flight_id, flight_number, airline_name, aircraft_model,
    origin_airport_code, origin_city, dest_airport_code, dest_city,
    departure_time, arrival_time, duration_minutes, base_fare, total_seats, available_seats, captain_name,
    frequent_flyer_miles, frequent_flyer_tier, frequent_flyer_perks, flight_status
) VALUES (
    110, 'SK-332', 'SKYTECH AIRLINES', 'Airbus A320neo',
    'AMD', 'Ahmedabad (AMD)', 'BOM', 'Mumbai (BOM)',
    DATE_ADD(NOW(), INTERVAL 3 DAY), DATE_ADD(NOW(), INTERVAL '3 DAY 1 HOUR 15 MINUTE'),
    75, 2900.00, 180, 49, 'Capt. Rohan Patel',
    330, 'Silver Tier', '1.0x Base Miles &bull; Priority Gate Service', 'SCHEDULED'
);

INSERT INTO shared_flights_dev_mock (
    flight_id, flight_number, airline_name, aircraft_model,
    origin_airport_code, origin_city, dest_airport_code, dest_city,
    departure_time, arrival_time, duration_minutes, base_fare, total_seats, available_seats, captain_name,
    frequent_flyer_miles, frequent_flyer_tier, frequent_flyer_perks, flight_status
) VALUES (
    111, 'SK-745', 'SKYTECH AIRLINES', 'ATR 72-600',
    'BLR', 'Bengaluru (BLR)', 'GOI', 'Goa Dabolim (GOI)',
    DATE_ADD(NOW(), INTERVAL 4 DAY), DATE_ADD(NOW(), INTERVAL '4 DAY 1 HOUR 20 MINUTE'),
    80, 3100.00, 78, 31, 'Capt. Tanvi Hegde',
    360, 'Silver Tier', '1.0x Base Miles &bull; Vacation Rewards Multiplier', 'SCHEDULED'
);

INSERT INTO shared_flights_dev_mock (
    flight_id, flight_number, airline_name, aircraft_model,
    origin_airport_code, origin_city, dest_airport_code, dest_city,
    departure_time, arrival_time, duration_minutes, base_fare, total_seats, available_seats, captain_name,
    frequent_flyer_miles, frequent_flyer_tier, frequent_flyer_perks, flight_status
) VALUES (
    112, 'SK-950', 'SKYTECH AIRLINES', 'Boeing 737 MAX 8',
    'DEL', 'New Delhi (DEL)', 'BKK', 'Bangkok Suvarnabhumi (BKK)',
    DATE_ADD(NOW(), INTERVAL 5 DAY), DATE_ADD(NOW(), INTERVAL '5 DAY 4 HOUR 20 MINUTE'),
    260, 11200.00, 189, 104, 'Capt. Devendra Joshi',
    1840, 'Platinum Elite', '1.5x Bonus Miles &bull; Suvarnabhumi VIP Fast-Track', 'SCHEDULED'
);

-- 3. Seed Sample Existing Booking (PNR: SK8M2P)
INSERT INTO bookings (
    booking_id, pnr, user_id, flight_id, booking_status,
    base_fare, seat_fees, tax_amount, total_amount,
    contact_email, contact_phone
) VALUES (
    1, 'SK8M2P', 2, 101, 'CONFIRMED',
    4500.00, 500.00, 600.00, 5600.00,
    'priya.nair@example.com', '+91 9811223344'
);

INSERT INTO passengers (
    passenger_id, booking_id, first_name, last_name,
    date_of_birth, gender, passenger_type, seat_number
) VALUES (
    1, 1, 'Priya', 'Nair', '1995-04-12', 'FEMALE', 'ADULT', '12A'
);

INSERT INTO booking_passengers (
    booking_passenger_id, booking_id, passenger_id, seat_number, passenger_status
) VALUES (
    1, 1, 1, '12A', 'CONFIRMED'
);

INSERT INTO seat_allocations (
    allocation_id, booking_id, passenger_id, flight_id, seat_number, seat_class, seat_price, allocation_status
) VALUES 
(1, 1, 1, 101, '12A', 'PREMIUM_ECONOMY', 500.00, 'ALLOCATED'),
(2, 1, NULL, 101, '12B', 'ECONOMY', 0.00, 'ALLOCATED');

INSERT INTO payments (
    payment_id, booking_id, payment_reference, razorpay_order_id, razorpay_payment_id,
    payment_method, amount, currency, payment_status
) VALUES (
    1, 1, 'PAY-SK8M2P-001', 'order_mock_001', 'pay_mock_001',
    'RAZORPAY', 5600.00, 'INR', 'SUCCESS'
);
