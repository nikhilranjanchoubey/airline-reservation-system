<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Airline Operations Dashboard | SkyTech Administration" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
<!-- Include Chart.js for real data visualizations -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <!-- Collapsible Sidebar -->
    <c:set var="activeTab" value="overview" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <!-- Main Operations Area -->
    <main class="admin-main">
        <!-- Page Header -->
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">Airline Operations Dashboard</h1>
                <div class="admin-header-meta">
                    <span><i class="bi bi-calendar3 me-1"></i> <c:out value="${currentDateFormatted}" /></span>
                    <span><i class="bi bi-shield-check text-success me-1"></i> Logged in as <strong><c:out value="${sessionScope.currentUser.firstName}" /> <c:out value="${sessionScope.currentUser.lastName}" /></strong></span>
                </div>
            </div>
            <div class="d-flex align-items-center gap-2">
                <a href="${pageContext.request.contextPath}/admin/notifications" class="admin-btn admin-btn-outline" title="Operational Alerts">
                    <i class="bi bi-bell"></i>
                    <span class="badge bg-danger rounded-pill">${pendingBookings.size()}</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/profile" class="admin-btn admin-btn-outline">
                    <i class="bi bi-person-gear"></i> Admin Profile
                </a>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-btn admin-btn-primary">
                    <i class="bi bi-arrow-clockwise"></i> Refresh Metrics
                </a>
            </div>
        </div>

        <!-- Alert messages -->
        <c:if test="${not empty flashSuccess}">
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
                <i class="bi bi-check-circle-fill fs-5"></i>
                <div><c:out value="${flashSuccess}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${not empty flashError}">
            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                <div><c:out value="${flashError}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- A. 8 Database-Derived KPI Metrics -->
        <div class="admin-kpi-grid">
            <!-- 1. Total Passengers -->
            <a href="${pageContext.request.contextPath}/admin/passengers" class="admin-kpi-card">
                <div>
                    <div class="admin-kpi-label">Total Passengers</div>
                    <div class="admin-kpi-value">${kpis.totalPassengers}</div>
                    <small class="text-muted">Distinct travelers manifested</small>
                </div>
                <div class="admin-kpi-icon kpi-icon-blue">
                    <i class="bi bi-person-badge-fill"></i>
                </div>
            </a>

            <!-- 2. Registered Accounts -->
            <a href="${pageContext.request.contextPath}/admin/passengers?role=PASSENGER" class="admin-kpi-card">
                <div>
                    <div class="admin-kpi-label">Registered Accounts</div>
                    <div class="admin-kpi-value">${kpis.registeredAccounts}</div>
                    <small class="text-muted">Active portal user logins</small>
                </div>
                <div class="admin-kpi-icon kpi-icon-navy">
                    <i class="bi bi-people-fill"></i>
                </div>
            </a>

            <!-- 3. Total Reservations -->
            <a href="${pageContext.request.contextPath}/admin/bookings" class="admin-kpi-card">
                <div>
                    <div class="admin-kpi-label">Total Reservations</div>
                    <div class="admin-kpi-value">${kpis.totalReservations}</div>
                    <small class="text-muted">All booking references</small>
                </div>
                <div class="admin-kpi-icon kpi-icon-blue">
                    <i class="bi bi-journal-text"></i>
                </div>
            </a>

            <!-- 4. Confirmed Bookings -->
            <a href="${pageContext.request.contextPath}/admin/bookings?status=CONFIRMED" class="admin-kpi-card">
                <div>
                    <div class="admin-kpi-label">Confirmed Bookings</div>
                    <div class="admin-kpi-value text-success">${kpis.confirmedBookings}</div>
                    <small class="text-muted">Ticketed & verified trips</small>
                </div>
                <div class="admin-kpi-icon kpi-icon-green">
                    <i class="bi bi-check2-circle"></i>
                </div>
            </a>

            <!-- 5. Pending Payments -->
            <a href="${pageContext.request.contextPath}/admin/bookings?status=PENDING_PAYMENT" class="admin-kpi-card">
                <div>
                    <div class="admin-kpi-label">Pending Payments</div>
                    <div class="admin-kpi-value text-warning">${kpis.pendingPayments}</div>
                    <small class="text-muted">Awaiting gateway settlement</small>
                </div>
                <div class="admin-kpi-icon kpi-icon-amber">
                    <i class="bi bi-hourglass-split"></i>
                </div>
            </a>

            <!-- 6. Cancelled Bookings -->
            <a href="${pageContext.request.contextPath}/admin/cancellations" class="admin-kpi-card">
                <div>
                    <div class="admin-kpi-label">Cancelled Bookings</div>
                    <div class="admin-kpi-value text-danger">${kpis.cancelledBookings}</div>
                    <small class="text-muted">Restored & refunded seats</small>
                </div>
                <div class="admin-kpi-icon kpi-icon-red">
                    <i class="bi bi-x-octagon-fill"></i>
                </div>
            </a>

            <!-- 7. Total Flights -->
            <a href="${pageContext.request.contextPath}/admin/flights" class="admin-kpi-card">
                <div>
                    <div class="admin-kpi-label">Total Flights</div>
                    <div class="admin-kpi-value">${kpis.totalFlights}</div>
                    <small class="text-muted">Active scheduled routes</small>
                </div>
                <div class="admin-kpi-icon kpi-icon-navy">
                    <i class="bi bi-airplane-fill"></i>
                </div>
            </a>

            <!-- 8. Verified Revenue -->
            <a href="${pageContext.request.contextPath}/admin/payments?status=SUCCESS" class="admin-kpi-card">
                <div>
                    <div class="admin-kpi-label">Verified Revenue</div>
                    <div class="admin-kpi-value text-success">
                        ₹<fmt:formatNumber value="${kpis.verifiedRevenue}" type="number" maxFractionDigits="0" />
                    </div>
                    <small class="text-muted">From verified successful payments</small>
                </div>
                <div class="admin-kpi-icon kpi-icon-green">
                    <i class="bi bi-currency-rupee"></i>
                </div>
            </a>
        </div>

        <!-- B. Real Database-Driven Charts -->
        <div class="admin-charts-grid">
            <!-- Chart 1: Bookings & Revenue Trend -->
            <div class="chart-card">
                <div class="d-flex align-items-center justify-content-between mb-3">
                    <h5 class="mb-0 fs-6 fw-bold text-navy"><i class="bi bi-graph-up text-primary me-2"></i>Bookings Activity (Last 7 Days)</h5>
                    <span class="badge bg-light text-muted border" id="bookingsTrendBadge">Real Data</span>
                </div>
                <div class="chart-canvas-container position-relative" id="bookingsTrendWrapper">
                    <canvas id="bookingsTrendChart"></canvas>
                    <div id="trendChartEmptyNotice" class="d-none position-absolute top-50 start-50 translate-middle text-center w-100 p-3">
                        <i class="bi bi-calendar-x text-muted fs-2 d-block mb-2"></i>
                        <div class="fw-semibold text-navy small">No 7-Day Booking Activity</div>
                        <small class="text-muted" style="font-size: 0.78rem;">New reservations will appear here automatically.</small>
                    </div>
                </div>
            </div>

            <!-- Chart 2: Booking Status Distribution -->
            <div class="chart-card">
                <div class="d-flex align-items-center justify-content-between mb-3">
                    <h5 class="mb-0 fs-6 fw-bold text-navy"><i class="bi bi-pie-chart-fill text-primary me-2"></i>Booking Status Distribution</h5>
                    <span class="badge bg-light text-muted border">Real Data</span>
                </div>
                <div class="chart-canvas-container position-relative" id="statusDistributionWrapper">
                    <canvas id="statusDistributionChart"></canvas>
                    <div id="statusChartEmptyNotice" class="d-none position-absolute top-50 start-50 translate-middle text-center w-100 p-3">
                        <i class="bi bi-pie-chart text-muted fs-2 d-block mb-2"></i>
                        <div class="fw-semibold text-navy small">No Status Records</div>
                        <small class="text-muted" style="font-size: 0.78rem;">Status distribution updates upon reservation creation.</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- C. Operational Sections -->
        <div class="row g-4 mb-4">
            <!-- Upcoming Departures -->
            <div class="col-lg-7">
                <div class="admin-card h-100">
                    <div class="admin-card-header">
                        <h2 class="admin-card-title">
                            <i class="bi bi-clock-history text-primary"></i> Upcoming Departures
                        </h2>
                        <a href="${pageContext.request.contextPath}/admin/flights" class="btn btn-sm btn-link text-decoration-none">Manage All</a>
                    </div>
                    <div class="admin-table-wrap">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Flight</th>
                                    <th>Route</th>
                                    <th>Date & Time</th>
                                    <th>Available Seats</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty upcomingDepartures}">
                                        <c:forEach var="dep" items="${upcomingDepartures}">
                                            <tr>
                                                <td class="fw-bold text-navy">
                                                    <c:out value="${dep.airlineCode}" /> <c:out value="${dep.flightNumber}" />
                                                </td>
                                                <td>
                                                    <span class="badge bg-light text-dark border">
                                                        <c:out value="${dep.originCode}" /> → <c:out value="${dep.destCode}" />
                                                    </span>
                                                </td>
                                                <td>
                                                    <div class="fw-semibold"><fmt:formatDate value="${dep.flightDate}" pattern="dd MMM yyyy" /></div>
                                                    <small class="text-muted">${dep.departureTime}</small>
                                                </td>
                                                <td>
                                                    <span class="fw-semibold ${dep.availableSeats < 20 ? 'text-danger' : 'text-success'}">
                                                        ${dep.availableSeats} / ${dep.totalSeats}
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="badge-status badge-status-${dep.status.toLowerCase()}">
                                                        <c:out value="${dep.status}" />
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="5" class="text-center py-4 text-muted">
                                                No upcoming departures recorded in database.
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Seat Inventory Summary & Quick Actions -->
            <div class="col-lg-5">
                <div class="admin-card h-100">
                    <div class="admin-card-header">
                        <h2 class="admin-card-title">
                            <i class="bi bi-grid-fill text-primary"></i> Flight Inventory Overview
                        </h2>
                        <span class="badge bg-light text-muted border">Active Schedules</span>
                    </div>

                    <div class="p-3 bg-light rounded-3 mb-4 border">
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Total Seat Capacity:</span>
                            <span class="fw-bold text-navy">${inventorySummary.totalCapacity}</span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Available Open Seats:</span>
                            <span class="fw-bold text-success">${inventorySummary.availableSeats}</span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Occupied / Booked Seats:</span>
                            <span class="fw-bold text-primary">${inventorySummary.bookedSeats}</span>
                        </div>
                        <div class="progress mt-3" style="height: 10px;">
                            <c:set var="fillPct" value="${inventorySummary.totalCapacity > 0 ? (inventorySummary.bookedSeats * 100 / inventorySummary.totalCapacity) : 0}" />
                            <div class="progress-bar bg-primary" role="progressbar" style="width: ${fillPct}%;" aria-valuenow="${fillPct}" aria-valuemin="0" aria-valuemax="100"></div>
                        </div>
                        <div class="text-end mt-1">
                            <small class="text-muted"><fmt:formatNumber value="${fillPct}" maxFractionDigits="1" />% Load Factor</small>
                        </div>
                    </div>

                    <h6 class="fw-bold text-navy mb-3"><i class="bi bi-lightning-charge text-warning me-1"></i> Quick Operations</h6>
                    <div class="d-grid gap-2">
                        <a href="${pageContext.request.contextPath}/admin/flights" class="admin-btn admin-btn-outline justify-content-between">
                            <span><i class="bi bi-plus-circle me-2 text-primary"></i>Schedule New Flight</span>
                            <i class="bi bi-chevron-right text-muted"></i>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/bookings?status=PENDING_PAYMENT" class="admin-btn admin-btn-outline justify-content-between">
                            <span><i class="bi bi-exclamation-circle me-2 text-warning"></i>Review Pending Bookings</span>
                            <span class="badge bg-warning text-dark">${pendingBookings.size()}</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/reports" class="admin-btn admin-btn-outline justify-content-between">
                            <span><i class="bi bi-file-earmark-spreadsheet me-2 text-success"></i>Export Route & Revenue Reports</span>
                            <i class="bi bi-chevron-right text-muted"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- D. Recent Reservations & Recent Verified Payments -->
        <div class="row g-4">
            <!-- Recent Reservations -->
            <div class="col-lg-6">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h2 class="admin-card-title">
                            <i class="bi bi-journal-bookmark text-primary"></i> Recent Reservations
                        </h2>
                        <a href="${pageContext.request.contextPath}/admin/bookings" class="btn btn-sm btn-link text-decoration-none">View All</a>
                    </div>
                    <div class="admin-table-wrap">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Ref / PNR</th>
                                    <th>Flight</th>
                                    <th>Fare</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty recentReservations}">
                                        <c:forEach var="res" items="${recentReservations}">
                                            <tr>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/admin/bookings?action=view&bookingId=${res.id}" class="fw-bold text-decoration-none text-navy">
                                                        <c:out value="${not empty res.pnr ? res.pnr : res.bookingReference}" />
                                                    </a>
                                                    <div class="text-muted" style="font-size: 0.75rem;"><c:out value="${res.contactEmail}" /></div>
                                                </td>
                                                <td>
                                                    <span class="badge bg-light text-dark border">
                                                        <c:out value="${res.flightNumber}" /> (<c:out value="${res.originCode}" />-<c:out value="${res.destCode}" />)
                                                    </span>
                                                </td>
                                                <td class="fw-semibold">₹<fmt:formatNumber value="${res.totalAmount}" maxFractionDigits="0" /></td>
                                                <td>
                                                    <span class="badge-status badge-status-${res.status.toLowerCase()}">
                                                        <c:out value="${res.status}" />
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4" class="text-center py-4 text-muted">No reservations found.</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Recent Verified Payments -->
            <div class="col-lg-6">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h2 class="admin-card-title">
                            <i class="bi bi-shield-check text-success"></i> Recent Verified Payments
                        </h2>
                        <a href="${pageContext.request.contextPath}/admin/payments" class="btn btn-sm btn-link text-decoration-none">View All</a>
                    </div>
                    <div class="admin-table-wrap">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Payment Ref</th>
                                    <th>Booking Ref</th>
                                    <th>Amount</th>
                                    <th>Gateway ID</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty recentPayments}">
                                        <c:forEach var="pay" items="${recentPayments}">
                                            <tr>
                                                <td>
                                                    <span class="fw-bold text-navy"><c:out value="${pay.paymentReference}" /></span>
                                                    <div class="text-muted" style="font-size: 0.72rem;">
                                                        <fmt:formatDate value="${pay.paidAt}" pattern="dd MMM, HH:mm" />
                                                    </div>
                                                </td>
                                                <td>
                                                    <span class="badge bg-light text-dark border">
                                                        <c:out value="${not empty pay.pnr ? pay.pnr : pay.bookingReference}" />
                                                    </span>
                                                </td>
                                                <td class="fw-bold text-success">₹<fmt:formatNumber value="${pay.amount}" maxFractionDigits="0" /></td>
                                                <td>
                                                    <code class="text-muted" style="font-size: 0.75rem;"><c:out value="${not empty pay.razorpayPaymentId ? pay.razorpayPaymentId : 'DIRECT_VERIFIED'}" /></code>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4" class="text-center py-4 text-muted">No verified payments found.</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    </main>
</div>

<!-- Chart initialization script with real database values -->
<script>
document.addEventListener("DOMContentLoaded", function() {
    // 1. Bookings Trend Chart
    const bookingDates = [];
    const bookingCounts = [];
    <c:forEach var="b" items="${chartBookings7Days}">
        bookingDates.push("${b.date}");
        bookingCounts.push(${b.count});
    </c:forEach>

    const ctxTrend = document.getElementById('bookingsTrendChart');
    const trendEmptyNotice = document.getElementById('trendChartEmptyNotice');
    const trendBadge = document.getElementById('bookingsTrendBadge');

    if (bookingDates.length === 0) {
        if (ctxTrend) ctxTrend.classList.add('d-none');
        if (trendEmptyNotice) trendEmptyNotice.classList.remove('d-none');
        if (trendBadge) {
            trendBadge.textContent = 'No Recent Activity';
            trendBadge.className = 'badge bg-light text-muted border';
        }
    } else if (ctxTrend) {
        if (bookingDates.length === 1 && trendBadge) {
            trendBadge.textContent = '1 Active Date';
            trendBadge.className = 'badge bg-info-subtle text-primary border';
        }

        new Chart(ctxTrend, {
            type: 'line',
            data: {
                labels: bookingDates,
                datasets: [{
                    label: 'Reservations Made',
                    data: bookingCounts,
                    borderColor: '#168BFF',
                    backgroundColor: 'rgba(22, 139, 255, 0.08)',
                    fill: true,
                    tension: 0.35,
                    borderWidth: 2.5,
                    pointBackgroundColor: '#168BFF',
                    pointBorderColor: '#FFFFFF',
                    pointBorderWidth: 2,
                    pointRadius: bookingDates.length === 1 ? 7 : 4,
                    pointHoverRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return context.parsed.y + ' reservations';
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { precision: 0 }
                    }
                }
            }
        });
    }

    // 2. Status Distribution Chart
    const statusLabels = [];
    const statusCounts = [];
    const statusColors = [];

    <c:forEach var="entry" items="${chartStatusDistribution}">
        statusLabels.push("${entry.key}");
        statusCounts.push(${entry.value});
        if ("${entry.key}" === "CONFIRMED") statusColors.push("#18A878");
        else if ("${entry.key}" === "PENDING_PAYMENT" || "${entry.key}" === "PENDING") statusColors.push("#F59E0B");
        else if ("${entry.key}" === "CANCELLED") statusColors.push("#E5484D");
        else statusColors.push("#64748B");
    </c:forEach>

    const ctxStatus = document.getElementById('statusDistributionChart');
    const statusEmptyNotice = document.getElementById('statusChartEmptyNotice');

    if (statusLabels.length === 0) {
        if (ctxStatus) ctxStatus.classList.add('d-none');
        if (statusEmptyNotice) statusEmptyNotice.classList.remove('d-none');
    } else if (ctxStatus) {
        new Chart(ctxStatus, {
            type: 'doughnut',
            data: {
                labels: statusLabels,
                datasets: [{
                    data: statusCounts,
                    backgroundColor: statusColors.length ? statusColors : ['#E2E8F0'],
                    borderWidth: 2,
                    borderColor: '#FFFFFF'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { boxWidth: 12, font: { size: 11 } }
                    }
                },
                cutout: '68%'
            }
        });
    }
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
