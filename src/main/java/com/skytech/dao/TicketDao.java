package com.skytech.dao;

import com.skytech.model.Ticket;
import com.skytech.util.DBConnectionUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for flight tickets and boarding passes.
 */
public class TicketDao {

    private static final Logger LOGGER = Logger.getLogger(TicketDao.class.getName());

    public boolean createTickets(List<Ticket> tickets) {
        if (tickets == null || tickets.isEmpty()) return false;

        String insertTicketSql = "INSERT INTO tickets (booking_id, passenger_id, ticket_number, pnr, " +
                "flight_number, origin_code, destination_code, departure_time, arrival_time, " +
                "seat_number, cabin_class, passenger_name, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String updatePassengerSql = "UPDATE passengers SET ticket_number = ? WHERE id = ?";

        Connection conn = null;
        try {
            conn = DBConnectionUtil.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement psTicket = conn.prepareStatement(insertTicketSql, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement psPass = conn.prepareStatement(updatePassengerSql)) {

                for (Ticket t : tickets) {
                    psTicket.setLong(1, t.getBookingId());
                    psTicket.setLong(2, t.getPassengerId());
                    psTicket.setString(3, t.getTicketNumber());
                    psTicket.setString(4, t.getPnr());
                    psTicket.setString(5, t.getFlightNumber());
                    psTicket.setString(6, t.getOriginCode());
                    psTicket.setString(7, t.getDestinationCode());
                    psTicket.setTimestamp(8, Timestamp.valueOf(t.getDepartureTime()));
                    psTicket.setTimestamp(9, Timestamp.valueOf(t.getArrivalTime()));
                    psTicket.setString(10, t.getSeatNumber());
                    psTicket.setString(11, t.getCabinClass() != null ? t.getCabinClass() : "Economy");
                    psTicket.setString(12, t.getPassengerName());
                    psTicket.setString(13, t.getStatus() != null ? t.getStatus() : "CONFIRMED");
                    psTicket.addBatch();

                    psPass.setString(1, t.getTicketNumber());
                    psPass.setLong(2, t.getPassengerId());
                    psPass.addBatch();
                }

                psTicket.executeBatch();
                psPass.executeBatch();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to create tickets transactionally: " + e.getMessage(), e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback failed: " + ex.getMessage(), ex);
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

    public List<Ticket> getTicketsByBookingId(long bookingId) {
        List<Ticket> list = new ArrayList<>();
        String sql = "SELECT * FROM tickets WHERE booking_id = ? ORDER BY ticket_id ASC";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapTicket(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve tickets by booking ID: " + e.getMessage(), e);
        }
        return list;
    }

    public Ticket getTicketByNumber(String ticketNumber) {
        String sql = "SELECT * FROM tickets WHERE ticket_number = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ticketNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapTicket(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve ticket by ticketNumber: " + e.getMessage(), e);
        }
        return null;
    }

    public List<Ticket> getTicketsByPnr(String pnr) {
        List<Ticket> list = new ArrayList<>();
        String sql = "SELECT * FROM tickets WHERE pnr = ? ORDER BY ticket_id ASC";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, pnr);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapTicket(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve tickets by PNR: " + e.getMessage(), e);
        }
        return list;
    }

    public boolean updateTicketsStatusForBooking(long bookingId, String status) {
        String sql = "UPDATE tickets SET status = ? WHERE booking_id = ?";
        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, bookingId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update ticket status for booking: " + e.getMessage(), e);
            return false;
        }
    }

    private Ticket mapTicket(ResultSet rs) throws SQLException {
        Ticket t = new Ticket();
        t.setTicketId(rs.getLong("ticket_id"));
        t.setBookingId(rs.getLong("booking_id"));
        t.setPassengerId(rs.getLong("passenger_id"));
        t.setTicketNumber(rs.getString("ticket_number"));
        t.setPnr(rs.getString("pnr"));
        t.setFlightNumber(rs.getString("flight_number"));
        t.setOriginCode(rs.getString("origin_code"));
        t.setDestinationCode(rs.getString("destination_code"));
        Timestamp dep = rs.getTimestamp("departure_time");
        if (dep != null) t.setDepartureTime(dep.toLocalDateTime());
        Timestamp arr = rs.getTimestamp("arrival_time");
        if (arr != null) t.setArrivalTime(arr.toLocalDateTime());
        t.setSeatNumber(rs.getString("seat_number"));
        t.setCabinClass(rs.getString("cabin_class"));
        t.setPassengerName(rs.getString("passenger_name"));
        t.setStatus(rs.getString("status"));
        t.setIssueDate(rs.getTimestamp("issue_date"));
        return t;
    }
}
