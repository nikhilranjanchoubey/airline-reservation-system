package com.skyport.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.skyport.dao.BookingDAO;
import com.skyport.model.Booking;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/search-booking")
public class PNRSearchServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String pnr = request.getParameter("pnr");

        // Validate PNR input
        if (pnr == null || pnr.trim().isEmpty()) {

            request.setAttribute(
                    "error",
                    "Please enter your PNR number."
            );

            request.getRequestDispatcher("/booking-details.jsp")
                   .forward(request, response);

            return;
        }

        pnr = pnr.trim();

        // Preserve the searched PNR
        request.setAttribute("searchedPNR", pnr);

        try {

            // Search for booking in database
            Booking booking = bookingDAO.findByPNR(pnr);

            if (booking != null) {

                request.setAttribute("booking", booking);

            } else {

                request.setAttribute(
                        "error",
                        "No booking found for PNR: " + pnr
                                + ". Please check your booking reference."
                );
            }

            request.getRequestDispatcher("/booking-details.jsp")
                   .forward(request, response);

        } catch (SQLException e) {

            throw new ServletException(
                    "Unable to retrieve booking details. Please try again later.",
                    e
            );
        }
    }
}