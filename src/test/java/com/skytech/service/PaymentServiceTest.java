package com.skytech.service;

import com.skytech.dao.PaymentDao;
import com.skytech.model.Booking;
import com.skytech.model.Payment;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.net.http.HttpClient;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PaymentServiceTest {

    @Mock
    private PaymentDao paymentDao;

    @Mock
    private HttpClient httpClient;

    private PaymentService paymentService;

    @BeforeEach
    void setUp() {
        paymentService = new PaymentService(paymentDao, httpClient);
    }

    @Test
    void testInitiateOrderCreatesPendingPayment() throws Exception {
        Booking booking = new Booking();
        booking.setId(42L);
        booking.setBookingReference("SKYT-TEST42");
        booking.setTotalAmount(new BigDecimal("5000.00"));

        @SuppressWarnings("unchecked")
        java.net.http.HttpResponse<String> mockResponse = mock(java.net.http.HttpResponse.class);
        when(mockResponse.statusCode()).thenReturn(200);
        when(mockResponse.body()).thenReturn("{\"id\":\"order_mock12345\"}");
        doReturn(mockResponse).when(httpClient).send(any(java.net.http.HttpRequest.class), any());

        when(paymentDao.createPayment(any(Payment.class))).thenAnswer(invocation -> {
            Payment p = invocation.getArgument(0);
            p.setId(99L);
            return true;
        });

        Payment payment = paymentService.initiateOrder(booking);

        assertNotNull(payment);
        assertEquals(42L, payment.getBookingId());
        assertEquals("PENDING", payment.getStatus());
        assertEquals("INR", payment.getCurrency());
        assertEquals("order_mock12345", payment.getRazorpayOrderId());
        verify(paymentDao, times(1)).createPayment(any(Payment.class));
    }

    @Test
    void testVerifySignatureHandlesSimulationSignatures() {
        // When not configured, simulated test signatures are validated
        String orderId = "order_sim_SKYT123_1001";
        String paymentId = "pay_sim_order_sim_SKYT123_1001";
        String validSig = "sim_sig_verified_SKYT123";

        boolean result = paymentService.verifySignature(orderId, paymentId, validSig);
        assertTrue(result, "Simulated signature should verify in demo/test environment");

        boolean invalidResult = paymentService.verifySignature(orderId, paymentId, "bad");
        assertFalse(invalidResult, "Invalid simulated signature should be rejected");
    }

    @Test
    void testVerifySignatureRejectsNulls() {
        assertFalse(paymentService.verifySignature(null, "pay123", "sig123"));
        assertFalse(paymentService.verifySignature("order123", null, "sig123"));
        assertFalse(paymentService.verifySignature("order123", "pay123", null));
    }

    @Test
    void testVerifyRealHmacSha256SignatureSuccessAndFailure() throws Exception {
        String orderId = "order_OId123456789";
        String paymentId = "pay_PId123456789";
        String secret = "aXkUG2wzv0STU1qphKmiG07J";

        // Compute valid HMAC-SHA256 signature
        javax.crypto.Mac mac = javax.crypto.Mac.getInstance("HmacSHA256");
        mac.init(new javax.crypto.spec.SecretKeySpec(secret.getBytes(java.nio.charset.StandardCharsets.UTF_8), "HmacSHA256"));
        byte[] rawHmac = mac.doFinal((orderId + "|" + paymentId).getBytes(java.nio.charset.StandardCharsets.UTF_8));
        String validSignature = java.util.HexFormat.of().formatHex(rawHmac);

        // Valid signature must pass
        boolean verified = paymentService.verifySignature(orderId, paymentId, validSignature);
        assertTrue(verified, "Cryptographic signature should verify successfully with valid secret");

        // Tampered signature must fail
        boolean tampered = paymentService.verifySignature(orderId, paymentId, "deadbeef12345678");
        assertFalse(tampered, "Tampered signature must be rejected");

        // Wrong order ID must fail
        boolean wrongOrder = paymentService.verifySignature("order_wrong", paymentId, validSignature);
        assertFalse(wrongOrder, "Mismatched order ID must fail verification");
    }

    @Test
    void testInitiateOrderReusesExistingPendingPayment() {
        Booking booking = new Booking();
        booking.setId(10L);
        booking.setBookingReference("SKYT-EXIST10");
        booking.setTotalAmount(new BigDecimal("7500.00"));

        Payment existing = new Payment();
        existing.setId(88L);
        existing.setBookingId(10L);
        existing.setRazorpayOrderId("order_existing_123");
        existing.setStatus("PENDING");
        existing.setAmount(new BigDecimal("7500.00"));

        when(paymentDao.getPaymentByBookingId(10L)).thenReturn(existing);

        Payment result = paymentService.initiateOrder(booking);

        assertNotNull(result);
        assertEquals("order_existing_123", result.getRazorpayOrderId());
        assertEquals(88L, result.getId());
        // Verify paymentDao.createPayment was NOT called because existing pending payment was reused
        verify(paymentDao, never()).createPayment(any(Payment.class));
    }

    @Test
    void testInitiateRefund() {
        String refundRef = paymentService.initiateRefund("pay_sim_12345", new BigDecimal("1000.00"));
        assertNotNull(refundRef);
        assertTrue(refundRef.startsWith("rfnd_sim_"));
    }
}
