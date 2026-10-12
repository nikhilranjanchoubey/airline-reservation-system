<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Operational Notifications | SkyTech Administration" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <c:set var="activeTab" value="notifications" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">Operational Notifications & Alerts</h1>
                <div class="admin-header-meta">
                    <span>Pending booking queues requiring settlement, payment verification notices, and cancellation records</span>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Pending Bookings Alert Queue -->
            <div class="col-lg-6">
                <div class="admin-card h-100">
                    <div class="admin-card-header">
                        <h2 class="admin-card-title text-navy">
                            <i class="bi bi-hourglass-split text-warning"></i> Pending Settlement Queue
                        </h2>
                        <span class="badge bg-warning text-dark">${pendingBookings.size()} Pending</span>
                    </div>

                    <c:choose>
                        <c:when test="${not empty pendingBookings}">
                            <div class="d-flex flex-column gap-3">
                                <c:forEach var="pb" items="${pendingBookings}">
                                    <div class="admin-notification-item">
                                        <div style="min-width: 0; flex: 1 1 180px;">
                                            <div class="fw-bold text-navy text-truncate">
                                                <c:out value="${pb.bookingReference}" /> — <c:out value="${pb.flightNumber}" />
                                            </div>
                                            <small class="text-muted d-block text-truncate">
                                                <c:out value="${pb.contactEmail}" /> | Created <fmt:formatDate value="${pb.createdAt}" pattern="dd MMM, HH:mm" />
                                            </small>
                                        </div>
                                        <div class="text-end d-flex flex-column align-items-end gap-1 flex-shrink-0">
                                            <div class="fw-bold text-navy">₹<fmt:formatNumber value="${pb.totalAmount}" maxFractionDigits="0" /></div>
                                            <a href="${pageContext.request.contextPath}/admin/bookings?action=view&bookingId=${pb.id}" class="btn btn-sm btn-outline-primary py-0 px-2" style="font-size: 0.75rem;">
                                                Inspect
                                            </a>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state">
                                <i class="bi bi-check-circle-fill text-success admin-empty-icon"></i>
                                <div class="admin-empty-title">Queue Clear</div>
                                <div class="admin-empty-desc">No bookings currently pending settlement.</div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Recent Cancellations Queue -->
            <div class="col-lg-6">
                <div class="admin-card h-100">
                    <div class="admin-card-header">
                        <h2 class="admin-card-title text-navy">
                            <i class="bi bi-x-circle text-danger"></i> Recent Cancellation Alerts
                        </h2>
                        <span class="badge bg-light text-danger border">${recentCancellations.size()} Processed</span>
                    </div>

                    <c:choose>
                        <c:when test="${not empty recentCancellations}">
                            <div class="d-flex flex-column gap-3">
                                <c:forEach var="rc" items="${recentCancellations}">
                                    <div class="admin-notification-item">
                                        <div style="min-width: 0; flex: 1 1 180px;">
                                            <div class="fw-bold text-navy text-truncate">
                                                <c:out value="${rc.pnr}" /> — <c:out value="${rc.flightNumber}" />
                                            </div>
                                            <small class="text-muted d-block text-truncate"><c:out value="${rc.cancellationReason}" /></small>
                                        </div>
                                        <div class="text-end d-flex flex-column align-items-end gap-1 flex-shrink-0">
                                            <span class="badge-status badge-status-${rc.refundStatus.contains('PROCESSED') || rc.refundStatus.contains('RECORDED') ? 'success' : 'pending'}">
                                                <c:out value="${rc.refundStatus}" />
                                            </span>
                                            <div class="small text-muted"><fmt:formatDate value="${rc.cancelledAt}" pattern="dd MMM, HH:mm" /></div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state">
                                <i class="bi bi-shield-check text-success admin-empty-icon"></i>
                                <div class="admin-empty-title">No Recent Cancellations</div>
                                <div class="admin-empty-desc">No cancellations logged in this period.</div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
