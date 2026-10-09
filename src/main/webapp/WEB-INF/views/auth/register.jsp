<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Create Account - SkyTech Airlines" />
<c:set var="activePage" value="register" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8 col-xl-7">
                <div class="auth-card">
                    <div class="auth-header">
                        <div class="icon-badge">
                            <i class="bi bi-person-plus"></i>
                        </div>
                        <h2>Create Passenger Account</h2>
                        <p>Join SkyTech Airlines for seamless flight booking, seat selection, and digital boarding passes</p>
                    </div>

                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert">
                            <i class="bi bi-exclamation-octagon-fill me-2 fs-5"></i>
                            <div><c:out value="${errorMessage}" /></div>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/register" method="post" class="needs-validation" novalidate>
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="firstName" class="form-label">First Name *</label>
                                <input type="text" class="form-control" id="firstName" name="firstName"
                                       value="<c:out value='${regFirstName}' />"
                                       placeholder="e.g. John" required pattern="[A-Za-z\s'-]{2,50}">
                                <div class="invalid-feedback">Enter 2-50 alphabetic characters.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="lastName" class="form-label">Last Name *</label>
                                <input type="text" class="form-control" id="lastName" name="lastName"
                                       value="<c:out value='${regLastName}' />"
                                       placeholder="e.g. Doe" required pattern="[A-Za-z\s'-]{2,50}">
                                <div class="invalid-feedback">Enter 2-50 alphabetic characters.</div>
                            </div>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="email" class="form-label">Email Address *</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light text-muted"><i class="bi bi-envelope"></i></span>
                                    <input type="email" class="form-control" id="email" name="email"
                                           value="<c:out value='${regEmail}' />"
                                           placeholder="john.doe@example.com" required>
                                    <div class="invalid-feedback">Enter a valid email address.</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label for="phone" class="form-label">Phone Number *</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light text-muted"><i class="bi bi-telephone"></i></span>
                                    <input type="tel" class="form-control" id="phone" name="phone"
                                           value="<c:out value='${regPhone}' />"
                                           placeholder="+1 555-0123" required pattern="\+?[0-9\s-]{7,20}">
                                    <div class="invalid-feedback">Enter a valid phone number (7-15 digits).</div>
                                </div>
                            </div>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="passportNumber" class="form-label">Passport Number <span class="text-muted fw-normal">(Optional)</span></label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light text-muted"><i class="bi bi-passport"></i></span>
                                    <input type="text" class="form-control" id="passportNumber" name="passportNumber"
                                           value="<c:out value='${regPassport}' />"
                                           placeholder="e.g. A12345678" pattern="[A-Za-z0-9]{6,20}">
                                    <div class="invalid-feedback">6-20 alphanumeric characters if provided.</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label for="dateOfBirth" class="form-label">Date of Birth <span class="text-muted fw-normal">(Optional)</span></label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light text-muted"><i class="bi bi-calendar"></i></span>
                                    <input type="date" class="form-control" id="dateOfBirth" name="dateOfBirth"
                                           value="<c:out value='${regDob}' />">
                                    <div class="invalid-feedback">Select a valid past date.</div>
                                </div>
                            </div>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="password" class="form-label">Password *</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light text-muted"><i class="bi bi-key"></i></span>
                                    <input type="password" class="form-control" id="password" name="password"
                                           placeholder="Min. 8 characters" required
                                           pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&amp;_#^~])[A-Za-z\d@$!%*?&amp;_#^~]{8,64}">
                                    <button class="btn btn-outline-secondary" type="button" id="togglePasswordBtn">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                    <div class="invalid-feedback">Requires upper, lower, number, special character (8+ chars).</div>
                                </div>
                                <div class="strength-meter-bar">
                                    <div id="strengthMeter" class="strength-meter-fill"></div>
                                </div>
                                <small id="strengthText" class="text-muted" style="font-size: 0.75rem;">Password strength</small>
                            </div>
                            <div class="col-md-6">
                                <label for="confirmPassword" class="form-label">Confirm Password *</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light text-muted"><i class="bi bi-shield-check"></i></span>
                                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword"
                                           placeholder="Re-enter password" required>
                                    <div class="invalid-feedback">Passwords must match.</div>
                                </div>
                            </div>
                        </div>

                        <div class="form-check mb-4">
                            <input class="form-check-input" type="checkbox" id="terms" required>
                            <label class="form-check-label small text-muted" for="terms">
                                I agree to SkyTech Airlines <a href="#" class="text-primary text-decoration-none">Terms of Carriage</a> and <a href="#" class="text-primary text-decoration-none">Privacy Policy</a>.
                            </label>
                            <div class="invalid-feedback">You must agree before registering.</div>
                        </div>

                        <button type="submit" class="btn btn-primary-airline w-100 py-3 mb-3">
                            <i class="bi bi-check2-circle me-1"></i> Register Passenger Account
                        </button>

                        <div class="text-center text-muted small">
                            Already registered with SkyTech? 
                            <a href="${pageContext.request.contextPath}/login" class="fw-semibold text-decoration-none">Sign In Here</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
