package com.airline.controller;

import com.skytech.dao.AdminDashboardDao;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AdminDashboardServletTest {

    @Mock
    private AdminDashboardDao dashboardDao;

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private RequestDispatcher dispatcher;

    private AdminDashboardServlet servlet;

    @BeforeEach
    void setUp() {
        servlet = new AdminDashboardServlet(dashboardDao);
    }

    @Test
    void testDoGetPopulatesKpisAndForwards() throws ServletException, IOException {
        Map<String, Object> kpiMap = new HashMap<>();
        kpiMap.put("totalBookings", 42L);
        when(dashboardDao.getDashboardKpis()).thenReturn(kpiMap);
        when(dashboardDao.getUpcomingDepartures(5)).thenReturn(Collections.emptyList());
        when(dashboardDao.getRecentReservations(6)).thenReturn(Collections.emptyList());
        when(dashboardDao.getRecentSuccessfulPayments(5)).thenReturn(Collections.emptyList());
        when(dashboardDao.getPendingPaymentBookings(5)).thenReturn(Collections.emptyList());
        when(dashboardDao.getRecentCancellations(5)).thenReturn(Collections.emptyList());
        when(dashboardDao.getInventorySummary()).thenReturn(Collections.emptyMap());
        when(request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp")).thenReturn(dispatcher);

        servlet.doGet(request, response);

        verify(request).setAttribute(eq("kpis"), eq(kpiMap));
        verify(request).setAttribute(eq("upcomingDepartures"), eq(Collections.emptyList()));
        verify(request).setAttribute(eq("recentReservations"), eq(Collections.emptyList()));
        verify(request).setAttribute(eq("recentPayments"), eq(Collections.emptyList()));
        verify(dispatcher).forward(request, response);
    }
}
