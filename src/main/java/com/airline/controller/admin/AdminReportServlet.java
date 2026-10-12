package com.airline.controller.admin;

import com.skytech.dao.AdminReportDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * Administrative controller for operational reports, route analytics,
 * and safe CSV data exporting with spreadsheet formula injection prevention.
 */
@WebServlet(name = "AdminReportServlet", urlPatterns = {"/admin/reports"})
public class AdminReportServlet extends HttpServlet {

    private final AdminReportDao reportDao = new AdminReportDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String format = request.getParameter("format");
        String reportType = request.getParameter("type");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");

        if ("csv".equalsIgnoreCase(format)) {
            exportCsv(response, reportType, fromDate, toDate);
            return;
        }

        List<Map<String, Object>> flightWise = reportDao.getFlightWiseReport(fromDate, toDate);
        List<Map<String, Object>> routePopularity = reportDao.getRoutePopularityReport();
        List<Map<String, Object>> revenueByDate = reportDao.getRevenueByDateReport(fromDate, toDate);

        request.setAttribute("flightWiseReport", flightWise);
        request.setAttribute("routePopularityReport", routePopularity);
        request.setAttribute("revenueByDateReport", revenueByDate);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);

        request.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(request, response);
    }

    private void exportCsv(HttpServletResponse response, String type, String fromDate, String toDate) throws IOException {
        response.setContentType("text/csv; charset=UTF-8");
        String filename = "skytech_" + (type != null ? type : "flights") + "_report_" + LocalDate.now() + ".csv";
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        PrintWriter writer = response.getWriter();

        if ("routes".equalsIgnoreCase(type)) {
            writer.println("Origin,Origin City,Destination,Destination City,Total Bookings,Confirmed Bookings,Total Revenue (INR)");
            List<Map<String, Object>> routes = reportDao.getRoutePopularityReport();
            for (Map<String, Object> r : routes) {
                writer.println(String.join(",",
                        AdminReportDao.escapeCsvFormula(r.get("originCode")),
                        AdminReportDao.escapeCsvFormula(r.get("originCity")),
                        AdminReportDao.escapeCsvFormula(r.get("destCode")),
                        AdminReportDao.escapeCsvFormula(r.get("destCity")),
                        AdminReportDao.escapeCsvFormula(r.get("totalBookings")),
                        AdminReportDao.escapeCsvFormula(r.get("confirmedBookings")),
                        AdminReportDao.escapeCsvFormula(r.get("totalRevenue"))
                ));
            }
        } else if ("revenue".equalsIgnoreCase(type)) {
            writer.println("Date,Currency,Transactions Count,Daily Revenue");
            List<Map<String, Object>> rev = reportDao.getRevenueByDateReport(fromDate, toDate);
            for (Map<String, Object> r : rev) {
                writer.println(String.join(",",
                        AdminReportDao.escapeCsvFormula(r.get("payDate")),
                        AdminReportDao.escapeCsvFormula(r.get("currency")),
                        AdminReportDao.escapeCsvFormula(r.get("transactionCount")),
                        AdminReportDao.escapeCsvFormula(r.get("dailyRevenue"))
                ));
            }
        } else {
            // Default: flight wise
            writer.println("Flight Number,Airline,Origin,Destination,Total Bookings,Confirmed Bookings,Cancelled Bookings,Total Revenue (INR)");
            List<Map<String, Object>> flights = reportDao.getFlightWiseReport(fromDate, toDate);
            for (Map<String, Object> f : flights) {
                writer.println(String.join(",",
                        AdminReportDao.escapeCsvFormula(f.get("flightNumber")),
                        AdminReportDao.escapeCsvFormula(f.get("airlineName")),
                        AdminReportDao.escapeCsvFormula(f.get("origin")),
                        AdminReportDao.escapeCsvFormula(f.get("destination")),
                        AdminReportDao.escapeCsvFormula(f.get("totalBookings")),
                        AdminReportDao.escapeCsvFormula(f.get("confirmedBookings")),
                        AdminReportDao.escapeCsvFormula(f.get("cancelledBookings")),
                        AdminReportDao.escapeCsvFormula(f.get("totalRevenue"))
                ));
            }
        }
        writer.flush();
    }
}
