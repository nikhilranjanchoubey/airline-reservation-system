package com.skytech.controller;

import com.airline.model.User;
import com.skytech.model.Booking;
import com.skytech.service.BookingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Controller providing the authenticated Passenger Dashboard ("My Trips").
 */
@WebServlet(name = "PassengerDashboardController", urlPatterns = {"/my-bookings", "/my-trips"})
public class PassengerDashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BookingService bookingService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.bookingService = new BookingService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("redirectAfterLogin", request.getContextPath() + "/my-bookings");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Booking> bookings = bookingService.getUserBookings((long) currentUser.getUserId());

        LocalDate today = LocalDate.now();
        List<Booking> upcomingTrips = new ArrayList<>();
        long confirmedCount = 0;
        long cancelledCount = 0;

        for (Booking b : bookings) {
            if (b.isConfirmed()) {
                confirmedCount++;
                if (b.getDepartureDate() == null || !b.getDepartureDate().isBefore(today)) {
                    upcomingTrips.add(b);
                }
            } else if (b.isCancelled()) {
                cancelledCount++;
            }
        }

        request.setAttribute("bookings", bookings);
        request.setAttribute("upcomingTrips", upcomingTrips);
        request.setAttribute("totalBookings", bookings.size());
        request.setAttribute("confirmedCount", confirmedCount);
        request.setAttribute("cancelledCount", cancelledCount);
        request.setAttribute("pageTitle", "My Trips & Bookings - SkyTech");

        request.getRequestDispatcher("/WEB-INF/views/passenger/dashboard.jsp").forward(request, response);
    }
}
