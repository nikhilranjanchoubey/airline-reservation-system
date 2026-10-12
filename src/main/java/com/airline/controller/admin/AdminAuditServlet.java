package com.airline.controller.admin;

import com.airline.dao.AdminAuditDao;
import com.airline.model.AdminAuditLog;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Administrative controller for inspecting security and action audit logs.
 */
@WebServlet(name = "AdminAuditServlet", urlPatterns = {"/admin/audit"})
public class AdminAuditServlet extends HttpServlet {

    private final AdminAuditDao auditDao = new AdminAuditDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<AdminAuditLog> logs = auditDao.getRecentLogs(100);
        request.setAttribute("auditLogs", logs);

        request.getRequestDispatcher("/WEB-INF/views/admin/audit.jsp").forward(request, response);
    }
}
