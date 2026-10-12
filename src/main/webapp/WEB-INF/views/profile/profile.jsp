<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <c:set var="pageTitle" value="Your Travel Profile - SkyTech" />
        <c:set var="activePage" value="profile" />

        <jsp:include page="/WEB-INF/views/common/header.jsp" />
        <jsp:include page="/WEB-INF/views/common/navbar.jsp" />

        <!-- 1. Cinematic Account Banner -->
        <section class="profile-hero-banner">
            <div class="profile-hero-overlay"></div>
            <div class="container profile-hero-content">
                <nav class="profile-breadcrumb" aria-label="breadcrumb">
                    <a href="${pageContext.request.contextPath}/">Home</a>
                    <i class="bi bi-chevron-right" style="font-size: 0.75rem;"></i>
                    <span>My Account</span>
                    <i class="bi bi-chevron-right" style="font-size: 0.75rem;"></i>
                    <span class="text-white fw-semibold">Profile</span>
                </nav>

                <h1 class="profile-hero-title">Passenger Profile &amp; Account</h1>
                <p class="profile-hero-desc">
                    Manage your personal identity, travel passport details, and passenger reservations.
                </p>
            </div>
        </section>

        <!-- 2. Main Profile Content Section -->
        <main class="container profile-content-wrap">
            <!-- Server Flash Alerts -->
            <c:if test="${not empty flashSuccess}">
                <div class="auth-alert auth-alert-success mb-4" role="alert">
                    <i class="bi bi-check-circle-fill fs-5"></i>
                    <div>
                        <c:out value="${flashSuccess}" />
                    </div>
                </div>
            </c:if>

            <c:if test="${not empty flashError}">
                <div class="auth-alert auth-alert-warning mb-4" role="alert">
                    <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                    <div>
                        <c:out value="${flashError}" />
                    </div>
                </div>
            </c:if>

            <c:if test="${not empty errorMessage}">
                <div class="auth-alert auth-alert-danger mb-4" role="alert">
                    <i class="bi bi-x-circle-fill fs-5"></i>
                    <div>
                        <c:out value="${errorMessage}" />
                    </div>
                </div>
            </c:if>

            <div class="row g-4">
                <!-- Left Column: Identity Overview Card -->
                <div class="col-lg-4">
                    <aside class="profile-identity-card">
                        <div class="profile-card-top-stripe"></div>
                        <div class="profile-identity-header">
                            <!-- Avatar Image / Initials Badge with Camera Trigger -->
                            <div class="profile-avatar-wrapper">
                                <div class="profile-avatar-circle" id="profileMainAvatar"
                                    title="Passenger Profile Photo">
                                    <c:choose>
                                        <c:when test="${not empty user.profilePhoto}">
                                            <img src="${pageContext.request.contextPath}${user.profilePhoto}"
                                                alt="Passenger Photo" id="currentAvatarImage">
                                        </c:when>
                                        <c:otherwise>
                                            <span id="currentAvatarInitials">
                                                <c:out value="${user.initials}" />
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <button type="button" class="profile-avatar-badge-btn" onclick="openAvatarModal()"
                                    title="Upload or Change Photo" aria-label="Change Photo">
                                    <i class="bi bi-camera-fill"></i>
                                </button>
                            </div>

                            <!-- Photo Action Buttons -->
                            <div class="profile-photo-actions-row">
                                <button type="button" class="btn-photo-action" onclick="openAvatarModal()">
                                    <i class="bi bi-camera"></i>
                                    <span>${not empty user.profilePhoto ? 'Change Photo' : 'Upload Photo'}</span>
                                </button>
                                <c:if test="${not empty user.profilePhoto}">
                                    <form action="${pageContext.request.contextPath}/profile" method="post"
                                        class="d-inline" onsubmit="return confirm('Remove your saved profile photo?');">
                                        <input type="hidden" name="action" value="remove_photo">
                                        <button type="submit" class="btn-photo-action btn-photo-action-danger"
                                            title="Remove Photo">
                                            <i class="bi bi-trash"></i>
                                            <span>Remove</span>
                                        </button>
                                    </form>
                                </c:if>
                            </div>

                            <h2 class="profile-passenger-name">
                                <c:out value="${user.fullName}" />
                            </h2>
                            <div class="profile-passenger-email">
                                <i class="bi bi-envelope me-1"></i>
                                <c:out value="${user.email}" />
                            </div>

                            <div class="profile-badges-row">
                                <c:choose>
                                    <c:when test="${user.role == 'ADMIN'}">
                                        <span class="badge-role-admin">
                                            <i class="bi bi-shield-lock-fill"></i> Administrator
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-role-passenger">
                                            <i class="bi bi-airplane-fill"></i> Passenger
                                        </span>
                                    </c:otherwise>
                                </c:choose>

                                <c:choose>
                                    <c:when test="${user.status == 'ACTIVE'}">
                                        <span class="badge-status-active">
                                            <i class="bi bi-check-circle-fill"></i> Active
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-role-admin"
                                            style="background:#FEE2E2; color:#991B1B; border-color:#FECACA;">
                                            <i class="bi bi-dash-circle-fill"></i>
                                            <c:out value="${user.status}" />
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="profile-details-list">
                            <div class="profile-detail-row">
                                <span class="profile-detail-label">
                                    <i class="bi bi-person-badge"></i> Account ID
                                </span>
                                <span class="profile-detail-value">#<c:out value="${user.userId}" /></span>
                            </div>

                            <div class="profile-detail-row">
                                <span class="profile-detail-label">
                                    <i class="bi bi-calendar-check"></i> Member Since
                                </span>
                                <span class="profile-detail-value">
                                    <c:out value="${user.formattedCreatedAt}" />
                                </span>
                            </div>

                            <div class="profile-detail-row">
                                <span class="profile-detail-label">
                                    <i class="bi bi-telephone-fill"></i> Mobile Phone
                                </span>
                                <span class="profile-detail-value">
                                    <c:choose>
                                        <c:when test="${not empty user.phone}">
                                            <c:out value="${user.phone}" />
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-neutral-placeholder">Not added</span>
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <div class="profile-detail-row">
                                <span class="profile-detail-label">
                                    <i class="bi bi-credit-card-2-front-fill"></i> Passport No.
                                </span>
                                <span class="profile-detail-value">
                                    <c:choose>
                                        <c:when test="${not empty user.maskedPassportNumber}">
                                            <span class="profile-masked-passport">
                                                <c:out value="${user.maskedPassportNumber}" />
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-neutral-placeholder">Not added</span>
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <div class="profile-detail-row">
                                <span class="profile-detail-label">
                                    <i class="bi bi-calendar-event-fill"></i> Date of Birth
                                </span>
                                <span class="profile-detail-value">
                                    <c:choose>
                                        <c:when test="${not empty user.formattedDateOfBirth}">
                                            <c:out value="${user.formattedDateOfBirth}" />
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-neutral-placeholder">Not added</span>
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <div class="profile-detail-row">
                                <span class="profile-detail-label">
                                    <i class="bi bi-translate"></i> Language
                                </span>
                                <span class="profile-detail-value text-muted" style="font-size: 0.85rem;">English
                                    (US)</span>
                            </div>

                            <div class="profile-detail-row">
                                <span class="profile-detail-label">
                                    <i class="bi bi-star-fill text-warning"></i> Cabin Class
                                </span>
                                <span class="profile-detail-value text-muted" style="font-size: 0.85rem;">Economy</span>
                            </div>
                        </div>
                    </aside>
                </div>

                <!-- Right Column: Personal Information & Password Tabs -->
                <div class="col-lg-8">
                    <section class="profile-form-card">
                        <!-- Navigation Tabs -->
                        <div class="profile-tabs-header">
                            <button type="button" class="profile-tab-btn ${activeTab != 'password' ? 'active' : ''}"
                                id="btnDetailsTab" onclick="switchProfileTab('details')">
                                <i class="bi bi-person-lines-fill"></i>
                                <span>Personal Details</span>
                            </button>
                            <button type="button" class="profile-tab-btn ${activeTab == 'password' ? 'active' : ''}"
                                id="btnPasswordTab" onclick="switchProfileTab('password')">
                                <i class="bi bi-key-fill"></i>
                                <span>Change Password</span>
                            </button>
                        </div>

                        <!-- Tab 1: Personal Details Form -->
                        <div id="detailsTabPane" style="display: ${activeTab != 'password' ? 'block' : 'none'};">
                            <form action="${pageContext.request.contextPath}/profile" method="post"
                                id="profileDetailsForm" novalidate>
                                <input type="hidden" name="action" value="update_details">

                                <div class="auth-fields-row">
                                    <div class="auth-field-group">
                                        <label for="firstName" class="auth-field-label">First Name <span
                                                class="required-mark">*</span></label>
                                        <div class="auth-input-wrapper">
                                            <i class="bi bi-person auth-field-icon"></i>
                                            <input type="text" class="auth-input-control" id="firstName"
                                                name="firstName" value="<c:out value='${user.firstName}' />" required
                                                pattern="[A-Za-z\s'-]{2,50}"
                                                data-original="<c:out value='${user.firstName}' />">
                                        </div>
                                    </div>

                                    <div class="auth-field-group">
                                        <label for="lastName" class="auth-field-label">Last Name <span
                                                class="required-mark">*</span></label>
                                        <div class="auth-input-wrapper">
                                            <i class="bi bi-person auth-field-icon"></i>
                                            <input type="text" class="auth-input-control" id="lastName" name="lastName"
                                                value="<c:out value='${user.lastName}' />" required
                                                pattern="[A-Za-z\s'-]{2,50}"
                                                data-original="<c:out value='${user.lastName}' />">
                                        </div>
                                    </div>
                                </div>

                                <div class="auth-fields-row">
                                    <div class="auth-field-group">
                                        <label for="email" class="auth-field-label">Email Address</label>
                                        <div class="auth-input-wrapper">
                                            <i class="bi bi-envelope auth-field-icon"></i>
                                            <input type="email" class="auth-input-control profile-input-readonly"
                                                id="email" value="<c:out value='${user.email}' />" readonly disabled>
                                        </div>
                                        <small class="text-muted" style="font-size: 0.78rem;">Email address is your
                                            primary account identifier and cannot be altered directly.</small>
                                    </div>

                                    <div class="auth-field-group">
                                        <label for="phone" class="auth-field-label">Mobile Number</label>
                                        <div class="auth-input-wrapper">
                                            <i class="bi bi-telephone auth-field-icon"></i>
                                            <input type="tel" class="auth-input-control" id="phone" name="phone"
                                                value="<c:out value='${user.phone}' />"
                                                placeholder="+1 555 123 4567 or +91 9876543210"
                                                pattern="^\+?[0-9\s-]{7,20}$"
                                                data-original="<c:out value='${user.phone}' />">
                                        </div>
                                        <small class="text-muted" style="font-size: 0.78rem;">Include country code (e.g.
                                            +1, +91, +44) for travel alerts and SMS notifications.</small>
                                    </div>
                                </div>

                                <div class="auth-fields-row">
                                    <div class="auth-field-group">
                                        <label for="passportNumber" class="auth-field-label">Passport Number <span
                                                class="text-muted fw-normal">(Optional)</span></label>
                                        <div class="auth-input-wrapper">
                                            <i class="bi bi-credit-card-2-front auth-field-icon"></i>
                                            <input type="text" class="auth-input-control text-uppercase"
                                                id="passportNumber" name="passportNumber"
                                                value="<c:out value='${user.passportNumber}' />"
                                                placeholder="e.g. P12345678" pattern="[A-Za-z0-9]{6,20}"
                                                data-original="<c:out value='${user.passportNumber}' />">
                                        </div>
                                        <small class="text-muted" style="font-size: 0.78rem;">Kept encrypted for
                                            seamless international flight check-in.</small>
                                    </div>

                                    <div class="auth-field-group">
                                        <label for="dateOfBirth" class="auth-field-label">Date of Birth <span
                                                class="text-muted fw-normal">(Optional)</span></label>
                                        <div class="auth-input-wrapper">
                                            <i class="bi bi-calendar auth-field-icon"></i>
                                            <input type="date" class="auth-input-control" id="dateOfBirth"
                                                name="dateOfBirth" value="<c:out value='${user.dateOfBirth}' />"
                                                data-original="<c:out value='${user.dateOfBirth}' />">
                                        </div>
                                        <small class="text-muted" style="font-size: 0.78rem;">Used to verify passenger
                                            age requirements on boarding passes.</small>
                                    </div>
                                </div>

                                <div class="profile-actions-bar">
                                    <button type="button" class="btn-profile-reset" id="btnResetDetails"
                                        onclick="resetProfileForm()">
                                        <i class="bi bi-arrow-counterclockwise me-1"></i> Reset Changes
                                    </button>
                                    <button type="submit" class="btn-profile-save" id="btnSaveDetails">
                                        <i class="bi bi-floppy-fill"></i>
                                        <span>Save Changes</span>
                                    </button>
                                </div>
                            </form>
                        </div>

                        <!-- Tab 2: Change Password Form -->
                        <div id="passwordTabPane" style="display: ${activeTab == 'password' ? 'block' : 'none'};">
                            <c:if test="${not empty passwordError}">
                                <div class="auth-alert auth-alert-danger mb-4" role="alert">
                                    <i class="bi bi-x-circle-fill fs-5"></i>
                                    <div>
                                        <c:out value="${passwordError}" />
                                    </div>
                                </div>
                            </c:if>

                            <c:if test="${not empty user.googleId && empty user.passwordHash}">
                                <div class="p-3 mb-4 rounded-3 border"
                                    style="background: #F8FAFC; border-color: #E2E8F0;">
                                    <div class="d-flex align-items-center gap-3">
                                        <i class="bi bi-google fs-3 text-primary"></i>
                                        <div>
                                            <h6 class="mb-1 fw-bold text-dark">Google Single Sign-On Account</h6>
                                            <p class="mb-0 text-muted small">Your account authenticates securely via
                                                your linked Google credentials (
                                                <c:out value="${user.email}" />). You do not require a separate SkyTech
                                                local password to sign in.
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </c:if>

                            <form action="${pageContext.request.contextPath}/profile" method="post"
                                id="changePasswordForm" novalidate>
                                <input type="hidden" name="action" value="change_password">

                                <div class="auth-field-group">
                                    <label for="currentPassword" class="auth-field-label">Current Password <span
                                            class="required-mark">*</span></label>
                                    <div class="auth-input-wrapper">
                                        <i class="bi bi-lock auth-field-icon"></i>
                                        <input type="password" class="auth-input-control" id="currentPassword"
                                            name="currentPassword" placeholder="Enter your current password" required
                                            autocomplete="current-password">
                                        <button type="button" class="btn-toggle-eye"
                                            onclick="togglePassField('currentPassword', this)"
                                            aria-label="Toggle password visibility">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="auth-fields-row">
                                    <div class="auth-field-group">
                                        <label for="newPassword" class="auth-field-label">New Password <span
                                                class="required-mark">*</span></label>
                                        <div class="auth-input-wrapper">
                                            <i class="bi bi-shield-lock auth-field-icon"></i>
                                            <input type="password" class="auth-input-control" id="newPassword"
                                                name="newPassword" placeholder="Min. 8 characters" required
                                                autocomplete="new-password">
                                            <button type="button" class="btn-toggle-eye"
                                                onclick="togglePassField('newPassword', this)"
                                                aria-label="Toggle password visibility">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <div class="auth-field-group">
                                        <label for="confirmPassword" class="auth-field-label">Confirm New Password <span
                                                class="required-mark">*</span></label>
                                        <div class="auth-input-wrapper">
                                            <i class="bi bi-shield-check auth-field-icon"></i>
                                            <input type="password" class="auth-input-control" id="confirmPassword"
                                                name="confirmPassword" placeholder="Re-enter new password" required
                                                autocomplete="new-password">
                                            <button type="button" class="btn-toggle-eye"
                                                onclick="togglePassField('confirmPassword', this)"
                                                aria-label="Toggle password visibility">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <!-- Password Strength Meter & Interactive Checklist -->
                                <div class="strength-meter-wrap">
                                    <div class="strength-bars">
                                        <div class="strength-bar" id="pBar1"></div>
                                        <div class="strength-bar" id="pBar2"></div>
                                        <div class="strength-bar" id="pBar3"></div>
                                        <div class="strength-bar" id="pBar4"></div>
                                    </div>
                                    <div class="strength-criteria-list">
                                        <div class="criteria-item" id="pCritLen">
                                            <span class="criteria-dot"></span>
                                            <span>At least 8 characters</span>
                                        </div>
                                        <div class="criteria-item" id="pCritNum">
                                            <span class="criteria-dot"></span>
                                            <span>Include a number</span>
                                        </div>
                                        <div class="criteria-item" id="pCritUp">
                                            <span class="criteria-dot"></span>
                                            <span>Include an uppercase letter</span>
                                        </div>
                                        <div class="criteria-item" id="pCritSpec">
                                            <span class="criteria-dot"></span>
                                            <span>Include a special character (@$!%*?&amp;_#^~)</span>
                                        </div>
                                    </div>
                                </div>

                                <div class="profile-actions-bar">
                                    <button type="submit" class="btn-profile-save" id="btnUpdatePassword">
                                        <i class="bi bi-shield-lock-fill"></i>
                                        <span>Update Password</span>
                                    </button>
                                </div>
                            </form>
                        </div>
                    </section>
                </div>
            </div>

            <!-- 3. Passenger Account Overview (Bookings & Travel Records) -->
            <section class="overview-section-card">
                <div class="overview-header">
                    <div class="overview-title-wrap">
                        <div class="overview-title-icon">
                            <i class="bi bi-airplane-engines-fill"></i>
                        </div>
                        <div>
                            <h3 class="overview-section-title">Passenger Travel &amp; Booking Overview</h3>
                            <p class="overview-section-subtitle">Real-time flight reservations and itinerary records
                                linked to your account</p>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/search-flights"
                        class="btn btn-sm btn-skytech-accent rounded-pill px-3 py-2 fw-semibold">
                        <i class="bi bi-plus-circle me-1"></i> Book New Flight
                    </a>
                </div>

                <!-- Metric Stat Cards -->
                <div class="overview-metrics-grid">
                    <div class="overview-metric-card">
                        <div class="overview-metric-label">
                            <i class="bi bi-briefcase-fill text-primary"></i> Total Bookings
                        </div>
                        <div class="overview-metric-val">
                            <c:out value="${totalBookings}" />
                        </div>
                    </div>

                    <div class="overview-metric-card">
                        <div class="overview-metric-label">
                            <i class="bi bi-clock-history text-info"></i> Upcoming Trips
                        </div>
                        <div class="overview-metric-val">
                            <c:out value="${upcomingCount}" />
                        </div>
                    </div>

                    <div class="overview-metric-card">
                        <div class="overview-metric-label">
                            <i class="bi bi-check-circle-fill text-success"></i> Completed Trips
                        </div>
                        <div class="overview-metric-val">
                            <c:out value="${completedCount}" />
                        </div>
                    </div>

                    <div class="overview-metric-card">
                        <div class="overview-metric-label">
                            <i class="bi bi-x-circle-fill text-danger"></i> Cancelled
                        </div>
                        <div class="overview-metric-val">
                            <c:out value="${cancelledCount}" />
                        </div>
                    </div>
                </div>

                <!-- Bookings List or Genuine Empty State -->
                <c:choose>
                    <c:when test="${not empty bookings}">
                        <div class="overview-table-wrap">
                            <table class="overview-table">
                                <thead>
                                    <tr>
                                        <th>Booking Ref / PNR</th>
                                        <th>Flight</th>
                                        <th>Route</th>
                                        <th>Travel Date</th>
                                        <th>Class</th>
                                        <th>Status</th>
                                        <th class="text-end">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="b" items="${bookings}">
                                        <tr>
                                            <td>
                                                <div class="fw-bold text-dark">
                                                    <c:out value="${b.bookingReference}" />
                                                </div>
                                                <c:if test="${not empty b.pnr}">
                                                    <small class="text-muted">
                                                        <c:out value="${b.pnr}" />
                                                    </small>
                                                </c:if>
                                            </td>
                                            <td>
                                                <span class="badge bg-light text-dark border">
                                                    <c:out value="${b.flightNumber}" />
                                                </span>
                                            </td>
                                            <td>
                                                <span class="fw-semibold">
                                                    <c:out value="${b.originCode}" />
                                                </span>
                                                <i class="bi bi-arrow-right text-muted mx-1"></i>
                                                <span class="fw-semibold">
                                                    <c:out value="${b.destinationCode}" />
                                                </span>
                                            </td>
                                            <td>
                                                <c:out value="${b.departureDate}" />
                                            </td>
                                            <td>
                                                <span class="badge bg-light text-secondary border">
                                                    <c:out value="${b.travelClass}" />
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${b.status == 'CONFIRMED'}">
                                                        <span class="overview-badge-confirmed"><i
                                                                class="bi bi-check-circle-fill me-1"></i>Confirmed</span>
                                                    </c:when>
                                                    <c:when test="${b.status == 'CANCELLED'}">
                                                        <span class="overview-badge-cancelled"><i
                                                                class="bi bi-x-circle-fill me-1"></i>Cancelled</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="overview-badge-pending"><i
                                                                class="bi bi-clock-fill me-1"></i>
                                                            <c:out value="${b.status}" />
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-end">
                                                <a href="${pageContext.request.contextPath}/manage-booking?bookingReference=${b.bookingReference}"
                                                    class="btn btn-sm btn-outline-primary rounded-pill px-3">
                                                    Manage
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="overview-empty-state">
                            <div class="overview-empty-icon">
                                <i class="bi bi-ticket-perforated"></i>
                            </div>
                            <h4 class="overview-empty-title">No bookings yet</h4>
                            <p class="overview-empty-desc">
                                No bookings yet. Explore available flights to plan your next trip.
                            </p>
                            <a href="${pageContext.request.contextPath}/search-flights"
                                class="btn btn-primary rounded-pill px-4 py-2 fw-semibold shadow-sm">
                                <i class="bi bi-search me-1"></i> Search Flights
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </main>

        <!-- 4. Profile Photo Upload Modal Dialog -->
        <div class="avatar-modal-backdrop" id="avatarUploadModal" role="dialog" aria-modal="true"
            aria-labelledby="avatarModalTitle">
            <div class="avatar-modal-card">
                <div class="d-flex align-items-center justify-content-between mb-3">
                    <h5 class="fw-bold mb-0 text-dark" id="avatarModalTitle">Upload Profile Photo</h5>
                    <button type="button" class="btn-close" onclick="closeAvatarModal()" aria-label="Close"></button>
                </div>
                <p class="text-muted small mb-3">Choose a PNG, JPG, or WebP image under 2MB. Your photo will be visible
                    on your profile and navbar.</p>

                <!-- Preview Circle -->
                <div class="avatar-preview-area">
                    <img id="avatarModalPreview"
                        src="${not empty user.profilePhoto ? pageContext.request.contextPath.concat(user.profilePhoto) : ''}"
                        style="${empty user.profilePhoto ? 'display:none;' : ''}" alt="Photo Preview">
                    <div id="avatarModalPlaceholder" class="text-secondary fs-1 fw-bold"
                        style="${not empty user.profilePhoto ? 'display:none;' : ''}">
                        <c:out value="${user.initials}" />
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/profile" method="post" enctype="multipart/form-data"
                    id="avatarUploadForm">
                    <input type="hidden" name="action" value="upload_photo">

                    <div class="mb-3">
                        <label for="profilePhotoFile" class="form-label small fw-semibold">Select Image File</label>
                        <input class="form-control form-control-sm" type="file" id="profilePhotoFile"
                            name="profilePhotoFile" accept="image/jpeg,image/png,image/webp" required
                            onchange="handleFileSelected(event)">
                        <div class="form-text text-danger d-none" id="fileSizeWarning">File size exceeds 2MB limit.
                            Please choose a smaller image.</div>
                    </div>

                    <div class="d-flex gap-2 justify-content-end mt-4">
                        <button type="button" class="btn btn-sm btn-light rounded-pill px-3"
                            onclick="closeAvatarModal()">Cancel</button>
                        <button type="submit" class="btn btn-sm btn-primary rounded-pill px-4 fw-semibold"
                            id="btnSaveAvatar" disabled>
                            <i class="bi bi-cloud-arrow-up-fill me-1"></i> Save Photo
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            // Tab switching handler
            function switchProfileTab(tabName) {
                const detailsPane = document.getElementById('detailsTabPane');
                const passPane = document.getElementById('passwordTabPane');
                const btnDetails = document.getElementById('btnDetailsTab');
                const btnPass = document.getElementById('btnPasswordTab');

                if (tabName === 'password') {
                    detailsPane.style.display = 'none';
                    passPane.style.display = 'block';
                    btnDetails.classList.remove('active');
                    btnPass.classList.add('active');
                } else {
                    detailsPane.style.display = 'block';
                    passPane.style.display = 'none';
                    btnPass.classList.remove('active');
                    btnDetails.classList.add('active');
                }
            }

            // Toggle password visibility
            function togglePassField(fieldId, btnElem) {
                const input = document.getElementById(fieldId);
                if (input) {
                    const isPassword = input.getAttribute('type') === 'password';
                    input.setAttribute('type', isPassword ? 'text' : 'password');
                    const icon = btnElem.querySelector('i');
                    if (icon) {
                        icon.className = isPassword ? 'bi bi-eye-slash' : 'bi bi-eye';
                    }
                }
            }

            // Reset Form to Original Saved Database Values
            function resetProfileForm() {
                const fields = ['firstName', 'lastName', 'phone', 'passportNumber', 'dateOfBirth'];
                fields.forEach(fieldId => {
                    const input = document.getElementById(fieldId);
                    if (input && input.hasAttribute('data-original')) {
                        input.value = input.getAttribute('data-original');
                    }
                });
            }

            // Modal Control & Image Preview
            function openAvatarModal() {
                const modal = document.getElementById('avatarUploadModal');
                modal.classList.add('show');
            }

            function closeAvatarModal() {
                const modal = document.getElementById('avatarUploadModal');
                modal.classList.remove('show');
                // Reset file input and preview
                const fileInput = document.getElementById('profilePhotoFile');
                fileInput.value = '';
                document.getElementById('btnSaveAvatar').disabled = true;
                document.getElementById('fileSizeWarning').classList.add('d-none');

                // Restore original preview
                const previewImg = document.getElementById('avatarModalPreview');
                const placeholder = document.getElementById('avatarModalPlaceholder');
                const originalSrc = "${not empty user.profilePhoto ? pageContext.request.contextPath.concat(user.profilePhoto) : ''}";
                if (originalSrc) {
                    previewImg.src = originalSrc;
                    previewImg.style.display = 'block';
                    placeholder.style.display = 'none';
                } else {
                    previewImg.style.display = 'none';
                    placeholder.style.display = 'block';
                }
            }

            function handleFileSelected(event) {
                const file = event.target.files[0];
                const previewImg = document.getElementById('avatarModalPreview');
                const placeholder = document.getElementById('avatarModalPlaceholder');
                const saveBtn = document.getElementById('btnSaveAvatar');
                const warning = document.getElementById('fileSizeWarning');

                if (!file) {
                    saveBtn.disabled = true;
                    return;
                }

                // Validate file size (< 2MB)
                if (file.size > 2 * 1024 * 1024) {
                    warning.classList.remove('d-none');
                    saveBtn.disabled = true;
                    return;
                } else {
                    warning.classList.add('d-none');
                }

                // Preview image
                const reader = new FileReader();
                reader.onload = function (e) {
                    previewImg.src = e.target.result;
                    previewImg.style.display = 'block';
                    placeholder.style.display = 'none';
                    saveBtn.disabled = false;
                };
                reader.readAsDataURL(file);
            }

            // Real-time password criteria for new password
            const newPassInput = document.getElementById('newPassword');
            const pBars = [
                document.getElementById('pBar1'),
                document.getElementById('pBar2'),
                document.getElementById('pBar3'),
                document.getElementById('pBar4')
            ];
            const pCritLen = document.getElementById('pCritLen');
            const pCritNum = document.getElementById('pCritNum');
            const pCritUp = document.getElementById('pCritUp');
            const pCritSpec = document.getElementById('pCritSpec');

            if (newPassInput) {
                newPassInput.addEventListener('input', function () {
                    const val = newPassInput.value;
                    const hasLen = val.length >= 8;
                    const hasNum = /\d/.test(val);
                    const hasUp = /[A-Z]/.test(val);
                    const hasSpec = /[@$!%*?&_#^~]/.test(val);

                    if (pCritLen) pCritLen.className = hasLen ? 'criteria-item valid' : 'criteria-item';
                    if (pCritNum) pCritNum.className = hasNum ? 'criteria-item valid' : 'criteria-item';
                    if (pCritUp) pCritUp.className = hasUp ? 'criteria-item valid' : 'criteria-item';
                    if (pCritSpec) pCritSpec.className = hasSpec ? 'criteria-item valid' : 'criteria-item';

                    const score = (hasLen ? 1 : 0) + (hasNum ? 1 : 0) + (hasUp ? 1 : 0) + (hasSpec ? 1 : 0);
                    const colors = ['#EF4444', '#F59E0B', '#3B82F6', '#10B981'];
                    const activeColor = score > 0 ? colors[score - 1] : '#E2E8F0';

                    pBars.forEach((bar, idx) => {
                        if (bar) {
                            bar.style.backgroundColor = (idx < score) ? activeColor : '#E2E8F0';
                        }
                    });
                });
            }

            // Client-side submission validation & loading feedback
            const detailsForm = document.getElementById('profileDetailsForm');
            const btnSaveDetails = document.getElementById('btnSaveDetails');
            if (detailsForm && btnSaveDetails) {
                detailsForm.addEventListener('submit', function () {
                    btnSaveDetails.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Saving...';
                    btnSaveDetails.style.opacity = '0.85';
                    btnSaveDetails.style.pointerEvents = 'none';
                });
            }

            const passForm = document.getElementById('changePasswordForm');
            const btnUpdatePassword = document.getElementById('btnUpdatePassword');
            const confPassInput = document.getElementById('confirmPassword');

            if (passForm && btnUpdatePassword) {
                passForm.addEventListener('submit', function (e) {
                    if (newPassInput && confPassInput && newPassInput.value !== confPassInput.value) {
                        e.preventDefault();
                        alert("New passwords do not match. Please verify your entries.");
                        confPassInput.focus();
                        return;
                    }

                    btnUpdatePassword.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Updating...';
                    btnUpdatePassword.style.opacity = '0.85';
                    btnUpdatePassword.style.pointerEvents = 'none';
                });
            }

            // Close avatar modal on Escape key
            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') {
                    closeAvatarModal();
                }
            });
        </script>

        <jsp:include page="/WEB-INF/views/common/footer.jsp" />