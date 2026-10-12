package com.airline.controller.admin;

import com.skytech.util.AppConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Administrative controller for system parameters, gateway configuration status,
 * and operational environment details.
 */
@WebServlet(name = "AdminSettingsServlet", urlPatterns = {"/admin/settings"})
public class AdminSettingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String rzKeyId = AppConfig.get("RAZORPAY_KEY_ID", "rzp_test_default");
        boolean isRazorpayConfigured = rzKeyId != null && !rzKeyId.isBlank() && !rzKeyId.contains("your_");
        boolean isTestMode = rzKeyId != null && rzKeyId.startsWith("rzp_test");

        request.setAttribute("isRazorpayConfigured", isRazorpayConfigured);
        request.setAttribute("isTestMode", isTestMode);
        // Mask the Key ID for security display: show only first 8 and last 4
        String maskedKeyId = (rzKeyId != null && rzKeyId.length() > 8)
                ? rzKeyId.substring(0, 8) + "••••••••" : "rzp_test_••••••••";
        request.setAttribute("maskedKeyId", maskedKeyId);

        request.setAttribute("dbHost", AppConfig.get("DB_HOST", "localhost"));
        request.setAttribute("dbPort", AppConfig.get("DB_PORT", "3306"));
        request.setAttribute("dbName", AppConfig.get("DB_NAME", "skytech_db"));

        request.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(request, response);
    }
}
