<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Flight Operations & Schedule Management | SkyTech" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <c:set var="activeTab" value="flights" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">Flight Operations & Scheduling</h1>
                <div class="admin-header-meta">
                    <span>Manage commercial airline flights, schedules, operational status, and capacity</span>
                </div>
            </div>
            <button type="button" class="admin-btn admin-btn-primary" data-bs-toggle="modal" data-bs-target="#addFlightModal">
                <i class="bi bi-plus-lg"></i> Schedule Flight
            </button>
        </div>

        <!-- Flash alerts -->
        <c:if test="${not empty flashSuccess}">
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
                <i class="bi bi-check-circle-fill"></i>
                <div><c:out value="${flashSuccess}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty flashError}">
            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill"></i>
                <div><c:out value="${flashError}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Search & Filter Bar -->
        <form method="GET" action="${pageContext.request.contextPath}/admin/flights" class="admin-filter-bar">
            <input type="text" name="search" class="admin-form-control flex-grow-1" placeholder="Search by Flight Number or City..." value="<c:out value='${search}' />">
            <select name="status" class="admin-form-control">
                <option value="ALL">All Flight Statuses</option>
                <option value="SCHEDULED" ${status == 'SCHEDULED' ? 'selected' : ''}>Scheduled</option>
                <option value="BOARDING" ${status == 'BOARDING' ? 'selected' : ''}>Boarding</option>
                <option value="DEPARTED" ${status == 'DEPARTED' ? 'selected' : ''}>Departed</option>
                <option value="ARRIVED" ${status == 'ARRIVED' ? 'selected' : ''}>Arrived</option>
                <option value="DELAYED" ${status == 'DELAYED' ? 'selected' : ''}>Delayed</option>
                <option value="CANCELLED" ${status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
            </select>
            <input type="date" name="date" class="admin-form-control" value="<c:out value='${date}' />">
            <button type="submit" class="admin-btn admin-btn-secondary">
                <i class="bi bi-funnel"></i> Filter
            </button>
            <a href="${pageContext.request.contextPath}/admin/flights" class="admin-btn admin-btn-outline">Reset</a>
        </form>

        <!-- Flights Table -->
        <div class="admin-card">
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Flight No</th>
                            <th>Airline</th>
                            <th>Origin → Destination</th>
                            <th>Date & Time</th>
                            <th>Aircraft</th>
                            <th>Base Fare</th>
                            <th>Seats Open</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty schedules}">
                                <c:forEach var="s" items="${schedules}">
                                    <tr>
                                        <td class="fw-bold text-navy">
                                            <c:out value="${s.flight.flightNumber}" />
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <i class="bi ${s.flight.airline.logoIcon} text-primary"></i>
                                                <span><c:out value="${s.flight.airline.airlineName}" /></span>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="fw-semibold">
                                                <c:out value="${s.flight.sourceAirport.airportCode}" /> → <c:out value="${s.flight.destinationAirport.airportCode}" />
                                            </div>
                                            <small class="text-muted"><c:out value="${s.flight.sourceAirport.city}" /> to <c:out value="${s.flight.destinationAirport.city}" /></small>
                                        </td>
                                        <td>
                                            <div class="fw-semibold"><fmt:formatDate value="${s.flightDate}" pattern="dd MMM yyyy" /></div>
                                            <small class="text-muted">${s.flight.departureTime} - ${s.flight.arrivalTime} (${s.flight.durationFormatted})</small>
                                        </td>
                                        <td>
                                            <small class="text-muted"><c:out value="${s.flight.aircraftModel}" /></small>
                                        </td>
                                        <td class="fw-bold text-navy">
                                            ₹<fmt:formatNumber value="${s.basePrice}" maxFractionDigits="0" />
                                        </td>
                                        <td>
                                            <span class="fw-semibold ${s.availableSeats < 20 ? 'text-danger' : 'text-success'}">
                                                ${s.availableSeats} / ${s.totalSeats}
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge-status badge-status-${s.status.toLowerCase()}">
                                                <c:out value="${s.status}" />
                                            </span>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-1">
                                                <!-- Update Status Dropdown -->
                                                <div class="dropdown">
                                                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle py-0 px-2" style="font-size: 0.78rem;" type="button" data-bs-toggle="dropdown">
                                                        Status
                                                    </button>
                                                    <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                                                        <li>
                                                            <form method="POST" action="${pageContext.request.contextPath}/admin/flights">
                                                                <input type="hidden" name="action" value="update_status">
                                                                <input type="hidden" name="scheduleId" value="${s.scheduleId}">
                                                                <input type="hidden" name="status" value="SCHEDULED">
                                                                <button class="dropdown-item" type="submit">Mark Scheduled</button>
                                                            </form>
                                                        </li>
                                                        <li>
                                                            <form method="POST" action="${pageContext.request.contextPath}/admin/flights">
                                                                <input type="hidden" name="action" value="update_status">
                                                                <input type="hidden" name="scheduleId" value="${s.scheduleId}">
                                                                <input type="hidden" name="status" value="BOARDING">
                                                                <button class="dropdown-item" type="submit">Mark Boarding</button>
                                                            </form>
                                                        </li>
                                                        <li>
                                                            <form method="POST" action="${pageContext.request.contextPath}/admin/flights">
                                                                <input type="hidden" name="action" value="update_status">
                                                                <input type="hidden" name="scheduleId" value="${s.scheduleId}">
                                                                <input type="hidden" name="status" value="DEPARTED">
                                                                <button class="dropdown-item" type="submit">Mark Departed</button>
                                                            </form>
                                                        </li>
                                                        <li>
                                                            <form method="POST" action="${pageContext.request.contextPath}/admin/flights">
                                                                <input type="hidden" name="action" value="update_status">
                                                                <input type="hidden" name="scheduleId" value="${s.scheduleId}">
                                                                <input type="hidden" name="status" value="ARRIVED">
                                                                <button class="dropdown-item" type="submit">Mark Arrived</button>
                                                            </form>
                                                        </li>
                                                        <li>
                                                            <form method="POST" action="${pageContext.request.contextPath}/admin/flights">
                                                                <input type="hidden" name="action" value="update_status">
                                                                <input type="hidden" name="scheduleId" value="${s.scheduleId}">
                                                                <input type="hidden" name="status" value="DELAYED">
                                                                <button class="dropdown-item text-warning" type="submit">Mark Delayed</button>
                                                            </form>
                                                        </li>
                                                    </ul>
                                                </div>

                                                <!-- Safe Deactivate Action -->
                                                <c:if test="${s.status != 'CANCELLED'}">
                                                    <form method="POST" action="${pageContext.request.contextPath}/admin/flights" onsubmit="return confirm('Safely deactivate / cancel this flight schedule?');">
                                                        <input type="hidden" name="action" value="deactivate">
                                                        <input type="hidden" name="scheduleId" value="${s.scheduleId}">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger py-0 px-2" style="font-size: 0.78rem;" title="Deactivate Flight">
                                                            <i class="bi bi-slash-circle"></i>
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="9">
                                        <div class="admin-empty-state">
                                            <i class="bi bi-airplane admin-empty-icon"></i>
                                            <div class="admin-empty-title">No Flight Schedules Found</div>
                                            <div class="admin-empty-desc">There are no flight schedules matching your current filters.</div>
                                            <button type="button" class="admin-btn admin-btn-primary" data-bs-toggle="modal" data-bs-target="#addFlightModal">
                                                Schedule New Flight
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="admin-pagination">
                    <span>Showing page ${currentPage} of ${totalPages} (${totalCount} total schedules)</span>
                    <div class="admin-page-links">
                        <c:forEach var="p" begin="1" end="${totalPages}">
                            <a href="${pageContext.request.contextPath}/admin/flights?page=${p}&search=${search}&status=${status}&date=${date}"
                               class="admin-page-btn ${currentPage == p ? 'active' : ''}">${p}</a>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
        </div>
    </main>
</div>

<!-- Modal: Schedule New Flight -->
<div class="modal fade" id="addFlightModal" tabindex="-1" aria-labelledby="addFlightModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form method="POST" action="${pageContext.request.contextPath}/admin/flights">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold text-navy" id="addFlightModalLabel">
                        <i class="bi bi-airplane-fill text-primary me-2"></i> Schedule New Flight
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Flight Number <span class="text-danger">*</span></label>
                            <input type="text" name="flightNumber" class="form-control text-uppercase" placeholder="e.g. ST-305" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Airline Operator <span class="text-danger">*</span></label>
                            <select name="airlineId" class="form-select" required>
                                <c:forEach var="al" items="${airlines}">
                                    <option value="${al.airlineId}"><c:out value="${al.airlineName}" /> (<c:out value="${al.airlineCode}" />)</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Origin Airport <span class="text-danger">*</span></label>
                            <select name="sourceAirportId" class="form-select" required>
                                <c:forEach var="ap" items="${airports}">
                                    <option value="${ap.airportId}"><c:out value="${ap.city}" /> (<c:out value="${ap.airportCode}" />) - <c:out value="${ap.airportName}" /></option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Destination Airport <span class="text-danger">*</span></label>
                            <select name="destAirportId" class="form-select" required>
                                <c:forEach var="ap" items="${airports}">
                                    <option value="${ap.airportId}"><c:out value="${ap.city}" /> (<c:out value="${ap.airportCode}" />) - <c:out value="${ap.airportName}" /></option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Flight Date <span class="text-danger">*</span></label>
                            <input type="date" name="flightDate" class="form-control" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Departure Time <span class="text-danger">*</span></label>
                            <input type="time" name="departureTime" class="form-control" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Arrival Time <span class="text-danger">*</span></label>
                            <input type="time" name="arrivalTime" class="form-control" required>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Duration (Minutes) <span class="text-danger">*</span></label>
                            <input type="number" name="durationMinutes" class="form-control" placeholder="135" min="30" max="1440" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Aircraft Model</label>
                            <select name="aircraftModel" class="form-select">
                                <option value="Airbus A320neo">Airbus A320neo</option>
                                <option value="Airbus A321neo">Airbus A321neo</option>
                                <option value="Boeing 737 MAX 8">Boeing 737 MAX 8</option>
                                <option value="Boeing 787-9 Dreamliner">Boeing 787-9 Dreamliner</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Total Seat Capacity <span class="text-danger">*</span></label>
                            <input type="number" name="totalSeats" class="form-control" value="180" min="20" max="450" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Base Economy Fare (INR) <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text">₹</span>
                                <input type="number" step="0.01" name="basePrice" class="form-control" placeholder="4800.00" min="500" required>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="admin-btn admin-btn-primary">Schedule Flight</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
