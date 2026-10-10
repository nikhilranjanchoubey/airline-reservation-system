<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Admin Dashboard - SkyTech Airlines" />
<c:set var="activePage" value="admin" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<!-- 1. Cinematic Admin Hero Banner -->
<section class="admin-hero-banner">
    <div class="admin-hero-overlay"></div>
    <div class="container admin-hero-content">
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
            <div>
                <nav class="admin-breadcrumb" aria-label="breadcrumb">
                    <a href="${pageContext.request.contextPath}/">Home</a>
                    <i class="bi bi-chevron-right"></i>
                    <span>Management Console</span>
                    <i class="bi bi-chevron-right"></i>
                    <span class="text-white fw-semibold">Dashboard</span>
                </nav>
                <h1 class="admin-hero-title">
                    <i class="bi bi-shield-lock-fill text-warning me-2"></i>Administrator Console
                </h1>
                <p class="admin-hero-desc mb-0">
                    Real-time passenger registry, security metrics, and access governance across SkyTech flight networks.
                </p>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/profile" class="btn-admin-profile-link">
                    <i class="bi bi-person-badge-fill me-2"></i>My Admin Profile
                </a>
            </div>
        </div>
    </div>
</section>

<!-- 2. Main Admin Dashboard Section -->
<main class="container admin-content-wrap py-4">
    <!-- Server Alerts -->
    <c:if test="${not empty flashSuccess}">
        <div class="auth-alert auth-alert-success mb-4" role="alert">
            <i class="bi bi-check-circle-fill fs-5"></i>
            <div><c:out value="${flashSuccess}" /></div>
        </div>
    </c:if>

    <c:if test="${not empty sessionScope.flashError}">
        <div class="auth-alert auth-alert-warning mb-4" role="alert">
            <i class="bi bi-exclamation-octagon-fill fs-5"></i>
            <div><c:out value="${sessionScope.flashError}" /></div>
        </div>
        <c:remove var="flashError" scope="session" />
    </c:if>

    <!-- KPI Metric Cards Grid -->
    <div class="row g-4 mb-4">
        <div class="col-sm-6 col-lg-3">
            <div class="admin-stat-card">
                <div class="admin-stat-icon icon-blue">
                    <i class="bi bi-people-fill"></i>
                </div>
                <div class="admin-stat-info">
                    <span class="admin-stat-label">Total Registered</span>
                    <h3 class="admin-stat-value"><c:out value="${totalUsers}" /></h3>
                </div>
            </div>
        </div>

        <div class="col-sm-6 col-lg-3">
            <div class="admin-stat-card">
                <div class="admin-stat-icon icon-sky">
                    <i class="bi bi-airplane-engines-fill"></i>
                </div>
                <div class="admin-stat-info">
                    <span class="admin-stat-label">Active Passengers</span>
                    <h3 class="admin-stat-value"><c:out value="${passengerCount}" /></h3>
                </div>
            </div>
        </div>

        <div class="col-sm-6 col-lg-3">
            <div class="admin-stat-card">
                <div class="admin-stat-icon icon-warning">
                    <i class="bi bi-shield-lock-fill"></i>
                </div>
                <div class="admin-stat-info">
                    <span class="admin-stat-label">System Admins</span>
                    <h3 class="admin-stat-value"><c:out value="${adminCount}" /></h3>
                </div>
            </div>
        </div>

        <div class="col-sm-6 col-lg-3">
            <div class="admin-stat-card">
                <div class="admin-stat-icon icon-success">
                    <i class="bi bi-check-circle-fill"></i>
                </div>
                <div class="admin-stat-info">
                    <span class="admin-stat-label">Active Accounts</span>
                    <h3 class="admin-stat-value"><c:out value="${activeCount}" /></h3>
                </div>
            </div>
        </div>
    </div>

    <!-- Live User Registry Table Card -->
    <div class="admin-table-card">
        <div class="admin-card-header">
            <div class="d-flex align-items-center gap-2">
                <div class="admin-header-icon">
                    <i class="bi bi-table"></i>
                </div>
                <div>
                    <h3 class="admin-card-title">User Accounts Registry</h3>
                    <p class="admin-card-sub">Central database of registered passengers and administrators</p>
                </div>
            </div>
            <span class="admin-live-badge">
                <span class="live-dot"></span> Live Database
            </span>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 admin-registry-table">
                <thead>
                    <tr>
                        <th class="ps-4">ID</th>
                        <th>User Name</th>
                        <th>Email Address</th>
                        <th>Phone Number</th>
                        <th>Account Role</th>
                        <th>Status</th>
                        <th>Registered Date</th>
                        <th class="text-end pe-4">Action Governance</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="u" items="${users}">
                        <tr>
                            <td class="ps-4">
                                <span class="user-id-badge">#<c:out value="${u.userId}" /></span>
                            </td>
                            <td>
                                <div class="user-name-text"><c:out value="${u.fullName}" /></div>
                                <c:if test="${not empty u.passportNumber}">
                                    <div class="user-passport-sub"><i class="bi bi-credit-card-2-front me-1"></i><c:out value="${u.passportNumber}" /></div>
                                </c:if>
                            </td>
                            <td>
                                <div class="user-email-text"><c:out value="${u.email}" /></div>
                                <c:if test="${not empty u.googleId}">
                                    <span class="google-linked-tag" title="Linked via Google Sign-In">
                                        <i class="bi bi-google me-1"></i>Google Linked
                                    </span>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty u.phone}">
                                        <c:out value="${u.phone}" />
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted fst-italic">Not provided</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.role == 'ADMIN'}">
                                        <span class="badge-role-admin"><i class="bi bi-shield-lock me-1"></i>ADMIN</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-role-passenger"><i class="bi bi-airplane me-1"></i>PASSENGER</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.status == 'ACTIVE'}">
                                        <span class="badge-status-active"><i class="bi bi-check2-circle me-1"></i>ACTIVE</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-status-suspended"><i class="bi bi-slash-circle me-1"></i>SUSPENDED</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="small text-muted">
                                <c:out value="${u.createdAt != null ? u.createdAt : 'N/A'}" />
                            </td>
                            <td class="text-end pe-4">
                                <form action="${pageContext.request.contextPath}/admin/dashboard" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="toggle_status">
                                    <input type="hidden" name="userId" value="${u.userId}">
                                    <c:choose>
                                        <c:when test="${u.status == 'ACTIVE'}">
                                            <button type="submit" class="btn-action-suspend" title="Suspend Account Access"
                                                    <c:if test="${sessionScope.currentUser.userId == u.userId}">disabled</c:if>>
                                                <i class="bi bi-slash-circle me-1"></i> Suspend
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="submit" class="btn-action-activate" title="Reactivate Account Access">
                                                <i class="bi bi-check-circle me-1"></i> Activate
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
