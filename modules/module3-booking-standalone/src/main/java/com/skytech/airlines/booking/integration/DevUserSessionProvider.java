package com.skytech.airlines.booking.integration;

import javax.servlet.http.HttpServletRequest;

public class DevUserSessionProvider implements IUserSessionProvider {
    private final AdaptiveAuthenticationProvider delegate = new AdaptiveAuthenticationProvider();

    @Override
    public Long getAuthenticatedUserId(HttpServletRequest request) { return delegate.getAuthenticatedUserId(request); }

    @Override
    public String getAuthenticatedUserEmail(HttpServletRequest request) { return delegate.getAuthenticatedUserEmail(request); }

    @Override
    public String getAuthenticatedUserName(HttpServletRequest request) { return delegate.getAuthenticatedUserName(request); }

    @Override
    public boolean isAuthenticated(HttpServletRequest request) { return delegate.isAuthenticated(request); }
}
