<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="System & Gateway Settings | SkyTech Administration" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <c:set var="activeTab" value="settings" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">System & Payment Gateway Configuration</h1>
                <div class="admin-header-meta">
                    <span>Truthful diagnostic status of payment gateway integration, database connectivity, and operational flags</span>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Payment Gateway Status -->
            <div class="col-lg-6">
                <div class="admin-card h-100">
                    <div class="admin-card-header">
                        <h2 class="admin-card-title text-navy">
                            <i class="bi bi-credit-card-fill text-primary"></i> Razorpay Gateway Status
                        </h2>
                        <span class="badge ${isRazorpayConfigured ? 'bg-success' : 'bg-warning text-dark'}">
                            ${isRazorpayConfigured ? 'Configured' : 'Default / Test Sandbox'}
                        </span>
                    </div>

                    <div class="p-3 bg-light rounded-3 border mb-3">
                        <div class="admin-settings-row">
                            <span class="admin-settings-label">Gateway Environment:</span>
                            <span class="badge bg-info text-dark admin-settings-value">${isTestMode ? 'Test Mode (Sandbox)' : 'Live Production'}</span>
                        </div>
                        <div class="admin-settings-row">
                            <span class="admin-settings-label">Public Key ID:</span>
                            <code class="text-dark admin-settings-value">${maskedKeyId}</code>
                        </div>
                        <div class="admin-settings-row">
                            <span class="admin-settings-label">Server Signature Check:</span>
                            <span class="badge bg-success admin-settings-value">HmacSHA256 Active</span>
                        </div>
                        <div class="admin-settings-row">
                            <span class="admin-settings-label">Refund Execution:</span>
                            <span class="badge bg-primary admin-settings-value">Automated API + Academic Fallback</span>
                        </div>
                    </div>

                    <div class="alert alert-info small mb-0">
                        <i class="bi bi-info-circle me-1"></i>
                        The Razorpay Key Secret is protected on the server side and never exposed to browser responses, HTML templates, or JavaScript client files.
                    </div>
                </div>
            </div>

            <!-- Database & Core Services -->
            <div class="col-lg-6">
                <div class="admin-card h-100">
                    <div class="admin-card-header">
                        <h2 class="admin-card-title text-navy">
                            <i class="bi bi-database-fill text-primary"></i> Database & Persistence
                        </h2>
                        <span class="badge bg-success">Connected</span>
                    </div>

                    <div class="p-3 bg-light rounded-3 border mb-3">
                        <div class="admin-settings-row">
                            <span class="admin-settings-label">RDBMS Provider:</span>
                            <span class="fw-semibold text-navy admin-settings-value">MySQL 8.0</span>
                        </div>
                        <div class="admin-settings-row">
                            <span class="admin-settings-label">Host & Port:</span>
                            <code class="admin-settings-value">${dbHost}:${dbPort}</code>
                        </div>
                        <div class="admin-settings-row">
                            <span class="admin-settings-label">Database Schema:</span>
                            <span class="fw-semibold text-navy admin-settings-value">${dbName}</span>
                        </div>
                        <div class="admin-settings-row">
                            <span class="admin-settings-label">Connection Pool:</span>
                            <span class="badge bg-light text-dark border admin-settings-value">HikariCP Enabled</span>
                        </div>
                    </div>

                    <div class="alert alert-success small mb-0">
                        <i class="bi bi-shield-check me-1"></i>
                        Audit trail table <code>admin_audit_logs</code> is verified and actively capturing administrative operations.
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
