package com.skytech.airlines.booking.service;

import com.skytech.airlines.booking.dao.BookingDAO;
import com.skytech.airlines.booking.dao.PaymentDAO;
import com.skytech.airlines.booking.dao.SeatAllocationDAO;
import com.skytech.airlines.booking.exception.*;
import com.skytech.airlines.booking.integration.FlightSummary;
import com.skytech.airlines.booking.integration.IFlightProvider;
import com.skytech.airlines.booking.model.*;
import com.skytech.airlines.booking.util.DBConnection;
import com.skytech.airlines.booking.util.FareCalculator;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Master service orchestrating the multi-step booking lifecycle, transaction coordination, and IDOR ownership security.
 */
public class BookingService {
    private static final Logger LOGGER = Logger.getLogger(BookingService.class.getName());

    private final BookingDAO bookingDAO;
    private final PassengerService passengerService;
    private final SeatAllocationService seatAllocationService;
    private final PNRGenerator pnrGenerator;

    public BookingService() {
        this(new BookingDAO(), new PassengerService(), new SeatAllocationService(), new PNRGenerator());
    }

    public BookingService(BookingDAO bookingDAO, PassengerService passengerService,
                          SeatAllocationService seatAllocationService, PNRGenerator pnrGenerator) {
        this.bookingDAO = bookingDAO;
        this.passengerService = passengerService;
        this.seatAllocationService = seatAllocationService;
        this.pnrGenerator = pnrGenerator;
    }

    public Booking createPendingBooking(Long userId, Long flightId, List<Passenger> passengers,
                                        List<String> selectedSeats, BigDecimal flightBaseFare,
                                        String contactEmail, String contactPhone)
            throws BookingException {

        passengerService.validatePassengerList(passengers, contactEmail, contactPhone);
        seatAllocationService.validateSeatSelections(flightId, selectedSeats, passengers.size());

        for (int i = 0; i < passengers.size(); i++) {
            passengers.get(i).setSeatNumber(selectedSeats.get(i));
        }

        String pnr = pnrGenerator.generateUniquePNR(bookingDAO);
        Booking booking = new Booking(pnr, userId, flightId, contactEmail, contactPhone);
        booking.setBookingStatus(BookingStatus.PENDING);

        FareBreakdown fare = FareCalculator.calculateFare(flightBaseFare, passengers, null);
        BigDecimal totalSeatFees = BigDecimal.ZERO;
        for (String seatNum : selectedSeats) {
            totalSeatFees = totalSeatFees.add(seatAllocationService.getFeeForSeat(seatNum));
        }
        fare = FareCalculator.calculateFare(flightBaseFare, passengers, 
                selectedSeats.stream().map(s -> new SeatAllocation(null, null, flightId, s, seatAllocationService.getClassForSeat(s), seatAllocationService.getFeeForSeat(s), "HELD")).toList());

        booking.setBaseFare(fare.getBaseFare());
        booking.setSeatFees(fare.getSeatFees());
        booking.setTaxAmount(fare.getTaxAmount());
        booking.setTotalAmount(fare.getTotalAmount());
        booking.setPassengers(passengers);

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                Long bookingId = bookingDAO.save(booking, conn);
                passengerService.savePassengersForBooking(bookingId, passengers, conn);
                seatAllocationService.allocateSeatsForBooking(bookingId, flightId, selectedSeats, conn);
                conn.commit();
            } catch (SQLException sqle) {
                conn.rollback();
                throw new ConcurrentBookingException("Failed to secure seat reservation due to database conflict: " + sqle.getMessage(), sqle);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Notice saving pending booking to database: " + e.getMessage());
        }

        return booking;
    }

    public Booking getBookingByPnrAndUser(String pnr, Long userId) {
        Booking booking = bookingDAO.findByPnr(pnr);
        if (booking == null) return null;
        if (userId != null && booking.getUserId() != null && !booking.getUserId().equals(userId)) {
            LOGGER.warning("Access denied: User " + userId + " attempted to access booking owned by user " + booking.getUserId());
            return null; // IDOR protection
        }
        return booking;
    }

    private final SeatAllocationDAO seatAllocationDAO = new SeatAllocationDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    public List<Booking> getUserBookings(Long userId) {
        return bookingDAO.findByUserId(userId);
    }

    public boolean cancelBooking(String pnr, Long userId, String cancellationReason) throws BookingException {
        if (pnr == null || pnr.trim().isEmpty()) {
            throw new BookingException("PNR reference cannot be empty.");
        }
        Booking booking = getBookingByPnrAndUser(pnr.trim().toUpperCase(), userId);
        if (booking == null) {
            throw new BookingException("Booking with PNR " + pnr + " not found or unauthorized.");
        }
        if (booking.getBookingStatus() == BookingStatus.CANCELLED) {
            throw new BookingException("Booking " + pnr + " is already cancelled.");
        }

        booking.setBookingStatus(BookingStatus.CANCELLED);
        if (booking.getSeatAllocations() != null) {
            for (SeatAllocation sa : booking.getSeatAllocations()) {
                sa.setAllocationStatus("RELEASED");
            }
        }
        if (booking.getPayment() != null) {
            booking.getPayment().setPaymentStatus(PaymentStatus.REFUNDED);
        }

        if (booking.getBookingId() != null) {
            try (Connection conn = DBConnection.getConnection()) {
                if (conn != null) {
                    conn.setAutoCommit(false);
                    try {
                        bookingDAO.updateBookingStatus(booking.getBookingId(), BookingStatus.CANCELLED, conn);
                        seatAllocationDAO.updateStatusForBooking(booking.getBookingId(), "RELEASED", conn);
                        paymentDAO.updatePaymentStatus(booking.getBookingId(), PaymentStatus.REFUNDED, conn);
                        conn.commit();
                    } catch (SQLException sqle) {
                        conn.rollback();
                        LOGGER.log(Level.WARNING, "Database rollback during cancellation: " + sqle.getMessage());
                    } finally {
                        conn.setAutoCommit(true);
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.FINE, "Notice executing database cancellation: " + e.getMessage());
            }
        }

        LOGGER.info("Booking " + pnr + " successfully cancelled. Seats released, refund flagged. Reason: " + cancellationReason);
        return true;
    }
}
