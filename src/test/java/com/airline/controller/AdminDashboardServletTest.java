package com.airline.controller;

import com.airline.dao.UserDao;
import com.airline.model.Role;
import com.airline.model.User;
import com.airline.service.UserService;
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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AdminDashboardServletTest {

    @Mock
    private UserDao userDao;

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private HttpSession session;

    @Mock
    private RequestDispatcher dispatcher;

    private UserService userService;
    private AdminDashboardServlet servlet;

    @BeforeEach
    void setUp() {
        userService = new UserService(userDao);
        servlet = new AdminDashboardServlet(userService);
    }

    @Test
    void testDoGetCalculatesStats() throws ServletException, IOException {
        User u1 = new User();
        u1.setUserId(1);
        u1.setRole(Role.ADMIN);
        u1.setStatus("ACTIVE");

        User u2 = new User();
        u2.setUserId(2);
        u2.setRole(Role.PASSENGER);
        u2.setStatus("ACTIVE");

        User u3 = new User();
        u3.setUserId(3);
        u3.setRole(Role.PASSENGER);
        u3.setStatus("SUSPENDED");

        List<User> list = Arrays.asList(u1, u2, u3);
        when(userDao.findAllUsers()).thenReturn(list);
        when(request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp")).thenReturn(dispatcher);

        servlet.doGet(request, response);

        verify(request).setAttribute("users", list);
        verify(request).setAttribute("totalUsers", 3);
        verify(request).setAttribute("passengerCount", 2L);
        verify(request).setAttribute("adminCount", 1L);
        verify(request).setAttribute("activeCount", 2L);
        verify(dispatcher).forward(request, response);
    }

    @Test
    void testDoGetHandlesEmptyUserList() throws ServletException, IOException {
        when(userDao.findAllUsers()).thenReturn(new ArrayList<>());
        when(request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp")).thenReturn(dispatcher);

        servlet.doGet(request, response);

        verify(request).setAttribute("totalUsers", 0);
        verify(request).setAttribute("passengerCount", 0L);
        verify(request).setAttribute("adminCount", 0L);
        verify(request).setAttribute("activeCount", 0L);
        verify(dispatcher).forward(request, response);
    }

    @Test
    void testDoPostToggleStatusSelfModificationPrevented() throws ServletException, IOException {
        when(request.getParameter("action")).thenReturn("toggle_status");
        when(request.getParameter("userId")).thenReturn("1");
        when(request.getSession(false)).thenReturn(session);
        when(request.getContextPath()).thenReturn("/airline-reservation-system");

        User currentAdmin = new User();
        currentAdmin.setUserId(1);
        when(session.getAttribute("currentUser")).thenReturn(currentAdmin);

        servlet.doPost(request, response);

        verify(session).setAttribute(eq("flashError"), contains("cannot modify your own"));
        verify(userDao, never()).updateStatus(anyInt(), anyString());
        verify(response).sendRedirect("/airline-reservation-system/admin/dashboard");
    }

    @Test
    void testDoPostToggleStatusSuccess() throws ServletException, IOException {
        when(request.getParameter("action")).thenReturn("toggle_status");
        when(request.getParameter("userId")).thenReturn("2");
        when(request.getSession(false)).thenReturn(session);
        when(request.getContextPath()).thenReturn("/airline-reservation-system");

        User currentAdmin = new User();
        currentAdmin.setUserId(1);
        when(session.getAttribute("currentUser")).thenReturn(currentAdmin);

        User targetUser = new User();
        targetUser.setUserId(2);
        targetUser.setStatus("ACTIVE");

        when(userDao.findById(2)).thenReturn(targetUser);
        when(userDao.updateStatus(2, "SUSPENDED")).thenReturn(true);

        servlet.doPost(request, response);

        verify(userDao).updateStatus(2, "SUSPENDED");
        verify(session).setAttribute(eq("flashSuccess"), contains("status updated successfully"));
        verify(response).sendRedirect("/airline-reservation-system/admin/dashboard");
    }
}
