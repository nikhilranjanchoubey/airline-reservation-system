package com.skytech.airlines.booking.integration;

import javax.servlet.http.HttpServletRequest;

public class DevAuthenticationProviderMock implements AuthenticationProvider {
    @Override
    public Long getAuthenticatedUserId(HttpServletRequest request) { return 1L; }

    @Override
    public String getAuthenticatedUserEmail(HttpServletRequest request) { return "rajesh.sharma@example.com"; }

    @Override
    public String getAuthenticatedUserName(HttpServletRequest request) { return "Rajesh Sharma"; }

    @Override
    public boolean isAuthenticated(HttpServletRequest request) { return true; }
}
