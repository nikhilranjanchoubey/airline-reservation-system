<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Operational Analytics & Reports | SkyTech Administration" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <c:set var="activeTab" value="reports" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">Operational Reports & Analytics</h1>
                <div class="admin-header-meta">
                    <span>Flight performance, route profitability, and verified revenue analytics from database</span>
                </div>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/admin/reports?format=csv&type=flights&fromDate=${fromDate}&toDate=${toDate}" class="admin-btn admin-btn-primary">
                    <i class="bi bi-download"></i> Export Flights CSV
                </a>
                <a href="${pageContext.request.contextPath}/admin/reports?format=csv&type=routes" class="admin-btn admin-btn-outline">
                    <i class="bi bi-file-earmark-spreadsheet"></i> Export Routes CSV
                </a>
                <a href="${pageContext.request.contextPath}/admin/reports?format=csv&type=revenue&fromDate=${fromDate}&toDate=${toDate}" class="admin-btn admin-btn-outline">
                    <i class="bi bi-currency-rupee"></i> Export Revenue CSV
                </a>
            </div>
        </div>

        <!-- Date Range Filter -->
        <form method="GET" action="${pageContext.request.contextPath}/admin/reports" class="admin-filter-bar">
            <span class="fw-semibold text-navy"><i class="bi bi-calendar3 me-1"></i> Reporting Period:</span>
            <input type="date" name="fromDate" class="admin-form-control" value="<c:out value='${fromDate}' />" title="From Date">
            <input type="date" name="toDate" class="admin-form-control" value="<c:out value='${toDate}' />" title="To Date">
            <button type="submit" class="admin-btn admin-btn-secondary">Apply Filter</button>
            <a href="${pageContext.request.contextPath}/admin/reports" class="admin-btn admin-btn-outline">Clear</a>
        </form>

        <!-- Route Popularity Report -->
        <div class="admin-card mb-4">
            <div class="admin-card-header">
                <h2 class="admin-card-title text-navy">
                    <i class="bi bi-signpost-split-fill text-primary"></i> Route Popularity & Revenue Yield
                </h2>
                <span class="badge bg-light text-muted border">Top Routes</span>
            </div>
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Origin Station</th>
                            <th>Destination Station</th>
                            <th>Total Reservations</th>
                            <th>Confirmed Bookings</th>
                            <th>Verified Revenue Volume</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty routePopularityReport}">
                                <c:forEach var="r" items="${routePopularityReport}">
                                    <tr>
                                        <td class="fw-bold text-navy">
                                            <span class="badge bg-primary text-white me-1">${r.originCode}</span> ${r.originCity}
                                        </td>
                                        <td class="fw-bold text-navy">
                                            <span class="badge bg-primary text-white me-1">${r.destCode}</span> ${r.destCity}
                                        </td>
                                        <td><span class="badge bg-light text-dark border">${r.totalBookings}</span></td>
                                        <td><span class="badge bg-success-subtle text-success border">${r.confirmedBookings}</span></td>
                                        <td class="fw-bold text-success">
                                            ₹<fmt:formatNumber value="${r.totalRevenue}" maxFractionDigits="0" />
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="5" class="text-center py-4 text-muted">No route booking data available.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Flight-Wise Performance Report -->
        <div class="admin-card">
            <div class="admin-card-header">
                <h2 class="admin-card-title text-navy">
                    <i class="bi bi-airplane-engines-fill text-primary"></i> Flight-Wise Operational Performance
                </h2>
                <span class="badge bg-light text-muted border">Database Records</span>
            </div>
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Flight No</th>
                            <th>Carrier</th>
                            <th>Sector</th>
                            <th>Total Bookings</th>
                            <th>Confirmed</th>
                            <th>Cancelled</th>
                            <th>Verified Revenue</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty flightWiseReport}">
                                <c:forEach var="f" items="${flightWiseReport}">
                                    <tr>
                                        <td class="fw-bold text-navy">${f.flightNumber}</td>
                                        <td>${f.airlineName}</td>
                                        <td><span class="badge bg-light text-dark border">${f.origin} → ${f.destination}</span></td>
                                        <td>${f.totalBookings}</td>
                                        <td><span class="badge-status badge-status-confirmed">${f.confirmedBookings}</span></td>
                                        <td><span class="badge-status badge-status-cancelled">${f.cancelledBookings}</span></td>
                                        <td class="fw-bold text-navy">
                                            ₹<fmt:formatNumber value="${f.totalRevenue}" maxFractionDigits="0" />
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-4 text-muted">No flight activity found in period.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
