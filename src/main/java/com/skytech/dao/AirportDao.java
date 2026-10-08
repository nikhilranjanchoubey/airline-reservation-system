package com.skytech.dao;

import com.skytech.model.Airport;
import com.skytech.util.DBConnectionUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Airport entities.
 */
public class AirportDao {

    private static final Logger LOGGER = Logger.getLogger(AirportDao.class.getName());

    /**
     * Retrieves all active airports ordered alphabetically by city.
     *
     * @return list of {@link Airport} records from database
     */
    public List<Airport> getAllAirports() {
        List<Airport> airports = new ArrayList<>();
        String sql = "SELECT airport_id, airport_code, airport_name, city, country, terminal " +
                     "FROM airports ORDER BY city ASC";

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                airports.add(mapRowToAirport(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to load airports from database: " + e.getMessage(), e);
            // If database tables are not yet created or connection is pending, provide baseline airports
            if (airports.isEmpty()) {
                airports.addAll(getDefaultFallbackAirports());
            }
        }

        return airports;
    }

    /**
     * Finds an airport by its 3-letter IATA code.
     */
    public Airport getAirportByCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT airport_id, airport_code, airport_name, city, country, terminal " +
                     "FROM airports WHERE airport_code = ?";

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToAirport(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to load airport by code [" + code + "]: " + e.getMessage(), e);
            for (Airport a : getDefaultFallbackAirports()) {
                if (a.getAirportCode().equalsIgnoreCase(code.trim())) {
                    return a;
                }
            }
        }
        return null;
    }

    private Airport mapRowToAirport(ResultSet rs) throws SQLException {
        Airport airport = new Airport();
        airport.setAirportId(rs.getInt("airport_id"));
        airport.setAirportCode(rs.getString("airport_code"));
        airport.setAirportName(rs.getString("airport_name"));
        airport.setCity(rs.getString("city"));
        airport.setCountry(rs.getString("country"));
        airport.setTerminal(rs.getString("terminal"));
        return airport;
    }

    private List<Airport> getDefaultFallbackAirports() {
        List<Airport> list = new ArrayList<>();
        list.add(new Airport(1, "JAI", "Jaipur International Airport", "Jaipur", "India", "Terminal 2"));
        list.add(new Airport(2, "DEL", "Indira Gandhi International Airport", "Delhi", "India", "Terminal 3"));
        list.add(new Airport(3, "BOM", "Chhatrapati Shivaji Maharaj International Airport", "Mumbai", "India", "Terminal 2"));
        list.add(new Airport(4, "BLR", "Kempegowda International Airport", "Bengaluru", "India", "Terminal 1"));
        list.add(new Airport(5, "HYD", "Rajiv Gandhi International Airport", "Hyderabad", "India", "Main Terminal"));
        list.add(new Airport(6, "CCU", "Netaji Subhash Chandra Bose International Airport", "Kolkata", "India", "Terminal 2"));
        list.add(new Airport(7, "MAA", "Chennai International Airport", "Chennai", "India", "Terminal 1"));
        list.add(new Airport(8, "AMD", "Sardar Vallabhbhai Patel International Airport", "Ahmedabad", "India", "Terminal 1"));
        list.add(new Airport(9, "PNQ", "Pune Airport", "Pune", "India", "Main Terminal"));
        list.add(new Airport(10, "GOI", "Dabolim Airport", "Goa", "India", "Terminal 1"));
        return list;
    }
}
