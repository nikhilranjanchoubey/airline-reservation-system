package com.airline.controller;

import com.airline.model.Role;
import com.airline.model.User;
import com.airline.service.ServiceResult;
import com.airline.service.UserService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class GoogleAuthServletTest {

    @Mock
    private UserService userService;

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private HttpSession session;

    private GoogleAuthServlet servlet;

    @BeforeEach
    void setUp() {
        servlet = new GoogleAuthServlet(userService);
    }

    @Test
    void testDoPostCsrfTokenMismatchRedirectsToLogin() throws Exception {
        Cookie[] cookies = new Cookie[]{new Cookie("g_csrf_token", "cookie-token-123")};
        when(request.getCookies()).thenReturn(cookies);
        when(request.getParameter("g_csrf_token")).thenReturn("mismatched-body-token");
        when(request.getSession(true)).thenReturn(session);
        when(request.getContextPath()).thenReturn("/airline");

        servlet.doPost(request, response);

        verify(session).setAttribute(eq("flashError"), contains("CSRF verification token mismatch"));
        verify(response).sendRedirect("/airline/login");
    }

    @Test
    void testDoPostMissingTokenRedirectsToLogin() throws Exception {
        String csrfToken = "valid-csrf-token";
        Cookie[] cookies = new Cookie[]{new Cookie("g_csrf_token", csrfToken)};
        when(request.getCookies()).thenReturn(cookies);
        when(request.getParameter("g_csrf_token")).thenReturn(csrfToken);
        when(request.getParameter("credential")).thenReturn(null);
        when(request.getSession(true)).thenReturn(session);
        when(request.getContextPath()).thenReturn("/airline");

        servlet.doPost(request, response);

        verify(session).setAttribute(eq("flashError"), contains("Missing ID token"));
        verify(response).sendRedirect("/airline/login");
    }

    @Test
    void testDoGetRedirectsToLogin() throws Exception {
        when(request.getContextPath()).thenReturn("/airline");
        servlet.doGet(request, response);
        verify(response).sendRedirect("/airline/login");
    }
}
