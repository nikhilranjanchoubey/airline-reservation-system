package com.skytech.service;

import com.airline.model.Role;
import com.airline.model.User;
import com.skytech.dao.*;
import com.skytech.model.*;
import com.skytech.util.DBConnectionUtil;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Core business service orchestrating the booking lifecycle:
 * verification, reservation creation, payment confirmation, inventory locking,
 * ticketing, and cancellations.
 */
public class BookingService {

    private static final Logger LOGGER = Logger.getLogger(BookingService.class.getName());
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String PNR_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    private final BookingDao bookingDao;
    private final SeatDao seatDao;
    private final TicketDao ticketDao;
    private final CancellationDao cancellationDao;
    private final PaymentDao paymentDao;
    private final FlightSearchService flightSearchService;
    private final PaymentService paymentService;

    public BookingService() {
        this.bookingDao = new BookingDao();
        this.seatDao = new SeatDao();
        this.ticketDao = new TicketDao();
        this.cancellationDao = new CancellationDao();
        this.paymentDao = new PaymentDao();
        this.flightSearchService = new FlightSearchService();
        this.paymentService = new PaymentService(this.paymentDao, java.net.http.HttpClient.newHttpClient());
    }

    public BookingService(BookingDao bookingDao, SeatDao seatDao, TicketDao ticketDao,
                          CancellationDao cancellationDao, PaymentDao paymentDao,
                          FlightSearchService flightSearchService) {
        this(bookingDao, seatDao, ticketDao, cancellationDao, paymentDao, flightSearchService,
             new PaymentService(paymentDao, java.net.http.HttpClient.newHttpClient()));
    }

    public BookingService(BookingDao bookingDao, SeatDao seatDao, TicketDao ticketDao,
                          CancellationDao cancellationDao, PaymentDao paymentDao,
                          FlightSearchService flightSearchService, PaymentService paymentService) {
        this.bookingDao = bookingDao;
        this.seatDao = seatDao;
        this.ticketDao = ticketDao;
        this.cancellationDao = cancellationDao;
        this.paymentDao = paymentDao;
        this.flightSearchService = flightSearchService;
        this.paymentService = paymentService != null ? paymentService : new PaymentService(paymentDao, java.net.http.HttpClient.newHttpClient());
    }

    /**
     * Creates a pending booking with revalidated server-side pricing and seat availability.
     */
    public Booking createPendingBooking(User user, int scheduleId, String travelClass,
                                        List<Passenger> passengers, List<String> seatNumbers,
                                        String contactEmail, String contactPhone) {

        if (user == null) {
            throw new IllegalStateException("Authentication is required to initiate a flight reservation.");
        }
        if (passengers == null || passengers.isEmpty()) {
            throw new IllegalArgumentException("At least one passenger must be specified.");
        }

        FlightSchedule schedule = null;
        try {
            schedule = flightSearchService.getFlightDetails(scheduleId, null);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to retrieve flight schedule: " + e.getMessage(), e);
        }
        if (schedule == null) {
            throw new IllegalArgumentException("The selected flight schedule is no longer available.");
        }


        if (travelClass == null || travelClass.trim().isEmpty()) {
            travelClass = "Economy";
        }

        // 1. Re-validate seat availability
        if (seatNumbers != null && !seatNumbers.isEmpty()) {
            for (String seat : seatNumbers) {
                if (seat != null && !seat.trim().isEmpty()) {
                    if (!seatDao.isSeatAvailable(scheduleId, seat.trim())) {
                        throw new IllegalStateException("Selected seat " + seat + " is already occupied. Please select an alternate seat.");
                    }
                }
            }
        }

        // 2. Server-side authoritative fare calculation
        BigDecimal basePerPassenger = schedule.getPriceForClass(travelClass);
        BigDecimal baseFareTotal = basePerPassenger.multiply(new BigDecimal(passengers.size()));

        // Calculate seat fees
        BigDecimal seatFeesTotal = BigDecimal.ZERO;
        String airlineCode = (schedule.getFlight() != null && schedule.getFlight().getAirline() != null)
                ? schedule.getFlight().getAirline().getAirlineCode() : "6E";

        if (seatNumbers != null) {
            for (String s : seatNumbers) {
                if (s != null && s.length() >= 2) {
                    try {
                        int row = Integer.parseInt(s.replaceAll("[^0-9]", ""));
                        String col = s.replaceAll("[^A-Za-z]", "").toUpperCase();
                        SeatPricingConfig.SeatPricingInfo pInfo = SeatPricingConfig.resolveSeatPricing(airlineCode, row, col);
                        seatFeesTotal = seatFeesTotal.add(pInfo.getPrice());
                    } catch (Exception ignored) {
                    }
                }
            }
        }

        // Statutory GST & Airport Fees (12%)
        BigDecimal subtotal = baseFareTotal.add(seatFeesTotal);
        BigDecimal taxesAndFees = subtotal.multiply(new BigDecimal("0.12")).setScale(2, RoundingMode.HALF_UP);
        BigDecimal grandTotal = subtotal.add(taxesAndFees).setScale(2, RoundingMode.HALF_UP);

        // Assign seats to passengers
        for (int i = 0; i < passengers.size(); i++) {
            if (seatNumbers != null && i < seatNumbers.size()) {
                passengers.get(i).setSeatNumber(seatNumbers.get(i));
            }
        }

        String seatNumbersJoined = (seatNumbers != null && !seatNumbers.isEmpty())
                ? String.join(", ", seatNumbers) : null;

        Booking booking = new Booking();
        booking.setBookingReference("SKYT-" + generateAlphanumeric(6));
        booking.setUserId((long) user.getUserId());
        booking.setScheduleId(scheduleId);
        booking.setFlightNumber(schedule.getFlight().getFlightNumber());
        booking.setTravelClass(travelClass);
        booking.setSeatNumbers(seatNumbersJoined);
        booking.setContactEmail(contactEmail != null ? contactEmail : user.getEmail());
        booking.setContactPhone(contactPhone != null ? contactPhone : user.getPhone());
        booking.setOriginCode(schedule.getFlight().getSourceAirport().getAirportCode());
        booking.setDestinationCode(schedule.getFlight().getDestinationAirport().getAirportCode());
        booking.setDepartureDate(schedule.getFlightDate() != null ? schedule.getFlightDate().toLocalDate() : null);
        booking.setStatus("PENDING_PAYMENT");
        booking.setProvider("LOCAL_CATALOG");
        booking.setTotalAmount(grandTotal);
        booking.setCurrency("INR");
        booking.setPassengers(passengers);
        booking.setSchedule(schedule);

        boolean created = bookingDao.createBooking(booking, passengers);
        if (!created) {
            throw new RuntimeException("Database error: Could not persist booking.");
        }

        return booking;
    }

    /**
     * Confirms booking following verified payment: updates status, issues PNR, locks seat inventory,
     * and generates e-tickets. Fully idempotent.
     */
    public Booking confirmPaymentAndIssueTickets(long bookingId, String razorpayOrderId,
                                                 String razorpayPaymentId, String signature,
                                                 String paymentMethod) {

        Booking booking = bookingDao.getBookingById(bookingId);
        if (booking == null) {
            throw new IllegalArgumentException("Booking not found with ID: " + bookingId);
        }

        // Idempotency: If already confirmed, return existing confirmed booking
        if (booking.isConfirmed()) {
            LOGGER.info("Booking [" + bookingId + "] is already confirmed. Returning existing record.");
            booking.setTickets(ticketDao.getTicketsByBookingId(bookingId));
            booking.setPayment(paymentDao.getPaymentByBookingId(bookingId));
            return booking;
        }

        // 1. Generate unique 6-character PNR
        String pnr = generatePnr();
        booking.setPnr(pnr);

        // 2. Update booking status in database
        boolean updated = bookingDao.confirmBooking(bookingId, pnr);
        if (!updated) {
            throw new RuntimeException("Failed to update booking to confirmed state.");
        }

        // 3. Update payment status to SUCCESS
        Payment payment = paymentDao.getPaymentByBookingId(bookingId);
        if (payment != null) {
            paymentDao.updatePaymentSuccess(payment.getId(), "REF_" + pnr, razorpayPaymentId, signature, paymentMethod);
        }

        // 4. Reserve seats in database and update schedule inventory count
        if (booking.getScheduleId() != null) {
            try (Connection conn = DBConnectionUtil.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    List<Passenger> passengers = booking.getPassengers();
                    if (passengers != null) {
                        for (Passenger p : passengers) {
                            if (p.getSeatNumber() != null && !p.getSeatNumber().trim().isEmpty()) {
                                seatDao.reserveSeat(booking.getScheduleId(), p.getSeatNumber().trim(), conn);
                            }
                        }
                        seatDao.updateScheduleInventoryCount(booking.getScheduleId(), -passengers.size(), conn);
                    }
                    conn.commit();
                } catch (SQLException e) {
                    conn.rollback();
                    LOGGER.log(Level.SEVERE, "Failed to reserve seats transactionally: " + e.getMessage(), e);
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Connection error updating seat inventory: " + e.getMessage(), e);
            }
        }

        // 5. Issue confirmed E-Tickets for all passengers
        List<Passenger> passengers = booking.getPassengers();
        List<Ticket> tickets = new ArrayList<>();
        if (passengers != null) {
            LocalDateTime depTime = LocalDateTime.now().plusDays(1).withHour(10).withMinute(0);
            LocalDateTime arrTime = depTime.plusHours(2);
            if (booking.getDepartureDate() != null) {
                depTime = booking.getDepartureDate().atTime(10, 0);
                arrTime = depTime.plusHours(2);
            }

            int idx = 1;
            for (Passenger p : passengers) {
                Ticket t = new Ticket();
                t.setBookingId(bookingId);
                t.setPassengerId(p.getId());
                t.setTicketNumber("098-" + bookingId + "-" + String.format("%03d", idx++));
                t.setPnr(pnr);
                t.setFlightNumber(booking.getFlightNumber());
                t.setOriginCode(booking.getOriginCode());
                t.setDestinationCode(booking.getDestinationCode());
                t.setDepartureTime(depTime);
                t.setArrivalTime(arrTime);
                t.setSeatNumber(p.getSeatNumber());
                t.setCabinClass(booking.getTravelClass());
                t.setPassengerName(p.getFullName());
                t.setStatus("CONFIRMED");
                tickets.add(t);
            }
            ticketDao.createTickets(tickets);
        }

        booking.setStatus("CONFIRMED");
        booking.setTickets(tickets);
        booking.setPayment(paymentDao.getPaymentByBookingId(bookingId));
        return booking;
    }

    /**
     * Processes cancellation: verifies eligibility, computes refund according to project policy,
     * updates statuses, and releases seat inventory.
     */
    public boolean cancelBooking(long bookingId, String reason, User currentUser) {
        Booking booking = bookingDao.getBookingById(bookingId);
        if (booking == null) {
            throw new IllegalArgumentException("Booking not found.");
        }

        // Authorization check
        if (currentUser == null || (currentUser.getRole() != Role.ADMIN && booking.getUserId() != null && booking.getUserId() != currentUser.getUserId())) {
            throw new SecurityException("Unauthorized to cancel this reservation.");
        }

        if (!booking.isConfirmed()) {
            throw new IllegalStateException("Only confirmed bookings may be cancelled.");
        }

        // Academic Cancellation Policy:
        // Standard cancellation fee: 25% of total amount or ₹1,000 per passenger, whichever is lower.
        int passengerCount = Math.max(1, booking.getPassengers() != null ? booking.getPassengers().size() : 1);
        BigDecimal pctFee = booking.getTotalAmount().multiply(new BigDecimal("0.25"));
        BigDecimal capFee = new BigDecimal(1000 * passengerCount);
        BigDecimal cancellationFee = pctFee.min(capFee).setScale(2, RoundingMode.HALF_UP);
        BigDecimal refundAmount = booking.getTotalAmount().subtract(cancellationFee).max(BigDecimal.ZERO);

        // 1. Update Booking Status
        bookingDao.updateBookingStatus(bookingId, "CANCELLED");

        // 2. Update Ticket Status
        ticketDao.updateTicketsStatusForBooking(bookingId, "CANCELLED");

        // 3. Release seat inventory
        if (booking.getScheduleId() != null) {
            try (Connection conn = DBConnectionUtil.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    List<Passenger> passengers = booking.getPassengers();
                    if (passengers != null) {
                        for (Passenger p : passengers) {
                            if (p.getSeatNumber() != null && !p.getSeatNumber().trim().isEmpty()) {
                                seatDao.releaseSeat(booking.getScheduleId(), p.getSeatNumber().trim(), conn);
                            }
                        }
                        seatDao.updateScheduleInventoryCount(booking.getScheduleId(), passengers.size(), conn);
                    }
                    conn.commit();
                } catch (SQLException e) {
                    conn.rollback();
                    LOGGER.log(Level.SEVERE, "Failed to release seats: " + e.getMessage(), e);
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Connection error releasing seats: " + e.getMessage(), e);
            }
        }

        // 4. Refund Processing with Razorpay API where available
        Payment payment = paymentDao.getPaymentByBookingId(bookingId);
        String refundRef = null;
        String refundStatus = "RECORDED_ACADEMIC_REFUND";

        if (payment != null && payment.getRazorpayPaymentId() != null) {
            String payId = payment.getRazorpayPaymentId().trim();
            if (payId.startsWith("pay_") && !payId.startsWith("pay_sim_")) {
                try {
                    refundRef = paymentService.initiateRefund(payId, refundAmount);
                    if (refundRef != null) {
                        refundStatus = "PROCESSED_RAZORPAY_TEST_REFUND";
                    } else {
                        refundStatus = "REFUND_PENDING";
                        refundRef = "PENDING_GATEWAY_RECONCILIATION";
                    }
                } catch (Exception e) {
                    refundStatus = "REFUND_PENDING";
                    refundRef = "ERR_" + System.currentTimeMillis();
                }
            } else {
                refundRef = "SIM_RFND_" + System.currentTimeMillis();
                refundStatus = "RECORDED_ACADEMIC_REFUND";
            }
        } else {
            refundRef = "SIM_RFND_" + System.currentTimeMillis();
            refundStatus = "RECORDED_ACADEMIC_REFUND";
        }

        // Record Cancellation in MySQL
        Cancellation cancellation = new Cancellation();
        cancellation.setBookingId(bookingId);
        cancellation.setPnr(booking.getPnr() != null ? booking.getPnr() : booking.getBookingReference());
        cancellation.setCancellationReason(reason != null ? reason : "Passenger requested cancellation");
        cancellation.setCancellationFee(cancellationFee);
        cancellation.setRefundAmount(refundAmount);
        cancellation.setRefundStatus(refundStatus);
        cancellation.setRefundReference(refundRef);
        cancellation.setCancelledByUserId(currentUser != null ? (long) currentUser.getUserId() : null);

        cancellationDao.recordCancellation(cancellation);
        return true;
    }

    public Booking getBookingById(long bookingId, User currentUser) {
        Booking booking = bookingDao.getBookingById(bookingId);
        if (booking == null) return null;

        // Verify ownership unless admin
        if (currentUser != null && currentUser.getRole() != Role.ADMIN) {
            if (booking.getUserId() != null && booking.getUserId() != currentUser.getUserId()) {
                throw new SecurityException("Access denied to this booking.");
            }
        }

        booking.setTickets(ticketDao.getTicketsByBookingId(bookingId));
        booking.setPayment(paymentDao.getPaymentByBookingId(bookingId));
        booking.setCancellation(cancellationDao.getCancellationByBookingId(bookingId));
        if (booking.getScheduleId() != null) {
            try {
                booking.setSchedule(flightSearchService.getFlightDetails(booking.getScheduleId(), null));
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Could not populate schedule for booking [" + bookingId + "]: " + e.getMessage());
            }
        }

        return booking;
    }

    public Booking getBookingByPnrAndLastName(String pnr, String lastName, User currentUser) {
        Booking booking = bookingDao.getBookingByReferenceOrPnr(pnr);
        if (booking == null) return null;

        // If authenticated user owns it or is admin, allow
        if (currentUser != null) {
            if (currentUser.getRole() == Role.ADMIN || (booking.getUserId() != null && booking.getUserId() == currentUser.getUserId())) {
                booking.setTickets(ticketDao.getTicketsByBookingId(booking.getId()));
                booking.setPayment(paymentDao.getPaymentByBookingId(booking.getId()));
                booking.setCancellation(cancellationDao.getCancellationByBookingId(booking.getId()));
                return booking;
            }
        }

        // If unauthenticated guest lookup, verify last name against passengers or contact
        if (lastName != null && !lastName.trim().isEmpty()) {
            String check = lastName.trim().toLowerCase();
            boolean matched = false;
            if (booking.getPassengers() != null) {
                for (Passenger p : booking.getPassengers()) {
                    if (p.getLastName() != null && p.getLastName().trim().equalsIgnoreCase(check)) {
                        matched = true;
                        break;
                    }
                }
            }
            if (matched) {
                booking.setTickets(ticketDao.getTicketsByBookingId(booking.getId()));
                booking.setPayment(paymentDao.getPaymentByBookingId(booking.getId()));
                booking.setCancellation(cancellationDao.getCancellationByBookingId(booking.getId()));
                return booking;
            }
        }

        return null;
    }

    public List<Booking> getUserBookings(long userId) {
        List<Booking> list = bookingDao.getBookingsByUserId(userId);
        for (Booking b : list) {
            b.setTickets(ticketDao.getTicketsByBookingId(b.getId()));
            b.setPayment(paymentDao.getPaymentByBookingId(b.getId()));
            b.setCancellation(cancellationDao.getCancellationByBookingId(b.getId()));
        }
        return list;
    }

    public List<Booking> getAllBookings() {
        List<Booking> list = bookingDao.getAllBookings();
        for (Booking b : list) {
            b.setTickets(ticketDao.getTicketsByBookingId(b.getId()));
            b.setPayment(paymentDao.getPaymentByBookingId(b.getId()));
        }
        return list;
    }

    public int countTotalBookings() {
        return bookingDao.countTotalBookings();
    }

    public int countConfirmedBookings() {
        return bookingDao.countConfirmedBookings();
    }

    public int countPendingBookings() {
        return bookingDao.countPendingBookings();
    }

    public int countCancelledBookings() {
        return bookingDao.countCancelledBookings();
    }


    public BigDecimal calculateTotalRevenue() {
        return bookingDao.calculateTotalRevenue();
    }

    private String generatePnr() {
        StringBuilder sb = new StringBuilder(6);
        for (int i = 0; i < 6; i++) {
            sb.append(PNR_CHARS.charAt(RANDOM.nextInt(PNR_CHARS.length())));
        }
        return sb.toString();
    }

    private String generateAlphanumeric(int length) {
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            sb.append(PNR_CHARS.charAt(RANDOM.nextInt(PNR_CHARS.length())));
        }
        return sb.toString();
    }
}
