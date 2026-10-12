<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Administrative Audit Trail | SkyTech Governance" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <c:set var="activeTab" value="audit" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">Administrative Audit Trail</h1>
                <div class="admin-header-meta">
                    <span>Immutable log of administrative operations, flight updates, passenger status changes, and cancellations</span>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/admin/audit" class="admin-btn admin-btn-outline">
                <i class="bi bi-arrow-clockwise"></i> Refresh Audit Log
            </a>
        </div>

        <div class="admin-card">
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Log ID</th>
                            <th>Timestamp</th>
                            <th>Administrator</th>
                            <th>Action</th>
                            <th>Target Entity</th>
                            <th>Record ID</th>
                            <th>Status</th>
                            <th>Summary & Details</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty auditLogs}">
                                <c:forEach var="log" items="${auditLogs}">
                                    <tr>
                                        <td>#${log.logId}</td>
                                        <td>
                                            <div class="fw-semibold"><fmt:formatDate value="${log.createdAt}" pattern="dd MMM yyyy" /></div>
                                            <small class="text-muted"><fmt:formatDate value="${log.createdAt}" pattern="HH:mm:ss" /></small>
                                        </td>
                                        <td class="fw-bold text-navy">
                                            <c:out value="${log.adminName}" />
                                            <div class="text-muted" style="font-size: 0.72rem;">User #${log.adminUserId}</div>
                                        </td>
                                        <td>
                                            <span class="badge bg-light text-navy border font-monospace"><c:out value="${log.action}" /></span>
                                        </td>
                                        <td><c:out value="${log.affectedRecordType}" /></td>
                                        <td><code><c:out value="${log.affectedRecordId}" /></code></td>
                                        <td>
                                            <span class="badge-status badge-status-${log.status.toLowerCase()}">
                                                <c:out value="${log.status}" />
                                            </span>
                                        </td>
                                        <td>
                                            <small class="text-muted"><c:out value="${log.details}" /></small>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8">
                                        <div class="admin-empty-state">
                                            <i class="bi bi-shield-check admin-empty-icon"></i>
                                            <div class="admin-empty-title">Audit Log Initialized</div>
                                            <div class="admin-empty-desc">New administrative actions will appear here in chronological order.</div>
                                        </div>
                                    </td>
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
