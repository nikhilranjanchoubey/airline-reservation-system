package com.airline.filter;

import com.airline.model.Role;
import com.airline.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Filter ensuring that only users with the ADMIN role can access admin management routes.
 */
@WebFilter(filterName = "AdminAuthorizationFilter", urlPatterns = {"/admin/*"})
public class AdminAuthorizationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || currentUser.getRole() != Role.ADMIN) {
            httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
            httpRequest.setAttribute("errorMessage", "Access Denied: Administrator privileges are required to view this area.");
            httpRequest.getRequestDispatcher("/WEB-INF/views/errors/403.jsp").forward(request, response);
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
