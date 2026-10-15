package com.skytech.controller.api;

import com.airline.model.Role;
import com.airline.model.User;
import com.google.gson.Gson;
import com.skytech.model.Booking;
import com.skytech.model.Passenger;
import com.skytech.model.Payment;
import com.skytech.service.BookingService;
import com.skytech.service.PaymentService;
import com.skytech.util.AppConfig;
import com.skytech.util.JsonUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * REST API Controller for Bookings, Payments, Checkout, and Cancellations:
 *   - POST /api/bookings/create
 *   - GET  /api/bookings/manage (by PNR + lastName)
 *   - GET  /api/bookings/user   (current user's bookings)
 *   - POST /api/bookings/cancel (cancel booking)
 *   - POST /api/payments/order  (create Razorpay order)
 *   - POST /api/payments/verify (cryptographic verification)
 */
@WebServlet(name = "BookingApiController", urlPatterns = {
        "/api/bookings/create",
        "/api/bookings/manage",
        "/api/bookings/user",
        "/api/bookings/cancel",
        "/api/payments/order",
        "/api/payments/verify"
})
public class BookingApiController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(BookingApiController.class.getName());
    private final Gson gson = JsonUtil.getGson();
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

        String path = request.getServletPath();
        if ("/api/bookings/manage".equalsIgnoreCase(path)) {
            handleManageBooking(request, response);
        } else if ("/api/bookings/user".equalsIgnoreCase(path)) {
            handleUserBookings(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        switch (path.toLowerCase()) {
            case "/api/bookings/create":
                handleCreateBooking(request, response);
                break;
            case "/api/bookings/cancel":
                handleCancelBooking(request, response);
                break;
            case "/api/payments/order":
                handleCreatePaymentOrder(request, response);
                break;
            case "/api/payments/verify":
                handleVerifyPayment(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                break;
        }
    }

    private void handleCreateBooking(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED, "Please sign in to complete your booking.");
            return;
        }

        Map<String, Object> body = readJsonBody(request);
        if (body == null) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid booking request body.");
            return;
        }

        int scheduleId = ((Number) body.get("scheduleId")).intValue();
        String travelClass = (String) body.getOrDefault("travelClass", "Economy");
        String contactEmail = (String) body.getOrDefault("contactEmail", currentUser.getEmail());
        String contactPhone = (String) body.getOrDefault("contactPhone", currentUser.getPhone());

        List<String> seats = (List<String>) body.getOrDefault("seats", new ArrayList<>());
        List<Map<String, Object>> passengerList = (List<Map<String, Object>>) body.get("passengers");

        if (passengerList == null || passengerList.isEmpty()) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "At least one passenger is required.");
            return;
        }

        List<Passenger> passengers = new ArrayList<>();
        int idx = 0;
        for (Map<String, Object> pMap : passengerList) {
            Passenger p = new Passenger();
            p.setFirstName((String) pMap.getOrDefault("firstName", "Passenger"));
            p.setLastName((String) pMap.getOrDefault("lastName", "Traveler"));
            p.setGender((String) pMap.getOrDefault("gender", "MALE"));
            p.setPassengerType((String) pMap.getOrDefault("passengerType", "ADULT"));
            p.setPassportNumber((String) pMap.get("passportNumber"));
            p.setNationality((String) pMap.getOrDefault("nationality", "Indian"));

            String dobStr = (String) pMap.get("dateOfBirth");
            if (dobStr != null && !dobStr.trim().isEmpty()) {
                try {
                    p.setDateOfBirth(LocalDate.parse(dobStr.trim()));
                } catch (Exception ignored) {}
            }

            if (idx < seats.size()) {
                p.setSeatNumber(seats.get(idx));
            }
            idx++;
            passengers.add(p);
        }

        try {
            Booking booking = bookingService.createPendingBooking(
                    currentUser,
                    scheduleId,
                    travelClass,
                    passengers,
                    seats,
                    contactEmail,
                    contactPhone
            );

            Map<String, Object> resp = new LinkedHashMap<>();
            resp.put("success", true);
            resp.put("message", "Booking created successfully.");
            resp.put("booking", booking);

            writeJsonResponse(response, HttpServletResponse.SC_CREATED, resp);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Booking creation failure: " + e.getMessage(), e);
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        }
    }

    private void handleManageBooking(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String pnr = request.getParameter("pnr");
        String lastName = request.getParameter("lastName");

        if (pnr == null || pnr.trim().isEmpty()) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "PNR is required.");
            return;
        }

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        Booking booking = bookingService.getBookingByPnrAndLastName(pnr.trim(), lastName, currentUser);
        if (booking == null) {
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "No reservation found for reference '" + pnr.trim() + "'.");
            return;
        }

        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("success", true);
        resp.put("booking", booking);
        writeJsonResponse(response, HttpServletResponse.SC_OK, resp);
    }

    private void handleUserBookings(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED, "Unauthenticated. Please sign in.");
            return;
        }

        List<Booking> bookings = bookingService.getUserBookings((long) currentUser.getUserId());
        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("success", true);
        resp.put("bookings", bookings);
        writeJsonResponse(response, HttpServletResponse.SC_OK, resp);
    }

    private void handleCancelBooking(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED, "Unauthenticated. Please sign in.");
            return;
        }

        Map<String, Object> body = readJsonBody(request);
        if (body == null || !body.containsKey("bookingId")) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Missing bookingId.");
            return;
        }

        long bookingId = ((Number) body.get("bookingId")).longValue();
        Booking booking = bookingService.getBookingById(bookingId, currentUser);
        if (booking == null) {
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "Booking not found.");
            return;
        }

        if (currentUser.getRole() != Role.ADMIN && booking.getUserId() != null && booking.getUserId() != currentUser.getUserId()) {
            writeError(response, HttpServletResponse.SC_FORBIDDEN, "Access denied to booking.");
            return;
        }

        String reason = (String) body.getOrDefault("reason", "Cancelled by passenger via portal");
        try {
            boolean cancelled = bookingService.cancelBooking(bookingId, reason, currentUser);
            if (cancelled) {
                Map<String, Object> resp = new LinkedHashMap<>();
                resp.put("success", true);
                resp.put("message", "Booking cancelled successfully.");
                writeJsonResponse(response, HttpServletResponse.SC_OK, resp);
            } else {
                writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Unable to cancel booking.");
            }
        } catch (Exception e) {
            writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    private void handleCreatePaymentOrder(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED, "Unauthenticated. Please sign in.");
            return;
        }

        Map<String, Object> body = readJsonBody(request);
        if (body == null || !body.containsKey("bookingId")) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Missing bookingId.");
            return;
        }

        long bookingId = ((Number) body.get("bookingId")).longValue();
        Booking booking = bookingService.getBookingById(bookingId, currentUser);
        if (booking == null) {
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "Booking not found.");
            return;
        }

        try {
            Payment payment = paymentService.initiateOrder(booking);
            Map<String, Object> resp = new LinkedHashMap<>();
            resp.put("success", true);
            resp.put("payment", payment);
            resp.put("razorpayKeyId", AppConfig.getRazorpayKeyId());
            resp.put("isRazorpayConfigured", AppConfig.isRazorpayConfigured());
            resp.put("amountInPaise", booking.getTotalAmount().multiply(new BigDecimal(100)).longValue());

            writeJsonResponse(response, HttpServletResponse.SC_OK, resp);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Payment order initiation failed: " + e.getMessage(), e);
            writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Order creation failed: " + e.getMessage());
        }
    }

    private void handleVerifyPayment(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED, "Unauthenticated. Please sign in.");
            return;
        }

        Map<String, Object> body = readJsonBody(request);
        if (body == null) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Missing verification payload.");
            return;
        }

        long bookingId = ((Number) body.get("bookingId")).longValue();
        String razorpayOrderId = (String) body.get("razorpay_order_id");
        String razorpayPaymentId = (String) body.get("razorpay_payment_id");
        String razorpaySignature = (String) body.get("razorpay_signature");
        String simulationAction = (String) body.get("simulation_action");

        Booking booking = bookingService.getBookingById(bookingId, currentUser);
        if (booking == null) {
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "Booking not found.");
            return;
        }

        Payment pendingPayment = paymentService.getPaymentByBookingId(bookingId);
        if (pendingPayment == null) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "No pending payment found.");
            return;
        }

        if ("fail".equalsIgnoreCase(simulationAction)) {
            paymentService.recordFailure(pendingPayment.getId(), "CANCELLED_BY_USER");
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Payment was cancelled by user.");
            return;
        }

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

                Map<String, Object> resp = new LinkedHashMap<>();
                resp.put("success", true);
                resp.put("message", "Payment verified and tickets issued!");
                resp.put("booking", confirmedBooking);

                writeJsonResponse(response, HttpServletResponse.SC_OK, resp);

            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Confirmation error: " + e.getMessage(), e);
                writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Confirmation error: " + e.getMessage());
            }
        } else {
            paymentService.recordFailure(pendingPayment.getId(), "INVALID_SIGNATURE");
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Payment verification failed. Invalid cryptographic signature.");
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> readJsonBody(HttpServletRequest request) {
        try {
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            if (sb.length() == 0) return null;
            return gson.fromJson(sb.toString(), Map.class);
        } catch (Exception e) {
            return null;
        }
    }

    private void writeJsonResponse(HttpServletResponse response, int status, Object data) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        try (PrintWriter out = response.getWriter()) {
            out.print(gson.toJson(data));
            out.flush();
        }
    }

    private void writeError(HttpServletResponse response, int status, String message) throws IOException {
        Map<String, Object> err = new LinkedHashMap<>();
        err.put("success", false);
        err.put("error", message);
        writeJsonResponse(response, status, err);
    }
}
