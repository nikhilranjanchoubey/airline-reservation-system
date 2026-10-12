package com.airline.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.IOException;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class LogoutServletTest {

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private HttpSession oldSession;

    @Mock
    private HttpSession newSession;

    private LogoutServlet servlet;

    @BeforeEach
    void setUp() {
        servlet = new LogoutServlet();
    }

    @Test
    void testLogoutInvalidatesSessionAndRedirects() throws ServletException, IOException {
        when(request.getSession(false)).thenReturn(oldSession);
        when(request.getSession(true)).thenReturn(newSession);
        when(request.getContextPath()).thenReturn("/airline-reservation-system");

        servlet.doGet(request, response);

        verify(oldSession).invalidate();
        verify(newSession).setAttribute("flashSuccess", "You have been logged out successfully.");
        verify(response).sendRedirect("/airline-reservation-system/login");
    }

    @Test
    void testLogoutWithNoPriorSession() throws ServletException, IOException {
        when(request.getSession(false)).thenReturn(null);
        when(request.getSession(true)).thenReturn(newSession);
        when(request.getContextPath()).thenReturn("/airline-reservation-system");

        servlet.doPost(request, response);

        verify(newSession).setAttribute("flashSuccess", "You have been logged out successfully.");
        verify(response).sendRedirect("/airline-reservation-system/login");
    }
}
