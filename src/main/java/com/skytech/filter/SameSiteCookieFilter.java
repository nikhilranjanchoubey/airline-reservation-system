package com.skytech.filter;

import com.skytech.util.AppConfig;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletResponseWrapper;

import java.io.IOException;
import java.util.Collection;

/**
 * Cookie security filter for cross-domain sessions (Vercel frontend + Render backend).
 * Automatically applies SameSite=None and Secure attributes to JSESSIONID cookies in production
 * or when accessed over HTTPS / cross-origin credentials.
 * Preserves standard HttpOnly cookie security without breaking local HTTP development.
 */
@WebFilter(filterName = "SameSiteCookieFilter", urlPatterns = {"/*"})
public class SameSiteCookieFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Determine if we are in an HTTPS or cross-domain context
        boolean isSecure = httpRequest.isSecure() ||
                "https".equalsIgnoreCase(httpRequest.getHeader("X-Forwarded-Proto")) ||
                "https".equalsIgnoreCase(httpRequest.getHeader("X-Forwarded-Ssl"));

        // If FRONTEND_ORIGIN is configured for production Vercel (https://*.vercel.app), enforce SameSite=None; Secure
        String frontendOrigin = AppConfig.get("FRONTEND_ORIGIN", null);
        boolean isProductionCrossDomain = frontendOrigin != null && frontendOrigin.contains("https://");

        final boolean requireSameSiteNone = isSecure || isProductionCrossDomain;

        HttpServletResponseWrapper wrappedResponse = new HttpServletResponseWrapper(httpResponse) {
            @Override
            public void addHeader(String name, String value) {
                if ("Set-Cookie".equalsIgnoreCase(name) && value != null) {
                    value = adjustCookieSameSite(value, requireSameSiteNone);
                }
                super.addHeader(name, value);
            }

            @Override
            public void setHeader(String name, String value) {
                if ("Set-Cookie".equalsIgnoreCase(name) && value != null) {
                    value = adjustCookieSameSite(value, requireSameSiteNone);
                }
                super.setHeader(name, value);
            }
        };

        chain.doFilter(request, wrappedResponse);
    }

    private String adjustCookieSameSite(String cookieHeader, boolean requireSameSiteNone) {
        if (!cookieHeader.toLowerCase().contains("samesite")) {
            if (requireSameSiteNone) {
                if (!cookieHeader.toLowerCase().contains("secure")) {
                    cookieHeader += "; Secure";
                }
                cookieHeader += "; SameSite=None";
            } else {
                cookieHeader += "; SameSite=Lax";
            }
        }
        return cookieHeader;
    }

    @Override
    public void destroy() {
    }
}
