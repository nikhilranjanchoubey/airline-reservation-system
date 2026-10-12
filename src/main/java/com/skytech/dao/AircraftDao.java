package com.skytech.dao;

import com.skytech.model.Aircraft;
import com.skytech.model.Seat;
import com.skytech.util.DBConnectionUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Aircraft inventory and cabin configuration in MySQL.
 */
public class AircraftDao {

    private static final Logger LOGGER = Logger.getLogger(AircraftDao.class.getName());

    public List<Aircraft> getAllAircraft() {
        List<Aircraft> list = new ArrayList<>();
        String sql = "SELECT aircraft_id, model_name, manufacturer, total_rows, seats_per_row " +
                     "FROM aircraft ORDER BY model_name ASC";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Aircraft a = new Aircraft();
                a.setAircraftId(rs.getInt("aircraft_id"));
                a.setModelName(rs.getString("model_name"));
                a.setManufacturer(rs.getString("manufacturer"));
                a.setTotalRows(rs.getInt("total_rows"));
                a.setSeatsPerRow(rs.getInt("seats_per_row"));
                list.add(a);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to retrieve aircraft list: " + e.getMessage(), e);
        }
        return list;
    }

    public Aircraft getAircraftById(int id) {
        String sql = "SELECT aircraft_id, model_name, manufacturer, total_rows, seats_per_row " +
                     "FROM aircraft WHERE aircraft_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Aircraft a = new Aircraft();
                    a.setAircraftId(rs.getInt("aircraft_id"));
                    a.setModelName(rs.getString("model_name"));
                    a.setManufacturer(rs.getString("manufacturer"));
                    a.setTotalRows(rs.getInt("total_rows"));
                    a.setSeatsPerRow(rs.getInt("seats_per_row"));
                    return a;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to retrieve aircraft by id: " + e.getMessage(), e);
        }
        return null;
    }

    public boolean createAircraft(Aircraft a) {
        String sql = "INSERT INTO aircraft (model_name, manufacturer, total_rows, seats_per_row) " +
                     "VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, a.getModelName().trim());
            ps.setString(2, a.getManufacturer().trim());
            ps.setInt(3, a.getTotalRows() > 0 ? a.getTotalRows() : 20);
            ps.setInt(4, a.getSeatsPerRow() > 0 ? a.getSeatsPerRow() : 6);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        a.setAircraftId(rs.getInt(1));
                    }
                }
                // Seed standard seats for the newly created aircraft
                seedSeatsForAircraft(a);
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to create aircraft: " + e.getMessage(), e);
        }
        return false;
    }

    public List<Seat> getSeatsByAircraftId(int aircraftId) {
        List<Seat> seats = new ArrayList<>();
        String sql = "SELECT seat_id, aircraft_id, seat_number, row_number, column_letter, seat_type, premium_fee " +
                     "FROM aircraft_seats WHERE aircraft_id = ? ORDER BY row_number ASC, column_letter ASC";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, aircraftId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Seat s = new Seat();
                    s.setSeatId(rs.getInt("seat_id"));
                    s.setAircraftId(rs.getInt("aircraft_id"));
                    s.setSeatNumber(rs.getString("seat_number"));
                    s.setRowNumber(rs.getInt("row_number"));
                    s.setColumnLetter(rs.getString("column_letter"));
                    s.setSeatType(rs.getString("seat_type"));
                    s.setPremiumFee(rs.getBigDecimal("premium_fee"));
                    seats.add(s);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to retrieve seats for aircraft [" + aircraftId + "]: " + e.getMessage(), e);
        }
        if (seats.isEmpty()) {
            Aircraft a = getAircraftById(aircraftId);
            if (a != null) {
                seedSeatsForAircraft(a);
                // Query again
                try (Connection conn = DBConnectionUtil.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, aircraftId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Seat s = new Seat();
                            s.setSeatId(rs.getInt("seat_id"));
                            s.setAircraftId(rs.getInt("aircraft_id"));
                            s.setSeatNumber(rs.getString("seat_number"));
                            s.setRowNumber(rs.getInt("row_number"));
                            s.setColumnLetter(rs.getString("column_letter"));
                            s.setSeatType(rs.getString("seat_type"));
                            s.setPremiumFee(rs.getBigDecimal("premium_fee"));
                            seats.add(s);
                        }
                    }
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Failed to retrieve newly seeded seats: " + e.getMessage(), e);
                }
            }
        }
        return seats;
    }

    private void seedSeatsForAircraft(Aircraft a) {
        String insertSeatSql = "INSERT INTO aircraft_seats (aircraft_id, seat_number, row_number, column_letter, seat_type, premium_fee) " +
                               "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertSeatSql)) {
            String[] cols = new String[]{"A", "B", "C", "D", "E", "F"};
            int numCols = Math.min(a.getSeatsPerRow(), cols.length);
            for (int r = 1; r <= a.getTotalRows(); r++) {
                for (int c = 0; c < numCols; c++) {
                    String col = cols[c];
                    String seatNum = r + col;
                    String type = "STANDARD";
                    double fee = 0.0;
                    if (r == 1) {
                        type = "EXTRA_LEGROOM";
                        fee = 500.0;
                    } else if (r == 12) {
                        type = "EXIT_ROW";
                        fee = 350.0;
                    } else if ("A".equals(col) || "F".equals(col)) {
                        type = "WINDOW";
                        fee = 150.0;
                    } else if ("C".equals(col) || "D".equals(col)) {
                        type = "AISLE";
                        fee = 100.0;
                    }
                    ps.setInt(1, a.getAircraftId());
                    ps.setString(2, seatNum);
                    ps.setInt(3, r);
                    ps.setString(4, col);
                    ps.setString(5, type);
                    ps.setBigDecimal(6, java.math.BigDecimal.valueOf(fee));
                    ps.addBatch();
                }
            }
            ps.executeBatch();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to seed seats for aircraft: " + e.getMessage(), e);
        }
    }
}
