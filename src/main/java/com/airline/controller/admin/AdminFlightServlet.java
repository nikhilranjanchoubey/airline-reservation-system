package com.airline.controller.admin;

import com.airline.dao.AdminAuditDao;
import com.airline.model.User;
import com.skytech.dao.AircraftDao;
import com.skytech.dao.AirlineDao;
import com.skytech.dao.AirportDao;
import com.skytech.dao.FlightManagementDao;
import com.skytech.model.Aircraft;
import com.skytech.model.Airline;
import com.skytech.model.Airport;
import com.skytech.model.Flight;
import com.skytech.model.FlightSchedule;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.util.List;

/**
 * Administrative controller for flight scheduling, fleet dispatch, route management,
 * and flight status changes (Scheduled, Boarding, Departed, Arrived, Delayed, Cancelled).
 */
@WebServlet(name = "AdminFlightServlet", urlPatterns = {"/admin/flights"})
public class AdminFlightServlet extends HttpServlet {

    private final FlightManagementDao flightDao = new FlightManagementDao();
    private final AirlineDao airlineDao = new AirlineDao();
    private final AirportDao airportDao = new AirportDao();
    private final AircraftDao aircraftDao = new AircraftDao();
    private final AdminAuditDao auditDao = new AdminAuditDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String origin = request.getParameter("origin");
        String dest = request.getParameter("dest");
        String dateStr = request.getParameter("date");

        int page = 1;
        int pageSize = 10;
        try {
            String pStr = request.getParameter("page");
            if (pStr != null) page = Math.max(1, Integer.parseInt(pStr));
        } catch (NumberFormatException ignored) {}

        List<FlightSchedule> schedules = flightDao.getFlightSchedules(search, status, origin, dest, dateStr, page, pageSize);
        int totalCount = flightDao.countFlightSchedules(search, status, origin, dest, dateStr);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);

        request.setAttribute("schedules", schedules);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", Math.max(1, totalPages));
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("origin", origin);
        request.setAttribute("dest", dest);
        request.setAttribute("date", dateStr);

        // Pre-load reference lists for modal forms
        request.setAttribute("airlines", airlineDao.getAllAirlines());
        request.setAttribute("airports", airportDao.getAllAirports());
        request.setAttribute("aircraftList", aircraftDao.getAllAircraft());

        // Handle flash notifications
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

        request.getRequestDispatcher("/WEB-INF/views/admin/flights.jsp").forward(request, response);
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
                    String flightNumber = request.getParameter("flightNumber");
                    int airlineId = Integer.parseInt(request.getParameter("airlineId"));
                    int srcAirportId = Integer.parseInt(request.getParameter("sourceAirportId"));
                    int dstAirportId = Integer.parseInt(request.getParameter("destAirportId"));
                    String depTimeStr = request.getParameter("departureTime");
                    String arrTimeStr = request.getParameter("arrivalTime");
                    int durationMinutes = Integer.parseInt(request.getParameter("durationMinutes"));
                    String flightDateStr = request.getParameter("flightDate");
                    BigDecimal basePrice = new BigDecimal(request.getParameter("basePrice"));
                    int totalSeats = Integer.parseInt(request.getParameter("totalSeats"));
                    String aircraftModel = request.getParameter("aircraftModel");

                    if (srcAirportId == dstAirportId) {
                        if (session != null) session.setAttribute("flashError", "Origin and destination airports must be distinct.");
                        break;
                    }

                    Flight flight = new Flight();
                    flight.setFlightNumber(flightNumber.trim().toUpperCase());
                    flight.setAirline(airlineDao.getAirlineById(airlineId));
                    Airport src = new Airport();
                    src.setAirportId(srcAirportId);
                    flight.setSourceAirport(src);
                    Airport dst = new Airport();
                    dst.setAirportId(dstAirportId);
                    flight.setDestinationAirport(dst);
                    flight.setDepartureTime(Time.valueOf(depTimeStr.length() == 5 ? depTimeStr + ":00" : depTimeStr));
                    flight.setArrivalTime(Time.valueOf(arrTimeStr.length() == 5 ? arrTimeStr + ":00" : arrTimeStr));
                    flight.setDurationMinutes(durationMinutes);
                    flight.setStops(0);
                    flight.setAircraftModel(aircraftModel != null ? aircraftModel : "Airbus A320neo");

                    FlightSchedule schedule = new FlightSchedule();
                    schedule.setFlightDate(Date.valueOf(flightDateStr));
                    schedule.setBasePrice(basePrice);
                    schedule.setEconomyPrice(basePrice);
                    schedule.setPremiumEconomyPrice(basePrice.multiply(BigDecimal.valueOf(1.35)));
                    schedule.setBusinessPrice(basePrice.multiply(BigDecimal.valueOf(2.20)));
                    schedule.setFirstClassPrice(basePrice.multiply(BigDecimal.valueOf(3.50)));
                    schedule.setTotalSeats(totalSeats);
                    schedule.setAvailableSeats(totalSeats);
                    schedule.setStatus("SCHEDULED");

                    boolean ok = flightDao.createFlightWithSchedule(flight, schedule);
                    if (ok) {
                        if (session != null) session.setAttribute("flashSuccess", "Flight " + flight.getFlightNumber() + " scheduled successfully.");
                        auditDao.logAction(adminId, adminName, "CREATE_FLIGHT", "FLIGHT", flight.getFlightNumber(),
                                "Scheduled flight " + flight.getFlightNumber() + " for date " + flightDateStr, "SUCCESS");
                    } else {
                        if (session != null) session.setAttribute("flashError", "Failed to schedule flight. Verify unique flight number.");
                        auditDao.logAction(adminId, adminName, "CREATE_FLIGHT", "FLIGHT", flightNumber, "Failed to schedule flight", "FAILED");
                    }
                    break;
                }
                case "update_status": {
                    int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
                    String newStatus = request.getParameter("status");
                    boolean ok = flightDao.updateFlightStatus(scheduleId, newStatus);
                    if (ok) {
                        if (session != null) session.setAttribute("flashSuccess", "Flight operational status updated to " + newStatus + ".");
                        auditDao.logAction(adminId, adminName, "UPDATE_STATUS", "FLIGHT_SCHEDULE", String.valueOf(scheduleId),
                                "Updated schedule status to " + newStatus, "SUCCESS");
                    } else {
                        if (session != null) session.setAttribute("flashError", "Could not update flight status.");
                    }
                    break;
                }
                case "deactivate": {
                    int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
                    boolean ok = flightDao.safeDeactivateFlight(scheduleId);
                    if (ok) {
                        if (session != null) session.setAttribute("flashSuccess", "Flight schedule deactivated successfully.");
                        auditDao.logAction(adminId, adminName, "DEACTIVATE_FLIGHT", "FLIGHT_SCHEDULE", String.valueOf(scheduleId),
                                "Safely cancelled / deactivated schedule " + scheduleId, "SUCCESS");
                    } else {
                        if (session != null) session.setAttribute("flashError", "Cannot deactivate flight: active passenger bookings are linked to this flight.");
                        auditDao.logAction(adminId, adminName, "DEACTIVATE_FLIGHT", "FLIGHT_SCHEDULE", String.valueOf(scheduleId),
                                "Deactivation blocked: active bookings exist", "FAILED");
                    }
                    break;
                }
                default:
                    if (session != null) session.setAttribute("flashError", "Unrecognized flight management action.");
            }
        } catch (Exception e) {
            if (session != null) session.setAttribute("flashError", "Invalid form input: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/flights");
    }
}
