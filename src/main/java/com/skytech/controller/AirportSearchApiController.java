package com.skytech.controller;

import com.google.gson.Gson;
import com.skytech.model.Airport;
import com.skytech.service.FlightSearchService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * REST API endpoint providing instant airport autocomplete results in JSON format.
 */
@WebServlet(name = "AirportSearchApiController", urlPatterns = {"/api/airports"})
public class AirportSearchApiController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final Gson gson = new Gson();
    private FlightSearchService flightSearchService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.flightSearchService = new FlightSearchService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String query = request.getParameter("q");
        List<Airport> matchingAirports = flightSearchService.searchAirports(query);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(gson.toJson(matchingAirports));
    }
}
