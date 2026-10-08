<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="common/header.jsp" />
<jsp:include page="common/navbar.jsp" />

<main class="py-5 bg-light min-vh-100 d-flex align-items-center">
    <div class="container py-4">
        <div class="row justify-content-center">
            <div class="col-lg-6 col-md-8 text-center">
                <div class="card border-0 shadow-sm p-4 p-md-5 rounded-4 bg-white">
                    <div class="d-inline-flex p-3 rounded-circle bg-danger-subtle text-danger mx-auto mb-4" style="width: 72px; height: 72px; align-items: center; justify-content: center;">
                        <i class="bi bi-exclamation-triangle-fill fs-2"></i>
                    </div>
                    <h2 class="fw-bold text-dark mb-2">Something went wrong</h2>
                    <p class="text-muted mb-4">
                        We apologize for the inconvenience. Our technical team has been notified. Please try again or return to the flight booking portal.
                    </p>
                    <div class="d-flex flex-wrap justify-content-center gap-3">
                        <a href="${pageContext.request.contextPath}/home" class="btn btn-primary rounded-pill px-4 py-2 fw-semibold">
                            <i class="bi bi-house-door me-1"></i> Return Home
                        </a>
                        <a href="${pageContext.request.contextPath}/search-flights" class="btn btn-outline-primary rounded-pill px-4 py-2 fw-semibold">
                            <i class="bi bi-search me-1"></i> Search Flights
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="common/footer.jsp" />
