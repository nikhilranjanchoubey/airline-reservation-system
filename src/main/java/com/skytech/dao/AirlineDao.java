package com.skytech.dao;

import com.skytech.model.Airline;
import com.skytech.util.DBConnectionUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Airline records in MySQL.
 */
public class AirlineDao {

    private static final Logger LOGGER = Logger.getLogger(AirlineDao.class.getName());

    public List<Airline> getAllAirlines() {
        List<Airline> list = new ArrayList<>();
        String sql = "SELECT airline_id, airline_code, airline_name, logo_icon, created_at " +
                     "FROM airlines ORDER BY airline_name ASC";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Airline a = new Airline();
                a.setAirlineId(rs.getInt("airline_id"));
                a.setAirlineCode(rs.getString("airline_code"));
                a.setAirlineName(rs.getString("airline_name"));
                a.setLogoIcon(rs.getString("logo_icon"));
                a.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(a);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to retrieve airlines: " + e.getMessage(), e);
        }
        return list;
    }

    public Airline getAirlineById(int id) {
        String sql = "SELECT airline_id, airline_code, airline_name, logo_icon, created_at " +
                     "FROM airlines WHERE airline_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Airline a = new Airline();
                    a.setAirlineId(rs.getInt("airline_id"));
                    a.setAirlineCode(rs.getString("airline_code"));
                    a.setAirlineName(rs.getString("airline_name"));
                    a.setLogoIcon(rs.getString("logo_icon"));
                    a.setCreatedAt(rs.getTimestamp("created_at"));
                    return a;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to retrieve airline by id: " + e.getMessage(), e);
        }
        return null;
    }

    public boolean createAirline(Airline a) {
        String sql = "INSERT INTO airlines (airline_code, airline_name, logo_icon) VALUES (?, ?, ?)";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, a.getAirlineCode().trim().toUpperCase());
            ps.setString(2, a.getAirlineName().trim());
            ps.setString(3, a.getLogoIcon() != null ? a.getLogoIcon() : "bi-airplane-fill");
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        a.setAirlineId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to create airline: " + e.getMessage(), e);
        }
        return false;
    }

    public boolean updateAirline(Airline a) {
        String sql = "UPDATE airlines SET airline_code = ?, airline_name = ?, logo_icon = ? WHERE airline_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, a.getAirlineCode().trim().toUpperCase());
            ps.setString(2, a.getAirlineName().trim());
            ps.setString(3, a.getLogoIcon() != null ? a.getLogoIcon() : "bi-airplane-fill");
            ps.setInt(4, a.getAirlineId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to update airline: " + e.getMessage(), e);
        }
        return false;
    }
}
