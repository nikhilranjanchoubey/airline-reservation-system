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
}
