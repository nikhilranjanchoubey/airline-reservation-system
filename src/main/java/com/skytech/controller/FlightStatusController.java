package com.skytech.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Controller for Flight Status tracking.
 */
@WebServlet(name = "FlightStatusController", urlPatterns = {"/flight-status"})
public class FlightStatusController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String flightNum = request.getParameter("flightNumber");
        if (flightNum != null && !flightNum.trim().isEmpty()) {
            request.setAttribute("flightNumber", flightNum.trim().toUpperCase());
            request.setAttribute("searched", true);
        }
        request.setAttribute("pageTitle", "Flight Status - SkyTech Airlines");
        request.getRequestDispatcher("/WEB-INF/views/flight/flight-status.jsp").forward(request, response);
    }
}
