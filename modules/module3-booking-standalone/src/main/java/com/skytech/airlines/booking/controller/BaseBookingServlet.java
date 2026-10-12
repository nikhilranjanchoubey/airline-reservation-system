package com.skytech.airlines.booking.controller;

import com.google.gson.Gson;
import com.skytech.airlines.booking.config.AppConfig;
import com.skytech.airlines.booking.integration.DevUserSessionProvider;
import com.skytech.airlines.booking.integration.IUserSessionProvider;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Base abstract servlet providing common helper methods, JSON responses,
 * error dispatching, and integration authentication checks.
 */
public abstract class BaseBookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected static final Gson GSON = new Gson();
    protected final IUserSessionProvider userSessionProvider = new DevUserSessionProvider();

    protected boolean checkAuthenticationOrRedirect(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!userSessionProvider.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + AppConfig.getModule1LoginUrl() +
                    "?redirect=" + request.getRequestURI());
            return false;
        }
        return true;
    }

    protected Long getUserId(HttpServletRequest request) {
        return userSessionProvider.getAuthenticatedUserId(request);
    }

    protected String getUserName(HttpServletRequest request) {
        return userSessionProvider.getAuthenticatedUserName(request);
    }

    protected String getUserEmail(HttpServletRequest request) {
        return userSessionProvider.getAuthenticatedUserEmail(request);
    }

    protected void setSessionError(HttpServletRequest request, String errorMessage) {
        HttpSession session = request.getSession(true);
        session.setAttribute("errorMessage", errorMessage);
    }

    protected void setSessionSuccess(HttpServletRequest request, String successMessage) {
        HttpSession session = request.getSession(true);
        session.setAttribute("successMessage", successMessage);
    }

    protected void forwardToJsp(String jspPath, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher(jspPath).forward(request, response);
    }

    protected void writeJsonResponse(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(GSON.toJson(data));
        out.flush();
    }
}
