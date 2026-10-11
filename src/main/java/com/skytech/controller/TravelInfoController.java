package com.skytech.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Controller for Travel Information, baggage rules, check-in policies, and FAQs.
 */
@WebServlet(name = "TravelInfoController", urlPatterns = {"/travel-information"})
public class TravelInfoController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", "Travel Information & Guidelines - SkyTech");
        request.getRequestDispatcher("/WEB-INF/views/flight/travel-information.jsp").forward(request, response);
    }
}
