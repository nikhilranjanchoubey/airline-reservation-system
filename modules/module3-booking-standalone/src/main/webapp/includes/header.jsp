<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SKYTECH AIRLINES &bull; Flight Reservation Portal</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Dedicated Theme Stylesheet -->
    <link href="${pageContext.request.contextPath}/assets/css/booking.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-expand-lg skytech-navbar sticky-top">
    <div class="container">
        <a class="skytech-brand" href="${pageContext.request.contextPath}/">
            <div class="skytech-logo-container">
                <svg class="skytech-logo-plane" viewBox="0 0 44 44" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path fill="#19A7D8" d="M 20 1.5 C 21.2 0 22.8 0 24 1.5 C 24.8 2.8 25.3 4.8 25.3 7.5 L 25.3 17.5 L 39 24.2 C 40.5 25 41 26.2 41 27.6 L 41 31 C 41 31.8 40.2 32.5 39.4 32.3 L 25.3 30 L 24.4 33.8 L 28.3 37.5 C 28.8 38 29.1 38.7 29.1 39.5 L 29.1 42 L 22 38.8 L 14.9 42 L 14.9 39.5 C 14.9 38.7 15.2 38 15.7 37.5 L 19.6 33.8 L 18.7 30 L 4.6 32.3 C 3.8 32.5 3 31.8 3 31 L 3 27.6 C 3 26.2 3.5 25 5 24.2 L 18.7 17.5 L 18.7 7.5 C 18.7 4.8 19.2 2.8 20 1.5 Z"/>
                </svg>
                <div class="skytech-logo-text">
                    <span class="skytech-logo-title">SKYTECH</span>
                    <span class="skytech-logo-subtitle">AIRLINES</span>
                </div>
            </div>
        </a>
        <button class="navbar-toggler text-white border-0" type="button" data-bs-toggle="collapse" data-bs-target="#skytechNav">
            <i class="bi bi-list fs-2 text-white"></i>
        </button>
        <div class="collapse navbar-collapse" id="skytechNav">
            <ul class="navbar-nav ms-auto align-items-center gap-1">
                <li class="nav-item">
                    <a class="nav-link skytech-nav-link" href="${pageContext.request.contextPath}/">
                        <i class="bi bi-compass me-1"></i> Flights
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link skytech-nav-link" href="${pageContext.request.contextPath}/booking/my-bookings">
                        <i class="bi bi-journal-bookmark me-1"></i> My Bookings
                    </a>
                </li>
                <li class="nav-item ms-lg-2">
                    <div class="d-flex align-items-center gap-2 bg-dark bg-opacity-50 px-3 py-1 rounded-pill border border-secondary border-opacity-25">
                        <i class="bi bi-person-circle text-primary fs-5"></i>
                        <span class="small text-white fw-semibold">Rajesh Sharma</span>
                        <span class="badge bg-primary small">Frequent Flyer</span>
                    </div>
                </li>
            </ul>
        </div>
    </div>
</nav>
<main>
