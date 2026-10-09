<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="User Profile - SkyTech Airlines" />
<c:set var="activePage" value="profile" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="py-5">
    <div class="container">
        <!-- Flash messages -->
        <c:if test="${not empty flashSuccess}">
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                <i class="bi bi-check-circle-fill me-2 fs-5"></i>
                <div><c:out value="${flashSuccess}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                <i class="bi bi-x-circle-fill me-2 fs-5"></i>
                <div><c:out value="${errorMessage}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <div class="row g-4">
            <!-- Left Side: Profile Summary Card -->
            <div class="col-lg-4">
                <div class="profile-card">
                    <div class="profile-cover"></div>
                    <div class="profile-avatar-wrap">
                        <div class="profile-avatar">
                            <i class="bi bi-person-fill"></i>
                        </div>
                    </div>
                    <div class="p-4 pt-3">
                        <h4 class="mb-1 text-dark fw-bold"><c:out value="${user.fullName}" /></h4>
                        <p class="text-muted small mb-3"><i class="bi bi-envelope me-1"></i> <c:out value="${user.email}" /></p>

                        <div class="d-flex flex-wrap gap-2 mb-4">
                            <c:choose>
                                <c:when test="${user.role == 'ADMIN'}">
                                    <span class="badge-role-admin"><i class="bi bi-shield-lock me-1"></i>Administrator</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge-role-passenger"><i class="bi bi-airplane me-1"></i>Passenger</span>
                                </c:otherwise>
                            </c:choose>
                            <span class="badge-status-active"><i class="bi bi-check2 me-1"></i><c:out value="${user.status}" /></span>
                        </div>

                        <ul class="list-group list-group-flush small">
                            <li class="list-group-item d-flex justify-content-between px-0 py-2">
                                <span class="text-muted">User ID</span>
                                <span class="fw-semibold">#<c:out value="${user.userId}" /></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between px-0 py-2">
                                <span class="text-muted">Phone</span>
                                <span class="fw-semibold"><c:out value="${user.phone}" /></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between px-0 py-2">
                                <span class="text-muted">Passport</span>
                                <span class="fw-semibold">
                                    <c:out value="${not empty user.passportNumber ? user.passportNumber : 'Not Provided'}" />
                                </span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between px-0 py-2">
                                <span class="text-muted">Date of Birth</span>
                                <span class="fw-semibold">
                                    <c:out value="${not empty user.dateOfBirth ? user.dateOfBirth : 'Not Provided'}" />
                                </span>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Right Side: Edit Profile & Password Tabs -->
            <div class="col-lg-8">
                <div class="card border-0 shadow-sm rounded-4 p-4">
                    <ul class="nav nav-tabs nav-fill mb-4" id="profileTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-semibold ${activeTab != 'password' ? 'active' : ''}" id="details-tab"
                                    data-bs-toggle="tab" data-bs-target="#detailsTabPane" type="button" role="tab"
                                    aria-controls="detailsTabPane" aria-selected="${activeTab != 'password'}">
                                <i class="bi bi-person-lines-fill me-1"></i> Personal Details
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-semibold ${activeTab == 'password' ? 'active' : ''}" id="password-tab"
                                    data-bs-toggle="tab" data-bs-target="#passwordTabPane" type="button" role="tab"
                                    aria-controls="passwordTabPane" aria-selected="${activeTab == 'password'}">
                                <i class="bi bi-key-fill me-1"></i> Change Password
                            </button>
                        </li>
                    </ul>

                    <div class="tab-content" id="profileTabsContent">
                        <!-- Details Tab -->
                        <div class="tab-pane fade ${activeTab != 'password' ? 'show active' : ''}" id="detailsTabPane" role="tabpanel" aria-labelledby="details-tab">
                            <form action="${pageContext.request.contextPath}/profile" method="post" class="needs-validation" novalidate>
                                <input type="hidden" name="action" value="update_details">

                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label for="firstName" class="form-label">First Name *</label>
                                        <input type="text" class="form-control" id="firstName" name="firstName"
                                               value="<c:out value='${user.firstName}' />" required pattern="[A-Za-z\s'-]{2,50}">
                                        <div class="invalid-feedback">Enter 2-50 alphabetic characters.</div>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="lastName" class="form-label">Last Name *</label>
                                        <input type="text" class="form-control" id="lastName" name="lastName"
                                               value="<c:out value='${user.lastName}' />" required pattern="[A-Za-z\s'-]{2,50}">
                                        <div class="invalid-feedback">Enter 2-50 alphabetic characters.</div>
                                    </div>
                                </div>

                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label for="email" class="form-label">Email Address</label>
                                        <input type="email" class="form-control bg-light" id="email"
                                               value="<c:out value='${user.email}' />" readonly disabled>
                                        <small class="text-muted" style="font-size: 0.78rem;">Email address cannot be changed directly.</small>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="phone" class="form-label">Phone Number *</label>
                                        <input type="tel" class="form-control" id="phone" name="phone"
                                               value="<c:out value='${user.phone}' />" required pattern="\+?[0-9\s-]{7,20}">
                                        <div class="invalid-feedback">Enter a valid phone number.</div>
                                    </div>
                                </div>

                                <div class="row g-3 mb-4">
                                    <div class="col-md-6">
                                        <label for="passportNumber" class="form-label">Passport Number</label>
                                        <input type="text" class="form-control" id="passportNumber" name="passportNumber"
                                               value="<c:out value='${user.passportNumber}' />" pattern="[A-Za-z0-9]{6,20}">
                                        <div class="invalid-feedback">6-20 alphanumeric characters.</div>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="dateOfBirth" class="form-label">Date of Birth</label>
                                        <input type="date" class="form-control" id="dateOfBirth" name="dateOfBirth"
                                               value="<c:out value='${user.dateOfBirth}' />">
                                        <div class="invalid-feedback">Select a valid past date.</div>
                                    </div>
                                </div>

                                <div class="text-end">
                                    <button type="submit" class="btn btn-primary-airline px-4">
                                        <i class="bi bi-floppy me-1"></i> Save Changes
                                    </button>
                                </div>
                            </form>
                        </div>

                        <!-- Change Password Tab -->
                        <div class="tab-pane fade ${activeTab == 'password' ? 'show active' : ''}" id="passwordTabPane" role="tabpanel" aria-labelledby="password-tab">
                            <c:if test="${not empty passwordError}">
                                <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-3" role="alert">
                                    <i class="bi bi-x-circle-fill me-2 fs-5"></i>
                                    <div><c:out value="${passwordError}" /></div>
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                            </c:if>

                            <form action="${pageContext.request.contextPath}/profile" method="post" class="needs-validation" novalidate>
                                <input type="hidden" name="action" value="change_password">

                                <div class="mb-3">
                                    <label for="currentPassword" class="form-label">Current Password *</label>
                                    <input type="password" class="form-control" id="currentPassword" name="currentPassword"
                                           placeholder="Enter current password" required autocomplete="current-password">
                                    <div class="invalid-feedback">Current password is required.</div>
                                </div>

                                <div class="mb-3">
                                    <label for="password" class="form-label">New Password *</label>
                                    <input type="password" class="form-control" id="password" name="newPassword"
                                           placeholder="Min. 8 characters, upper, lower, digit, symbol" required
                                           pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&amp;_#^~])[A-Za-z\d@$!%*?&amp;_#^~]{8,64}">
                                    <div class="invalid-feedback">Must be >= 8 chars with upper, lower, digit, and special char.</div>
                                    <div class="strength-meter-bar">
                                        <div class="strength-meter-fill" id="strengthFill"></div>
                                    </div>
                                    <div class="mt-1">
                                        <small id="strengthText" class="text-muted" style="font-size: 0.75rem;">Min. 8 characters</small>
                                    </div>
                                </div>

                                <div class="mb-4">
                                    <label for="confirmPassword" class="form-label">Confirm New Password *</label>
                                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword"
                                           placeholder="Re-type new password" required>
                                    <div class="invalid-feedback">Passwords must match.</div>
                                </div>

                                <div class="text-end">
                                    <button type="submit" class="btn btn-warning px-4 fw-semibold">
                                        <i class="bi bi-shield-lock-fill me-1"></i> Update Password
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
