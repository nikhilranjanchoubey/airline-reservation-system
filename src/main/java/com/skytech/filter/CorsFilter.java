package com.skytech.filter;

import com.skytech.util.AppConfig;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.*;
import java.util.logging.Logger;

/**
 * Global Cross-Origin Resource Sharing (CORS) filter.
 * Manages allowed origins dynamically from the FRONTEND_ORIGIN environment variable.
 * Supports explicit development origins (localhost:5173, localhost:3000) and production Vercel domains.
 * Handles OPTIONS preflight requests with credentials and strict header policies.
 */
@WebFilter(filterName = "CorsFilter", urlPatterns = {"/api/*", "/health"})
public class CorsFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(CorsFilter.class.getName());
    private static final Set<String> DEFAULT_DEV_ORIGINS = new HashSet<>(Arrays.asList(
            "http://localhost:5173",
            "http://127.0.0.1:5173",
            "http://localhost:3000",
            "http://127.0.0.1:3000"
    ));

    @Override
    public void init(FilterConfig filterConfig) {
        LOGGER.info("SkyTech CorsFilter initialized for /api/* and /health");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String origin = httpRequest.getHeader("Origin");

        if (origin != null && !origin.trim().isEmpty()) {
            origin = origin.trim();
            if (isOriginAllowed(origin)) {
                // Return exact matched origin to support credentials (never wildcard "*")
                httpResponse.setHeader("Access-Control-Allow-Origin", origin);
                httpResponse.setHeader("Access-Control-Allow-Credentials", "true");
                httpResponse.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH");
                httpResponse.setHeader("Access-Control-Allow-Headers",
                        "Content-Type, Authorization, X-Requested-With, Accept, Origin, Access-Control-Request-Method, Access-Control-Request-Headers");
                httpResponse.setHeader("Access-Control-Max-Age", "86400"); // 24 hours preflight cache
            }
        }

        // Handle preflight OPTIONS requests directly
        if ("OPTIONS".equalsIgnoreCase(httpRequest.getMethod())) {
            httpResponse.setStatus(HttpServletResponse.SC_NO_CONTENT);
            return;
        }

        chain.doFilter(request, response);
    }

    /**
     * Determines whether an incoming Origin header is allowed based on FRONTEND_ORIGIN and development defaults.
     */
    private boolean isOriginAllowed(String origin) {
        if (DEFAULT_DEV_ORIGINS.contains(origin)) {
            return true;
        }

        String configuredFrontend = AppConfig.get("FRONTEND_ORIGIN", null);
        if (configuredFrontend != null && !configuredFrontend.trim().isEmpty()) {
            String[] allowedArray = configuredFrontend.split(",");
            for (String allowed : allowedArray) {
                String clean = allowed.trim();
                // Match exact or remove trailing slash
                if (clean.endsWith("/")) {
                    clean = clean.substring(0, clean.length() - 1);
                }
                if (origin.equalsIgnoreCase(clean)) {
                    return true;
                }
                // Allow preview deployments for vercel if explicitly configured with *.vercel.app wildcard pattern
                if (clean.startsWith("*.") && origin.toLowerCase().endsWith(clean.substring(1).toLowerCase())) {
                    return true;
                }
            }
        }

        return false;
    }

    @Override
    public void destroy() {
    }
}
