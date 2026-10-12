package com.skyport.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.skyport.model.Booking;
import com.skyport.util.DBConnection;

public class BookingDAO {

    // Find booking details using PNR
    public Booking findByPNR(String pnr) throws SQLException {

        String sql = "SELECT * FROM bookings WHERE pnr = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, pnr);

            try (ResultSet result = statement.executeQuery()) {

                if (result.next()) {

                    Booking booking = new Booking();

                    booking.setBookingId(
                            result.getInt("booking_id"));

                    booking.setPnr(
                            result.getString("pnr"));

                    booking.setPassengerName(
                            result.getString("passenger_name"));

                    booking.setFlightNumber(
                            result.getString("flight_number"));

                    booking.setSource(
                            result.getString("source"));

                    booking.setDestination(
                            result.getString("destination"));

                    booking.setDepartureDate(
                            result.getDate("departure_date"));

                    booking.setDepartureTime(
                            result.getTime("departure_time"));

                    booking.setTotalAmount(
                            result.getBigDecimal("total_amount"));

                    booking.setBookingStatus(
                            result.getString("booking_status"));

                    return booking;
                }
            }
        }

        return null;
    }

    // Cancel a booking using its PNR
    public String cancelBooking(String pnr) throws SQLException {

        String checkSql =
                "SELECT booking_status FROM bookings WHERE pnr = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement checkStatement =
                     connection.prepareStatement(checkSql)) {

            checkStatement.setString(1, pnr);

            String status;

            try (ResultSet result = checkStatement.executeQuery()) {

                if (!result.next()) {
                    return "NOT_FOUND";
                }

                status = result.getString("booking_status");
            }

            // Check current booking status
            if ("CANCELLED".equalsIgnoreCase(status)) {
                return "ALREADY_CANCELLED";
            }

            if (!"CONFIRMED".equalsIgnoreCase(status)) {
                return "NOT_CANCELLABLE";
            }

            // Update booking status
            String updateSql =
                    "UPDATE bookings "
                    + "SET booking_status = 'CANCELLED' "
                    + "WHERE pnr = ? "
                    + "AND booking_status = 'CONFIRMED'";

            try (PreparedStatement updateStatement =
                         connection.prepareStatement(updateSql)) {

                updateStatement.setString(1, pnr);

                int rowsUpdated = updateStatement.executeUpdate();

                if (rowsUpdated > 0) {
                    return "SUCCESS";
                }

                return "ALREADY_CANCELLED";
            }
        }
    }
}