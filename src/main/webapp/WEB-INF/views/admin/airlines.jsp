<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Airline Operator Management | SkyTech Administration" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <c:set var="activeTab" value="airlines" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">Airline Operator Registry</h1>
                <div class="admin-header-meta">
                    <span>Manage commercial airline operators, IATA codes, and network carrier branding</span>
                </div>
            </div>
            <button type="button" class="admin-btn admin-btn-primary" data-bs-toggle="modal" data-bs-target="#addAirlineModal">
                <i class="bi bi-plus-lg"></i> Register Carrier
            </button>
        </div>

        <!-- Flash alerts -->
        <c:if test="${not empty flashSuccess}">
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
                <i class="bi bi-check-circle-fill"></i>
                <div><c:out value="${flashSuccess}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty flashError}">
            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill"></i>
                <div><c:out value="${flashError}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="admin-card">
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Airline ID</th>
                            <th>Designator Code</th>
                            <th>Carrier Name</th>
                            <th>Icon / Brand</th>
                            <th>Registered At</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="al" items="${airlines}">
                            <tr>
                                <td>#${al.airlineId}</td>
                                <td>
                                    <span class="badge bg-primary text-white fs-6 px-2 py-1"><c:out value="${al.airlineCode}" /></span>
                                </td>
                                <td class="fw-bold text-navy"><c:out value="${al.airlineName}" /></td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <i class="bi ${al.logoIcon} fs-5 text-primary"></i>
                                        <small class="text-muted"><c:out value="${al.logoIcon}" /></small>
                                    </div>
                                </td>
                                <td><c:out value="${al.createdAt}" /></td>
                                <td>
                                    <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2" style="font-size: 0.78rem;"
                                            data-bs-toggle="modal" data-bs-target="#editAirlineModal${al.airlineId}">
                                        <i class="bi bi-pencil-square"></i> Edit
                                    </button>

                                    <!-- Edit Modal -->
                                    <div class="modal fade" id="editAirlineModal${al.airlineId}" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog">
                                            <div class="modal-content">
                                                <form method="POST" action="${pageContext.request.contextPath}/admin/airlines">
                                                    <input type="hidden" name="action" value="edit">
                                                    <input type="hidden" name="airlineId" value="${al.airlineId}">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title fw-bold text-navy">Edit Carrier: ${al.airlineCode}</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body p-4">
                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">Carrier Code <span class="text-danger">*</span></label>
                                                            <input type="text" name="airlineCode" maxlength="3" class="form-control text-uppercase" value="${al.airlineCode}" required>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">Carrier Name <span class="text-danger">*</span></label>
                                                            <input type="text" name="airlineName" class="form-control" value="${al.airlineName}" required>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">Bootstrap Icon Class</label>
                                                            <input type="text" name="logoIcon" class="form-control" value="${al.logoIcon}">
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                                        <button type="submit" class="admin-btn admin-btn-primary">Save Changes</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<!-- Modal: Add Airline -->
<div class="modal fade" id="addAirlineModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST" action="${pageContext.request.contextPath}/admin/airlines">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold text-navy">
                        <i class="bi bi-building text-primary me-2"></i> Register Airline Carrier
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Carrier IATA Code <span class="text-danger">*</span></label>
                        <input type="text" name="airlineCode" maxlength="3" class="form-control text-uppercase" placeholder="e.g. 6E" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Carrier Legal Name <span class="text-danger">*</span></label>
                        <input type="text" name="airlineName" class="form-control" placeholder="e.g. IndiGo" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Icon Identifier</label>
                        <input type="text" name="logoIcon" class="form-control" value="bi-airplane-fill">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="admin-btn admin-btn-primary">Register Carrier</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
