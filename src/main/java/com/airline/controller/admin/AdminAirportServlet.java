package com.airline.controller.admin;

import com.airline.dao.AdminAuditDao;
import com.airline.model.User;
import com.skytech.dao.AirportDao;
import com.skytech.model.Airport;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Administrative controller for Airport Station Management.
 * Supports adding, updating, and reviewing airport stations across the route network.
 */
@WebServlet(name = "AdminAirportServlet", urlPatterns = {"/admin/airports"})
public class AdminAirportServlet extends HttpServlet {

    private final AirportDao airportDao = new AirportDao();
    private final AdminAuditDao auditDao = new AdminAuditDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Airport> airports = airportDao.getAllAirports();
        request.setAttribute("airports", airports);

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

        request.getRequestDispatcher("/WEB-INF/views/admin/airports.jsp").forward(request, response);
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
                    String code = request.getParameter("airportCode");
                    String name = request.getParameter("airportName");
                    String city = request.getParameter("city");
                    String country = request.getParameter("country");
                    String terminal = request.getParameter("terminal");

                    if (code == null || code.trim().length() != 3) {
                        if (session != null) session.setAttribute("flashError", "IATA airport code must be exactly 3 characters.");
                        break;
                    }

                    Airport a = new Airport();
                    a.setAirportCode(code.trim().toUpperCase());
                    a.setAirportName(name.trim());
                    a.setCity(city.trim());
                    a.setCountry(country != null && !country.isBlank() ? country.trim() : "India");
                    a.setTerminal(terminal != null && !terminal.isBlank() ? terminal.trim() : "Terminal 1");

                    boolean ok = airportDao.createAirport(a);
                    if (ok) {
                        if (session != null) session.setAttribute("flashSuccess", "Airport " + a.getAirportCode() + " created successfully.");
                        auditDao.logAction(adminId, adminName, "CREATE_AIRPORT", "AIRPORT", a.getAirportCode(),
                                "Added airport " + a.getAirportCode() + " (" + a.getCity() + ")", "SUCCESS");
                    } else {
                        if (session != null) session.setAttribute("flashError", "Could not create airport. Verify code is not duplicate.");
                    }
                    break;
                }
                case "edit": {
                    int airportId = Integer.parseInt(request.getParameter("airportId"));
                    String code = request.getParameter("airportCode");
                    String name = request.getParameter("airportName");
                    String city = request.getParameter("city");
                    String country = request.getParameter("country");
                    String terminal = request.getParameter("terminal");

                    Airport a = new Airport();
                    a.setAirportId(airportId);
                    a.setAirportCode(code.trim().toUpperCase());
                    a.setAirportName(name.trim());
                    a.setCity(city.trim());
                    a.setCountry(country != null && !country.isBlank() ? country.trim() : "India");
                    a.setTerminal(terminal != null && !terminal.isBlank() ? terminal.trim() : "Terminal 1");

                    boolean ok = airportDao.updateAirport(a);
                    if (ok) {
                        if (session != null) session.setAttribute("flashSuccess", "Airport " + a.getAirportCode() + " updated successfully.");
                        auditDao.logAction(adminId, adminName, "UPDATE_AIRPORT", "AIRPORT", a.getAirportCode(),
                                "Updated airport details for " + a.getAirportCode(), "SUCCESS");
                    } else {
                        if (session != null) session.setAttribute("flashError", "Could not update airport.");
                    }
                    break;
                }
                default:
                    if (session != null) session.setAttribute("flashError", "Unrecognized airport action.");
            }
        } catch (Exception e) {
            if (session != null) session.setAttribute("flashError", "Invalid form input: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/airports");
    }
}
