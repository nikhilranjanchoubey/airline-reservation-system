package com.skytech.airlines.booking.controller;

import com.skytech.airlines.booking.exception.BookingException;
import com.skytech.airlines.booking.exception.PaymentVerificationException;
import com.skytech.airlines.booking.model.Booking;
import com.skytech.airlines.booking.service.PaymentService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.logging.Logger;

@WebServlet(name = "PaymentCallbackServlet", urlPatterns = {"/booking/payment-callback"})
public class PaymentCallbackServlet extends BaseBookingServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(PaymentCallbackServlet.class.getName());

    private final PaymentService paymentService = new PaymentService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAuthenticationOrRedirect(request, response)) {
            return;
        }

        String pnr = request.getParameter("pnr");
        String razorpayOrderId = request.getParameter("razorpay_order_id");
        String razorpayPaymentId = request.getParameter("razorpay_payment_id");
        String razorpaySignature = request.getParameter("razorpay_signature");

        if (pnr == null || pnr.trim().isEmpty()) {
            setSessionError(request, "Missing PNR reference in payment response.");
            response.sendRedirect(request.getContextPath() + "/booking/my-bookings");
            return;
        }

        pnr = pnr.trim().toUpperCase();

        if (razorpayOrderId == null || razorpayOrderId.trim().isEmpty() ||
            razorpayPaymentId == null || razorpayPaymentId.trim().isEmpty() ||
            razorpaySignature == null || razorpaySignature.trim().isEmpty()) {

            setSessionError(request, "Incomplete payment callback data. If deducted, contact support with PNR: " + pnr);
            response.sendRedirect(request.getContextPath() + "/booking/payment?pnr=" + pnr);
            return;
        }

        Long userId = getUserId(request);

        try {
            Booking confirmed = paymentService.processPaymentCallback(
                    pnr, razorpayOrderId.trim(), razorpayPaymentId.trim(), razorpaySignature.trim(), userId
            );
            response.sendRedirect(request.getContextPath() + "/booking/confirmation?pnr=" + confirmed.getPnr() + "&payment=success");

        } catch (BookingException e) {
            setSessionError(request, "Payment confirmation failed: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/booking/payment?pnr=" + pnr);
        }
    }
}
