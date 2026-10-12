<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Cancellation & Refund Governance | SkyTech Administration" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <c:set var="activeTab" value="cancellations" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">Cancellation & Refund Governance</h1>
                <div class="admin-header-meta">
                    <span>Audit cancellations, calculate refund entitlements, and execute safe transactional seat releases</span>
                </div>
            </div>
            <button type="button" class="admin-btn admin-btn-danger" data-bs-toggle="modal" data-bs-target="#adminCancelModal">
                <i class="bi bi-x-circle"></i> Cancel Booking
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
        <form method="GET" action="${pageContext.request.contextPath}/admin/cancellations" class="admin-filter-bar">
            <input type="text" name="search" class="admin-form-control flex-grow-1" placeholder="Search by PNR, Reference, Flight, or Refund Ref..." value="<c:out value='${search}' />">
            <select name="refundStatus" class="admin-form-control">
                <option value="ALL">All Refund States</option>
                <option value="PROCESSED_RAZORPAY_TEST_REFUND" ${refundStatus == 'PROCESSED_RAZORPAY_TEST_REFUND' ? 'selected' : ''}>Processed (Gateway)</option>
                <option value="RECORDED_ACADEMIC_REFUND" ${refundStatus == 'RECORDED_ACADEMIC_REFUND' ? 'selected' : ''}>Recorded (Academic)</option>
                <option value="REFUND_PENDING" ${refundStatus == 'REFUND_PENDING' ? 'selected' : ''}>Refund Pending</option>
            </select>
            <input type="date" name="fromDate" class="admin-form-control" value="<c:out value='${fromDate}' />" title="From Cancellation Date">
            <input type="date" name="toDate" class="admin-form-control" value="<c:out value='${toDate}' />" title="To Cancellation Date">
            <button type="submit" class="admin-btn admin-btn-secondary">
                <i class="bi bi-funnel"></i> Filter
            </button>
            <a href="${pageContext.request.contextPath}/admin/cancellations" class="admin-btn admin-btn-outline">Reset</a>
        </form>

        <!-- Cancellations Table -->
        <div class="admin-card">
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Cancellation ID</th>
                            <th>Booking Ref / PNR</th>
                            <th>Flight</th>
                            <th>Original Fare</th>
                            <th>Fee</th>
                            <th>Refund Amount</th>
                            <th>Refund Status & Ref</th>
                            <th>Reason</th>
                            <th>Cancelled At</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty cancellations}">
                                <c:forEach var="c" items="${cancellations}">
                                    <tr>
                                        <td class="fw-bold text-navy">#${c.cancellationId}</td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/admin/bookings?action=view&bookingId=${c.bookingId}" class="fw-bold text-navy text-decoration-none">
                                                <c:out value="${not empty c.pnr ? c.pnr : c.bookingReference}" />
                                            </a>
                                            <div class="text-muted" style="font-size: 0.72rem;"><c:out value="${c.contactEmail}" /></div>
                                        </td>
                                        <td>
                                            <div class="fw-semibold"><c:out value="${c.flightNumber}" /></div>
                                            <small class="text-muted"><c:out value="${c.originCode}" /> → <c:out value="${c.destCode}" /></small>
                                        </td>
                                        <td class="fw-semibold text-muted">
                                            ₹<fmt:formatNumber value="${c.totalAmount}" maxFractionDigits="0" />
                                        </td>
                                        <td class="text-danger fw-semibold">
                                            -₹<fmt:formatNumber value="${c.cancellationFee}" maxFractionDigits="0" />
                                        </td>
                                        <td class="fw-bold text-success">
                                            ₹<fmt:formatNumber value="${c.refundAmount}" maxFractionDigits="0" />
                                        </td>
                                        <td>
                                            <span class="badge-status badge-status-${c.refundStatus.contains('RECORDED') || c.refundStatus.contains('PROCESSED') ? 'success' : 'pending'}">
                                                <c:out value="${c.refundStatus}" />
                                            </span>
                                            <div class="text-muted font-monospace" style="font-size: 0.72rem;"><c:out value="${c.refundReference}" /></div>
                                        </td>
                                        <td>
                                            <small class="text-navy"><c:out value="${c.cancellationReason}" /></small>
                                        </td>
                                        <td>
                                            <div class="fw-semibold"><fmt:formatDate value="${c.cancelledAt}" pattern="dd MMM yyyy" /></div>
                                            <small class="text-muted"><fmt:formatDate value="${c.cancelledAt}" pattern="HH:mm" /></small>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="9">
                                        <div class="admin-empty-state">
                                            <i class="bi bi-x-octagon admin-empty-icon"></i>
                                            <div class="admin-empty-title">No Cancellations Recorded</div>
                                            <div class="admin-empty-desc">No reservation cancellations found matching the filters.</div>
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
                    <span>Showing page ${currentPage} of ${totalPages} (${totalCount} total cancellations)</span>
                    <div class="admin-page-links">
                        <c:forEach var="p" begin="1" end="${totalPages}">
                            <a href="${pageContext.request.contextPath}/admin/cancellations?page=${p}&search=${search}&refundStatus=${refundStatus}&fromDate=${fromDate}&toDate=${toDate}"
                               class="admin-page-btn ${currentPage == p ? 'active' : ''}">${p}</a>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
        </div>
    </main>
</div>

<!-- Modal: Execute Administrative Cancellation -->
<div class="modal fade" id="adminCancelModal" tabindex="-1" aria-labelledby="adminCancelModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST" action="${pageContext.request.contextPath}/admin/cancellations">
                <input type="hidden" name="action" value="cancel_booking">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold text-danger" id="adminCancelModalLabel">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i> Cancel Flight Booking
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="alert alert-warning small">
                        <i class="bi bi-shield-exclamation me-1"></i>
                        Cancelling a confirmed booking will atomically mark tickets as cancelled, calculate refund entitlements, and restore occupied seats back to open flight inventory.
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Internal Booking ID <span class="text-danger">*</span></label>
                        <input type="number" name="bookingId" class="form-control" placeholder="e.g. 101" required>
                        <small class="text-muted">Enter the numeric ID from the Bookings Registry.</small>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Official Cancellation Reason <span class="text-danger">*</span></label>
                        <textarea name="reason" rows="3" class="form-control" placeholder="e.g. Operational schedule adjustment / passenger emergency request" required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="admin-btn admin-btn-danger">Confirm & Release Seats</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
