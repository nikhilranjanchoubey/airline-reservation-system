package com.skytech.dao;

import com.skytech.util.DBConnectionUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object providing aggregated operational analytics,
 * KPIs, charts data, and operational summaries for the SkyTech Admin Dashboard.
 */
public class AdminDashboardDao {

    private static final Logger LOGGER = Logger.getLogger(AdminDashboardDao.class.getName());

    public Map<String, Object> getDashboardKpis() {
        Map<String, Object> kpis = new HashMap<>();

        // Default zeroes
        kpis.put("totalPassengers", 0L);
        kpis.put("registeredAccounts", 0L);
        kpis.put("totalReservations", 0L);
        kpis.put("confirmedBookings", 0L);
        kpis.put("pendingPayments", 0L);
        kpis.put("cancelledBookings", 0L);
        kpis.put("totalFlights", 0L);
        kpis.put("verifiedRevenue", BigDecimal.ZERO);

        try (Connection conn = DBConnectionUtil.getConnection()) {
            // 1. Total Passengers
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM passengers")) {
                if (rs.next()) kpis.put("totalPassengers", rs.getLong(1));
            }

            // 2. Registered Accounts
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM users WHERE role = 'PASSENGER'")) {
                if (rs.next()) kpis.put("registeredAccounts", rs.getLong(1));
            }

            // 3. Total Reservations
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM bookings")) {
                if (rs.next()) kpis.put("totalReservations", rs.getLong(1));
            }

            // 4. Confirmed Bookings
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM bookings WHERE status = 'CONFIRMED'")) {
                if (rs.next()) kpis.put("confirmedBookings", rs.getLong(1));
            }

            // 5. Pending Payments
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM bookings WHERE status = 'PENDING_PAYMENT'")) {
                if (rs.next()) kpis.put("pendingPayments", rs.getLong(1));
            }

            // 6. Cancelled Bookings
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM bookings WHERE status = 'CANCELLED'")) {
                if (rs.next()) kpis.put("cancelledBookings", rs.getLong(1));
            }

            // 7. Total Flights
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM flights")) {
                if (rs.next()) kpis.put("totalFlights", rs.getLong(1));
            }

            // 8. Revenue from Verified Payments (only payments with status = 'SUCCESS' and booking confirmed)
            String revSql = "SELECT COALESCE(SUM(p.amount), 0) FROM payments p " +
                            "JOIN bookings b ON p.booking_id = b.id " +
                            "WHERE p.status = 'SUCCESS' AND b.status = 'CONFIRMED'";
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(revSql)) {
                if (rs.next()) {
                    BigDecimal rev = rs.getBigDecimal(1);
                    kpis.put("verifiedRevenue", rev != null ? rev : BigDecimal.ZERO);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to compute dashboard KPIs: " + e.getMessage(), e);
        }

        return kpis;
    }

    public List<Map<String, Object>> getUpcomingDepartures(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT fs.schedule_id, f.flight_number, al.airline_name, al.airline_code, " +
                     "sa.airport_code AS origin_code, sa.city AS origin_city, " +
                     "da.airport_code AS dest_code, da.city AS dest_city, " +
                     "fs.flight_date, f.departure_time, f.arrival_time, fs.available_seats, fs.total_seats, fs.status " +
                     "FROM flight_schedules fs " +
                     "JOIN flights f ON fs.flight_id = f.flight_id " +
                     "JOIN airlines al ON f.airline_id = al.airline_id " +
                     "JOIN airports sa ON f.source_airport_id = sa.airport_id " +
                     "JOIN airports da ON f.destination_airport_id = da.airport_id " +
                     "ORDER BY fs.flight_date ASC, f.departure_time ASC " +
                     "LIMIT ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit > 0 ? limit : 5);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("scheduleId", rs.getInt("schedule_id"));
                    map.put("flightNumber", rs.getString("flight_number"));
                    map.put("airlineName", rs.getString("airline_name"));
                    map.put("airlineCode", rs.getString("airline_code"));
                    map.put("originCode", rs.getString("origin_code"));
                    map.put("originCity", rs.getString("origin_city"));
                    map.put("destCode", rs.getString("dest_code"));
                    map.put("destCity", rs.getString("dest_city"));
                    map.put("flightDate", rs.getDate("flight_date"));
                    map.put("departureTime", rs.getTime("departure_time"));
                    map.put("arrivalTime", rs.getTime("arrival_time"));
                    map.put("availableSeats", rs.getInt("available_seats"));
                    map.put("totalSeats", rs.getInt("total_seats"));
                    map.put("status", rs.getString("status"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get upcoming departures: " + e.getMessage(), e);
        }
        return list;
    }

    public List<Map<String, Object>> getRecentReservations(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT b.id, b.booking_reference, b.pnr, b.flight_number, b.origin_code, b.destination_code, " +
                     "b.departure_date, b.status, b.total_amount, b.contact_email, b.created_at, " +
                     "(SELECT COUNT(*) FROM passengers p WHERE p.booking_id = b.id) AS passenger_count, " +
                     "(SELECT p.status FROM payments p WHERE p.booking_id = b.id ORDER BY p.id DESC LIMIT 1) AS payment_status " +
                     "FROM bookings b " +
                     "ORDER BY b.created_at DESC " +
                     "LIMIT ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit > 0 ? limit : 5);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getLong("id"));
                    map.put("bookingReference", rs.getString("booking_reference"));
                    map.put("pnr", rs.getString("pnr"));
                    map.put("flightNumber", rs.getString("flight_number"));
                    map.put("originCode", rs.getString("origin_code"));
                    map.put("destCode", rs.getString("destination_code"));
                    map.put("departureDate", rs.getDate("departure_date"));
                    map.put("status", rs.getString("status"));
                    map.put("totalAmount", rs.getBigDecimal("total_amount"));
                    map.put("contactEmail", rs.getString("contact_email"));
                    map.put("createdAt", rs.getTimestamp("created_at"));
                    map.put("passengerCount", rs.getInt("passenger_count"));
                    map.put("paymentStatus", rs.getString("payment_status"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get recent reservations: " + e.getMessage(), e);
        }
        return list;
    }

    public List<Map<String, Object>> getRecentSuccessfulPayments(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.id, p.payment_reference, p.amount, p.currency, p.status, p.paid_at, " +
                     "p.razorpay_payment_id, p.razorpay_order_id, b.booking_reference, b.pnr, b.flight_number, b.contact_email " +
                     "FROM payments p " +
                     "JOIN bookings b ON p.booking_id = b.id " +
                     "WHERE p.status = 'SUCCESS' " +
                     "ORDER BY p.paid_at DESC, p.created_at DESC " +
                     "LIMIT ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit > 0 ? limit : 5);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getLong("id"));
                    map.put("paymentReference", rs.getString("payment_reference"));
                    map.put("amount", rs.getBigDecimal("amount"));
                    map.put("currency", rs.getString("currency"));
                    map.put("status", rs.getString("status"));
                    map.put("paidAt", rs.getTimestamp("paid_at"));
                    map.put("razorpayPaymentId", rs.getString("razorpay_payment_id"));
                    map.put("razorpayOrderId", rs.getString("razorpay_order_id"));
                    map.put("bookingReference", rs.getString("booking_reference"));
                    map.put("pnr", rs.getString("pnr"));
                    map.put("flightNumber", rs.getString("flight_number"));
                    map.put("contactEmail", rs.getString("contact_email"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get recent successful payments: " + e.getMessage(), e);
        }
        return list;
    }

    public List<Map<String, Object>> getPendingPaymentBookings(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT b.id, b.booking_reference, b.flight_number, b.origin_code, b.destination_code, " +
                     "b.departure_date, b.total_amount, b.contact_email, b.created_at " +
                     "FROM bookings b " +
                     "WHERE b.status = 'PENDING_PAYMENT' " +
                     "ORDER BY b.created_at DESC " +
                     "LIMIT ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit > 0 ? limit : 5);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getLong("id"));
                    map.put("bookingReference", rs.getString("booking_reference"));
                    map.put("flightNumber", rs.getString("flight_number"));
                    map.put("originCode", rs.getString("origin_code"));
                    map.put("destCode", rs.getString("destination_code"));
                    map.put("departureDate", rs.getDate("departure_date"));
                    map.put("totalAmount", rs.getBigDecimal("total_amount"));
                    map.put("contactEmail", rs.getString("contact_email"));
                    map.put("createdAt", rs.getTimestamp("created_at"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get pending payment bookings: " + e.getMessage(), e);
        }
        return list;
    }

    public List<Map<String, Object>> getRecentCancellations(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT c.cancellation_id, c.booking_id, c.pnr, c.cancellation_reason, c.cancellation_fee, " +
                     "c.refund_amount, c.refund_status, c.refund_reference, c.cancelled_at, " +
                     "b.flight_number, b.total_amount, b.contact_email " +
                     "FROM cancellations c " +
                     "LEFT JOIN bookings b ON c.booking_id = b.id " +
                     "ORDER BY c.cancelled_at DESC " +
                     "LIMIT ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit > 0 ? limit : 5);
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
                    map.put("cancelledAt", rs.getTimestamp("cancelled_at"));
                    map.put("flightNumber", rs.getString("flight_number"));
                    map.put("totalAmount", rs.getBigDecimal("total_amount"));
                    map.put("contactEmail", rs.getString("contact_email"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get recent cancellations: " + e.getMessage(), e);
        }
        return list;
    }

    public Map<String, Object> getInventorySummary() {
        Map<String, Object> map = new HashMap<>();
        map.put("totalCapacity", 0);
        map.put("availableSeats", 0);
        map.put("bookedSeats", 0);
        String sql = "SELECT COALESCE(SUM(total_seats), 0) AS total_cap, " +
                     "COALESCE(SUM(available_seats), 0) AS avail_cap " +
                     "FROM flight_schedules WHERE flight_date >= CURDATE()";
        try (Connection conn = DBConnectionUtil.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                int total = rs.getInt("total_cap");
                int avail = rs.getInt("avail_cap");
                map.put("totalCapacity", total);
                map.put("availableSeats", avail);
                map.put("bookedSeats", Math.max(0, total - avail));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get inventory summary: " + e.getMessage(), e);
        }
        return map;
    }

    public List<Map<String, Object>> getBookingsLast7Days() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT DATE(created_at) AS b_date, COUNT(*) AS cnt " +
                     "FROM bookings " +
                     "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
                     "GROUP BY DATE(created_at) " +
                     "ORDER BY b_date ASC";
        try (Connection conn = DBConnectionUtil.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("date", rs.getString("b_date"));
                m.put("count", rs.getInt("cnt"));
                list.add(m);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get 7-day bookings: " + e.getMessage(), e);
        }
        return list;
    }

    public List<Map<String, Object>> getRevenueLast7Days() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT DATE(p.paid_at) AS p_date, SUM(p.amount) AS rev " +
                     "FROM payments p " +
                     "JOIN bookings b ON p.booking_id = b.id " +
                     "WHERE p.status = 'SUCCESS' AND b.status = 'CONFIRMED' " +
                     "  AND p.paid_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
                     "GROUP BY DATE(p.paid_at) " +
                     "ORDER BY p_date ASC";
        try (Connection conn = DBConnectionUtil.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("date", rs.getString("p_date"));
                m.put("revenue", rs.getBigDecimal("rev"));
                list.add(m);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get 7-day revenue: " + e.getMessage(), e);
        }
        return list;
    }

    public Map<String, Integer> getBookingStatusDistribution() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT status, COUNT(*) AS cnt FROM bookings GROUP BY status";
        try (Connection conn = DBConnectionUtil.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                map.put(rs.getString("status"), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get status distribution: " + e.getMessage(), e);
        }
        return map;
    }

    public List<Map<String, Object>> getPopularRoutes(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT origin_code, destination_code, COUNT(*) AS booking_count, " +
                     "COALESCE(SUM(total_amount), 0) AS total_volume " +
                     "FROM bookings " +
                     "GROUP BY origin_code, destination_code " +
                     "ORDER BY booking_count DESC " +
                     "LIMIT ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit > 0 ? limit : 5);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("originCode", rs.getString("origin_code"));
                    m.put("destCode", rs.getString("destination_code"));
                    m.put("bookingCount", rs.getInt("booking_count"));
                    m.put("totalVolume", rs.getBigDecimal("total_volume"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get popular routes: " + e.getMessage(), e);
        }
        return list;
    }
}
