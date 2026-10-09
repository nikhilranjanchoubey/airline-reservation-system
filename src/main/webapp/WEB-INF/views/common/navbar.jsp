<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<nav class="navbar navbar-expand-lg navbar-skytech">
    <div class="container-fluid px-lg-5">
        <!-- Logo matching screenshot -->
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">
            <span class="brand-plane-icon">
                <i class="bi bi-airplane-fill"></i>
            </span>
            <div class="brand-text-stack">
                <span class="brand-name">SkyTech</span>
                <span class="brand-tagline">AIRLINES</span>
            </div>
        </a>

        <button class="navbar-toggler border-0 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#skytechNav" aria-controls="skytechNav" aria-expanded="false" aria-label="Toggle navigation">
            <i class="bi bi-list fs-2 text-white"></i>
        </button>

        <div class="collapse navbar-collapse" id="skytechNav">
            <!-- Center Navigation Links -->
            <ul class="navbar-nav mx-auto align-items-lg-center gap-1 my-3 my-lg-0">
                <li class="nav-item">
                    <a class="nav-link ${empty activePage || activePage == 'home' ? 'active' : ''}" href="${pageContext.request.contextPath}/">
                        Home
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'flights' ? 'active' : ''}" href="${pageContext.request.contextPath}/#searchPanelSection">
                        Flights
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'checkin' ? 'active' : ''}" href="${pageContext.request.contextPath}/#searchPanelSection">
                        Check-In
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'services' ? 'active' : ''}" href="${pageContext.request.contextPath}/#servicesSection">
                        Services
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'contact' ? 'active' : ''}" href="${pageContext.request.contextPath}/#footerSection">
                        Contact
                    </a>
                </li>
            </ul>

            <!-- Right Action Bar: Search Icon, Login, Sign Up -->
            <div class="d-flex align-items-center gap-3">
                <button type="button" class="nav-search-trigger" onclick="document.getElementById('searchFromAirport').focus()" title="Quick Flight Search" aria-label="Search Flights">
                    <i class="bi bi-search"></i>
                </button>

                <c:choose>
                    <c:when test="${not empty sessionScope.currentUser}">
                        <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                            <a class="nav-link text-warning fw-semibold px-2" href="${pageContext.request.contextPath}/admin/dashboard">
                                <i class="bi bi-shield-lock-fill me-1"></i> Admin Panel
                            </a>
                        </c:if>

                        <a class="nav-link text-white fw-semibold px-2" href="${pageContext.request.contextPath}/profile">
                            <i class="bi bi-person-circle me-1"></i> <c:out value="${sessionScope.currentUser.firstName}" />
                        </a>

                        <a class="btn btn-sm btn-outline-light rounded-pill px-3 py-1" href="${pageContext.request.contextPath}/logout">
                            Sign Out
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a class="nav-link text-white fw-semibold px-2" href="${pageContext.request.contextPath}/login">
                            Login
                        </a>
                        <a class="btn-electric-signup" href="${pageContext.request.contextPath}/register">
                            Sign Up
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>
