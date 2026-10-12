package com.airline.controller.admin;

import com.skytech.dao.AdminPaymentDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Administrative controller for payment transactions and gateway reconciliation.
 * Inspects Razorpay order and payment IDs, verified status, amounts, and timestamps.
 */
@WebServlet(name = "AdminPaymentServlet", urlPatterns = {"/admin/payments"})
public class AdminPaymentServlet extends HttpServlet {

    private final AdminPaymentDao paymentDao = new AdminPaymentDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");

        int page = 1;
        int pageSize = 10;
        try {
            String pStr = request.getParameter("page");
            if (pStr != null) page = Math.max(1, Integer.parseInt(pStr));
        } catch (NumberFormatException ignored) {}

        List<Map<String, Object>> payments = paymentDao.searchPayments(search, status, fromDate, toDate, page, pageSize);
        int totalCount = paymentDao.countPayments(search, status, fromDate, toDate);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);

        request.setAttribute("payments", payments);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", Math.max(1, totalPages));
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);

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

        request.getRequestDispatcher("/WEB-INF/views/admin/payments.jsp").forward(request, response);
    }
}
