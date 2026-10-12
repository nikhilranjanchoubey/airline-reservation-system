package com.skytech.controller;

import com.airline.model.Role;
import com.airline.model.User;
import com.skytech.model.Booking;
import com.skytech.service.BookingService;
import com.skytech.service.TicketService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.OutputStream;

/**
 * Controller serving electronic PDF ticket downloads and in-browser previews.
 */
@WebServlet(name = "TicketController", urlPatterns = {"/ticket/download", "/ticket/view"})
public class TicketController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookingService bookingService;
    private TicketService ticketService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.bookingService = new BookingService();
        this.ticketService = new TicketService();
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

        String idParam = request.getParameter("id");
        String pnrParam = request.getParameter("pnr");

        Booking booking = null;
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                long bookingId = Long.parseLong(idParam.trim());
                booking = bookingService.getBookingById(bookingId, currentUser);
            } catch (NumberFormatException ignored) {
            }
        } else if (pnrParam != null && !pnrParam.trim().isEmpty()) {
            booking = bookingService.getBookingByPnrAndLastName(pnrParam.trim(), null, currentUser);
        }

        if (booking == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Ticket or booking not found.");
            return;
        }

        if (currentUser.getRole() != Role.ADMIN && booking.getUserId() != null && booking.getUserId() != currentUser.getUserId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied to download this ticket.");
            return;
        }

        if (!booking.isConfirmed()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tickets are only issued for confirmed reservations.");
            return;
        }

        byte[] pdfBytes = ticketService.generateTicketPdf(booking, null);
        if (pdfBytes == null || pdfBytes.length == 0) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating electronic ticket PDF.");
            return;
        }

        String pnr = booking.getPnr() != null ? booking.getPnr() : booking.getBookingReference();
        String filename = "SkyTech-Ticket-" + pnr + ".pdf";

        response.setContentType("application/pdf");
        response.setContentLength(pdfBytes.length);

        if (request.getRequestURI().endsWith("/download")) {
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
        } else {
            response.setHeader("Content-Disposition", "inline; filename=\"" + filename + "\"");
        }

        try (OutputStream out = response.getOutputStream()) {
            out.write(pdfBytes);
            out.flush();
        }
    }
}
