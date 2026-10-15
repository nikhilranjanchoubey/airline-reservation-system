package com.skytech.controller;

import com.google.gson.Gson;
import com.skytech.util.DBConnectionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Health check endpoint for Render, Docker, and frontend connection verification.
 * Accessible at:
 *   - /api/health
 *   - /health
 */
@WebServlet(name = "HealthController", urlPatterns = {"/api/health", "/health"})
public class HealthController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(HealthController.class.getName());
    private static final Gson GSON = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        boolean dbConnected = false;
        try (Connection conn = DBConnectionUtil.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                dbConnected = true;
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Health check database probe warning: " + e.getMessage());
        }

        Map<String, Object> health = new LinkedHashMap<>();
        health.put("status", dbConnected ? "UP" : "DEGRADED");
        health.put("service", "SkyTech Airline Reservation System API");
        health.put("database", dbConnected ? "CONNECTED" : "DISCONNECTED");
        health.put("timestamp", Instant.now().toString());

        if (!dbConnected) {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        } else {
            response.setStatus(HttpServletResponse.SC_OK);
        }

        try (PrintWriter out = response.getWriter()) {
            out.print(GSON.toJson(health));
            out.flush();
        }
    }
}
