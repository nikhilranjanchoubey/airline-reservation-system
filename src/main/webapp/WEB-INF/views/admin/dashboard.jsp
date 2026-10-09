<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Admin Dashboard - SkyTech Airlines" />
<c:set var="activePage" value="admin" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="py-5">
    <div class="container">
        <!-- Header Banner -->
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center mb-4">
            <div>
                <span class="section-badge"><i class="bi bi-shield-check me-1"></i> Management Console</span>
                <h2 class="fw-bold text-dark mb-1">SkyTech Administrator Dashboard</h2>
                <p class="text-muted small mb-0">System metrics, passenger registry & access governance</p>
            </div>
            <div class="mt-3 mt-md-0">
                <a href="${pageContext.request.contextPath}/profile" class="btn btn-outline-primary rounded-pill px-3 py-2 small fw-semibold">
                    <i class="bi bi-person-circle me-1"></i> Admin Profile
                </a>
            </div>
        </div>

        <!-- Flash alerts -->
        <c:if test="${not empty flashSuccess}">
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                <i class="bi bi-check-circle-fill me-2 fs-5"></i>
                <div><c:out value="${flashSuccess}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <c:if test="${not empty sessionScope.flashError}">
            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                <i class="bi bi-exclamation-octagon-fill me-2 fs-5"></i>
                <div><c:out value="${sessionScope.flashError}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="flashError" scope="session" />
        </c:if>

        <!-- KPI Metric Cards -->
        <div class="row g-3 mb-4">
            <div class="col-sm-6 col-lg-3">
                <div class="stat-card">
                    <div class="stat-icon bg-primary-subtle text-primary">
                        <i class="bi bi-people-fill"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Total Registered</div>
                        <h3 class="fw-bold text-dark mb-0"><c:out value="${totalUsers}" /></h3>
                    </div>
                </div>
            </div>

            <div class="col-sm-6 col-lg-3">
                <div class="stat-card">
                    <div class="stat-icon bg-info-subtle text-info">
                        <i class="bi bi-airplane-engines-fill"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Active Passengers</div>
                        <h3 class="fw-bold text-dark mb-0"><c:out value="${passengerCount}" /></h3>
                    </div>
                </div>
            </div>

            <div class="col-sm-6 col-lg-3">
                <div class="stat-card">
                    <div class="stat-icon bg-warning-subtle text-warning">
                        <i class="bi bi-shield-lock-fill"></i>
                    </div>
                    <div>
                        <div class="text-muted small">System Admins</div>
                        <h3 class="fw-bold text-dark mb-0"><c:out value="${adminCount}" /></h3>
                    </div>
                </div>
            </div>

            <div class="col-sm-6 col-lg-3">
                <div class="stat-card">
                    <div class="stat-icon bg-success-subtle text-success">
                        <i class="bi bi-check-circle-fill"></i>
                    </div>
                    <div>
                        <div class="text-muted small">Active Accounts</div>
                        <h3 class="fw-bold text-dark mb-0"><c:out value="${activeCount}" /></h3>
                    </div>
                </div>
            </div>
        </div>

        <!-- Users Table -->
        <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
            <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                <h5 class="fw-bold mb-0 text-dark"><i class="bi bi-table me-2 text-primary"></i>User Accounts Registry</h5>
                <span class="badge bg-light text-muted border px-3 py-2">Live Database</span>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light small text-muted text-uppercase">
                        <tr>
                            <th class="ps-4">ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Joined</th>
                            <th class="text-end pe-4">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="u" items="${users}">
                            <tr>
                                <td class="ps-4 fw-bold text-secondary">#<c:out value="${u.userId}" /></td>
                                <td>
                                    <div class="fw-semibold text-dark"><c:out value="${u.fullName}" /></div>
                                    <c:if test="${not empty u.passportNumber}">
                                        <small class="text-muted"><i class="bi bi-passport me-1"></i><c:out value="${u.passportNumber}" /></small>
                                    </c:if>
                                </td>
                                <td><c:out value="${u.email}" /></td>
                                <td><c:out value="${u.phone}" /></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.role == 'ADMIN'}">
                                            <span class="badge-role-admin"><i class="bi bi-shield-lock me-1"></i>ADMIN</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-role-passenger"><i class="bi bi-airplane me-1"></i>PASSENGER</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.status == 'ACTIVE'}">
                                            <span class="badge-status-active"><i class="bi bi-check2 me-1"></i>ACTIVE</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-status-suspended"><i class="bi bi-slash-circle me-1"></i>SUSPENDED</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="small text-muted">
                                    <c:out value="${u.createdAt != null ? u.createdAt : 'N/A'}" />
                                </td>
                                <td class="text-end pe-4">
                                    <form action="${pageContext.request.contextPath}/admin/dashboard" method="post" class="d-inline">
                                        <input type="hidden" name="action" value="toggle_status">
                                        <input type="hidden" name="userId" value="${u.userId}">
                                        <c:choose>
                                            <c:when test="${u.status == 'ACTIVE'}">
                                                <button type="submit" class="btn btn-sm btn-outline-danger" title="Suspend Account"
                                                        <c:if test="${sessionScope.currentUser.userId == u.userId}">disabled</c:if>>
                                                    <i class="bi bi-slash-circle me-1"></i> Suspend
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="submit" class="btn btn-sm btn-outline-success" title="Activate Account">
                                                    <i class="bi bi-check-circle me-1"></i> Activate
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
