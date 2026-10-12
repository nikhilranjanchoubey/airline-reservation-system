package com.skytech.airlines.booking.integration;

import javax.servlet.http.HttpServletRequest;

public interface IUserSessionProvider {
    Long getAuthenticatedUserId(HttpServletRequest request);
    String getAuthenticatedUserEmail(HttpServletRequest request);
    String getAuthenticatedUserName(HttpServletRequest request);
    boolean isAuthenticated(HttpServletRequest request);
}
