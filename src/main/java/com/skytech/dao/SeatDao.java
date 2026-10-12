package com.skytech.dao;

import com.skytech.model.Seat;
import com.skytech.service.SeatPricingConfig;
import com.skytech.util.DBConnectionUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for aircraft seat maps and schedule seat inventories.
 */
public class SeatDao {

    private static final Logger LOGGER = Logger.getLogger(SeatDao.class.getName());

    /**
     * Retrieves all seats with real-time inventory status for a specific flight schedule.
     *
     * @param scheduleId flight schedule identifier
     * @return list of {@link Seat} objects
     */
    public List<Seat> getSeatsForSchedule(int scheduleId) {
        return getSeatsForSchedule(scheduleId, "6E");
    }

    public List<Seat> getSeatsForSchedule(int scheduleId, String airlineCode) {
        List<Seat> seats = new ArrayList<>();

        String sql = "SELECT s.seat_id, s.aircraft_id, s.seat_number, s.row_number, s.column_letter, " +
                "  s.seat_type, s.premium_fee, COALESCE(inv.status, 'AVAILABLE') AS seat_status " +
                "FROM aircraft_seats s " +
                "LEFT JOIN flight_seat_inventory inv ON s.seat_id = inv.seat_id AND inv.schedule_id = ? " +
                "ORDER BY s.row_number ASC, s.column_letter ASC";

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, scheduleId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int row = rs.getInt("row_number");
                    String col = rs.getString("column_letter");
                    SeatPricingConfig.SeatPricingInfo pricing = SeatPricingConfig.resolveSeatPricing(airlineCode, row, col);

                    Seat seat = new Seat();
                    seat.setSeatId(rs.getInt("seat_id"));
                    seat.setAircraftId(rs.getInt("aircraft_id"));
                    seat.setSeatNumber(rs.getString("seat_number"));
                    seat.setRowNumber(row);
                    seat.setColumnLetter(col);
                    seat.setSeatType(pricing.getCategory().name());
                    seat.setPremiumFee(pricing.getPrice());
                    seat.setCategoryLabel(pricing.getCategoryLabel());
                    seat.setStatus(rs.getString("seat_status"));
                    seats.add(seat);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Database seat map lookup failed for scheduleId [" + scheduleId + "]. Using demo cabin baseline.", e);
        }

        // If database did not return rows (e.g. table empty or offline), supply realistic demo cabin layout
        if (seats.isEmpty()) {
            seats = generateDemoCabinSeats(airlineCode);
        }

        return seats;
    }

    /**
     * Generates a realistic 20-row (3x3 configuration: A B C | D E F) aircraft cabin map
     * with airline-specific ancillary pricing.
     */
    public List<Seat> generateDemoCabinSeats() {
        return generateDemoCabinSeats("6E");
    }

    public List<Seat> generateDemoCabinSeats(String airlineCode) {
        List<Seat> demoSeats = new ArrayList<>();
        String[] cols = {"A", "B", "C", "D", "E", "F"};

        for (int row = 1; row <= 20; row++) {
            for (String col : cols) {
                String seatNum = row + col;
                SeatPricingConfig.SeatPricingInfo pricing = SeatPricingConfig.resolveSeatPricing(airlineCode, row, col);
                String status = "AVAILABLE";

                // Simulate realistic occupancy across rows
                if (seatNum.equals("1A") || seatNum.equals("2B") || seatNum.equals("3C") ||
                    seatNum.equals("5D") || seatNum.equals("6E") || seatNum.equals("8F") ||
                    seatNum.equals("12A") || seatNum.equals("12B") || seatNum.equals("15C")) {
                    status = "OCCUPIED";
                } else if (seatNum.equals("1F") || seatNum.equals("13A")) {
                    status = "BLOCKED";
                }

                Seat seat = new Seat(
                    row * 10 + col.charAt(0),
                    seatNum,
                    row,
                    col,
                    pricing.getCategory().name(),
                    pricing.getPrice(),
                    status,
                    pricing.getCategoryLabel()
                );
                demoSeats.add(seat);
            }
        }
        return demoSeats;
    }

    /**
     * Checks if a seat is currently available for booking on a specific schedule.
     */
    public boolean isSeatAvailable(int scheduleId, String seatNumber) {
        String sql = "SELECT COALESCE(inv.status, 'AVAILABLE') AS seat_status " +
                     "FROM aircraft_seats s " +
                     "LEFT JOIN flight_seat_inventory inv ON s.seat_id = inv.seat_id AND inv.schedule_id = ? " +
                     "WHERE s.seat_number = ? LIMIT 1";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setString(2, seatNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "AVAILABLE".equalsIgnoreCase(rs.getString("seat_status"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Error checking seat availability for schedule " + scheduleId + ", seat " + seatNumber, e);
        }
        return true;
    }

    /**
     * Reserves a seat on a schedule inside an active transaction.
     */
    public boolean reserveSeat(int scheduleId, String seatNumber, Connection conn) throws SQLException {
        String sql = "INSERT INTO flight_seat_inventory (schedule_id, seat_id, status) " +
                     "SELECT ?, seat_id, 'OCCUPIED' FROM aircraft_seats WHERE seat_number = ? LIMIT 1 " +
                     "ON DUPLICATE KEY UPDATE status = 'OCCUPIED'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setString(2, seatNumber);
            int rows = ps.executeUpdate();
            return rows > 0;
        }
    }

    /**
     * Releases a seat back to available status inside an active transaction.
     */
    public boolean releaseSeat(int scheduleId, String seatNumber, Connection conn) throws SQLException {
        String sql = "UPDATE flight_seat_inventory inv " +
                     "JOIN aircraft_seats s ON inv.seat_id = s.seat_id " +
                     "SET inv.status = 'AVAILABLE' " +
                     "WHERE inv.schedule_id = ? AND s.seat_number = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setString(2, seatNumber);
            int rows = ps.executeUpdate();
            return rows > 0;
        }
    }

    /**
     * Updates available seat count in flight_schedules.
     */
    public void updateScheduleInventoryCount(int scheduleId, int delta, Connection conn) throws SQLException {
        String sql;
        if (delta < 0) {
            sql = "UPDATE flight_schedules SET available_seats = GREATEST(0, available_seats + ?) WHERE schedule_id = ?";
        } else {
            sql = "UPDATE flight_schedules SET available_seats = LEAST(total_seats, available_seats + ?) WHERE schedule_id = ?";
        }
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, delta);
            ps.setInt(2, scheduleId);
            ps.executeUpdate();
        }
    }
}

