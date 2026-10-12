<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Airport Stations & Network Infrastructure | SkyTech" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <c:set var="activeTab" value="airports" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">Airport Stations & Hub Management</h1>
                <div class="admin-header-meta">
                    <span>Manage commercial airport stations, IATA codes, cities, and terminal facilities</span>
                </div>
            </div>
            <button type="button" class="admin-btn admin-btn-primary" data-bs-toggle="modal" data-bs-target="#addAirportModal">
                <i class="bi bi-plus-lg"></i> Add Station
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
                            <th>Station ID</th>
                            <th>IATA Code</th>
                            <th>Airport Facility Name</th>
                            <th>City / Metro</th>
                            <th>Country</th>
                            <th>Default Terminal</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="ap" items="${airports}">
                            <tr>
                                <td>#${ap.airportId}</td>
                                <td>
                                    <span class="badge bg-primary text-white fs-6 px-2 py-1"><c:out value="${ap.airportCode}" /></span>
                                </td>
                                <td class="fw-bold text-navy"><c:out value="${ap.airportName}" /></td>
                                <td><c:out value="${ap.city}" /></td>
                                <td><c:out value="${ap.country}" /></td>
                                <td><span class="badge bg-light text-dark border"><c:out value="${not empty ap.terminal ? ap.terminal : 'Terminal 1'}" /></span></td>
                                <td>
                                    <button type="button" class="btn btn-sm btn-outline-secondary py-0 px-2" style="font-size: 0.78rem;"
                                            data-bs-toggle="modal" data-bs-target="#editAirportModal${ap.airportId}">
                                        <i class="bi bi-pencil-square"></i> Edit
                                    </button>

                                    <!-- Edit Modal for this airport -->
                                    <div class="modal fade" id="editAirportModal${ap.airportId}" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog">
                                            <div class="modal-content">
                                                <form method="POST" action="${pageContext.request.contextPath}/admin/airports">
                                                    <input type="hidden" name="action" value="edit">
                                                    <input type="hidden" name="airportId" value="${ap.airportId}">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title fw-bold text-navy">Edit Airport: ${ap.airportCode}</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body p-4">
                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">IATA Code <span class="text-danger">*</span></label>
                                                            <input type="text" name="airportCode" maxlength="3" class="form-control text-uppercase" value="${ap.airportCode}" required>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">Airport Name <span class="text-danger">*</span></label>
                                                            <input type="text" name="airportName" class="form-control" value="${ap.airportName}" required>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">City <span class="text-danger">*</span></label>
                                                            <input type="text" name="city" class="form-control" value="${ap.city}" required>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">Country</label>
                                                            <input type="text" name="country" class="form-control" value="${ap.country}">
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label fw-semibold">Terminal</label>
                                                            <input type="text" name="terminal" class="form-control" value="${ap.terminal}">
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

<!-- Modal: Add Airport -->
<div class="modal fade" id="addAirportModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST" action="${pageContext.request.contextPath}/admin/airports">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold text-navy">
                        <i class="bi bi-geo-alt-fill text-primary me-2"></i> Register Airport Station
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">3-Letter IATA Code <span class="text-danger">*</span></label>
                        <input type="text" name="airportCode" maxlength="3" class="form-control text-uppercase" placeholder="e.g. BLR" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Airport Official Name <span class="text-danger">*</span></label>
                        <input type="text" name="airportName" class="form-control" placeholder="e.g. Kempegowda International Airport" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">City <span class="text-danger">*</span></label>
                        <input type="text" name="city" class="form-control" placeholder="e.g. Bengaluru" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Country</label>
                        <input type="text" name="country" class="form-control" value="India">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Terminal Facility</label>
                        <input type="text" name="terminal" class="form-control" value="Terminal 1">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="admin-btn admin-btn-primary">Add Airport</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
