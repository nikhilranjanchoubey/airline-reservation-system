package com.skytech.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
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
        request.setAttribute("pageTitle", "Travel Information & Guidelines - SkyTech Airlines");
        request.getRequestDispatcher("/WEB-INF/views/flight/travel-information.jsp").forward(request, response);
    }
}
