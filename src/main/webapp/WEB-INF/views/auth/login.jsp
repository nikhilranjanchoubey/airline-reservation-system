<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Sign In - SkyTech Airlines" />
<c:set var="activePage" value="login" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-7 col-lg-5">
                <div class="auth-card">
                    <div class="auth-header">
                        <div class="icon-badge">
                            <i class="bi bi-person-lock"></i>
                        </div>
                        <h2>Welcome Back</h2>
                        <p>Sign in to your SkyTech account to manage bookings & boarding passes</p>
                    </div>

                    <!-- Flash messages -->
                    <c:if test="${not empty flashSuccess}">
                        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert">
                            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
                            <div><c:out value="${flashSuccess}" /></div>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <c:if test="${not empty flashError}">
                        <div class="alert alert-warning alert-dismissible fade show d-flex align-items-center" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
                            <div><c:out value="${flashError}" /></div>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert">
                            <i class="bi bi-x-circle-fill me-2 fs-5"></i>
                            <div><c:out value="${errorMessage}" /></div>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/login" method="post" class="needs-validation" novalidate>
                        <div class="mb-3">
                            <label for="email" class="form-label">Email Address</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light text-muted"><i class="bi bi-envelope"></i></span>
                                <input type="email" class="form-control" id="email" name="email"
                                       value="<c:out value='${loginEmail}' />"
                                       placeholder="passenger@airline.com" required autocomplete="email">
                                <div class="invalid-feedback">Please enter a valid email address.</div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="password" class="form-label">Password</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light text-muted"><i class="bi bi-lock"></i></span>
                                <input type="password" class="form-control" id="password" name="password"
                                       placeholder="Enter your password" required autocomplete="current-password">
                                <div class="invalid-feedback">Password is required.</div>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary-airline w-100 mb-3">
                            <i class="bi bi-box-arrow-in-right me-1"></i> Sign In to SkyTech
                        </button>

                        <div class="text-center text-muted small">
                            Don't have an account yet? 
                            <a href="${pageContext.request.contextPath}/register" class="fw-semibold text-decoration-none">Create Passenger Account</a>
                        </div>
                    </form>

                    <!-- Quick Demo Credentials Guide -->
                    <div class="mt-4 p-3 bg-light rounded-3 border">
                        <div class="d-flex align-items-center text-secondary small fw-bold mb-2">
                            <i class="bi bi-info-circle-fill me-1 text-primary"></i> Pre-seeded Demo Credentials
                        </div>
                        <div class="small text-muted">
                            <div><strong>Admin:</strong> <code>admin@airline.com</code> / <code>Admin@12345</code></div>
                            <div><strong>Passenger:</strong> <code>passenger@airline.com</code> / <code>Passenger@12345</code></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
