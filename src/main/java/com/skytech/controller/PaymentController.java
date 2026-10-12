package com.skytech.controller;

import com.airline.model.Role;
import com.airline.model.User;
import com.skytech.model.Booking;
import com.skytech.model.Payment;
import com.skytech.service.BookingService;
import com.skytech.service.PaymentService;
import com.skytech.util.AppConfig;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller handling Razorpay checkout rendering, simulation modes, and server-side payment verification.
 */
@WebServlet(name = "PaymentController", urlPatterns = {"/booking/checkout", "/booking/verify-payment"})
public class PaymentController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(PaymentController.class.getName());

    private BookingService bookingService;
    private PaymentService paymentService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.bookingService = new BookingService();
        this.paymentService = new PaymentService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String bookingIdParam = request.getParameter("bookingId");
        if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/search-flights");
            return;
        }

        long bookingId;
        try {
            bookingId = Long.parseLong(bookingIdParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/search-flights");
            return;
        }

        Booking booking = bookingService.getBookingById(bookingId, currentUser);
        if (booking == null) {
            response.sendRedirect(request.getContextPath() + "/search-flights");
            return;
        }

        // Ownership verification
        if (currentUser.getRole() != Role.ADMIN && booking.getUserId() != null && booking.getUserId() != currentUser.getUserId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied to booking.");
            return;
        }

        // If already confirmed, redirect directly to confirmation page
        if (booking.isConfirmed()) {
            response.sendRedirect(request.getContextPath() + "/booking/confirmation?id=" + booking.getId());
            return;
        }

        // Safe configuration diagnostics (never exposes secrets)
        AppConfig.logSafeDiagnostics();

        // Initiate or retrieve existing payment order
        Payment payment = null;
        String errorMessage = request.getParameter("error");
        try {
            payment = paymentService.initiateOrder(booking);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Payment order initiation failed: " + e.getMessage(), e);
            if (errorMessage == null || errorMessage.trim().isEmpty()) {
                errorMessage = e.getMessage();
            }
        }

        long amountInPaise = booking.getTotalAmount().multiply(new BigDecimal(100)).longValue();

        request.setAttribute("booking", booking);
        request.setAttribute("payment", payment);
        request.setAttribute("amountInPaise", amountInPaise);
        request.setAttribute("razorpayKeyId", AppConfig.getRazorpayKeyId());
        request.setAttribute("isRazorpayConfigured", AppConfig.isRazorpayConfigured());
        request.setAttribute("errorMessage", errorMessage);
        request.setAttribute("pageTitle", "Complete Payment - SkyTech");

        request.getRequestDispatcher("/WEB-INF/views/booking/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String razorpayOrderId = request.getParameter("razorpay_order_id");
        String razorpayPaymentId = request.getParameter("razorpay_payment_id");
        String razorpaySignature = request.getParameter("razorpay_signature");
        String simulationAction = request.getParameter("simulation_action");

        long bookingId;
        try {
            bookingId = Long.parseLong(bookingIdStr.trim());
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/search-flights");
            return;
        }

        Booking booking = bookingService.getBookingById(bookingId, currentUser);
        if (booking == null) {
            response.sendRedirect(request.getContextPath() + "/search-flights");
            return;
        }

        // 1. Verify booking ownership
        if (currentUser.getRole() != Role.ADMIN && booking.getUserId() != null && booking.getUserId() != currentUser.getUserId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied to booking.");
            return;
        }

        // 2. Reject payment if booking was already cancelled
        if ("CANCELLED".equalsIgnoreCase(booking.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/booking/checkout?bookingId=" + bookingId + "&error=This%20booking%20has%20been%20cancelled.%20Payment%20cannot%20be%20processed.");
            return;
        }

        // 3. Idempotency check: If already confirmed, redirect directly to confirmation page
        if (booking.isConfirmed()) {
            response.sendRedirect(request.getContextPath() + "/booking/confirmation?id=" + bookingId);
            return;
        }

        // 4. Verify payment order in database
        Payment pendingPayment = paymentService.getPaymentByBookingId(bookingId);
        if (pendingPayment == null) {
            response.sendRedirect(request.getContextPath() + "/booking/checkout?bookingId=" + bookingId + "&error=No%20pending%20payment%20order%20found%20for%20this%20booking.");
            return;
        }

        // Verify order ID matches server-side recorded order
        if (razorpayOrderId == null || !razorpayOrderId.trim().equals(pendingPayment.getRazorpayOrderId())) {
            LOGGER.warning("Payment order ID mismatch on booking [" + bookingId + "]. Received: " + razorpayOrderId 
                    + ", Expected: " + pendingPayment.getRazorpayOrderId());
            response.sendRedirect(request.getContextPath() + "/booking/checkout?bookingId=" + bookingId + "&error=Invalid%20order%20reference.%20Payment%20verification%20rejected.");
            return;
        }

        // Handle simulation cancellation action
        if ("fail".equalsIgnoreCase(simulationAction)) {
            paymentService.recordFailure(pendingPayment.getId(), "CANCELLED_BY_USER");
            response.sendRedirect(request.getContextPath() + "/booking/checkout?bookingId=" + bookingId + "&error=Payment%20was%20cancelled%20by%20the%20passenger.");
            return;
        }

        // 5. Server-side cryptographic HMAC-SHA256 signature verification
        boolean verified = paymentService.verifySignature(razorpayOrderId, razorpayPaymentId, razorpaySignature);

        if (verified) {
            try {
                Booking confirmedBooking = bookingService.confirmPaymentAndIssueTickets(
                        bookingId,
                        razorpayOrderId,
                        razorpayPaymentId,
                        razorpaySignature,
                        "RAZORPAY"
                );
                LOGGER.info("Booking [" + bookingId + "] verified & confirmed successfully with PNR: " + confirmedBooking.getPnr());
                response.sendRedirect(request.getContextPath() + "/booking/confirmation?id=" + bookingId);
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Failed executing transactional confirmation for booking [" + bookingId + "]: " + e.getMessage(), e);
                response.sendRedirect(request.getContextPath() + "/booking/checkout?bookingId=" + bookingId + "&error=Confirmation%20failure:%20" + e.getMessage());
            }
        } else {
            LOGGER.warning("Payment signature verification failed for booking [" + bookingId + "], order [" + razorpayOrderId + "]");
            paymentService.recordFailure(pendingPayment.getId(), "INVALID_SIGNATURE");
            response.sendRedirect(request.getContextPath() + "/booking/checkout?bookingId=" + bookingId + "&error=Payment%20verification%20failed.%20Invalid%20cryptographic%20signature.");
        }
    }
}
