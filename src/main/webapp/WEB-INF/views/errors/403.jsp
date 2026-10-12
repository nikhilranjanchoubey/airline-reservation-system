<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="403 - Restricted Airspace | SkyTech" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<section class="error-hero-banner">
    <div class="error-hero-overlay"></div>
    <main class="container error-page-wrap d-flex align-items-center justify-content-center py-5">
        <div class="error-glass-card text-center p-5">
            <div class="error-badge-glow icon-danger">
                <i class="bi bi-shield-lock-fill"></i>
            </div>
            <h1 class="error-code-title text-danger">403</h1>
            <h2 class="error-heading-text">Restricted Airspace</h2>
            <p class="error-desc-text">
                Access Denied. You do not possess the required administrator security clearance to enter this flight management sector.
            </p>
            <div class="d-flex justify-content-center gap-3 flex-wrap mt-4">
                <a href="${pageContext.request.contextPath}/profile" class="btn-error-primary">
                    <i class="bi bi-person-circle me-2"></i>My Passenger Profile
                </a>
                <a href="${pageContext.request.contextPath}/" class="btn-error-secondary">
                    <i class="bi bi-airplane-fill me-2" style="transform: rotate(-35deg); display: inline-block;"></i>Home Terminal
                </a>
            </div>
        </div>
    </main>
</section>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
