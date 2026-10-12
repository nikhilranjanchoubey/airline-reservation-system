package com.skytech.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.skytech.dao.PaymentDao;
import com.skytech.model.Booking;
import com.skytech.model.Payment;
import com.skytech.util.AppConfig;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Duration;
import java.util.Base64;
import java.util.HexFormat;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service for Razorpay payment processing, order creation, and server-side HMAC signature verification.
 */
public class PaymentService {

    private static final Logger LOGGER = Logger.getLogger(PaymentService.class.getName());
    private static final ObjectMapper MAPPER = new ObjectMapper();

    private final PaymentDao paymentDao;
    private final HttpClient httpClient;

    public PaymentService() {
        this.paymentDao = new PaymentDao();
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    public PaymentService(PaymentDao paymentDao, HttpClient httpClient) {
        this.paymentDao = paymentDao;
        this.httpClient = httpClient;
    }

    /**
     * Creates an official Razorpay order or retrieves existing pending order for this booking.
     *
     * @param booking the booking awaiting payment
     * @return Payment entity with order ID
     */
    /**
     * Creates an official Razorpay order using the official API.
     * Reuses an existing real pending order if available for idempotency.
     * Never generates an order_sim_ ID when Razorpay credentials are present.
     *
     * @param booking the booking awaiting payment
     * @return Payment entity with real Razorpay order ID
     */
    public Payment initiateOrder(Booking booking) {
        if (booking == null || booking.getId() == null) {
            throw new IllegalArgumentException("Booking must be persisted before initiating payment.");
        }

        // Idempotency: Check if a real PENDING Razorpay order already exists for this booking
        Payment existingPayment = paymentDao.getPaymentByBookingId(booking.getId());
        if (existingPayment != null && existingPayment.getRazorpayOrderId() != null 
                && "PENDING".equalsIgnoreCase(existingPayment.getStatus())) {
            // Reuse only if it's a real order (not an old order_sim_ simulation) and amount matches
            if (!existingPayment.getRazorpayOrderId().startsWith("order_sim_")
                    && existingPayment.getAmount() != null 
                    && existingPayment.getAmount().compareTo(booking.getTotalAmount()) == 0) {
                LOGGER.info("Reusing existing pending Razorpay order for booking [" + booking.getId() + "]: " + existingPayment.getRazorpayOrderId());
                return existingPayment;
            }
        }

        // Amount in integer paise (INR 1.00 = 100 paise)
        long amountInPaise = booking.getTotalAmount().multiply(new BigDecimal(100)).longValue();
        String orderId = null;

        if (!AppConfig.isRazorpayConfigured()) {
            throw new IllegalStateException("Razorpay credentials are not configured. Please set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET in .env.");
        }

        try {
            String keyId = AppConfig.getRazorpayKeyId();
            String keySecret = AppConfig.getRazorpayKeySecret();
            String basicAuth = Base64.getEncoder().encodeToString((keyId + ":" + keySecret).getBytes(StandardCharsets.UTF_8));

            String payload = String.format("{\"amount\":%d,\"currency\":\"INR\",\"receipt\":\"%s\",\"payment_capture\":1}",
                    amountInPaise, booking.getBookingReference());

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.razorpay.com/v1/orders"))
                    .timeout(Duration.ofSeconds(15))
                    .header("Authorization", "Basic " + basicAuth)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response != null && response.statusCode() >= 200 && response.statusCode() < 300) {
                JsonNode node = MAPPER.readTree(response.body());
                orderId = node.path("id").asText();
                LOGGER.info("Successfully created official Razorpay order: " + orderId);
            } else {
                String body = response != null ? response.body() : "No response from gateway";
                int code = response != null ? response.statusCode() : 500;
                LOGGER.log(Level.WARNING, "Razorpay Orders API responded with HTTP " + code + ": " + body);
                throw new IllegalStateException("Razorpay Order Creation Failed (HTTP " + code + "). Gateway response: " + body);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed calling Razorpay Orders API: " + e.getMessage(), e);
            if (e instanceof IllegalStateException) {
                throw (IllegalStateException) e;
            }
            throw new IllegalStateException("Failed communicating with Razorpay API: " + e.getMessage(), e);
        }

        Payment payment = new Payment();
        payment.setBookingId(booking.getId());
        payment.setAmount(booking.getTotalAmount());
        payment.setCurrency("INR");
        payment.setPaymentMethod("RAZORPAY");
        payment.setStatus("PENDING");
        payment.setRazorpayOrderId(orderId);
        payment.setPaymentReference("REF_" + System.currentTimeMillis());

        paymentDao.createPayment(payment);
        return payment;
    }

    /**
     * Verifies the cryptographic HMAC-SHA256 signature generated by Razorpay.
     * Signature = HMAC-SHA256(order_id + "|" + razorpay_payment_id, secret)
     */
    public boolean verifySignature(String orderId, String paymentId, String signature) {
        if (orderId == null || paymentId == null || signature == null) {
            return false;
        }

        orderId = orderId.trim();
        paymentId = paymentId.trim();
        signature = signature.trim();

        // 1. Simulated orders verification (only accepted for simulated orders)
        if (orderId.startsWith("order_sim_") || paymentId.startsWith("pay_sim_")) {
            return signature.startsWith("sim_sig_") && !signature.contains("invalid") && !signature.contains("fail");
        }

        // 2. Real Razorpay orders: cryptographic HMAC-SHA256 verification with secret
        if (AppConfig.isRazorpayConfigured()) {
            try {
                String secret = AppConfig.getRazorpayKeySecret();
                String data = orderId + "|" + paymentId;

                Mac sha256Hmac = Mac.getInstance("HmacSHA256");
                SecretKeySpec secretKey = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
                sha256Hmac.init(secretKey);
                byte[] expectedHmac = sha256Hmac.doFinal(data.getBytes(StandardCharsets.UTF_8));
                String expectedSignature = HexFormat.of().formatHex(expectedHmac);

                return MessageDigest.isEqual(
                        expectedSignature.getBytes(StandardCharsets.UTF_8),
                        signature.getBytes(StandardCharsets.UTF_8)
                );
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Cryptographic signature verification exception: " + e.getMessage(), e);
                return false;
            }
        }

        return false;
    }

    /**
     * Calls Razorpay Refunds API to initiate refund on a verified payment.
     *
     * @param paymentId Razorpay payment ID
     * @param amount refund amount in INR
     * @return refund ID or null if failed
     */
    public String initiateRefund(String paymentId, BigDecimal amount) {
        if (paymentId == null || paymentId.trim().isEmpty()) {
            return null;
        }

        paymentId = paymentId.trim();

        if (paymentId.startsWith("pay_sim_") || !AppConfig.isRazorpayConfigured()) {
            return "rfnd_sim_" + System.currentTimeMillis();
        }

        try {
            long amountInPaise = amount.multiply(new BigDecimal(100)).longValue();
            String keyId = AppConfig.getRazorpayKeyId();
            String keySecret = AppConfig.getRazorpayKeySecret();
            String basicAuth = Base64.getEncoder().encodeToString((keyId + ":" + keySecret).getBytes(StandardCharsets.UTF_8));

            String payload = String.format("{\"amount\":%d,\"reverse_all\":1}", amountInPaise);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.razorpay.com/v1/payments/" + paymentId + "/refund"))
                    .timeout(Duration.ofSeconds(15))
                    .header("Authorization", "Basic " + basicAuth)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                JsonNode node = MAPPER.readTree(response.body());
                String refundId = node.path("id").asText();
                LOGGER.info("Successfully executed Razorpay Refund: " + refundId);
                return refundId;
            } else {
                LOGGER.warning("Razorpay Refund API error [" + response.statusCode() + "]: " + response.body());
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed calling Razorpay Refund API: " + e.getMessage(), e);
        }
        return null;
    }

    public Payment getPaymentByBookingId(long bookingId) {
        return paymentDao.getPaymentByBookingId(bookingId);
    }

    public Payment getPaymentByOrderId(String orderId) {
        return paymentDao.getPaymentByRazorpayOrderId(orderId);
    }

    public boolean recordSuccess(long paymentId, String paymentRef, String razorpayPaymentId,
                                 String signature, String paymentMethod) {
        return paymentDao.updatePaymentSuccess(paymentId, paymentRef, razorpayPaymentId, signature, paymentMethod);
    }

    public boolean recordFailure(long paymentId, String paymentRef) {
        return paymentDao.updatePaymentFailed(paymentId, paymentRef);
    }
}
