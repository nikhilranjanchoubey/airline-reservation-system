# SKYTECH Airlines — Team Integration Contracts

This document formalizes the boundary contracts between Module 3 (Booking & Passenger Management) and other project team members.

## 1. Module 1: Authentication & User Management
- **Interface**: `com.skytech.airlines.booking.integration.AuthenticationProvider`
- **Method**:
  ```java
  Long getAuthenticatedUserId(HttpServletRequest request);
  String getAuthenticatedUserEmail(HttpServletRequest request);
  String getAuthenticatedUserName(HttpServletRequest request);
  boolean isAuthenticated(HttpServletRequest request);
  ```
- **Session Agreement**: Module 1 stores either `userId` (Long), `userEmail` (String), and `userName` (String), or a session attribute `user` containing a User POJO with standard getter methods.
- **Development Fallback**: `AdaptiveAuthenticationProvider` automatically handles either format and falls back to Capt. Rajesh Sharma (User ID #1) in development mode.

## 2. Module 2: Flight Search & Availability
- **Interface**: `com.skytech.airlines.booking.integration.FlightProvider`
- **Method**:
  ```java
  FlightSummary getFlightById(Long flightId);
  boolean hasAvailableSeats(Long flightId, int requiredSeats);
  List<FlightSummary> getSampleFlights();
  ```
- **Flight Identification**: Team modules agree on a numeric `flight_id` (BIGINT) identifying a specific flight instance/schedule.

## 3. Module 4: Ticketing & Cancellation
- **Service Interface**: `com.skytech.airlines.booking.integration.IBookingExportService`
- **REST JSON Endpoint**: `GET /api/booking/details?pnr={PNR}`
- **Cancellation Contract**:
  ```java
  boolean cancelBookingByPnr(String pnr, String reason);
  ```
- **Atomicity**: Cancelling a booking automatically transitions `booking_status` to `CANCELLED`, `allocation_status` to `RELEASED` (returning seats to available inventory), and `payment_status` to `REFUNDED`.

## 4. Module 5: Admin Dashboard
- **DAO Contract**: `com.skytech.airlines.booking.dao.BookingDAO`
- **Method**:
  ```java
  List<Booking> findAllBookings();
  ```
- Exposes complete flight booking records, passenger count, total revenues, and seat occupancy for administrative dashboards.
