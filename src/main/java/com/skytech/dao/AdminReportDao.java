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
 * Data Access Object for Administrative Reports & Analytics:
 * generates operational summaries, route popularity reports, flight-wise metrics,
 * and safe CSV data generation with formula injection prevention.
 */
public class AdminReportDao {

    private static final Logger LOGGER = Logger.getLogger(AdminReportDao.class.getName());

    public List<Map<String, Object>> getFlightWiseReport(String fromDate, String toDate) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT f.flight_number, al.airline_name, " +
                "sa.airport_code AS origin, da.airport_code AS destination, " +
                "COUNT(b.id) AS total_bookings, " +
                "SUM(CASE WHEN b.status = 'CONFIRMED' THEN 1 ELSE 0 END) AS confirmed_bookings, " +
                "SUM(CASE WHEN b.status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_bookings, " +
                "COALESCE(SUM(CASE WHEN b.status = 'CONFIRMED' THEN b.total_amount ELSE 0 END), 0) AS total_revenue " +
                "FROM flights f " +
                "JOIN airlines al ON f.airline_id = al.airline_id " +
                "JOIN airports sa ON f.source_airport_id = sa.airport_id " +
                "JOIN airports da ON f.destination_airport_id = da.airport_id " +
                "LEFT JOIN bookings b ON f.flight_number = b.flight_number "
        );

        List<Object> params = new ArrayList<>();
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND b.departure_date >= ? ");
            params.add(Date.valueOf(fromDate.trim()));
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND b.departure_date <= ? ");
            params.add(Date.valueOf(toDate.trim()));
        }

        sql.append(" GROUP BY f.flight_number, al.airline_name, sa.airport_code, da.airport_code " +
                   " ORDER BY total_bookings DESC, total_revenue DESC");

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("flightNumber", rs.getString("flight_number"));
                    map.put("airlineName", rs.getString("airline_name"));
                    map.put("origin", rs.getString("origin"));
                    map.put("destination", rs.getString("destination"));
                    map.put("totalBookings", rs.getInt("total_bookings"));
                    map.put("confirmedBookings", rs.getInt("confirmed_bookings"));
                    map.put("cancelledBookings", rs.getInt("cancelled_bookings"));
                    map.put("totalRevenue", rs.getBigDecimal("total_revenue"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get flight-wise report: " + e.getMessage(), e);
        }
        return list;
    }

    public List<Map<String, Object>> getRoutePopularityReport() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT b.origin_code, sa.city AS origin_city, " +
                     "b.destination_code, da.city AS dest_city, " +
                     "COUNT(b.id) AS total_bookings, " +
                     "SUM(CASE WHEN b.status = 'CONFIRMED' THEN 1 ELSE 0 END) AS confirmed_bookings, " +
                     "COALESCE(SUM(CASE WHEN b.status = 'CONFIRMED' THEN b.total_amount ELSE 0 END), 0) AS total_revenue " +
                     "FROM bookings b " +
                     "LEFT JOIN airports sa ON b.origin_code = sa.airport_code " +
                     "LEFT JOIN airports da ON b.destination_code = da.airport_code " +
                     "GROUP BY b.origin_code, sa.city, b.destination_code, da.city " +
                     "ORDER BY total_bookings DESC LIMIT 10";
        try (Connection conn = DBConnectionUtil.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("originCode", rs.getString("origin_code"));
                map.put("originCity", rs.getString("origin_city"));
                map.put("destCode", rs.getString("destination_code"));
                map.put("destCity", rs.getString("dest_city"));
                map.put("totalBookings", rs.getInt("total_bookings"));
                map.put("confirmedBookings", rs.getInt("confirmed_bookings"));
                map.put("totalRevenue", rs.getBigDecimal("total_revenue"));
                list.add(map);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get route popularity report: " + e.getMessage(), e);
        }
        return list;
    }

    public List<Map<String, Object>> getRevenueByDateReport(String fromDate, String toDate) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT DATE(p.paid_at) AS pay_date, p.currency, " +
                "COUNT(p.id) AS transaction_count, " +
                "SUM(p.amount) AS daily_revenue " +
                "FROM payments p " +
                "JOIN bookings b ON p.booking_id = b.id " +
                "WHERE p.status = 'SUCCESS' AND b.status = 'CONFIRMED' "
        );

        List<Object> params = new ArrayList<>();
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND DATE(p.paid_at) >= ? ");
            params.add(Date.valueOf(fromDate.trim()));
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND DATE(p.paid_at) <= ? ");
            params.add(Date.valueOf(toDate.trim()));
        }

        sql.append(" GROUP BY DATE(p.paid_at), p.currency ORDER BY pay_date DESC");

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("payDate", rs.getDate("pay_date"));
                    map.put("currency", rs.getString("currency"));
                    map.put("transactionCount", rs.getInt("transaction_count"));
                    map.put("dailyRevenue", rs.getBigDecimal("daily_revenue"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get revenue by date: " + e.getMessage(), e);
        }
        return list;
    }

    /**
     * Sanitizes string to prevent CSV / Spreadsheet formula injection.
     * Prefixes sensitive leading symbols (=, +, -, @, \t, \r) with an apostrophe.
     */
    public static String escapeCsvFormula(Object raw) {
        if (raw == null) return "";
        String str = raw.toString().trim();
        if (str.isEmpty()) return "";
        char first = str.charAt(0);
        if (first == '=' || first == '+' || first == '-' || first == '@' || first == '\t' || first == '\r') {
            str = "'" + str;
        }
        if (str.contains(",") || str.contains("\"") || str.contains("\n")) {
            str = "\"" + str.replace("\"", "\"\"") + "\"";
        }
        return str;
    }
}
