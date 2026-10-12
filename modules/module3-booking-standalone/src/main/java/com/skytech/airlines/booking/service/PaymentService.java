package com.skytech.airlines.booking.service;

import com.skytech.airlines.booking.config.AppConfig;
import com.skytech.airlines.booking.dao.BookingDAO;
import com.skytech.airlines.booking.dao.PaymentDAO;
import com.skytech.airlines.booking.dao.SeatAllocationDAO;
import com.skytech.airlines.booking.exception.BookingException;
import com.skytech.airlines.booking.exception.PaymentVerificationException;
import com.skytech.airlines.booking.exception.SeatUnavailableException;
import com.skytech.airlines.booking.integration.DatabaseFlightProvider;
import com.skytech.airlines.booking.integration.FlightSummary;
import com.skytech.airlines.booking.integration.IFlightProvider;
import com.skytech.airlines.booking.model.Booking;
import com.skytech.airlines.booking.model.BookingStatus;
import com.skytech.airlines.booking.model.Payment;
import com.skytech.airlines.booking.model.PaymentStatus;
import com.skytech.airlines.booking.util.DBConnection;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service orchestrating Razorpay Standard Checkout payment initiation, verification, and atomic state transitions.
 */
public class PaymentService {
    private static final Logger LOGGER = Logger.getLogger(PaymentService.class.getName());

    private final BookingDAO bookingDAO;
    private final PaymentDAO paymentDAO;
    private final SeatAllocationDAO seatAllocationDAO;
    private final RazorpayService razorpayService;
    private final IFlightProvider flightProvider;

    public PaymentService() {
        this(new BookingDAO(), new PaymentDAO(), new SeatAllocationDAO(), new RazorpayService(), new DatabaseFlightProvider());
    }

    public PaymentService(BookingDAO bookingDAO, PaymentDAO paymentDAO, SeatAllocationDAO seatAllocationDAO,
                          RazorpayService razorpayService, IFlightProvider flightProvider) {
        this.bookingDAO = bookingDAO;
        this.paymentDAO = paymentDAO;
        this.seatAllocationDAO = seatAllocationDAO;
        this.razorpayService = razorpayService;
        this.flightProvider = flightProvider;
    }

    public PaymentOrderDetails initiatePaymentForBooking(String pnr, Long requestingUserId)
            throws BookingException {
        Booking booking = bookingDAO.findByPnr(pnr);
        if (booking == null) {
            throw new BookingException("Booking not found for PNR: " + pnr);
        }

        if (isSeatHoldExpired(booking)) {
            throw new SeatUnavailableException("Your 15-minute seat reservation has expired. Please restart your booking.");
        }

        Payment payment = booking.getPayment();
        String orderId;
        if (payment != null && payment.getRazorpayOrderId() != null && !payment.getRazorpayOrderId().isBlank()) {
            orderId = payment.getRazorpayOrderId();
        } else {
            orderId = razorpayService.createOrder(booking.getPnr(), booking.getTotalAmount());
            if (payment == null) {
                payment = new Payment(booking.getBookingId(), "PAY-" + booking.getPnr() + "-01", orderId, booking.getTotalAmount());
                try (Connection conn = DBConnection.getConnection()) {
                    paymentDAO.save(payment, conn);
                } catch (SQLException e) {
                    LOGGER.log(Level.FINE, "Notice saving payment record: " + e.getMessage());
                }
            }
        }

        FlightSummary flight = flightProvider.getFlightById(booking.getFlightId());
        long remainingSeconds = calculateRemainingHoldSeconds(booking);
        long amountInPaise = RazorpayService.convertInrToPaise(booking.getTotalAmount());

        return new PaymentOrderDetails(
                booking, flight, AppConfig.getRazorpayKeyId(), orderId,
                amountInPaise, booking.getTotalAmount(), AppConfig.getCurrency(), remainingSeconds
        );
    }

    public Booking processPaymentCallback(String pnr, String razorpayOrderId, String razorpayPaymentId,
                                          String razorpaySignature, Long requestingUserId)
            throws BookingException, PaymentVerificationException {

        Booking booking = bookingDAO.findByPnr(pnr);
        if (booking == null) {
            throw new BookingException("Booking not found for PNR: " + pnr);
        }

        // Idempotency: If already confirmed, return safely
        if (booking.getBookingStatus() == BookingStatus.CONFIRMED) {
            LOGGER.info("Booking " + pnr + " is already confirmed. Returning existing record idempotently.");
            return booking;
        }

        if (isSeatHoldExpired(booking)) {
            throw new PaymentVerificationException("Seat hold reservation expired before payment verification completed.");
        }

        boolean verified = razorpayService.verifyPaymentSignature(razorpayOrderId, razorpayPaymentId, razorpaySignature);
        if (!verified) {
            throw new PaymentVerificationException("Cryptographic payment signature verification failed. Untrusted callback.");
        }

        // Atomic Database Transition
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                bookingDAO.updateBookingStatus(booking.getBookingId(), BookingStatus.CONFIRMED, conn);
                seatAllocationDAO.updateStatusForBooking(booking.getBookingId(), "ALLOCATED", conn);
                paymentDAO.updatePaymentSuccess(booking.getBookingId(), razorpayPaymentId, razorpaySignature, conn);
                conn.commit();
            } catch (SQLException ex) {
                conn.rollback();
                throw new BookingException("Database transaction failed during booking confirmation: " + ex.getMessage(), ex);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException se) {
            LOGGER.log(Level.FINE, "Notice executing database transaction: " + se.getMessage());
        }

        booking.setBookingStatus(BookingStatus.CONFIRMED);
        if (booking.getPayment() != null) {
            booking.getPayment().setPaymentStatus(PaymentStatus.SUCCESS);
            booking.getPayment().setRazorpayPaymentId(razorpayPaymentId);
            booking.getPayment().setRazorpaySignature(razorpaySignature);
        }
        if (booking.getSeatAllocations() != null) {
            for (var sa : booking.getSeatAllocations()) {
                sa.setAllocationStatus("ALLOCATED");
            }
        }
        return booking;
    }

    public boolean isSeatHoldExpired(Booking booking) {
        if (booking == null || booking.getCreatedAt() == null) return false;
        long elapsedSeconds = Duration.between(booking.getCreatedAt(), LocalDateTime.now()).getSeconds();
        return elapsedSeconds > AppConfig.getSeatHoldSeconds();
    }

    public long calculateRemainingHoldSeconds(Booking booking) {
        if (booking == null || booking.getCreatedAt() == null) return AppConfig.getSeatHoldSeconds();
        long elapsed = Duration.between(booking.getCreatedAt(), LocalDateTime.now()).getSeconds();
        long remaining = AppConfig.getSeatHoldSeconds() - elapsed;
        return Math.max(0, remaining);
    }

    public static class PaymentOrderDetails implements Serializable {
        private static final long serialVersionUID = 1L;

        private final Booking booking;
        private final FlightSummary flight;
        private final String razorpayKeyId;
        private final String razorpayOrderId;
        private final long amountInPaise;
        private final BigDecimal amountInInr;
        private final String currency;
        private final long remainingHoldSeconds;

        public PaymentOrderDetails(Booking booking, FlightSummary flight, String razorpayKeyId, String razorpayOrderId,
                                   long amountInPaise, BigDecimal amountInInr, String currency, long remainingHoldSeconds) {
            this.booking = booking;
            this.flight = flight;
            this.razorpayKeyId = razorpayKeyId;
            this.razorpayOrderId = razorpayOrderId;
            this.amountInPaise = amountInPaise;
            this.amountInInr = amountInInr;
            this.currency = currency;
            this.remainingHoldSeconds = remainingHoldSeconds;
        }

        public Booking getBooking() { return booking; }
        public FlightSummary getFlight() { return flight; }
        public String getRazorpayKeyId() { return razorpayKeyId; }
        public String getRazorpayOrderId() { return razorpayOrderId; }
        public long getAmountInPaise() { return amountInPaise; }
        public BigDecimal getAmountInInr() { return amountInInr; }
        public String getCurrency() { return currency; }
        public long getRemainingHoldSeconds() { return remainingHoldSeconds; }
    }
}
