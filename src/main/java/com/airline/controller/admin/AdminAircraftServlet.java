package com.airline.controller.admin;

import com.airline.dao.AdminAuditDao;
import com.airline.model.User;
import com.skytech.dao.AircraftDao;
import com.skytech.model.Aircraft;
import com.skytech.model.Seat;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Administrative controller for Aircraft Fleet and Cabin Configuration.
 * Displays aircraft types, seat capacities, and cabin layout configurations.
 */
@WebServlet(name = "AdminAircraftServlet", urlPatterns = {"/admin/aircraft"})
public class AdminAircraftServlet extends HttpServlet {

    private final AircraftDao aircraftDao = new AircraftDao();
    private final AdminAuditDao auditDao = new AdminAuditDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Aircraft> fleet = aircraftDao.getAllAircraft();
        request.setAttribute("fleet", fleet);

        int totalAircraft = (fleet != null) ? fleet.size() : 0;
        int totalConfiguredSeats = 0;
        int totalRowsSum = 0;
        if (fleet != null) {
            for (Aircraft a : fleet) {
                totalConfiguredSeats += a.getTotalCapacity();
                totalRowsSum += a.getTotalRows();
            }
        }
        request.setAttribute("totalAircraft", totalAircraft);
        request.setAttribute("totalConfiguredSeats", totalConfiguredSeats);
        request.setAttribute("totalRowsSum", totalRowsSum);

        String viewAircraftIdStr = request.getParameter("aircraftId");
        if (viewAircraftIdStr != null) {
            try {
                int aId = Integer.parseInt(viewAircraftIdStr);
                Aircraft selected = aircraftDao.getAircraftById(aId);
                List<Seat> seats = aircraftDao.getSeatsByAircraftId(aId);
                request.setAttribute("selectedAircraft", selected);
                request.setAttribute("aircraftSeats", seats);
            } catch (NumberFormatException ignored) {}
        }

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

        request.getRequestDispatcher("/WEB-INF/views/admin/aircraft.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User admin = (session != null) ? (User) session.getAttribute("currentUser") : null;
        int adminId = (admin != null) ? admin.getUserId() : 1;
        String adminName = (admin != null) ? (admin.getFirstName() + " " + admin.getLastName()).trim() : "Administrator";

        String action = request.getParameter("action");
        if ("add".equalsIgnoreCase(action)) {
            try {
                String modelName = request.getParameter("modelName");
                String manufacturer = request.getParameter("manufacturer");
                int totalRows = Integer.parseInt(request.getParameter("totalRows"));
                int seatsPerRow = Integer.parseInt(request.getParameter("seatsPerRow"));

                Aircraft a = new Aircraft();
                a.setModelName(modelName.trim());
                a.setManufacturer(manufacturer.trim());
                a.setTotalRows(totalRows);
                a.setSeatsPerRow(seatsPerRow);

                boolean ok = aircraftDao.createAircraft(a);
                if (ok) {
                    if (session != null) session.setAttribute("flashSuccess", "Aircraft " + a.getModelName() + " registered and cabin seat matrix generated.");
                    auditDao.logAction(adminId, adminName, "CREATE_AIRCRAFT", "AIRCRAFT", String.valueOf(a.getAircraftId()),
                            "Registered aircraft " + a.getModelName() + " (" + a.getTotalCapacity() + " seats)", "SUCCESS");
                } else {
                    if (session != null) session.setAttribute("flashError", "Failed to register aircraft.");
                }
            } catch (Exception e) {
                if (session != null) session.setAttribute("flashError", "Invalid aircraft data: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/aircraft");
    }
}
