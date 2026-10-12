package com.skytech.airlines.booking.integration;

import com.skytech.airlines.booking.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Live Database-backed Flight Provider querying shared flights table with fallback to in-memory mock.
 */
public class DatabaseFlightProvider implements IFlightProvider {
    private static final Logger LOGGER = Logger.getLogger(DatabaseFlightProvider.class.getName());
    private final DevFlightProviderMock fallbackMock = new DevFlightProviderMock();

    @Override
    public FlightSummary getFlightById(Long flightId) {
        if (flightId == null) return null;

        String sql = "SELECT flight_id, flight_number, airline_name, aircraft_model, origin_airport_code, " +
                     "origin_city, dest_airport_code, dest_city, departure_time, arrival_time, duration_minutes, " +
                     "base_fare, total_seats, available_seats, flight_status FROM shared_flights_dev_mock WHERE flight_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, flightId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    FlightSummary fs = new FlightSummary();
                    fs.setFlightId(rs.getLong("flight_id"));
                    fs.setFlightNumber(rs.getString("flight_number"));
                    fs.setAirlineName(rs.getString("airline_name"));
                    fs.setAircraftModel(rs.getString("aircraft_model"));
                    fs.setOriginAirportCode(rs.getString("origin_airport_code"));
                    fs.setOriginCity(rs.getString("origin_city"));
                    fs.setDestAirportCode(rs.getString("dest_airport_code"));
                    fs.setDestCity(rs.getString("dest_city"));
                    Timestamp dep = rs.getTimestamp("departure_time");
                    if (dep != null) fs.setDepartureTime(dep.toLocalDateTime());
                    Timestamp arr = rs.getTimestamp("arrival_time");
                    if (arr != null) fs.setArrivalTime(arr.toLocalDateTime());
                    fs.setDurationMinutes(rs.getInt("duration_minutes"));
                    fs.setBaseFare(rs.getBigDecimal("base_fare"));
                    fs.setTotalSeats(rs.getInt("total_seats"));
                    fs.setAvailableSeats(rs.getInt("available_seats"));
                    try {
                        String cap = rs.getString("captain_name");
                        if (cap != null && !cap.trim().isEmpty()) fs.setCaptainName(cap);
                    } catch (Exception ignored) {}
                    try {
                        int ffm = rs.getInt("frequent_flyer_miles");
                        if (ffm > 0) fs.setFrequentFlyerMiles(ffm);
                        String fft = rs.getString("frequent_flyer_tier");
                        if (fft != null && !fft.trim().isEmpty()) fs.setFrequentFlyerTier(fft);
                        String ffp = rs.getString("frequent_flyer_perks");
                        if (ffp != null && !ffp.trim().isEmpty()) fs.setFrequentFlyerPerks(ffp);
                    } catch (Exception ignored) {}
                    return fs;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.FINE, "Database flight lookup notice for flightId " + flightId + ": " + e.getMessage());
        }

        return fallbackMock.getFlightById(flightId);
    }

    @Override
    public boolean hasAvailableSeats(Long flightId, int requiredSeats) {
        FlightSummary fs = getFlightById(flightId);
        return fs != null && fs.getAvailableSeats() >= requiredSeats;
    }

    @Override
    public List<FlightSummary> getSampleFlights() {
        String sql = "SELECT flight_id, flight_number, airline_name, aircraft_model, origin_airport_code, " +
                     "origin_city, dest_airport_code, dest_city, departure_time, arrival_time, duration_minutes, " +
                     "base_fare, total_seats, available_seats, flight_status FROM shared_flights_dev_mock " +
                     "WHERE flight_status = 'SCHEDULED' ORDER BY departure_time ASC";

        List<FlightSummary> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                FlightSummary fs = new FlightSummary();
                fs.setFlightId(rs.getLong("flight_id"));
                fs.setFlightNumber(rs.getString("flight_number"));
                fs.setAirlineName(rs.getString("airline_name"));
                fs.setAircraftModel(rs.getString("aircraft_model"));
                fs.setOriginAirportCode(rs.getString("origin_airport_code"));
                fs.setOriginCity(rs.getString("origin_city"));
                fs.setDestAirportCode(rs.getString("dest_airport_code"));
                fs.setDestCity(rs.getString("dest_city"));
                Timestamp dep = rs.getTimestamp("departure_time");
                if (dep != null) fs.setDepartureTime(dep.toLocalDateTime());
                Timestamp arr = rs.getTimestamp("arrival_time");
                if (arr != null) fs.setArrivalTime(arr.toLocalDateTime());
                fs.setDurationMinutes(rs.getInt("duration_minutes"));
                fs.setBaseFare(rs.getBigDecimal("base_fare"));
                fs.setTotalSeats(rs.getInt("total_seats"));
                fs.setAvailableSeats(rs.getInt("available_seats"));
                fs.setFlightStatus(rs.getString("flight_status"));
                try {
                    String cap = rs.getString("captain_name");
                    if (cap != null && !cap.trim().isEmpty()) fs.setCaptainName(cap);
                } catch (Exception ignored) {}
                try {
                    int ffm = rs.getInt("frequent_flyer_miles");
                    if (ffm > 0) fs.setFrequentFlyerMiles(ffm);
                    String fft = rs.getString("frequent_flyer_tier");
                    if (fft != null && !fft.trim().isEmpty()) fs.setFrequentFlyerTier(fft);
                    String ffp = rs.getString("frequent_flyer_perks");
                    if (ffp != null && !ffp.trim().isEmpty()) fs.setFrequentFlyerPerks(ffp);
                } catch (Exception ignored) {}
                list.add(fs);
            }
            if (!list.isEmpty()) return list;
        } catch (Exception e) {
            LOGGER.log(Level.FINE, "Database query notice for sample flights: " + e.getMessage());
        }

        return fallbackMock.getSampleFlights();
    }
}
