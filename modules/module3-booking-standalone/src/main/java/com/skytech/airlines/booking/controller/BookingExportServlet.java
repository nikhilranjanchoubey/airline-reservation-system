package com.skytech.airlines.booking.controller;

import com.skytech.airlines.booking.integration.BookingExportServiceImpl;
import com.skytech.airlines.booking.integration.IBookingExportService;
import com.skytech.airlines.booking.model.Booking;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * REST endpoint exposing booking details to Module 4 (Ticketing & Cancellation) and Module 5 (Admin).
 */
@WebServlet(name = "BookingExportServlet", urlPatterns = {"/api/booking/details"})
public class BookingExportServlet extends BaseBookingServlet {
    private static final long serialVersionUID = 1L;

    private final IBookingExportService exportService = new BookingExportServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pnr = request.getParameter("pnr");
        if (pnr == null || pnr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            Map<String, String> err = new HashMap<>();
            err.put("error", "Missing pnr parameter");
            writeJsonResponse(response, err);
            return;
        }

        Booking booking = exportService.getBookingByPnr(pnr.trim().toUpperCase());
        if (booking == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            Map<String, String> err = new HashMap<>();
            err.put("error", "No booking found for PNR: " + pnr);
            writeJsonResponse(response, err);
            return;
        }

        writeJsonResponse(response, booking);
    }
}
