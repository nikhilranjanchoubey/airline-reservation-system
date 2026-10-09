<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="currentUri" value="${pageContext.request.requestURI}" />
<c:set var="isHomeActive" value="${currentUri.endsWith('/home') || currentUri.endsWith('/skytech/') || currentUri.endsWith('/skytech')}" />
<c:set var="isFlightsActive" value="${currentUri.contains('/search-flights') || currentUri.contains('/flight-results') || currentUri.contains('/flight-details') || currentUri.contains('/seat-selection')}" />
<c:set var="isManageActive" value="${currentUri.contains('/manage-booking')}" />
<c:set var="isStatusActive" value="${currentUri.contains('/flight-status')}" />
<c:set var="isTravelInfoActive" value="${currentUri.contains('/travel-information')}" />

<nav class="navbar navbar-expand-lg navbar-dark bg-skytech sticky-top" id="skyTechMainNavbar">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/home" aria-label="SkyTech Homepage">
            <span class="brand-icon-wrapper">
                <i class="bi bi-airplane-engines-fill text-skytech-accent fs-4"></i>
            </span>
            <span class="fw-bold tracking-wide fs-4 text-white">SKYTECH</span>
        </a>

        <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#skyTechNavbar"
                aria-controls="skyTechNavbar" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="skyTechNavbar">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-3 gap-lg-1">
                <li class="nav-item">
                    <a class="nav-link ${isHomeActive ? 'active fw-semibold' : ''}" href="${pageContext.request.contextPath}/home">
                        Home
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${isFlightsActive ? 'active fw-semibold' : ''}" href="${pageContext.request.contextPath}/search-flights">
                        Flights
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${isManageActive ? 'active fw-semibold' : ''}" href="${pageContext.request.contextPath}/manage-booking">
                        Manage Trip
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${isStatusActive ? 'active fw-semibold' : ''}" href="${pageContext.request.contextPath}/flight-status">
                        Flight Status
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${isTravelInfoActive ? 'active fw-semibold' : ''}" href="${pageContext.request.contextPath}/travel-information">
                        Travel Information
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/home#popularRoutesSection">
                        Deals
                    </a>
                </li>
            </ul>

            <div class="d-flex flex-wrap align-items-center gap-2 mt-2 mt-lg-0">
                <button type="button" class="btn btn-outline-light btn-sm rounded-pill px-3" data-bs-toggle="modal" data-bs-target="#skyTechSignInModal">
                    <i class="bi bi-person me-1"></i> Sign In
                </button>
                <a class="btn btn-skytech-accent btn-sm rounded-pill px-3 shadow-sm fw-semibold" href="${pageContext.request.contextPath}/search-flights">
                    <i class="bi bi-search me-1"></i> Search Flights
                </a>
            </div>
        </div>
    </div>
</nav>

<!-- SkyTech Customer Sign-In Modal -->
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
                    Access your flight reservations, frequent flyer points, and manage bookings across Indian destinations.
                </p>
                <form onsubmit="event.preventDefault(); document.getElementById('signInAlert').classList.remove('d-none');">
                    <div class="mb-3">
                        <label for="modalEmailInput" class="form-label small fw-bold text-muted">EMAIL ADDRESS</label>
                        <input type="email" class="form-control form-control-sm" id="modalEmailInput" placeholder="name@example.com" required>
                    </div>
                    <div class="mb-3">
                        <label for="modalPasswordInput" class="form-label small fw-bold text-muted">PASSWORD</label>
                        <input type="password" class="form-control form-control-sm" id="modalPasswordInput" placeholder="Enter your password" required>
                    </div>
                    <div id="signInAlert" class="alert alert-info py-2 small d-none" role="alert">
                        <i class="bi bi-info-circle me-1"></i> Authentication service is in active synchronization. You can search, select seats, and manage bookings directly!
                    </div>
                    <button type="submit" class="btn btn-primary w-100 rounded-pill py-2 fw-semibold">
                        Sign In
                    </button>
                </form>
                <div class="text-center mt-3">
                    <a href="${pageContext.request.contextPath}/manage-booking" class="small text-decoration-none text-muted">
                        Looking for an existing reservation? <span class="text-primary fw-semibold">Retrieve Booking &rarr;</span>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
