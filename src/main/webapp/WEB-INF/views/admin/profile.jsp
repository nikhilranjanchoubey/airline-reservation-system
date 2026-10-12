<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Administrator Profile | SkyTech Administration" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <c:set var="activeTab" value="profile" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <!-- Page Header -->
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">Administrator Profile &amp; Account</h1>
                <div class="admin-header-meta">
                    <span><i class="bi bi-shield-check text-warning me-1"></i> System Administrator Console Profile</span>
                    <span><i class="bi bi-person-badge text-primary me-1"></i> Account ID: <strong>#<c:out value="${user.userId}" /></strong></span>
                </div>
            </div>
            <div class="d-flex align-items-center gap-2">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-btn admin-btn-outline">
                    <i class="bi bi-speedometer2"></i> Dashboard Overview
                </a>
            </div>
        </div>

        <!-- Flash alerts -->
        <c:if test="${not empty flashSuccess}">
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
                <i class="bi bi-check-circle-fill fs-5"></i>
                <div><c:out value="${flashSuccess}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${not empty flashError}">
            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                <div><c:out value="${flashError}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <div class="row g-4">
            <!-- Left: Admin Summary Card -->
            <div class="col-lg-4 col-md-5">
                <div class="admin-card h-100 text-center">
                    <div class="admin-profile-avatar-wrap mx-auto mb-3">
                        <div class="admin-profile-avatar-circle">
                            <i class="bi bi-shield-lock-fill"></i>
                        </div>
                    </div>

                    <h2 class="fs-5 fw-bold text-navy mb-1">
                        <c:out value="${user.firstName}" /> <c:out value="${user.lastName}" />
                    </h2>
                    <p class="text-muted small mb-3">
                        <i class="bi bi-envelope me-1"></i> <c:out value="${user.email}" />
                    </p>

                    <div class="d-flex justify-content-center gap-2 flex-wrap mb-4">
                        <span class="badge-role-admin">
                            <i class="bi bi-shield-lock-fill"></i> System Administrator
                        </span>
                        <span class="badge-status-active">
                            <i class="bi bi-check-circle-fill"></i> Active
                        </span>
                    </div>

                    <div class="admin-profile-info-list text-start">
                        <div class="admin-profile-info-row">
                            <span class="admin-profile-info-label">
                                <i class="bi bi-person-badge"></i> Account ID
                            </span>
                            <span class="admin-profile-info-val">#<c:out value="${user.userId}" /></span>
                        </div>
                        <div class="admin-profile-info-row">
                            <span class="admin-profile-info-label">
                                <i class="bi bi-shield-shaded"></i> Authorization
                            </span>
                            <span class="admin-profile-info-val text-warning fw-bold">Full Ops Control</span>
                        </div>
                        <div class="admin-profile-info-row">
                            <span class="admin-profile-info-label">
                                <i class="bi bi-calendar-check"></i> Member Since
                            </span>
                            <span class="admin-profile-info-val"><c:out value="${user.formattedCreatedAt}" /></span>
                        </div>
                        <div class="admin-profile-info-row">
                            <span class="admin-profile-info-label">
                                <i class="bi bi-telephone"></i> Mobile Phone
                            </span>
                            <span class="admin-profile-info-val">
                                <c:choose>
                                    <c:when test="${not empty user.phone}">
                                        <c:out value="${user.phone}" />
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted fst-italic">Not specified</span>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="admin-profile-info-row">
                            <span class="admin-profile-info-label">
                                <i class="bi bi-lock-fill"></i> Credentials
                            </span>
                            <span class="admin-profile-info-val text-success">PBKDF2 SHA-256</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right: Admin Tabs Card -->
            <div class="col-lg-8 col-md-7">
                <div class="admin-card">
                    <!-- Nav Tabs -->
                    <ul class="nav nav-pills admin-profile-pills mb-4" id="adminProfileTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="tab-details-btn" data-bs-toggle="pill" data-bs-target="#tab-details" type="button" role="tab">
                                <i class="bi bi-person-vcard me-2"></i> Account Details
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="tab-security-btn" data-bs-toggle="pill" data-bs-target="#tab-security" type="button" role="tab">
                                <i class="bi bi-shield-lock me-2"></i> Security &amp; Password
                            </button>
                        </li>
                    </ul>

                    <div class="tab-content" id="adminProfileTabContent">
                        <!-- Tab 1: Account Details Form -->
                        <div class="tab-pane fade show active" id="tab-details" role="tabpanel">
                            <form action="${pageContext.request.contextPath}/admin/profile" method="POST" id="adminDetailsForm">
                                <input type="hidden" name="action" value="update_profile">

                                <div class="row g-3 mb-3">
                                    <div class="col-sm-6">
                                        <label for="adminFirstName" class="form-label small fw-bold text-navy">
                                            First Name <span class="text-danger">*</span>
                                        </label>
                                        <input type="text" class="form-control admin-form-control" id="adminFirstName" name="firstName"
                                               value="<c:out value='${user.firstName}' />" required
                                               data-original="<c:out value='${user.firstName}' />">
                                    </div>
                                    <div class="col-sm-6">
                                        <label for="adminLastName" class="form-label small fw-bold text-navy">
                                            Last Name <span class="text-danger">*</span>
                                        </label>
                                        <input type="text" class="form-control admin-form-control" id="adminLastName" name="lastName"
                                               value="<c:out value='${user.lastName}' />" required
                                               data-original="<c:out value='${user.lastName}' />">
                                    </div>
                                </div>

                                <div class="row g-3 mb-3">
                                    <div class="col-sm-6">
                                        <label for="adminEmail" class="form-label small fw-bold text-navy">Email Address</label>
                                        <input type="email" class="form-control admin-form-control bg-light" id="adminEmail"
                                               value="<c:out value='${user.email}' />" readonly disabled>
                                        <small class="text-muted" style="font-size: 0.78rem;">
                                            Email address is your primary account identifier and cannot be altered directly.
                                        </small>
                                    </div>
                                    <div class="col-sm-6">
                                        <label for="adminPhone" class="form-label small fw-bold text-navy">Mobile Number</label>
                                        <input type="tel" class="form-control admin-form-control" id="adminPhone" name="phone"
                                               value="<c:out value='${user.phone}' />" placeholder="+1 800 555 0199"
                                               data-original="<c:out value='${user.phone}' />">
                                        <small class="text-muted" style="font-size: 0.78rem;">
                                            Include country code for operational alerts and SMS notifications.
                                        </small>
                                    </div>
                                </div>

                                <div class="d-flex align-items-center gap-3 mt-4 pt-2 border-top">
                                    <button type="submit" class="admin-btn admin-btn-primary" id="btnSaveAdminDetails">
                                        <i class="bi bi-check2-circle"></i> Save Changes
                                    </button>
                                    <button type="button" class="admin-btn admin-btn-secondary" onclick="resetAdminProfileForm()">
                                        <i class="bi bi-arrow-counterclockwise"></i> Reset Changes
                                    </button>
                                </div>
                            </form>
                        </div>

                        <!-- Tab 2: Security & Password Form -->
                        <div class="tab-pane fade" id="tab-security" role="tabpanel">
                            <form action="${pageContext.request.contextPath}/admin/profile" method="POST" id="adminPasswordForm">
                                <input type="hidden" name="action" value="change_password">

                                <div class="mb-3">
                                    <label for="currentPassword" class="form-label small fw-bold text-navy">
                                        Current Password <span class="text-danger">*</span>
                                    </label>
                                    <div class="input-group">
                                        <input type="password" class="form-control admin-form-control" id="currentPassword" name="currentPassword" required placeholder="Enter your current password">
                                        <button class="btn btn-outline-secondary" type="button" onclick="togglePassVisibility('currentPassword', this)" aria-label="Toggle password visibility">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="row g-3 mb-3">
                                    <div class="col-sm-6">
                                        <label for="newPassword" class="form-label small fw-bold text-navy">
                                            New Password <span class="text-danger">*</span>
                                        </label>
                                        <div class="input-group">
                                            <input type="password" class="form-control admin-form-control" id="newPassword" name="newPassword" required placeholder="Minimum 8 characters">
                                            <button class="btn btn-outline-secondary" type="button" onclick="togglePassVisibility('newPassword', this)" aria-label="Toggle password visibility">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                    </div>
                                    <div class="col-sm-6">
                                        <label for="confirmPassword" class="form-label small fw-bold text-navy">
                                            Confirm New Password <span class="text-danger">*</span>
                                        </label>
                                        <div class="input-group">
                                            <input type="password" class="form-control admin-form-control" id="confirmPassword" name="confirmPassword" required placeholder="Re-enter new password">
                                            <button class="btn btn-outline-secondary" type="button" onclick="togglePassVisibility('confirmPassword', this)" aria-label="Toggle password visibility">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <div class="alert alert-light border small text-muted mb-4">
                                    <i class="bi bi-info-circle me-1 text-primary"></i>
                                    Password must be at least 8 characters long and contain uppercase, numeric, and special characters.
                                </div>

                                <div class="d-flex align-items-center gap-3 pt-2 border-top">
                                    <button type="submit" class="admin-btn admin-btn-primary" id="btnUpdateAdminPassword">
                                        <i class="bi bi-shield-lock"></i> Update Password
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
function resetAdminProfileForm() {
    const fields = ['adminFirstName', 'adminLastName', 'adminPhone'];
    fields.forEach(id => {
        const el = document.getElementById(id);
        if (el && el.hasAttribute('data-original')) {
            el.value = el.getAttribute('data-original');
        }
    });
}

function togglePassVisibility(inputId, btn) {
    const input = document.getElementById(inputId);
    if (!input) return;
    const isPass = input.type === 'password';
    input.type = isPass ? 'text' : 'password';
    const icon = btn.querySelector('i');
    if (icon) {
        icon.className = isPass ? 'bi bi-eye-slash' : 'bi bi-eye';
    }
}
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
