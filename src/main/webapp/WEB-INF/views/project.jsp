<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Architecture & Documentation | SkyTech PBL</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .doc-badge { font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 700; }
        .module-card { border: 1px solid var(--st-border, #e2e8f0); border-radius: 12px; background: #fff; transition: transform 0.2s; }
        .module-card:hover { transform: translateY(-3px); box-shadow: 0 10px 25px rgba(0,0,0,0.06); }
        .code-snippet { background: #0f172a; color: #38bdf8; padding: 1rem; border-radius: 8px; font-family: monospace; font-size: 0.85rem; }
    </style>
</head>
<body class="bg-light">

<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="container py-5" style="max-width: 1100px;">
    <!-- Header Banner -->
    <div class="bg-white p-4 p-md-5 rounded-4 shadow-sm border mb-4">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
            <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill doc-badge">
                <i class="bi bi-mortarboard-fill me-1"></i> Academic Project Evaluation
            </span>
            <span class="badge bg-dark px-3 py-2 rounded-pill doc-badge">
                <i class="bi bi-git me-1"></i> Branch: feature/flight-search
            </span>
        </div>
        <h1 class="h2 fw-bold text-dark mb-2">SkyTech — Airline Reservation System</h1>
        <p class="text-secondary lead fs-6 mb-4">
            Java Enterprise College PBL Web Application built with classic MVC architecture on Apache Tomcat 9, JDBC, Servlets, and JSP.
        </p>

        <div class="row g-3 pt-3 border-top">
            <div class="col-sm-6 col-md-3">
                <div class="text-muted small">Architecture</div>
                <div class="fw-semibold text-dark">MVC (Model-View-Controller)</div>
            </div>
            <div class="col-sm-6 col-md-3">
                <div class="text-muted small">Server Runtime</div>
                <div class="fw-semibold text-dark">Apache Tomcat 9.0</div>
            </div>
            <div class="col-sm-6 col-md-3">
                <div class="text-muted small">Database & ORM</div>
                <div class="fw-semibold text-dark">MySQL 8.0 / Native JDBC</div>
            </div>
            <div class="col-sm-6 col-md-3">
                <div class="text-muted small">External API</div>
                <div class="fw-semibold text-dark">Amadeus Self-Service API</div>
            </div>
        </div>
    </div>

    <!-- Active Diagnostics & Data Status -->
    <div class="card border-0 shadow-sm rounded-4 mb-4">
        <div class="card-header bg-white py-3 border-bottom">
            <div class="d-flex align-items-center justify-content-between">
                <h5 class="mb-0 fw-bold"><i class="bi bi-cpu text-primary me-2"></i>Runtime Engine Diagnostics</h5>
                <span class="badge ${providerName eq 'AmadeusFlightProvider' ? 'bg-success' : 'bg-primary'} px-3 py-2">
                    Active Provider: ${providerName}
                </span>
            </div>
        </div>
        <div class="card-body p-4">
            <div class="row g-4 align-items-center">
                <div class="col-md-7">
                    <h6 class="fw-bold mb-2">Dual-Engine Provider Abstraction</h6>
                    <p class="text-secondary small mb-3">
                        SkyTech implements an enterprise Provider Pattern via <code>FlightProvider</code> interface. 
                        When live API keys are supplied in <code>api.properties</code>, the system queries the live Amadeus global distribution system (GDS) for pricing and flight offers. 
                        When offline or in mock mode, it seamlessly falls back to <code>DatabaseFlightProvider</code> using local MySQL relational storage.
                    </p>
                    <div class="d-flex gap-2">
                        <span class="badge bg-light text-dark border"><i class="bi bi-check2-circle text-success me-1"></i>PreparedStatements Security</span>
                        <span class="badge bg-light text-dark border"><i class="bi bi-check2-circle text-success me-1"></i>HikariCP / DBCP Ready</span>
                        <span class="badge bg-light text-dark border"><i class="bi bi-check2-circle text-success me-1"></i>No Inlined Secrets</span>
                    </div>
                </div>
                <div class="col-md-5">
                    <div class="code-snippet">
                        <div>// Provider Selection Pipeline</div>
                        <div>FlightSearchController</div>
                        <div>&nbsp;&nbsp;↳ FlightSearchService</div>
                        <div>&nbsp;&nbsp;&nbsp;&nbsp;↳ FlightProvider (Interface)</div>
                        <div class="text-warning">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── AmadeusFlightProvider (Live)</div>
                        <div class="text-success">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── DatabaseFlightProvider (Fallback)</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Team Module Breakdown -->
    <h4 class="fw-bold text-dark mb-3"><i class="bi bi-kanban me-2 text-primary"></i>Team Modular Architecture</h4>
    <div class="row g-3 mb-5">
        <div class="col-md-6 col-lg-4">
            <div class="module-card p-4 h-100">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <span class="badge bg-secondary bg-opacity-10 text-secondary">Module 1</span>
                    <span class="badge bg-info text-dark">Foundation</span>
                </div>
                <h5 class="fw-bold fs-6 mb-2">Authentication & Users</h5>
                <p class="text-secondary small mb-3">
                    User registration, bcrypt password hashing, login session lifecycle management, and profile management.
                </p>
                <div class="text-muted small border-top pt-2"><i class="bi bi-person me-1"></i>Team Member Module</div>
            </div>
        </div>

        <div class="col-md-6 col-lg-4">
            <div class="module-card p-4 h-100 border-primary" style="box-shadow: 0 0 0 1px var(--st-primary, #0284c7);">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <span class="badge bg-primary">Module 2 • Active Branch</span>
                    <span class="badge bg-success">Production Ready</span>
                </div>
                <h5 class="fw-bold fs-6 mb-2 text-primary">Flight Search & Availability</h5>
                <p class="text-secondary small mb-3">
                    One-way, round-trip, multi-city route segment builder, date validations, dynamic filters, seat selection map, Amadeus & local DB provider abstraction.
                </p>
                <div class="text-primary small fw-semibold border-top pt-2"><i class="bi bi-star-fill me-1"></i>Lead: Nikhil Ranjan Choubey</div>
            </div>
        </div>

        <div class="col-md-6 col-lg-4">
            <div class="module-card p-4 h-100">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <span class="badge bg-secondary bg-opacity-10 text-secondary">Module 3</span>
                    <span class="badge bg-warning text-dark">Next Integration</span>
                </div>
                <h5 class="fw-bold fs-6 mb-2">Booking & Passenger Management</h5>
                <p class="text-secondary small mb-3">
                    Passenger manifests, PNR generation, seat reservation locking, and customer booking retrieval.
                </p>
                <div class="text-muted small border-top pt-2"><i class="bi bi-person me-1"></i>Team Member Module</div>
            </div>
        </div>

        <div class="col-md-6 col-lg-4">
            <div class="module-card p-4 h-100">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <span class="badge bg-secondary bg-opacity-10 text-secondary">Module 4</span>
                    <span class="badge bg-secondary text-white">Planned</span>
                </div>
                <h5 class="fw-bold fs-6 mb-2">Ticketing & Cancellation</h5>
                <p class="text-secondary small mb-3">
                    E-ticket PDF rendering, boarding pass issuance, cancellation workflows, and refund calculations.
                </p>
                <div class="text-muted small border-top pt-2"><i class="bi bi-person me-1"></i>Team Member Module</div>
            </div>
        </div>

        <div class="col-md-6 col-lg-4">
            <div class="module-card p-4 h-100">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <span class="badge bg-secondary bg-opacity-10 text-secondary">Module 5</span>
                    <span class="badge bg-secondary text-white">Planned</span>
                </div>
                <h5 class="fw-bold fs-6 mb-2">Admin Dashboard & Fleet Management</h5>
                <p class="text-secondary small mb-3">
                    Flight schedule CRUD, aircraft fleet management, fare adjustments, and booking analytics.
                </p>
                <div class="text-muted small border-top pt-2"><i class="bi bi-person me-1"></i>Team Member Module</div>
            </div>
        </div>

        <div class="col-md-6 col-lg-4">
            <div class="module-card p-4 h-100 bg-white">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <span class="badge bg-dark text-white">Shared</span>
                    <span class="badge bg-light text-dark border">Standard</span>
                </div>
                <h5 class="fw-bold fs-6 mb-2">Shared Foundation & DB</h5>
                <p class="text-secondary small mb-3">
                    Centralized connection pool (`DatabaseConnection`), base schema DDL, standard utility helpers, and error handling.
                </p>
                <div class="text-muted small border-top pt-2"><i class="bi bi-share me-1"></i>Shared Team Infrastructure</div>
            </div>
        </div>
    </div>

    <!-- Quick Navigation Back -->
    <div class="text-center">
        <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-primary px-4 py-2 rounded-pill">
            <i class="bi bi-arrow-left me-2"></i>Return to Airline Customer Portal
        </a>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
