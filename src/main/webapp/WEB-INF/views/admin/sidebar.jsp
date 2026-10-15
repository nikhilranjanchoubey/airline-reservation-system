<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="reqUri" value="${pageContext.request.requestURI}" />
<c:set var="act" value="${requestScope.activeTab}" />

<aside class="admin-sidebar" id="adminSidebar">
    <div class="admin-sidebar-header d-flex align-items-center justify-content-between">
        <div>
            <div class="text-uppercase fw-bold" style="font-size: 0.72rem; letter-spacing: 0.1em; color: var(--sky-cyan);">
                Flight Ops Control
            </div>
            <div class="fw-bold text-white fs-6">
                SkyTech Console
            </div>
        </div>
        <div class="d-flex align-items-center gap-2">
            <span class="badge bg-primary rounded-pill px-2 py-1" style="font-size: 0.65rem;">ADMIN</span>
            <button type="button" class="btn btn-sm btn-link text-white-50 d-lg-none p-0 border-0 ms-1" id="adminSidebarClose" aria-label="Close Admin Sidebar">
                <i class="bi bi-x-lg fs-5"></i>
            </button>
        </div>
    </div>

    <ul class="admin-sidebar-nav">
        <li class="admin-nav-item">
            <a class="admin-nav-link ${(reqUri.endsWith('/admin') || reqUri.endsWith('/dashboard') || act == 'overview') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/dashboard">
                <i class="bi bi-speedometer2"></i>
                <span>Overview</span>
            </a>
        </li>
        <li class="admin-nav-item">
            <a class="admin-nav-link ${(reqUri.contains('/admin/flights') || act == 'flights') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/flights">
                <i class="bi bi-airplane-fill"></i>
                <span>Flight Management</span>
            </a>
        </li>
        <li class="admin-nav-item">
            <a class="admin-nav-link ${(reqUri.contains('/admin/airports') || act == 'airports') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/airports">
                <i class="bi bi-geo-alt-fill"></i>
                <span>Airport Management</span>
            </a>
        </li>
        <li class="admin-nav-item">
            <a class="admin-nav-link ${(reqUri.contains('/admin/airlines') || act == 'airlines') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/airlines">
                <i class="bi bi-building"></i>
                <span>Airline Management</span>
            </a>
        </li>
        <li class="admin-nav-item">
            <a class="admin-nav-link ${(reqUri.contains('/admin/aircraft') || act == 'aircraft') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/aircraft">
                <i class="bi bi-grid-3x3-gap-fill"></i>
                <span>Aircraft & Seats</span>
            </a>
        </li>
        <li class="admin-nav-item">
            <a class="admin-nav-link ${(reqUri.contains('/admin/passengers') || act == 'passengers') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/passengers">
                <i class="bi bi-people-fill"></i>
                <span>Passenger Registry</span>
            </a>
        </li>
        <li class="admin-nav-item">
            <a class="admin-nav-link ${(reqUri.contains('/admin/bookings') || act == 'bookings') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/bookings">
                <i class="bi bi-journal-bookmark-fill"></i>
                <span>Bookings Registry</span>
            </a>
        </li>
        <li class="admin-nav-item">
            <a class="admin-nav-link ${(reqUri.contains('/admin/payments') || act == 'payments') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/payments">
                <i class="bi bi-credit-card-2-front-fill"></i>
                <span>Payment Transactions</span>
            </a>
        </li>
        <li class="admin-nav-item">
            <a class="admin-nav-link ${(reqUri.contains('/admin/cancellations') || act == 'cancellations') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/cancellations">
                <i class="bi bi-x-circle-fill"></i>
                <span>Cancellations & Refunds</span>
            </a>
        </li>
        <li class="admin-nav-item">
            <a class="admin-nav-link ${(reqUri.contains('/admin/reports') || act == 'reports') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/reports">
                <i class="bi bi-file-earmark-bar-graph-fill"></i>
                <span>Reports & Exports</span>
            </a>
        </li>
        <li class="admin-nav-item">
            <a class="admin-nav-link ${(reqUri.contains('/admin/notifications') || act == 'notifications') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/notifications">
                <i class="bi bi-bell-fill"></i>
                <span>Notifications</span>
            </a>
        </li>
        <li class="admin-nav-item">
            <a class="admin-nav-link ${(reqUri.contains('/admin/audit') || act == 'audit') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/audit">
                <i class="bi bi-shield-check"></i>
                <span>Audit Logs</span>
            </a>
        </li>
        <li class="admin-nav-item">
            <a class="admin-nav-link ${(reqUri.contains('/admin/profile') || act == 'profile') ? 'active' : ''}"
               href="${pageContext.request.contextPath}/admin/profile">
                <i class="bi bi-person-badge-fill"></i>
                <span>Admin Profile</span>
            </a>
        </li>
    </ul>

    <div class="admin-sidebar-footer">
        <div class="admin-user-identity">
            <div class="admin-user-avatar" aria-label="Administrator Avatar">
                <c:choose>
                    <c:when test="${not empty sessionScope.currentUser.firstName}">
                        <c:out value="${sessionScope.currentUser.firstName.substring(0, 1).toUpperCase()}" />
                    </c:when>
                    <c:otherwise>S</c:otherwise>
                </c:choose>
            </div>
            <div class="admin-user-info">
                <div class="admin-user-name" title="<c:out value='${not empty sessionScope.currentUser.firstName ? sessionScope.currentUser.firstName : \"System\"} ${not empty sessionScope.currentUser.lastName ? sessionScope.currentUser.lastName : \"Administrator\"}' />">
                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser.firstName}">
                            <c:out value="${sessionScope.currentUser.firstName}" /> <c:out value="${sessionScope.currentUser.lastName}" />
                        </c:when>
                        <c:otherwise>System Administrator</c:otherwise>
                    </c:choose>
                </div>
                <div class="admin-user-email" title="<c:out value='${not empty sessionScope.currentUser.email ? sessionScope.currentUser.email : \"admin@airline.com\"}' />">
                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser.email}">
                            <c:out value="${sessionScope.currentUser.email}" />
                        </c:when>
                        <c:otherwise>admin@airline.com</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</aside>
<div class="admin-sidebar-backdrop" id="adminSidebarBackdrop"></div>

<script>
(function() {
    function initSidebarDrawer() {
        const sidebar = document.getElementById('adminSidebar');
        const backdrop = document.getElementById('adminSidebarBackdrop');
        const toggleBtn = document.getElementById('adminSidebarToggle');
        const closeBtn = document.getElementById('adminSidebarClose');

        function openSidebar() {
            if (sidebar) sidebar.classList.add('show');
            if (backdrop) backdrop.classList.add('show');
            document.body.style.overflow = 'hidden';
        }

        function closeSidebar() {
            if (sidebar) sidebar.classList.remove('show');
            if (backdrop) backdrop.classList.remove('show');
            document.body.style.overflow = '';
        }

        if (toggleBtn) {
            toggleBtn.addEventListener('click', function(e) {
                e.preventDefault();
                if (sidebar && sidebar.classList.contains('show')) {
                    closeSidebar();
                } else {
                    openSidebar();
                }
            });
        }

        if (closeBtn) {
            closeBtn.addEventListener('click', function(e) {
                e.preventDefault();
                closeSidebar();
            });
        }

        if (backdrop) {
            backdrop.addEventListener('click', function() {
                closeSidebar();
            });
        }

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && sidebar && sidebar.classList.contains('show')) {
                closeSidebar();
            }
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSidebarDrawer);
    } else {
        initSidebarDrawer();
    }
})();
</script>
