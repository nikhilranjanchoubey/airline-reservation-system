<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="404 - Flight Route Not Found | SkyTech" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="py-5 d-flex align-items-center" style="min-height: 70vh;">
    <div class="container text-center">
        <div class="row justify-content-center">
            <div class="col-md-7 col-lg-5">
                <div class="auth-card p-5">
                    <div class="display-1 fw-bold text-primary mb-2">404</div>
                    <div class="fs-4 fw-bold text-dark mb-2">Flight Route Off Radar</div>
                    <p class="text-muted small mb-4">
                        The page or resource you requested could not be located in our flight navigation computer.
                    </p>
                    <a href="${pageContext.request.contextPath}/" class="btn btn-primary-airline px-4 py-2">
                        <i class="bi bi-airplane me-1"></i> Return to Terminal
                    </a>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
