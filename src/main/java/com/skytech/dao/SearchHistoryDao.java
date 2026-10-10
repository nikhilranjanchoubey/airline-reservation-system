package com.skytech.dao;

import com.skytech.model.FlightSearchRequest;
import com.skytech.util.DBConnectionUtil;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for persisting and querying flight search history.
 * Operates safely with fail-soft error handling to ensure external searches
 * remain functional even during temporary database disruptions.
 */
public class SearchHistoryDao {

    private static final Logger LOGGER = Logger.getLogger(SearchHistoryDao.class.getName());

    private static final String SQL_INSERT_SEARCH = 
            "INSERT INTO flight_searches " +
            "(user_id, origin_code, destination_code, departure_date, return_date, adults, children, infants, cabin_class, provider, searched_at) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

    /**
     * Persists a search query record into MySQL using PreparedStatements.
     *
     * @param request search parameters
     * @param provider name of the flight provider used
     * @return true if successfully persisted, false otherwise
     */
    public boolean saveSearch(FlightSearchRequest request, String provider) {
        if (request == null || request.getOrigin() == null || request.getDestination() == null || request.getDepartureDate() == null) {
            return false;
        }

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT_SEARCH)) {

            if (request.getUserId() != null) {
                ps.setLong(1, request.getUserId());
            } else {
                ps.setNull(1, Types.BIGINT);
            }

            ps.setString(2, request.getOrigin().trim().toUpperCase());
            ps.setString(3, request.getDestination().trim().toUpperCase());
            ps.setDate(4, Date.valueOf(request.getDepartureDate()));

            if (request.getReturnDate() != null) {
                ps.setDate(5, Date.valueOf(request.getReturnDate()));
            } else {
                ps.setNull(5, Types.DATE);
            }

            ps.setInt(6, request.getAdults());
            ps.setInt(7, request.getChildren());
            ps.setInt(8, request.getInfants());
            ps.setString(9, request.getCabinClass() != null ? request.getCabinClass().trim().toUpperCase() : "ECONOMY");
            ps.setString(10, provider != null ? provider : "ReefAPI");

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Search history could not be saved to MySQL: " + e.getMessage());
            return false;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Unexpected error saving search history: " + e.getMessage());
            return false;
        }
    }
}
