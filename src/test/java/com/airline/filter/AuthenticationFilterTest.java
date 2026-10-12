package com.airline.filter;

import com.airline.model.Role;
import com.airline.model.User;
import jakarta.servlet.FilterChain;
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
class AuthenticationFilterTest {

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private HttpSession session;

    @Mock
    private FilterChain chain;

    private AuthenticationFilter filter;

    @BeforeEach
    void setUp() {
        filter = new AuthenticationFilter();
    }

    @Test
    void testUnauthenticatedUserRedirectedToLogin() throws IOException, ServletException {
        when(request.getSession(false)).thenReturn(null);
        when(request.getSession(true)).thenReturn(session);
        when(request.getSession()).thenReturn(session);
        when(request.getRequestURI()).thenReturn("/airline-reservation-system/profile");
        when(request.getQueryString()).thenReturn(null);
        when(request.getContextPath()).thenReturn("/airline-reservation-system");

        filter.doFilter(request, response, chain);

        verify(response).setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        verify(session).setAttribute("flashError", "Please sign in to access this page.");
        verify(session).setAttribute("redirectAfterLogin", "/airline-reservation-system/profile");
        verify(response).sendRedirect("/airline-reservation-system/login");
        verify(chain, never()).doFilter(request, response);
    }

    @Test
    void testAuthenticatedPassengerAllowed() throws IOException, ServletException {
        User user = new User();
        user.setEmail("passenger@airline.com");
        user.setRole(Role.PASSENGER);

        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("currentUser")).thenReturn(user);

        filter.doFilter(request, response, chain);

        verify(response).setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        verify(chain).doFilter(request, response);
        verify(response, never()).sendRedirect(anyString());
    }
}
