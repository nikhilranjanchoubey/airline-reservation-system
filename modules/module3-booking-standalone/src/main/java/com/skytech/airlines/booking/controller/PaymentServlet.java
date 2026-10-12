package com.skytech.airlines.booking.controller;

import com.skytech.airlines.booking.exception.BookingException;
import com.skytech.airlines.booking.exception.SeatUnavailableException;
import com.skytech.airlines.booking.model.Booking;
import com.skytech.airlines.booking.model.BookingStatus;
import com.skytech.airlines.booking.service.PaymentService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "PaymentServlet", urlPatterns = {"/booking/payment"})
public class PaymentServlet extends BaseBookingServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(PaymentServlet.class.getName());

    private final PaymentService paymentService = new PaymentService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAuthenticationOrRedirect(request, response)) {
            return;
        }

        String pnr = request.getParameter("pnr");
        if (pnr == null || pnr.trim().isEmpty()) {
            setSessionError(request, "PNR reference is required to access payment.");
            response.sendRedirect(request.getContextPath() + "/booking/my-bookings");
            return;
        }

        pnr = pnr.trim().toUpperCase();
        Long userId = getUserId(request);

        try {
            PaymentService.PaymentOrderDetails orderDetails = paymentService.initiatePaymentForBooking(pnr, userId);
            Booking booking = orderDetails.getBooking();

            if (booking.getBookingStatus() == BookingStatus.CONFIRMED) {
                response.sendRedirect(request.getContextPath() + "/booking/confirmation?pnr=" + pnr);
                return;
            }

            request.setAttribute("stepNumber", 5);
            request.setAttribute("orderDetails", orderDetails);
            request.setAttribute("booking", booking);
            request.setAttribute("flight", orderDetails.getFlight());
            request.setAttribute("passengers", booking.getPassengers());
            request.setAttribute("razorpayKeyId", orderDetails.getRazorpayKeyId());
            request.setAttribute("razorpayOrderId", orderDetails.getRazorpayOrderId());
            request.setAttribute("amountInPaise", orderDetails.getAmountInPaise());
            request.setAttribute("amountInInr", orderDetails.getAmountInInr());
            request.setAttribute("currency", orderDetails.getCurrency());
            request.setAttribute("remainingHoldSeconds", orderDetails.getRemainingHoldSeconds());
            request.setAttribute("userName", getUserName(request));

            forwardToJsp("/booking/payment.jsp", request, response);

        } catch (SeatUnavailableException e) {
            setSessionError(request, e.getMessage());
            response.sendRedirect(request.getContextPath() + "/booking/my-bookings");

        } catch (BookingException e) {
            setSessionError(request, e.getMessage());
            response.sendRedirect(request.getContextPath() + "/booking/my-bookings");
        }
    }
}
