package com.skyport.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.skyport.dao.BookingDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/cancel-booking")
public class CancelBookingServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String pnr = request.getParameter("pnr");

        // Validate PNR
        if (pnr == null || pnr.trim().isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "PNR number is required."
            );
            return;
        }

        pnr = pnr.trim();

        try {
            // Cancel the booking
            String result = bookingDAO.cancelBooking(pnr);

            // Handle each possible result
            if ("SUCCESS".equals(result)) {

                request.setAttribute(
                        "message",
                        "Your ticket has been cancelled successfully."
                );

            } else if ("ALREADY_CANCELLED".equals(result)) {

                request.setAttribute(
                        "message",
                        "This ticket has already been cancelled."
                );

            } else if ("NOT_FOUND".equals(result)) {

                request.setAttribute(
                        "message",
                        "No booking exists for this PNR number."
                );

            } else if ("NOT_CANCELLABLE".equals(result)) {

                request.setAttribute(
                        "message",
                        "This booking cannot be cancelled."
                );

            } else {

                request.setAttribute(
                        "message",
                        "Cancellation could not be completed. Please try again."
                );
            }

            request.setAttribute("pnr", pnr);

            // Display the result page
            request.getRequestDispatcher("/cancellation-result.jsp")
                   .forward(request, response);

        } catch (SQLException e) {

            throw new ServletException(
                    "Unable to cancel the booking.",
                    e
            );
        }
    }
}