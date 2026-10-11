package com.airline.filter;

import com.airline.model.Role;
import com.airline.model.User;
import jakarta.servlet.FilterChain;
import jakarta.servlet.RequestDispatcher;
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
class AdminAuthorizationFilterTest {

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private HttpSession session;

    @Mock
    private FilterChain chain;

    @Mock
    private RequestDispatcher dispatcher;

    private AdminAuthorizationFilter filter;

    @BeforeEach
    void setUp() {
        filter = new AdminAuthorizationFilter();
    }

    @Test
    void testUnauthenticatedUserDeniedWith403() throws IOException, ServletException {
        when(request.getSession(false)).thenReturn(null);
        when(request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp")).thenReturn(dispatcher);

        filter.doFilter(request, response, chain);

        verify(response).setStatus(HttpServletResponse.SC_FORBIDDEN);
        verify(request).setAttribute(eq("errorMessage"), contains("Access Denied"));
        verify(dispatcher).forward(request, response);
        verify(chain, never()).doFilter(request, response);
    }

    @Test
    void testPassengerRoleDeniedWith403() throws IOException, ServletException {
        User passenger = new User();
        passenger.setEmail("passenger@airline.com");
        passenger.setRole(Role.PASSENGER);

        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("currentUser")).thenReturn(passenger);
        when(request.getRequestDispatcher("/WEB-INF/views/errors/403.jsp")).thenReturn(dispatcher);

        filter.doFilter(request, response, chain);

        verify(response).setStatus(HttpServletResponse.SC_FORBIDDEN);
        verify(dispatcher).forward(request, response);
        verify(chain, never()).doFilter(request, response);
    }

    @Test
    void testAdminRoleAllowed() throws IOException, ServletException {
        User admin = new User();
        admin.setEmail("admin@airline.com");
        admin.setRole(Role.ADMIN);

        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("currentUser")).thenReturn(admin);

        filter.doFilter(request, response, chain);

        verify(chain).doFilter(request, response);
        verify(dispatcher, never()).forward(any(), any());
    }
}
