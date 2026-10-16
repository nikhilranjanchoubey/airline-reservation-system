package com.skytech.controller;

import com.google.gson.Gson;
import com.skytech.util.AppConfig;
import com.skytech.util.DBConnectionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
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
        boolean tablesReady = false;
        java.util.List<String> missingCoreTables = new java.util.ArrayList<>();
        String[] coreTables = {"users", "airports", "flights", "flight_schedules", "bookings", "passengers"};
        String catalog = null;
        String dbProduct = null;
        int userCount = 0;
        int bookingCount = 0;
        String passengerAccount = null;
        String probeError = null;

        try (Connection conn = DBConnectionUtil.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                dbConnected = true;
                catalog = conn.getCatalog();
                try {
                    dbProduct = conn.getMetaData().getDatabaseProductName() + " " + conn.getMetaData().getDatabaseProductVersion();
                } catch (Exception ignored) {
                }
                try (java.sql.Statement stmt = conn.createStatement()) {
                    for (String tbl : coreTables) {
                        try {
                            stmt.execute("SELECT 1 FROM `" + tbl + "` LIMIT 1");
                        } catch (SQLException e) {
                            missingCoreTables.add(tbl);
                        }
                    }
                    if (missingCoreTables.isEmpty()) {
                        try (java.sql.ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM `users`")) {
                            if (rs.next()) userCount = rs.getInt(1);
                        }
                        try (java.sql.ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM `bookings`")) {
                            if (rs.next()) bookingCount = rs.getInt(1);
                        }
                        try (java.sql.ResultSet rs = stmt.executeQuery("SELECT first_name, last_name FROM `users` WHERE email='passenger@airline.com'")) {
                            if (rs.next()) passengerAccount = rs.getString(1) + " " + rs.getString(2);
                        }
                    }
                }
                tablesReady = missingCoreTables.isEmpty();
            } else {
                probeError = (conn == null) ? "DBConnectionUtil.getConnection() returned null" : "Database connection is closed";
            }
        } catch (Throwable t) {
            LOGGER.log(Level.WARNING, "Health check database probe warning: " + t.getMessage());
            String rawErr = t.getClass().getSimpleName() + ": " + (t.getMessage() != null ? t.getMessage() : "null");
            probeError = rawErr.replaceAll(":[^/@\\s]+@", ":***@");
        }

        boolean fullyOperational = dbConnected && tablesReady;
        Map<String, Object> health = new LinkedHashMap<>();
        health.put("status", fullyOperational ? "UP" : "DEGRADED");
        health.put("service", "SkyTech Airline Reservation System API");
        health.put("database", dbConnected ? (tablesReady ? "CONNECTED" : "SCHEMA_INCOMPLETE") : "DISCONNECTED");
        health.put("databaseTarget", sanitizeTargetUrl(AppConfig.getDbUrl()));
        health.put("databaseUser", AppConfig.getDbUsername());
        health.put("databaseSource", AppConfig.getConfigurationSource("DB_URL"));
        if (probeError != null) {
            health.put("databaseError", probeError);
        }
        if (catalog != null) {
            health.put("databaseCatalog", catalog);
        }
        if (dbProduct != null) {
            health.put("databaseEngine", dbProduct);
        }
        health.put("tablesReady", tablesReady);
        health.put("userCount", userCount);
        health.put("bookingCount", bookingCount);
        if (passengerAccount != null) {
            health.put("passengerAccount", passengerAccount);
        }
        if (!missingCoreTables.isEmpty()) {
            health.put("missingTables", missingCoreTables);
        }
        health.put("timestamp", Instant.now().toString());

        if (!fullyOperational) {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        } else {
            response.setStatus(HttpServletResponse.SC_OK);
        }

        try (PrintWriter out = response.getWriter()) {
            out.print(GSON.toJson(health));
            out.flush();
        }
    }

    private static String sanitizeTargetUrl(String url) {
        if (url == null) return "null";
        int q = url.indexOf('?');
        return q > 0 ? url.substring(0, q) : url;
    }
}
