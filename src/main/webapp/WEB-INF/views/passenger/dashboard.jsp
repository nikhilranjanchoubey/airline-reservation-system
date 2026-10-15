<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="My Trips - SkyTech" />
    <jsp:param name="activePage" value="manage" />
</jsp:include>
<jsp:include page="../common/navbar.jsp" />

<main class="container py-4 py-lg-5 trips-dashboard-container">
    <!-- Personalized Welcome Card with Actual User Profile Photo / Initials Fallback -->
    <div class="trips-welcome-card">
        <div class="trips-welcome-inner">
            <div class="trips-user-identity">
                <div class="trips-avatar-circle" title="Passenger Avatar">
                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser.profilePhoto}">
                            <img src="${pageContext.request.contextPath}${sessionScope.currentUser.profilePhoto}"
                                 alt="<c:out value='${sessionScope.currentUser.firstName}' /> <c:out value='${sessionScope.currentUser.lastName}' />"
                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                            <span style="display: none;"><c:out value="${sessionScope.currentUser.initials}" /></span>
                        </c:when>
                        <c:otherwise>
                            <span><c:out value="${not empty sessionScope.currentUser.initials ? sessionScope.currentUser.initials : 'P'}" /></span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div>
                    <h1 class="trips-welcome-title">
                        Welcome back, <c:out value="${sessionScope.currentUser.firstName}" />!
                    </h1>
                    <p class="trips-welcome-subtitle">
                        Manage your bookings, tickets, and travel plans in one place.
                    </p>
                </div>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/search-flights" class="btn-book-new-flight">
                    <i class="bi bi-search"></i> Book a New Flight
                </a>
            </div>
        </div>
    </div>

    <!-- Reservation Statistics (Database Driven) -->
    <div class="row g-3 mb-4">
        <!-- Total Reservations (Blue) -->
        <div class="col-md-4">
            <div class="trips-stat-card">
                <div>
                    <div class="trips-stat-label">Total Reservations</div>
                    <div class="trips-stat-value value-total">${totalBookings}</div>
                </div>
                <div class="trips-stat-icon-wrap icon-wrap-total">
                    <i class="bi bi-ticket-perforated-fill"></i>
                </div>
            </div>
        </div>
        <!-- Confirmed Trips (Green) -->
        <div class="col-md-4">
            <div class="trips-stat-card">
                <div>
                    <div class="trips-stat-label">Confirmed Trips</div>
                    <div class="trips-stat-value value-confirmed">${confirmedCount}</div>
                </div>
                <div class="trips-stat-icon-wrap icon-wrap-confirmed">
                    <i class="bi bi-check-circle-fill"></i>
                </div>
            </div>
        </div>
        <!-- Cancelled / Refunded (Red) -->
        <div class="col-md-4">
            <div class="trips-stat-card">
                <div>
                    <div class="trips-stat-label">Cancelled / Refunded</div>
                    <div class="trips-stat-value value-cancelled">${cancelledCount}</div>
                </div>
                <div class="trips-stat-icon-wrap icon-wrap-cancelled">
                    <i class="bi bi-x-circle-fill"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- My Bookings & Itineraries Section -->
    <div class="trips-table-card">
        <div class="trips-table-card-header">
            <h2 class="trips-table-card-title">
                <i class="bi bi-briefcase-fill text-primary"></i> My Bookings &amp; Itineraries
            </h2>
            <span class="trips-count-badge" id="tripsRecordCountBadge">${bookings.size()} ${bookings.size() == 1 ? 'Record' : 'Records'}</span>
        </div>

        <c:choose>
            <c:when test="${empty bookings}">
                <!-- Empty State -->
                <div class="trips-empty-state">
                    <div class="trips-empty-icon">
                        <i class="bi bi-airplane"></i>
                    </div>
                    <div class="trips-empty-title">No Reservations Found</div>
                    <p class="trips-empty-desc">
                        You haven't made any flight bookings yet. Search flights across our network to plan your upcoming journey.
                    </p>
                    <a href="${pageContext.request.contextPath}/search-flights" class="btn-book-new-flight">
                        <i class="bi bi-search"></i> Search Flights Now
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <!-- Bookings Table Container -->
                <div class="trips-table-wrap">
                    <table class="trips-table" id="myTripsTable">
                        <thead>
                            <tr>
                                <th style="width: 170px;">PNR / Reference</th>
                                <th style="width: 130px;">Flight</th>
                                <th style="width: 170px;">Route</th>
                                <th style="width: 140px;">Travel Date</th>
                                <th style="width: 130px;">Status</th>
                                <th style="width: 130px;">Amount</th>
                                <th class="text-end pe-4" style="min-width: 170px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="tripsTableBody">
                            <c:forEach var="b" items="${bookings}" varStatus="status">
                                <tr class="trip-row" data-index="${status.index}">
                                    <td>
                                        <a href="${pageContext.request.contextPath}/manage-booking?pnr=${not empty b.pnr ? b.pnr : b.bookingReference}"
                                           class="trips-pnr-link"
                                           title="View Booking Itinerary #${b.id}">
                                            <c:out value="${not empty b.pnr ? b.pnr : b.bookingReference}" />
                                        </a>
                                        <div class="trips-booked-date">
                                            Booked: <fmt:formatDate value="${b.createdAt}" pattern="dd MMM yyyy" />
                                        </div>
                                    </td>
                                    <td>
                                        <span class="trips-flight-badge">
                                            <c:out value="${b.flightNumber}" />
                                        </span>
                                        <div class="trips-class-label"><c:out value="${b.travelClass}" /> Class</div>
                                    </td>
                                    <td>
                                        <div class="trips-route-text">
                                            <span><c:out value="${b.originCode}" /></span>
                                            <i class="bi bi-arrow-right text-muted" style="font-size: 0.8rem;"></i>
                                            <span><c:out value="${b.destinationCode}" /></span>
                                        </div>
                                        <div class="trips-pax-count">
                                            ${not empty b.passengers ? b.passengers.size() : 1} Traveler(s)
                                        </div>
                                    </td>
                                    <td>
                                        <span class="trips-travel-date">${b.departureDate}</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${b.status == 'CONFIRMED'}">
                                                <span class="trips-status-badge trips-status-confirmed">
                                                    <i class="bi bi-check-circle-fill"></i> Confirmed
                                                </span>
                                            </c:when>
                                            <c:when test="${b.status == 'CANCELLED' || b.status == 'REFUNDED'}">
                                                <span class="trips-status-badge trips-status-cancelled">
                                                    <i class="bi bi-x-circle-fill"></i> <c:out value="${b.status == 'REFUNDED' ? 'Refunded' : 'Cancelled'}" />
                                                </span>
                                            </c:when>
                                            <c:when test="${b.status == 'PENDING' || b.status == 'PENDING_PAYMENT'}">
                                                <span class="trips-status-badge trips-status-pending">
                                                    <i class="bi bi-clock-fill"></i> Pending
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="trips-status-badge trips-status-pending">
                                                    <c:out value="${b.status}" />
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="trips-fare-amount">
                                            ₹<fmt:formatNumber value="${b.totalAmount}" type="number" maxFractionDigits="2" />
                                        </span>
                                    </td>
                                    <td class="text-end pe-4">
                                        <div class="trips-actions-wrap">
                                            <c:if test="${b.status == 'CONFIRMED'}">
                                                <a href="${pageContext.request.contextPath}/ticket/download?id=${b.id}"
                                                   class="btn-trips-action btn-trips-pdf"
                                                   title="Download Official E-Ticket PDF">
                                                    <i class="bi bi-file-earmark-pdf"></i> PDF
                                                </a>
                                                <a href="${pageContext.request.contextPath}/manage-booking?pnr=${not empty b.pnr ? b.pnr : b.bookingReference}"
                                                   class="btn-trips-action btn-trips-manage"
                                                   title="Manage Flight / Cancel Reservation">
                                                    Manage
                                                </a>
                                            </c:if>
                                            <c:if test="${b.status == 'PENDING' || b.status == 'PENDING_PAYMENT'}">
                                                <a href="${pageContext.request.contextPath}/booking/checkout?bookingId=${b.id}"
                                                   class="btn-trips-action btn-trips-pay"
                                                   title="Complete Secured Online Payment">
                                                    <i class="bi bi-credit-card-2-front"></i> Pay Now
                                                </a>
                                            </c:if>
                                            <c:if test="${b.status == 'CANCELLED' || b.status == 'REFUNDED'}">
                                                <a href="${pageContext.request.contextPath}/manage-booking?pnr=${not empty b.pnr ? b.pnr : b.bookingReference}"
                                                   class="btn-trips-action btn-trips-refund"
                                                   title="Review Cancellation & Refund Receipt">
                                                    Details
                                                </a>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- Client-Side Pagination Bar (when > 5 bookings) -->
                <div class="trips-pagination-bar" id="tripsPaginationBar">
                    <div class="trips-pagination-info" id="tripsPaginationInfo">
                        Showing 1 to ${bookings.size()} of ${bookings.size()} records
                    </div>
                    <div class="trips-pagination-controls" id="tripsPaginationControls">
                        <!-- Rendered by JavaScript -->
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />

<script>
document.addEventListener('DOMContentLoaded', function () {
    const tableBody = document.getElementById('tripsTableBody');
    if (!tableBody) return;

    const rows = Array.from(tableBody.querySelectorAll('.trip-row'));
    const totalRecords = rows.length;
    const pageSize = 10;
    const paginationBar = document.getElementById('tripsPaginationBar');
    const paginationInfo = document.getElementById('tripsPaginationInfo');
    const paginationControls = document.getElementById('tripsPaginationControls');

    if (totalRecords <= pageSize) {
        if (paginationInfo) {
            paginationInfo.textContent = 'Showing ' + (totalRecords > 0 ? '1' : '0') + ' to ' + totalRecords + ' of ' + totalRecords + ' bookings';
        }
        if (paginationControls) {
            paginationControls.style.display = 'none';
        }
        return;
    }

    const totalPages = Math.ceil(totalRecords / pageSize);
    let currentPage = 1;

    function renderPage(page) {
        currentPage = page;
        const start = (page - 1) * pageSize;
        const end = Math.min(start + pageSize, totalRecords);

        rows.forEach((row, index) => {
            if (index >= start && index < end) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });

        if (paginationInfo) {
            paginationInfo.textContent = 'Showing ' + (start + 1) + ' to ' + end + ' of ' + totalRecords + ' bookings';
        }

        renderControls();
    }

    function renderControls() {
        if (!paginationControls) return;
        paginationControls.innerHTML = '';

        // Previous Button
        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'btn-page-step';
        prevBtn.innerHTML = '<i class="bi bi-chevron-left"></i>';
        prevBtn.disabled = (currentPage === 1);
        prevBtn.addEventListener('click', () => renderPage(currentPage - 1));
        paginationControls.appendChild(prevBtn);

        // Page Number Buttons
        for (let i = 1; i <= totalPages; i++) {
            const pageBtn = document.createElement('button');
            pageBtn.type = 'button';
            pageBtn.className = 'btn-page-step' + (i === currentPage ? ' active' : '');
            pageBtn.textContent = i;
            pageBtn.addEventListener('click', () => renderPage(i));
            paginationControls.appendChild(pageBtn);
        }

        // Next Button
        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'btn-page-step';
        nextBtn.innerHTML = '<i class="bi bi-chevron-right"></i>';
        nextBtn.disabled = (currentPage === totalPages);
        nextBtn.addEventListener('click', () => renderPage(currentPage + 1));
        paginationControls.appendChild(nextBtn);
    }

    renderPage(1);
});
</script>
