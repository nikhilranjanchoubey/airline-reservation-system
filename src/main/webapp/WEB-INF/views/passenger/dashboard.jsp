<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="My Trips - SkyTech" />
    <jsp:param name="activePage" value="manage" />
</jsp:include>
<jsp:include page="../common/navbar.jsp" />


<main class="container py-4 py-lg-5" style="max-width: 1140px;">
    <!-- Welcome Header Banner -->
    <div class="card sky-card border-0 rounded-4 shadow-sm p-4 mb-4 bg-white">
        <div class="d-flex flex-wrap align-items-center justify-content-between gap-3">
            <div class="d-flex align-items-center gap-3">
                <div class="rounded-circle bg-primary-subtle text-primary p-3 d-flex align-items-center justify-content-center" style="width: 60px; height: 60px;">
                    <i class="bi bi-person-fill fs-2"></i>
                </div>
                <div>
                    <h3 class="fw-bold text-dark mb-1 font-heading">
                        Welcome back, <c:out value="${sessionScope.currentUser.firstName}" />!
                    </h3>
                    <p class="text-muted small mb-0">
                        Manage your flight reservations, download electronic tickets, and review travel itineraries.
                    </p>
                </div>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/search-flights" class="btn btn-primary rounded-pill px-4 shadow-sm fw-semibold">
                    <i class="bi bi-search me-1"></i> Book a New Flight
                </a>
            </div>
        </div>
    </div>

    <!-- Metrics Cards Row -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="card sky-card border-0 rounded-4 shadow-sm p-3 bg-white">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-muted small text-uppercase fw-bold">Total Reservations</span>
                        <h3 class="fw-bold text-dark mt-1 mb-0">${totalBookings}</h3>
                    </div>
                    <div class="p-3 bg-primary-subtle text-primary rounded-3">
                        <i class="bi bi-ticket-perforated-fill fs-4"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card sky-card border-0 rounded-4 shadow-sm p-3 bg-white">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-muted small text-uppercase fw-bold">Confirmed Trips</span>
                        <h3 class="fw-bold text-success mt-1 mb-0">${confirmedCount}</h3>
                    </div>
                    <div class="p-3 bg-success-subtle text-success rounded-3">
                        <i class="bi bi-check-circle-fill fs-4"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card sky-card border-0 rounded-4 shadow-sm p-3 bg-white">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-muted small text-uppercase fw-bold">Cancelled / Refunded</span>
                        <h3 class="fw-bold text-danger mt-1 mb-0">${cancelledCount}</h3>
                    </div>
                    <div class="p-3 bg-danger-subtle text-danger rounded-3">
                        <i class="bi bi-x-circle-fill fs-4"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Booking List Section -->
    <div class="card sky-card border-0 rounded-4 shadow-sm overflow-hidden mb-4">
        <div class="card-header bg-white py-3 px-4 border-bottom d-flex align-items-center justify-content-between">
            <h5 class="fw-bold text-dark mb-0 font-heading">
                <i class="bi bi-briefcase-fill text-primary me-2"></i>My Bookings &amp; Itineraries
            </h5>
            <span class="badge bg-light text-muted border">${bookings.size()} Records</span>
        </div>
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${empty bookings}">
                    <!-- Empty State -->
                    <div class="text-center py-5 px-3">
                        <div class="display-3 text-muted opacity-50 mb-3">
                            <i class="bi bi-airplane"></i>
                        </div>
                        <h5 class="fw-bold text-dark mb-2">No Bookings Found</h5>
                        <p class="text-muted small mb-4" style="max-width: 450px; margin: 0 auto;">
                            You haven't made any flight bookings yet. Search flights across our network to plan your upcoming journey.
                        </p>
                        <a href="${pageContext.request.contextPath}/search-flights" class="btn btn-primary rounded-pill px-4">
                            <i class="bi bi-search me-1"></i> Search Flights Now
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Bookings Table -->
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light small text-uppercase text-muted">
                                <tr>
                                    <th class="ps-4">PNR / Ref</th>
                                    <th>Flight</th>
                                    <th>Route</th>
                                    <th>Travel Date</th>
                                    <th>Status</th>
                                    <th>Amount</th>
                                    <th class="text-end pe-4">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="b" items="${bookings}">
                                    <tr>
                                        <td class="ps-4">
                                            <strong class="font-monospace text-primary fs-6">
                                                ${not empty b.pnr ? b.pnr : b.bookingReference}
                                            </strong>
                                            <div class="text-muted small" style="font-size: 0.75rem;">
                                                Booked: <fmt:formatDate value="${b.createdAt}" pattern="dd MMM yyyy" />
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge bg-light text-dark border font-monospace">
                                                ${b.flightNumber}
                                            </span>
                                            <div class="text-muted small">${b.travelClass}</div>
                                        </td>
                                        <td>
                                            <div class="fw-semibold text-dark">
                                                ${b.originCode} &rarr; ${b.destinationCode}
                                            </div>
                                            <div class="text-muted small">
                                                ${b.passengers.size()} Traveler(s)
                                            </div>
                                        </td>
                                        <td>
                                            <span class="fw-semibold text-dark">${b.departureDate}</span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${b.status == 'CONFIRMED'}">
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-1">
                                                        CONFIRMED
                                                    </span>
                                                </c:when>
                                                <c:when test="${b.status == 'CANCELLED'}">
                                                    <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill px-3 py-1">
                                                        CANCELLED
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle rounded-pill px-3 py-1">
                                                        ${b.status}
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <strong class="text-dark">&#8377;<fmt:formatNumber value="${b.totalAmount}" type="number" maxFractionDigits="2" /></strong>
                                        </td>
                                        <td class="text-end pe-4">
                                            <div class="d-flex justify-content-end gap-2">
                                                <c:if test="${b.status == 'CONFIRMED'}">
                                                    <a href="${pageContext.request.contextPath}/ticket/download?id=${b.id}"
                                                       class="btn btn-sm btn-outline-primary rounded-pill px-3" title="Download PDF E-Ticket">
                                                        <i class="bi bi-file-earmark-pdf me-1"></i> PDF
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/manage-booking?pnr=${b.pnr}"
                                                       class="btn btn-sm btn-light border rounded-pill px-3" title="View details and cancellation policy">
                                                        Manage
                                                    </a>
                                                </c:if>
                                                <c:if test="${b.status == 'PENDING' || b.status == 'PENDING_PAYMENT'}">
                                                    <a href="${pageContext.request.contextPath}/booking/checkout?bookingId=${b.id}"
                                                       class="btn btn-sm btn-warning rounded-pill px-3 fw-semibold">
                                                        Complete Payment
                                                    </a>
                                                </c:if>
                                                <c:if test="${b.status == 'CANCELLED'}">
                                                    <a href="${pageContext.request.contextPath}/manage-booking?pnr=${not empty b.pnr ? b.pnr : b.bookingReference}"
                                                       class="btn btn-sm btn-outline-secondary rounded-pill px-3">
                                                        View Refund
                                                    </a>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
