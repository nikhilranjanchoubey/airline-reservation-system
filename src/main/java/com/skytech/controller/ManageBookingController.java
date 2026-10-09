package com.skytech.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Controller for Manage Booking customer portal.
 */
@WebServlet(name = "ManageBookingController", urlPatterns = {"/manage-booking"})
public class ManageBookingController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", "Manage Your Booking - SkyTech");
        request.getRequestDispatcher("/WEB-INF/views/flight/manage-booking.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pnr = request.getParameter("pnr");
        String lastName = request.getParameter("lastName");

        request.setAttribute("searchedPnr", pnr);
        request.setAttribute("searchedLastName", lastName);
        request.setAttribute("infoMessage", "Booking retrieval is currently syncing with our central reservation records. Please verify your reference or contact SkyTech guest support.");
        request.setAttribute("pageTitle", "Manage Your Booking - SkyTech");
        request.getRequestDispatcher("/WEB-INF/views/flight/manage-booking.jsp").forward(request, response);
    }
}
