<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Reservations & Booking Registry | SkyTech Administration" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <c:set var="activeTab" value="bookings" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">Master Reservations Registry</h1>
                <div class="admin-header-meta">
                    <span>Central registry of passenger bookings, PNRs, ticket manifests, and payment statuses</span>
                </div>
            </div>
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
        <form method="GET" action="${pageContext.request.contextPath}/admin/bookings" class="admin-filter-bar">
            <input type="text" name="search" class="admin-form-control flex-grow-1" placeholder="Search by PNR, Booking Ref, or Passenger Email..." value="<c:out value='${search}' />">
            <select name="status" class="admin-form-control">
                <option value="ALL">All Booking Statuses</option>
                <option value="CONFIRMED" ${status == 'CONFIRMED' ? 'selected' : ''}>Confirmed</option>
                <option value="PENDING_PAYMENT" ${status == 'PENDING_PAYMENT' ? 'selected' : ''}>Pending Payment</option>
                <option value="CANCELLED" ${status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
            </select>
            <input type="text" name="flightNumber" class="admin-form-control text-uppercase" placeholder="Flight No (e.g. ST-101)" value="<c:out value='${flightNumber}' />" style="width: 150px;">
            <input type="date" name="fromDate" class="admin-form-control" value="<c:out value='${fromDate}' />" title="From Departure Date">
            <input type="date" name="toDate" class="admin-form-control" value="<c:out value='${toDate}' />" title="To Departure Date">
            <button type="submit" class="admin-btn admin-btn-secondary">
                <i class="bi bi-funnel"></i> Filter
            </button>
            <a href="${pageContext.request.contextPath}/admin/bookings" class="admin-btn admin-btn-outline">Reset</a>
        </form>

        <!-- Booking Manifest Inspection Card if viewing specific booking -->
        <c:if test="${not empty bookingDetails}">
            <div class="admin-card border-primary mb-4">
                <div class="admin-card-header bg-light">
                    <h2 class="admin-card-title text-navy">
                        <i class="bi bi-ticket-perforated-fill text-primary"></i> Booking Dossier: <c:out value="${not empty bookingDetails.pnr ? bookingDetails.pnr : bookingDetails.bookingReference}" />
                    </h2>
                    <div class="d-flex align-items-center gap-2">
                        <c:if test="${bookingDetails.status == 'CONFIRMED'}">
                            <a href="${pageContext.request.contextPath}/ticket?pnr=${not empty bookingDetails.pnr ? bookingDetails.pnr : bookingDetails.bookingReference}"
                               target="_blank" class="admin-btn admin-btn-primary btn-sm">
                                <i class="bi bi-printer"></i> View & Print E-Ticket
                            </a>
                        </c:if>
                        <a href="${pageContext.request.contextPath}/admin/bookings" class="btn btn-sm btn-outline-secondary">Close View</a>
                    </div>
                </div>

                <div class="row g-3 p-3">
                    <div class="col-md-3">
                        <div class="text-muted small">Booking Reference</div>
                        <div class="fw-bold"><c:out value="${bookingDetails.bookingReference}" /></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small">Issued PNR</div>
                        <div class="fw-bold text-primary"><c:out value="${not empty bookingDetails.pnr ? bookingDetails.pnr : 'PENDING'}" /></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small">Flight Number</div>
                        <div class="fw-semibold"><c:out value="${bookingDetails.flightNumber}" /></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small">Route & Travel Date</div>
                        <div class="fw-semibold">
                            <c:out value="${bookingDetails.originCode}" /> → <c:out value="${bookingDetails.destCode}" />
                            (<fmt:formatDate value="${bookingDetails.departureDate}" pattern="dd MMM yyyy" />)
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small">Contact Email</div>
                        <div><c:out value="${bookingDetails.contactEmail}" /></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small">Contact Phone</div>
                        <div><c:out value="${not empty bookingDetails.contactPhone ? bookingDetails.contactPhone : '—'}" /></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small">Cabin Class & Seats</div>
                        <div><c:out value="${bookingDetails.travelClass}" /> (<c:out value="${not empty bookingDetails.seatNumbers ? bookingDetails.seatNumbers : 'Assigned at check-in'}" />)</div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small">Total Fare & Status</div>
                        <div class="fw-bold text-navy">
                            ₹<fmt:formatNumber value="${bookingDetails.totalAmount}" maxFractionDigits="2" />
                            <span class="badge-status badge-status-${bookingDetails.status.toLowerCase()} ms-1"><c:out value="${bookingDetails.status}" /></span>
                        </div>
                    </div>
                </div>

                <!-- Passenger Manifest -->
                <div class="mt-4 border-top pt-3">
                    <h5 class="fs-6 fw-bold text-navy mb-3"><i class="bi bi-people me-1"></i> Passenger Manifest</h5>
                    <div class="admin-table-wrap">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Passenger Name</th>
                                    <th>Type</th>
                                    <th>Gender</th>
                                    <th>Seat</th>
                                    <th>Ticket Number</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${bookingDetails.passengers}" varStatus="status">
                                    <tr>
                                        <td>${status.count}</td>
                                        <td class="fw-bold text-navy"><c:out value="${p.firstName}" /> <c:out value="${p.lastName}" /></td>
                                        <td><span class="badge bg-light text-dark border"><c:out value="${p.passengerType}" /></span></td>
                                        <td><c:out value="${p.gender}" /></td>
                                        <td class="fw-semibold text-primary"><c:out value="${not empty p.seatNumber ? p.seatNumber : 'Auto'}" /></td>
                                        <td><code><c:out value="${not empty p.ticketNumber ? p.ticketNumber : 'CONFIRMED_ON_ISSUE'}" /></code></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Gateway Payment Record -->
                <c:if test="${not empty bookingDetails.payment}">
                    <div class="mt-4 border-top pt-3">
                        <h5 class="fs-6 fw-bold text-navy mb-3"><i class="bi bi-credit-card-2-front me-1"></i> Linked Payment Verification Record</h5>
                        <div class="p-3 bg-light rounded-3 border">
                            <div class="row g-2">
                                <div class="col-md-3">
                                    <div class="text-muted small">Payment Status:</div>
                                    <span class="badge-status badge-status-${bookingDetails.payment.status.toLowerCase()}"><c:out value="${bookingDetails.payment.status}" /></span>
                                </div>
                                <div class="col-md-3">
                                    <div class="text-muted small">Gateway Payment ID:</div>
                                    <code class="text-dark"><c:out value="${not empty bookingDetails.payment.razorpayPaymentId ? bookingDetails.payment.razorpayPaymentId : 'DIRECT_RECONCILED'}" /></code>
                                </div>
                                <div class="col-md-3">
                                    <div class="text-muted small">Gateway Order ID:</div>
                                    <code class="text-dark"><c:out value="${bookingDetails.payment.razorpayOrderId}" /></code>
                                </div>
                                <div class="col-md-3">
                                    <div class="text-muted small">Settlement Timestamp:</div>
                                    <div><fmt:formatDate value="${bookingDetails.payment.paidAt}" pattern="dd MMM yyyy, HH:mm" /></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:if>
            </div>
        </c:if>

        <!-- Bookings Registry Table -->
        <div class="admin-card">
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Ref / PNR</th>
                            <th>Passenger Contact</th>
                            <th>Flight</th>
                            <th>Route</th>
                            <th>Travel Date</th>
                            <th class="th-pax">Pax</th>
                            <th>Class</th>
                            <th>Total Fare</th>
                            <th>Booking Status</th>
                            <th>Payment Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty bookings}">
                                <c:forEach var="b" items="${bookings}">
                                    <tr>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/admin/bookings?action=view&bookingId=${b.id}" class="fw-bold text-decoration-none text-navy">
                                                <c:out value="${not empty b.pnr ? b.pnr : b.bookingReference}" />
                                            </a>
                                            <div class="text-muted" style="font-size: 0.72rem;">#${b.id}</div>
                                        </td>
                                        <td>
                                            <div class="fw-semibold text-navy"><c:out value="${b.passengerName}" /></div>
                                            <small class="text-muted"><c:out value="${b.contactEmail}" /></small>
                                        </td>
                                        <td class="fw-semibold"><c:out value="${b.flightNumber}" /></td>
                                        <td>
                                            <span class="badge bg-light text-dark border">
                                                <c:out value="${b.originCode}" /> → <c:out value="${b.destCode}" />
                                            </span>
                                        </td>
                                        <td><fmt:formatDate value="${b.departureDate}" pattern="dd MMM yyyy" /></td>
                                        <td class="td-pax">
                                            <span class="admin-pax-badge" title="${not empty b.passengerCount && b.passengerCount > 0 ? b.passengerCount : 1} Passenger(s)">
                                                <c:out value="${not empty b.passengerCount && b.passengerCount > 0 ? b.passengerCount : 1}" />
                                            </span>
                                        </td>
                                        <td><small class="text-muted"><c:out value="${b.travelClass}" /></small></td>
                                        <td class="fw-bold text-navy">₹<fmt:formatNumber value="${b.totalAmount}" maxFractionDigits="0" /></td>
                                        <td>
                                            <span class="badge-status badge-status-${b.status.toLowerCase()}">
                                                <c:out value="${b.status}" />
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge-status badge-status-${not empty b.paymentStatus ? b.paymentStatus.toLowerCase() : 'pending'}">
                                                <c:out value="${not empty b.paymentStatus ? b.paymentStatus : 'PENDING'}" />
                                            </span>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-1">
                                                <a href="${pageContext.request.contextPath}/admin/bookings?action=view&bookingId=${b.id}"
                                                   class="btn btn-sm btn-outline-primary py-0 px-2" style="font-size: 0.78rem;" title="View Booking Details">
                                                    <i class="bi bi-eye"></i> View
                                                </a>
                                                <c:if test="${b.status == 'CONFIRMED'}">
                                                    <a href="${pageContext.request.contextPath}/ticket?pnr=${not empty b.pnr ? b.pnr : b.bookingReference}"
                                                       target="_blank" class="btn btn-sm btn-outline-success py-0 px-2" style="font-size: 0.78rem;" title="Download E-Ticket">
                                                        <i class="bi bi-printer"></i> Ticket
                                                    </a>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="11">
                                        <div class="admin-empty-state">
                                            <i class="bi bi-journal-x admin-empty-icon"></i>
                                            <div class="admin-empty-title">No Reservations Found</div>
                                            <div class="admin-empty-desc">No bookings matched the search and filter criteria.</div>
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
                    <span>Showing page ${currentPage} of ${totalPages} (${totalCount} total bookings)</span>
                    <div class="admin-page-links">
                        <c:forEach var="p" begin="1" end="${totalPages}">
                            <a href="${pageContext.request.contextPath}/admin/bookings?page=${p}&search=${search}&status=${status}&flightNumber=${flightNumber}&fromDate=${fromDate}&toDate=${toDate}"
                               class="admin-page-btn ${currentPage == p ? 'active' : ''}">${p}</a>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
        </div>
    </main>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
