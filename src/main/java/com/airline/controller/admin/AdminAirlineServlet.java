package com.airline.controller.admin;

import com.airline.dao.AdminAuditDao;
import com.airline.model.User;
import com.skytech.dao.AirlineDao;
import com.skytech.model.Airline;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Administrative controller for Partner Airline and Operator Registry.
 */
@WebServlet(name = "AdminAirlineServlet", urlPatterns = {"/admin/airlines"})
public class AdminAirlineServlet extends HttpServlet {

    private final AirlineDao airlineDao = new AirlineDao();
    private final AdminAuditDao auditDao = new AdminAuditDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Airline> airlines = airlineDao.getAllAirlines();
        request.setAttribute("airlines", airlines);

        HttpSession session = request.getSession(false);
        if (session != null) {
            String flashSuccess = (String) session.getAttribute("flashSuccess");
            if (flashSuccess != null) {
                request.setAttribute("flashSuccess", flashSuccess);
                session.removeAttribute("flashSuccess");
            }
            String flashError = (String) session.getAttribute("flashError");
            if (flashError != null) {
                request.setAttribute("flashError", flashError);
                session.removeAttribute("flashError");
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/airlines.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User admin = (session != null) ? (User) session.getAttribute("currentUser") : null;
        int adminId = (admin != null) ? admin.getUserId() : 1;
        String adminName = (admin != null) ? (admin.getFirstName() + " " + admin.getLastName()).trim() : "Administrator";

        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action.toLowerCase()) {
                case "add": {
                    String code = request.getParameter("airlineCode");
                    String name = request.getParameter("airlineName");
                    String icon = request.getParameter("logoIcon");

                    if (code == null || code.trim().length() < 2) {
                        if (session != null) session.setAttribute("flashError", "Airline code must be at least 2 characters.");
                        break;
                    }

                    Airline a = new Airline();
                    a.setAirlineCode(code.trim().toUpperCase());
                    a.setAirlineName(name.trim());
                    a.setLogoIcon(icon != null && !icon.isBlank() ? icon.trim() : "bi-airplane-fill");

                    boolean ok = airlineDao.createAirline(a);
                    if (ok) {
                        if (session != null) session.setAttribute("flashSuccess", "Airline " + a.getAirlineName() + " added successfully.");
                        auditDao.logAction(adminId, adminName, "CREATE_AIRLINE", "AIRLINE", a.getAirlineCode(),
                                "Added airline " + a.getAirlineName(), "SUCCESS");
                    } else {
                        if (session != null) session.setAttribute("flashError", "Failed to add airline. Code might already exist.");
                    }
                    break;
                }
                case "edit": {
                    int airlineId = Integer.parseInt(request.getParameter("airlineId"));
                    String code = request.getParameter("airlineCode");
                    String name = request.getParameter("airlineName");
                    String icon = request.getParameter("logoIcon");

                    Airline a = new Airline();
                    a.setAirlineId(airlineId);
                    a.setAirlineCode(code.trim().toUpperCase());
                    a.setAirlineName(name.trim());
                    a.setLogoIcon(icon != null && !icon.isBlank() ? icon.trim() : "bi-airplane-fill");

                    boolean ok = airlineDao.updateAirline(a);
                    if (ok) {
                        if (session != null) session.setAttribute("flashSuccess", "Airline updated successfully.");
                        auditDao.logAction(adminId, adminName, "UPDATE_AIRLINE", "AIRLINE", a.getAirlineCode(),
                                "Updated airline " + a.getAirlineName(), "SUCCESS");
                    } else {
                        if (session != null) session.setAttribute("flashError", "Could not update airline.");
                    }
                    break;
                }
                default:
                    if (session != null) session.setAttribute("flashError", "Unrecognized airline action.");
            }
        } catch (Exception e) {
            if (session != null) session.setAttribute("flashError", "Invalid form input: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/airlines");
    }
}
