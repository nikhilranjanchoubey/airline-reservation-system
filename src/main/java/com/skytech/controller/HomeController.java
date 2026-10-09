package com.skytech.controller;

import com.skytech.util.DBConnectionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;

/**
 * Foundational Home / Landing page controller.
 * Dispatches requests to the secure WEB-INF/views/index.jsp view.
 */
@WebServlet(name = "HomeController", urlPatterns = {"/home"})
public class HomeController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setAttribute("pageTitle", "Welcome to SkyTech");
        request.setAttribute("systemStatus", "Operational");

        java.time.LocalDate today = java.time.LocalDate.now(java.time.ZoneId.of("Asia/Kolkata"));
        request.setAttribute("todayDate", today.toString());
        request.setAttribute("minDate", today.toString());
        request.setAttribute("today", today.toString());
        request.setAttribute("todayFormatted", today.format(java.time.format.DateTimeFormatter.ofPattern("dd MMM uuuu", java.util.Locale.ENGLISH)));
        request.setAttribute("todayDayOfWeek", today.getDayOfWeek().getDisplayName(java.time.format.TextStyle.FULL, java.util.Locale.ENGLISH));

        // Foundation check: check if database is reachable (non-blocking)
        boolean dbConnected = false;
        String dbMessage;
        try (Connection conn = DBConnectionUtil.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                dbConnected = true;
                dbMessage = "Connected to MySQL successfully.";
            } else {
                dbMessage = "Connection returned null or closed.";
            }
        } catch (Exception e) {
            dbConnected = false;
            dbMessage = "Database not connected yet (" + e.getMessage() + "). Configure src/main/resources/db.properties.";
        }

        request.setAttribute("dbConnected", dbConnected);
        request.setAttribute("dbMessage", dbMessage);

        try {
            com.skytech.service.FlightSearchService flightSearchService = new com.skytech.service.FlightSearchService();
            request.setAttribute("popularDeals", flightSearchService.getPopularRouteDeals());
            request.setAttribute("airports", flightSearchService.getAllAirports());
        } catch (Exception e) {
            // graceful fallback if DB/provider not ready
            request.setAttribute("popularDeals", java.util.Collections.emptyList());
        }

        request.getRequestDispatcher("/WEB-INF/views/index.jsp").forward(request, response);
    }
}
