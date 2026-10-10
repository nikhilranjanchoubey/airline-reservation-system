<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Your Travel Profile - SkyTech Airlines" />
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

        <h1 class="profile-hero-title">Your Travel Profile</h1>
        <p class="profile-hero-desc">
            Manage your personal identity, travel passport details, and account security preferences.
        </p>
    </div>
</section>

<!-- 2. Main Profile Content Section -->
<main class="container profile-content-wrap">
    <!-- Server Flash Alerts -->
    <c:if test="${not empty flashSuccess}">
        <div class="auth-alert auth-alert-success mb-4" role="alert">
            <i class="bi bi-check-circle-fill fs-5"></i>
            <div><c:out value="${flashSuccess}" /></div>
        </div>
    </c:if>

    <c:if test="${not empty flashError}">
        <div class="auth-alert auth-alert-warning mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill fs-5"></i>
            <div><c:out value="${flashError}" /></div>
        </div>
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="auth-alert auth-alert-danger mb-4" role="alert">
            <i class="bi bi-x-circle-fill fs-5"></i>
            <div><c:out value="${errorMessage}" /></div>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Left Column: Identity Overview Card -->
        <div class="col-lg-4">
            <aside class="profile-identity-card">
                <div class="profile-card-top-stripe"></div>
                <div class="profile-identity-header">
                    <!-- Initials Avatar Badge -->
                    <div class="profile-avatar-circle" title="Passenger Avatar">
                        <c:choose>
                            <c:when test="${not empty user.firstName && not empty user.lastName}">
                                <c:out value="${user.firstName.substring(0,1)}${user.lastName.substring(0,1)}" />
                            </c:when>
                            <c:otherwise>
                                <i class="bi bi-person-fill"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <h2 class="profile-passenger-name"><c:out value="${user.fullName}" /></h2>
                    <div class="profile-passenger-email">
                        <i class="bi bi-envelope me-1"></i><c:out value="${user.email}" />
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

                        <span class="badge-status-active">
                            <i class="bi bi-check-circle-fill"></i> <c:out value="${user.status}" />
                        </span>
                    </div>
                </div>

                <div class="profile-details-list">
                    <div class="profile-detail-row">
                        <span class="profile-detail-label">
                            <i class="bi bi-hash"></i> Account ID
                        </span>
                        <span class="profile-detail-value">#<c:out value="${user.userId}" /></span>
                    </div>

                    <div class="profile-detail-row">
                        <span class="profile-detail-label">
                            <i class="bi bi-telephone-fill"></i> Contact Phone
                        </span>
                        <span class="profile-detail-value"><c:out value="${user.phone}" /></span>
                    </div>

                    <div class="profile-detail-row">
                        <span class="profile-detail-label">
                            <i class="bi bi-credit-card-2-front-fill"></i> Passport No.
                        </span>
                        <span class="profile-detail-value">
                            <c:out value="${not empty user.passportNumber ? user.passportNumber : 'Not Provided'}" />
                        </span>
                    </div>

                    <div class="profile-detail-row">
                        <span class="profile-detail-label">
                            <i class="bi bi-calendar-event-fill"></i> Date of Birth
                        </span>
                        <span class="profile-detail-value">
                            <c:out value="${not empty user.dateOfBirth ? user.dateOfBirth : 'Not Provided'}" />
                        </span>
                    </div>
                </div>
            </aside>
        </div>

        <!-- Right Column: Personal Information & Password Tabs -->
        <div class="col-lg-8">
            <section class="profile-form-card">
                <!-- Custom Navigation Tabs -->
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
                    <form action="${pageContext.request.contextPath}/profile" method="post" id="profileDetailsForm" novalidate>
                        <input type="hidden" name="action" value="update_details">

                        <div class="auth-fields-row">
                            <div class="auth-field-group">
                                <label for="firstName" class="auth-field-label">First Name <span class="required-mark">*</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-person auth-field-icon"></i>
                                    <input type="text" class="auth-input-control" id="firstName" name="firstName"
                                           value="<c:out value='${user.firstName}' />" required pattern="[A-Za-z\s'-]{2,50}">
                                </div>
                            </div>

                            <div class="auth-field-group">
                                <label for="lastName" class="auth-field-label">Last Name <span class="required-mark">*</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-person auth-field-icon"></i>
                                    <input type="text" class="auth-input-control" id="lastName" name="lastName"
                                           value="<c:out value='${user.lastName}' />" required pattern="[A-Za-z\s'-]{2,50}">
                                </div>
                            </div>
                        </div>

                        <div class="auth-fields-row">
                            <div class="auth-field-group">
                                <label for="email" class="auth-field-label">Email Address <span class="text-muted fw-normal">(Account ID)</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-envelope auth-field-icon"></i>
                                    <input type="email" class="auth-input-control profile-input-readonly" id="email"
                                           value="<c:out value='${user.email}' />" readonly disabled>
                                </div>
                                <small class="text-muted" style="font-size: 0.78rem;">Email address is your primary account identifier and cannot be changed directly.</small>
                            </div>

                            <div class="auth-field-group">
                                <label for="phone" class="auth-field-label">Contact Phone <span class="required-mark">*</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-telephone auth-field-icon"></i>
                                    <input type="tel" class="auth-input-control" id="phone" name="phone"
                                           value="<c:out value='${user.phone}' />" required pattern="\+?[0-9\s-]{7,20}">
                                </div>
                            </div>
                        </div>

                        <div class="auth-fields-row">
                            <div class="auth-field-group">
                                <label for="passportNumber" class="auth-field-label">Passport Number <span class="text-muted fw-normal">(Optional)</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-credit-card-2-front auth-field-icon"></i>
                                    <input type="text" class="auth-input-control" id="passportNumber" name="passportNumber"
                                           value="<c:out value='${user.passportNumber}' />" placeholder="e.g. A12345678" pattern="[A-Za-z0-9]{6,20}">
                                </div>
                            </div>

                            <div class="auth-field-group">
                                <label for="dateOfBirth" class="auth-field-label">Date of Birth <span class="text-muted fw-normal">(Optional)</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-calendar auth-field-icon"></i>
                                    <input type="date" class="auth-input-control" id="dateOfBirth" name="dateOfBirth"
                                           value="<c:out value='${user.dateOfBirth}' />">
                                </div>
                            </div>
                        </div>

                        <div class="profile-actions-bar">
                            <button type="reset" class="btn-profile-reset">
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
                            <div><c:out value="${passwordError}" /></div>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/profile" method="post" id="changePasswordForm" novalidate>
                        <input type="hidden" name="action" value="change_password">

                        <div class="auth-field-group">
                            <label for="currentPassword" class="auth-field-label">Current Password <span class="required-mark">*</span></label>
                            <div class="auth-input-wrapper">
                                <i class="bi bi-lock auth-field-icon"></i>
                                <input type="password" class="auth-input-control" id="currentPassword" name="currentPassword"
                                       placeholder="Enter your current password" required autocomplete="current-password">
                                <button type="button" class="btn-toggle-eye" onclick="togglePassField('currentPassword', this)" aria-label="Toggle password visibility">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>
                        </div>

                        <div class="auth-fields-row">
                            <div class="auth-field-group">
                                <label for="newPassword" class="auth-field-label">New Password <span class="required-mark">*</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-shield-lock auth-field-icon"></i>
                                    <input type="password" class="auth-input-control" id="newPassword" name="newPassword"
                                           placeholder="Min. 8 characters" required autocomplete="new-password">
                                    <button type="button" class="btn-toggle-eye" onclick="togglePassField('newPassword', this)" aria-label="Toggle password visibility">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                </div>
                            </div>

                            <div class="auth-field-group">
                                <label for="confirmPassword" class="auth-field-label">Confirm New Password <span class="required-mark">*</span></label>
                                <div class="auth-input-wrapper">
                                    <i class="bi bi-shield-check auth-field-icon"></i>
                                    <input type="password" class="auth-input-control" id="confirmPassword" name="confirmPassword"
                                           placeholder="Re-enter new password" required autocomplete="new-password">
                                    <button type="button" class="btn-toggle-eye" onclick="togglePassField('confirmPassword', this)" aria-label="Toggle password visibility">
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
</main>

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
        newPassInput.addEventListener('input', function() {
            const val = newPassInput.value;
            const hasLen = val.length >= 8;
            const hasNum = /\d/.test(val);
            const hasUp = /[A-Z]/.test(val);
            const hasSpec = /[@$!%*?&_#^~]/.test(val);

            pCritLen.className = hasLen ? 'criteria-item valid' : 'criteria-item';
            pCritNum.className = hasNum ? 'criteria-item valid' : 'criteria-item';
            pCritUp.className = hasUp ? 'criteria-item valid' : 'criteria-item';
            pCritSpec.className = hasSpec ? 'criteria-item valid' : 'criteria-item';

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
        detailsForm.addEventListener('submit', function() {
            btnSaveDetails.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Saving...';
            btnSaveDetails.style.opacity = '0.85';
            btnSaveDetails.style.pointerEvents = 'none';
        });
    }

    const passForm = document.getElementById('changePasswordForm');
    const btnUpdatePassword = document.getElementById('btnUpdatePassword');
    const confPassInput = document.getElementById('confirmPassword');

    if (passForm && btnUpdatePassword) {
        passForm.addEventListener('submit', function(e) {
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
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
