package com.skytech.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.io.IOException;

import static org.mockito.Mockito.*;

class CorsFilterTest {

    private CorsFilter corsFilter;

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private FilterChain filterChain;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        corsFilter = new CorsFilter();
    }

    @Test
    @DisplayName("Allows localhost:5173 origin and sets proper CORS headers")
    void testAllowedLocalOrigin() throws IOException, ServletException {
        when(request.getHeader("Origin")).thenReturn("http://localhost:5173");
        when(request.getMethod()).thenReturn("GET");

        corsFilter.doFilter(request, response, filterChain);

        verify(response).setHeader("Access-Control-Allow-Origin", "http://localhost:5173");
        verify(response).setHeader("Access-Control-Allow-Credentials", "true");
        verify(filterChain).doFilter(request, response);
    }

    @Test
    @DisplayName("Blocks disallowed origin from receiving CORS headers")
    void testDisallowedOrigin() throws IOException, ServletException {
        when(request.getHeader("Origin")).thenReturn("http://malicious-site.com");
        when(request.getMethod()).thenReturn("GET");

        corsFilter.doFilter(request, response, filterChain);

        verify(response, never()).setHeader(eq("Access-Control-Allow-Origin"), anyString());
        verify(filterChain).doFilter(request, response);
    }

    @Test
    @DisplayName("Handles OPTIONS preflight request with 204 No Content without continuing chain")
    void testOptionsPreflight() throws IOException, ServletException {
        when(request.getHeader("Origin")).thenReturn("http://localhost:5173");
        when(request.getMethod()).thenReturn("OPTIONS");

        corsFilter.doFilter(request, response, filterChain);

        verify(response).setHeader("Access-Control-Allow-Origin", "http://localhost:5173");
        verify(response).setStatus(HttpServletResponse.SC_NO_CONTENT);
        verify(filterChain, never()).doFilter(request, response);
    }
}
