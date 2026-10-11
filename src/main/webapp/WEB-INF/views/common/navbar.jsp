<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="currentUri" value="${pageContext.request.requestURI}" />
<c:set var="isHomeActive" value="${currentUri.endsWith('/') || currentUri.endsWith('/home') || currentUri.endsWith('/skytech/') || currentUri.endsWith('/skytech') || currentUri.endsWith('/index.jsp')}" />
<c:set var="isFlightsActive" value="${currentUri.contains('/search-flights') || currentUri.contains('/flight-results') || currentUri.contains('/flight-details') || currentUri.contains('/seat-selection')}" />
<c:set var="isManageActive" value="${currentUri.contains('/manage-booking')}" />
<c:set var="isStatusActive" value="${currentUri.contains('/flight-status')}" />
<c:set var="isTravelInfoActive" value="${currentUri.contains('/travel-information')}" />
<c:set var="isAboutActive" value="${currentUri.contains('/about')}" />
<c:set var="isProjectActive" value="${currentUri.contains('/project')}" />

<nav class="navbar navbar-expand-lg navbar-dark bg-skytech sticky-top" id="skyTechMainNavbar">
    <div class="container-fluid px-lg-4">
        <!-- Logo -->
        <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/" aria-label="SkyTech Homepage">
            <span class="brand-icon-wrapper">
                <i class="bi bi-airplane-engines-fill text-skytech-accent fs-4"></i>
            </span>
            <span class="fw-bold tracking-wide fs-4 text-white">SkyTech</span>
        </a>

        <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#skyTechNavbar"
                aria-controls="skyTechNavbar" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="skyTechNavbar">
            <!-- Center Navigation Links -->
            <ul class="navbar-nav mx-auto mb-2 mb-lg-0 gap-lg-1">
                <li class="nav-item">
                    <a class="nav-link ${isHomeActive ? 'active fw-semibold' : ''}" href="${pageContext.request.contextPath}/">
                        Home
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${isFlightsActive ? 'active fw-semibold' : ''}" href="${pageContext.request.contextPath}/search-flights">
                        Flights
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${isStatusActive ? 'active fw-semibold' : ''}" href="${pageContext.request.contextPath}/flight-status">
                        Flight Status
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${isManageActive ? 'active fw-semibold' : ''}" href="${pageContext.request.contextPath}/manage-booking">
                        Manage Trip
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${isTravelInfoActive ? 'active fw-semibold' : ''}" href="${pageContext.request.contextPath}/travel-information">
                        Travel Information
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${isAboutActive ? 'active fw-semibold' : ''}" href="${pageContext.request.contextPath}/about">
                        About
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${isProjectActive ? 'active fw-semibold' : ''}" href="${pageContext.request.contextPath}/project">
                        Project Docs
                    </a>
                </li>
            </ul>

            <!-- Right Action Bar: Search CTA + Auth Actions -->
            <div class="d-flex flex-wrap align-items-center gap-2 mt-2 mt-lg-0">
                <c:choose>
                    <c:when test="${not empty sessionScope.currentUser}">
                        <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                            <a class="btn btn-sm btn-outline-warning rounded-pill px-3" href="${pageContext.request.contextPath}/admin/dashboard">
                                <i class="bi bi-shield-lock-fill me-1"></i> Admin Panel
                            </a>
                        </c:if>

                        <a class="btn btn-sm btn-outline-light rounded-pill px-3 text-white" href="${pageContext.request.contextPath}/profile">
                            <i class="bi bi-person-circle me-1"></i> <c:out value="${sessionScope.currentUser.firstName}" />
                        </a>

                        <a class="btn btn-sm btn-light rounded-pill px-3 py-1 fw-semibold" href="${pageContext.request.contextPath}/logout">
                            Sign Out
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a class="btn btn-outline-light btn-sm rounded-pill px-3" href="${pageContext.request.contextPath}/login">
                            <i class="bi bi-person me-1"></i> Login
                        </a>
                        <a class="btn btn-primary btn-sm rounded-pill px-3 shadow-sm fw-semibold" href="${pageContext.request.contextPath}/register">
                            Sign Up
                        </a>
                    </c:otherwise>
                </c:choose>

                <a class="btn btn-skytech-accent btn-sm rounded-pill px-3 shadow-sm fw-semibold ms-lg-1" href="${pageContext.request.contextPath}/search-flights">
                    <i class="bi bi-search me-1"></i> Search Flights
                </a>
            </div>
        </div>
    </div>
</nav>

<!-- SkyTech Customer Sign-In Modal (Functional with Auth Backend) -->
<div class="modal fade" id="skyTechSignInModal" tabindex="-1" aria-labelledby="skyTechSignInModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content shadow border-0 rounded-4">
            <div class="modal-header border-bottom">
                <h5 class="modal-title fw-bold text-dark" id="skyTechSignInModalLabel">
                    <i class="bi bi-person-circle text-primary me-2"></i>Sign In to SkyTech
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <p class="text-muted small mb-4">
                    Access your flight reservations, manage passenger profiles, and explore real-time flights.
                </p>
                <form action="${pageContext.request.contextPath}/login" method="POST">
                    <div class="mb-3">
                        <label for="modalEmailInput" class="form-label small fw-bold text-muted">EMAIL ADDRESS</label>
                        <input type="email" class="form-control" id="modalEmailInput" name="email" placeholder="name@example.com" required>
                    </div>
                    <div class="mb-3">
                        <label for="modalPasswordInput" class="form-label small fw-bold text-muted">PASSWORD</label>
                        <input type="password" class="form-control" id="modalPasswordInput" name="password" placeholder="Enter your password" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 rounded-pill py-2 fw-semibold">
                        Sign In
                    </button>
                </form>
                <div class="text-center mt-3 d-flex justify-content-between small">
                    <a href="${pageContext.request.contextPath}/register" class="text-primary text-decoration-none fw-semibold">
                        Create an Account &rarr;
                    </a>
                    <a href="${pageContext.request.contextPath}/manage-booking" class="text-muted text-decoration-none">
                        Retrieve Booking &rarr;
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
