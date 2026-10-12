<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Payment Transactions & Gateway Audits | SkyTech Administration" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <c:set var="activeTab" value="payments" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">Payment Transactions & Gateway Audits</h1>
                <div class="admin-header-meta">
                    <span>Inspect gateway order identifiers, cryptographic payment signatures, settlement statuses, and refund records</span>
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

        <!-- Search & Filter Bar -->
        <form method="GET" action="${pageContext.request.contextPath}/admin/payments" class="admin-filter-bar">
            <input type="text" name="search" class="admin-form-control flex-grow-1" placeholder="Search by Razorpay Payment ID, Order ID, or Booking Reference..." value="<c:out value='${search}' />">
            <select name="status" class="admin-form-control">
                <option value="ALL">All Payment Statuses</option>
                <option value="SUCCESS" ${status == 'SUCCESS' ? 'selected' : ''}>Success / Verified</option>
                <option value="PENDING" ${status == 'PENDING' ? 'selected' : ''}>Pending Verification</option>
                <option value="FAILED" ${status == 'FAILED' ? 'selected' : ''}>Failed</option>
            </select>
            <input type="date" name="fromDate" class="admin-form-control" value="<c:out value='${fromDate}' />" title="From Date">
            <input type="date" name="toDate" class="admin-form-control" value="<c:out value='${toDate}' />" title="To Date">
            <button type="submit" class="admin-btn admin-btn-secondary">
                <i class="bi bi-funnel"></i> Filter
            </button>
            <a href="${pageContext.request.contextPath}/admin/payments" class="admin-btn admin-btn-outline">Reset</a>
        </form>

        <!-- Payments Table -->
        <div class="admin-card">
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Txn ID</th>
                            <th>Booking Ref / PNR</th>
                            <th>Contact Email</th>
                            <th>Amount (INR)</th>
                            <th>Gateway Order ID</th>
                            <th>Gateway Payment ID</th>
                            <th>Method</th>
                            <th>Status</th>
                            <th>Settled At</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty payments}">
                                <c:forEach var="p" items="${payments}">
                                    <tr>
                                        <td class="fw-bold text-navy">
                                            #${p.id}
                                            <div class="text-muted" style="font-size: 0.72rem;"><c:out value="${p.paymentReference}" /></div>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/admin/bookings?action=view&bookingId=${p.bookingId}" class="fw-semibold text-decoration-none">
                                                <c:out value="${not empty p.pnr ? p.pnr : p.bookingReference}" />
                                            </a>
                                            <div class="text-muted" style="font-size: 0.72rem;"><c:out value="${p.flightNumber}" /></div>
                                        </td>
                                        <td><c:out value="${p.contactEmail}" /></td>
                                        <td class="fw-bold text-navy">
                                            ₹<fmt:formatNumber value="${p.amount}" maxFractionDigits="2" />
                                        </td>
                                        <td>
                                            <code class="text-muted" style="font-size: 0.75rem;"><c:out value="${not empty p.razorpayOrderId ? p.razorpayOrderId : 'DIRECT_ORDER'}" /></code>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty p.razorpayPaymentId}">
                                                    <code class="text-dark fw-bold" style="font-size: 0.78rem;"><c:out value="${p.razorpayPaymentId}" /></code>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted" style="font-size: 0.75rem;">Awaiting Callback</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><small class="badge bg-light text-dark border"><c:out value="${p.paymentMethod}" /></small></td>
                                        <td>
                                            <span class="badge-status badge-status-${p.status.toLowerCase()}">
                                                <c:out value="${p.status}" />
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty p.paidAt}">
                                                    <div class="fw-semibold"><fmt:formatDate value="${p.paidAt}" pattern="dd MMM yyyy" /></div>
                                                    <small class="text-muted"><fmt:formatDate value="${p.paidAt}" pattern="HH:mm:ss" /></small>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="9">
                                        <div class="admin-empty-state">
                                            <i class="bi bi-credit-card admin-empty-icon"></i>
                                            <div class="admin-empty-title">No Transactions Recorded</div>
                                            <div class="admin-empty-desc">No payment transaction records match your query.</div>
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
                    <span>Showing page ${currentPage} of ${totalPages} (${totalCount} total transactions)</span>
                    <div class="admin-page-links">
                        <c:forEach var="p" begin="1" end="${totalPages}">
                            <a href="${pageContext.request.contextPath}/admin/payments?page=${p}&search=${search}&status=${status}&fromDate=${fromDate}&toDate=${toDate}"
                               class="admin-page-btn ${currentPage == p ? 'active' : ''}">${p}</a>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
        </div>
    </main>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
