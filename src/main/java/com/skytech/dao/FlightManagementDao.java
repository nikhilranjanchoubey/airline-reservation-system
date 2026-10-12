package com.skytech.dao;

import com.skytech.model.Airline;
import com.skytech.model.Airport;
import com.skytech.model.Flight;
import com.skytech.model.FlightSchedule;
import com.skytech.util.DBConnectionUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Flight Operations, Scheduling, and Administrative Governance.
 */
public class FlightManagementDao {

    private static final Logger LOGGER = Logger.getLogger(FlightManagementDao.class.getName());

    public List<FlightSchedule> getFlightSchedules(String search, String status, String origin,
                                                   String dest, String dateStr, int page, int pageSize) {
        List<FlightSchedule> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT s.schedule_id, s.flight_id, s.flight_date, s.base_price, s.economy_price, " +
                "  s.premium_economy_price, s.business_price, s.first_class_price, " +
                "  s.available_seats, s.total_seats, s.status, " +
                "  f.flight_number, f.departure_time, f.arrival_time, f.duration_minutes, f.stops, f.aircraft_model, " +
                "  al.airline_id, al.airline_code, al.airline_name, al.logo_icon, " +
                "  src.airport_id AS src_id, src.airport_code AS src_code, src.airport_name AS src_name, " +
                "  src.city AS src_city, src.country AS src_country, src.terminal AS src_terminal, " +
                "  dst.airport_id AS dst_id, dst.airport_code AS dst_code, dst.airport_name AS dst_name, " +
                "  dst.city AS dst_city, dst.country AS dst_country, dst.terminal AS dst_terminal " +
                "FROM flight_schedules s " +
                "JOIN flights f ON s.flight_id = f.flight_id " +
                "JOIN airlines al ON f.airline_id = al.airline_id " +
                "JOIN airports src ON f.source_airport_id = src.airport_id " +
                "JOIN airports dst ON f.destination_airport_id = dst.airport_id " +
                "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, search, status, origin, dest, dateStr);

        sql.append(" ORDER BY s.flight_date DESC, f.departure_time ASC LIMIT ? OFFSET ?");
        int offset = Math.max(0, (page - 1) * pageSize);
        params.add(pageSize);
        params.add(offset);

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapScheduleRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to load flight schedules: " + e.getMessage(), e);
        }
        return list;
    }

    public int countFlightSchedules(String search, String status, String origin, String dest, String dateStr) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) " +
                "FROM flight_schedules s " +
                "JOIN flights f ON s.flight_id = f.flight_id " +
                "JOIN airlines al ON f.airline_id = al.airline_id " +
                "JOIN airports src ON f.source_airport_id = src.airport_id " +
                "JOIN airports dst ON f.destination_airport_id = dst.airport_id " +
                "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, search, status, origin, dest, dateStr);

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to count flight schedules: " + e.getMessage(), e);
        }
        return 0;
    }

    private void appendFilters(StringBuilder sql, List<Object> params, String search,
                               String status, String origin, String dest, String dateStr) {
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (f.flight_number LIKE ? OR al.airline_name LIKE ? OR src.city LIKE ? OR dst.city LIKE ?) ");
            String wild = "%" + search.trim() + "%";
            params.add(wild);
            params.add(wild);
            params.add(wild);
            params.add(wild);
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim())) {
            sql.append(" AND s.status = ? ");
            params.add(status.trim().toUpperCase());
        }
        if (origin != null && !origin.trim().isEmpty() && !"ALL".equalsIgnoreCase(origin.trim())) {
            sql.append(" AND src.airport_code = ? ");
            params.add(origin.trim().toUpperCase());
        }
        if (dest != null && !dest.trim().isEmpty() && !"ALL".equalsIgnoreCase(dest.trim())) {
            sql.append(" AND dst.airport_code = ? ");
            params.add(dest.trim().toUpperCase());
        }
        if (dateStr != null && !dateStr.trim().isEmpty()) {
            try {
                LocalDate d = LocalDate.parse(dateStr.trim());
                sql.append(" AND s.flight_date = ? ");
                params.add(Date.valueOf(d));
            } catch (Exception ignored) {
            }
        }
    }

    public boolean createFlightWithSchedule(Flight flight, FlightSchedule schedule) {
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. Check or insert flight
            int flightId = -1;
            String checkFlightSql = "SELECT flight_id FROM flights WHERE flight_number = ?";
            try (PreparedStatement psCheck = conn.prepareStatement(checkFlightSql)) {
                psCheck.setString(1, flight.getFlightNumber().trim().toUpperCase());
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        flightId = rs.getInt(1);
                    }
                }
            }

            if (flightId == -1) {
                String insertFlightSql = "INSERT INTO flights (flight_number, airline_id, source_airport_id, " +
                        "destination_airport_id, departure_time, arrival_time, duration_minutes, stops, aircraft_model) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement psFlight = conn.prepareStatement(insertFlightSql, Statement.RETURN_GENERATED_KEYS)) {
                    psFlight.setString(1, flight.getFlightNumber().trim().toUpperCase());
                    psFlight.setInt(2, flight.getAirline().getAirlineId());
                    psFlight.setInt(3, flight.getSourceAirport().getAirportId());
                    psFlight.setInt(4, flight.getDestinationAirport().getAirportId());
                    psFlight.setTime(5, flight.getDepartureTime());
                    psFlight.setTime(6, flight.getArrivalTime());
                    psFlight.setInt(7, flight.getDurationMinutes());
                    psFlight.setInt(8, flight.getStops());
                    psFlight.setString(9, flight.getAircraftModel() != null ? flight.getAircraftModel() : "Airbus A320neo");
                    psFlight.executeUpdate();
                    try (ResultSet rs = psFlight.getGeneratedKeys()) {
                        if (rs.next()) {
                            flightId = rs.getInt(1);
                        }
                    }
                }
            }

            if (flightId == -1) {
                conn.rollback();
                return false;
            }

            // 2. Insert schedule
            String insertScheduleSql = "INSERT INTO flight_schedules (flight_id, flight_date, base_price, " +
                    "economy_price, premium_economy_price, business_price, first_class_price, available_seats, total_seats, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                    "ON DUPLICATE KEY UPDATE base_price = VALUES(base_price), economy_price = VALUES(economy_price), " +
                    "available_seats = VALUES(available_seats), status = VALUES(status)";
            try (PreparedStatement psSched = conn.prepareStatement(insertScheduleSql)) {
                psSched.setInt(1, flightId);
                psSched.setDate(2, schedule.getFlightDate());
                psSched.setBigDecimal(3, schedule.getBasePrice());
                psSched.setBigDecimal(4, schedule.getEconomyPrice());
                psSched.setBigDecimal(5, schedule.getPremiumEconomyPrice() != null ? schedule.getPremiumEconomyPrice() : schedule.getEconomyPrice().multiply(BigDecimal.valueOf(1.35)));
                psSched.setBigDecimal(6, schedule.getBusinessPrice() != null ? schedule.getBusinessPrice() : schedule.getEconomyPrice().multiply(BigDecimal.valueOf(2.20)));
                psSched.setBigDecimal(7, schedule.getFirstClassPrice() != null ? schedule.getFirstClassPrice() : schedule.getEconomyPrice().multiply(BigDecimal.valueOf(3.50)));
                psSched.setInt(8, schedule.getAvailableSeats() > 0 ? schedule.getAvailableSeats() : 180);
                psSched.setInt(9, schedule.getTotalSeats() > 0 ? schedule.getTotalSeats() : 180);
                psSched.setString(10, schedule.getStatus() != null ? schedule.getStatus() : "SCHEDULED");
                psSched.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to create flight & schedule: " + e.getMessage(), e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    public boolean updateFlightSchedule(int scheduleId, Flight flight, FlightSchedule schedule) {
        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            conn.setAutoCommit(false);

            // Update flight master
            String updateFlightSql = "UPDATE flights f JOIN flight_schedules s ON f.flight_id = s.flight_id " +
                    "SET f.departure_time = ?, f.arrival_time = ?, f.duration_minutes = ?, f.aircraft_model = ? " +
                    "WHERE s.schedule_id = ?";
            try (PreparedStatement psF = conn.prepareStatement(updateFlightSql)) {
                psF.setTime(1, flight.getDepartureTime());
                psF.setTime(2, flight.getArrivalTime());
                psF.setInt(3, flight.getDurationMinutes());
                psF.setString(4, flight.getAircraftModel());
                psF.setInt(5, scheduleId);
                psF.executeUpdate();
            }

            // Update schedule inventory & fares
            String updateSchedSql = "UPDATE flight_schedules SET base_price = ?, economy_price = ?, " +
                    "premium_economy_price = ?, business_price = ?, first_class_price = ?, " +
                    "available_seats = ?, status = ? WHERE schedule_id = ?";
            try (PreparedStatement psS = conn.prepareStatement(updateSchedSql)) {
                psS.setBigDecimal(1, schedule.getBasePrice());
                psS.setBigDecimal(2, schedule.getEconomyPrice());
                psS.setBigDecimal(3, schedule.getPremiumEconomyPrice());
                psS.setBigDecimal(4, schedule.getBusinessPrice());
                psS.setBigDecimal(5, schedule.getFirstClassPrice());
                psS.setInt(6, schedule.getAvailableSeats());
                psS.setString(7, schedule.getStatus());
                psS.setInt(8, scheduleId);
                psS.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update flight schedule: " + e.getMessage(), e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    public boolean updateFlightStatus(int scheduleId, String status) {
        String sql = "UPDATE flight_schedules SET status = ? WHERE schedule_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.trim().toUpperCase());
            ps.setInt(2, scheduleId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to update schedule status: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean safeDeactivateFlight(int scheduleId) {
        return updateFlightStatus(scheduleId, "CANCELLED");
    }

    private FlightSchedule mapScheduleRow(ResultSet rs) throws SQLException {
        Airline al = new Airline();
        al.setAirlineId(rs.getInt("airline_id"));
        al.setAirlineCode(rs.getString("airline_code"));
        al.setAirlineName(rs.getString("airline_name"));
        al.setLogoIcon(rs.getString("logo_icon"));

        Airport src = new Airport();
        src.setAirportId(rs.getInt("src_id"));
        src.setAirportCode(rs.getString("src_code"));
        src.setAirportName(rs.getString("src_name"));
        src.setCity(rs.getString("src_city"));
        src.setCountry(rs.getString("src_country"));
        src.setTerminal(rs.getString("src_terminal"));

        Airport dst = new Airport();
        dst.setAirportId(rs.getInt("dst_id"));
        dst.setAirportCode(rs.getString("dst_code"));
        dst.setAirportName(rs.getString("dst_name"));
        dst.setCity(rs.getString("dst_city"));
        dst.setCountry(rs.getString("dst_country"));
        dst.setTerminal(rs.getString("dst_terminal"));

        Flight f = new Flight();
        f.setFlightId(rs.getInt("flight_id"));
        f.setFlightNumber(rs.getString("flight_number"));
        f.setAirline(al);
        f.setSourceAirport(src);
        f.setDestinationAirport(dst);
        f.setDepartureTime(rs.getTime("departure_time"));
        f.setArrivalTime(rs.getTime("arrival_time"));
        f.setDurationMinutes(rs.getInt("duration_minutes"));
        f.setStops(rs.getInt("stops"));
        f.setAircraftModel(rs.getString("aircraft_model"));

        FlightSchedule s = new FlightSchedule();
        s.setScheduleId(rs.getInt("schedule_id"));
        s.setFlightId(rs.getInt("flight_id"));
        s.setFlight(f);
        s.setFlightDate(rs.getDate("flight_date"));
        s.setBasePrice(rs.getBigDecimal("base_price"));
        s.setEconomyPrice(rs.getBigDecimal("economy_price"));
        s.setPremiumEconomyPrice(rs.getBigDecimal("premium_economy_price"));
        s.setBusinessPrice(rs.getBigDecimal("business_price"));
        s.setFirstClassPrice(rs.getBigDecimal("first_class_price"));
        s.setAvailableSeats(rs.getInt("available_seats"));
        s.setTotalSeats(rs.getInt("total_seats"));
        s.setStatus(rs.getString("status"));

        return s;
    }
}
