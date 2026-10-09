<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<nav class="navbar navbar-expand-lg navbar-dark navbar-skytech sticky-top">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">
            <span class="brand-icon-wrap">
                <i class="bi bi-airplane-fill"></i>
            </span>
            <span>SkyTech</span>
        </a>
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#skytechNav" aria-controls="skytechNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="skytechNav">
            <!-- Center Navigation Links (Matching SkyTech UI) -->
            <ul class="navbar-nav mx-auto align-items-lg-center gap-1 my-2 my-lg-0">
                <li class="nav-item">
                    <a class="nav-link ${empty activePage || activePage == 'home' ? 'active' : ''}" href="${pageContext.request.contextPath}/">
                        Home
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'flights' ? 'active' : ''}" href="${pageContext.request.contextPath}/#flightsSection">
                        Flights
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'checkin' ? 'active' : ''}" href="${pageContext.request.contextPath}/#checkinSection">
                        Check-In
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'services' ? 'active' : ''}" href="${pageContext.request.contextPath}/#servicesSection">
                        Services
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'contact' ? 'active' : ''}" href="${pageContext.request.contextPath}/#contactSection">
                        Contact
                    </a>
                </li>
            </ul>

            <!-- Right Action / User Session -->
            <ul class="navbar-nav align-items-lg-center gap-2">
                <c:choose>
                    <c:when test="${not empty sessionScope.currentUser}">
                        <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                            <li class="nav-item">
                                <a class="nav-link ${activePage == 'admin' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/dashboard">
                                    <i class="bi bi-shield-lock-fill text-warning me-1"></i> Admin Panel
                                </a>
                            </li>
                        </c:if>

                        <li class="nav-item">
                            <a class="nav-link ${activePage == 'profile' ? 'active' : ''}" href="${pageContext.request.contextPath}/profile">
                                <i class="bi bi-person-circle me-1"></i>
                                <c:out value="${sessionScope.currentUser.firstName}" />
                            </a>
                        </li>

                        <li class="nav-item">
                            <a class="btn btn-sm btn-outline-light rounded-pill px-3 py-1 text-light" href="${pageContext.request.contextPath}/logout">
                                <i class="bi bi-box-arrow-right me-1"></i> Sign Out
                            </a>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item">
                            <a class="nav-link ${activePage == 'login' ? 'active' : ''}" href="${pageContext.request.contextPath}/login">
                                <i class="bi bi-box-arrow-in-right me-1"></i> Sign In
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="btn-skytech-auth text-decoration-none d-inline-block text-center" href="${pageContext.request.contextPath}/register">
                                Login / Sign Up
                            </a>
                        </li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>
