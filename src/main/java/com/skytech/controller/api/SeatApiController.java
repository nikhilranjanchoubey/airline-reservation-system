package com.skytech.controller.api;

import com.google.gson.Gson;
import com.skytech.model.FlightSchedule;
import com.skytech.model.Seat;
import com.skytech.service.FlightSearchService;
import com.skytech.service.SeatMapService;
import com.skytech.util.JsonUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * REST API Controller for Aircraft Seat Maps and Availability:
 *   - GET /api/seats/map
 *
 * Integrates with SeatMapService and FlightSearchService.
 */
@WebServlet(name = "SeatApiController", urlPatterns = {"/api/seats/map"})
public class SeatApiController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(SeatApiController.class.getName());
    private final Gson gson = JsonUtil.getGson();
    private FlightSearchService flightSearchService;
    private SeatMapService seatMapService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.flightSearchService = new FlightSearchService();
        this.seatMapService = new SeatMapService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("scheduleId");
        if (idParam == null || idParam.trim().isEmpty()) idParam = request.getParameter("id");

        if (idParam == null || idParam.trim().isEmpty()) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Missing scheduleId parameter.");
            return;
        }

        int scheduleId;
        try {
            scheduleId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid scheduleId.");
            return;
        }

        try {
            LocalDate depDate = null;
            String depDateParam = request.getParameter("departureDate");
            if (depDateParam != null && !depDateParam.trim().isEmpty()) {
                try {
                    depDate = LocalDate.parse(depDateParam.trim());
                } catch (Exception ignored) {}
            }

            FlightSchedule schedule = flightSearchService.getFlightDetails(scheduleId, depDate);
            if (schedule == null) {
                writeError(response, HttpServletResponse.SC_NOT_FOUND, "Flight schedule not found.");
                return;
            }

            String airlineCode = (schedule.getFlight() != null && schedule.getFlight().getAirline() != null)
                    ? schedule.getFlight().getAirline().getAirlineCode() : "6E";

            List<Seat> seatMap = seatMapService.getSeatMapForSchedule(scheduleId, airlineCode);

            Map<String, Object> resp = new LinkedHashMap<>();
            resp.put("success", true);
            resp.put("schedule", schedule);
            resp.put("seats", seatMap);

            writeJsonResponse(response, HttpServletResponse.SC_OK, resp);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading seat map: " + e.getMessage(), e);
            writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading seat map: " + e.getMessage());
        }
    }

    private void writeJsonResponse(HttpServletResponse response, int status, Object data) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        try (PrintWriter out = response.getWriter()) {
            out.print(gson.toJson(data));
            out.flush();
        }
    }

    private void writeError(HttpServletResponse response, int status, String message) throws IOException {
        Map<String, Object> err = new LinkedHashMap<>();
        err.put("success", false);
        err.put("error", message);
        writeJsonResponse(response, status, err);
    }
}
