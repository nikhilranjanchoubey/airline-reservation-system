<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="404 - Flight Route Not Found | SkyTech" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<section class="error-hero-banner">
    <div class="error-hero-overlay"></div>
    <main class="container error-page-wrap d-flex align-items-center justify-content-center py-5">
        <div class="error-glass-card text-center p-5">
            <div class="error-badge-glow icon-sky">
                <i class="bi bi-compass-fill"></i>
            </div>
            <h1 class="error-code-title text-primary">404</h1>
            <h2 class="error-heading-text">Flight Route Off Radar</h2>
            <p class="error-desc-text">
                The requested URL or flight navigation path could not be located in our flight management system.
            </p>
            <div class="d-flex justify-content-center gap-3 flex-wrap mt-4">
                <a href="${pageContext.request.contextPath}/" class="btn-error-primary">
                    <i class="bi bi-airplane-fill me-2" style="transform: rotate(-35deg); display: inline-block;"></i>Return to Home Terminal
                </a>
            </div>
        </div>
    </main>
</section>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
