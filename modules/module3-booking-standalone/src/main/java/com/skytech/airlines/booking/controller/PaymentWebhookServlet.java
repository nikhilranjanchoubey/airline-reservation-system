package com.skytech.airlines.booking.controller;

import com.skytech.airlines.booking.config.AppConfig;
import com.skytech.airlines.booking.service.RazorpayService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.logging.Logger;

@WebServlet(name = "PaymentWebhookServlet", urlPatterns = {"/booking/payment-webhook"})
public class PaymentWebhookServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(PaymentWebhookServlet.class.getName());

    private final RazorpayService razorpayService = new RazorpayService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String signature = request.getHeader("X-Razorpay-Signature");
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        String body = sb.toString();

        boolean valid = razorpayService.verifyWebhookSignature(body, signature, AppConfig.getRazorpayWebhookSecret());
        if (valid) {
            LOGGER.info("Verified Razorpay webhook event received.");
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("{\"status\":\"success\"}");
        } else {
            LOGGER.warning("Untrusted webhook request rejected: Invalid signature.");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"invalid_signature\"}");
        }
    }
}
