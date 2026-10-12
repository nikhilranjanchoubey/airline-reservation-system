<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Passenger Management & Account Registry | SkyTech" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <c:set var="activeTab" value="passengers" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">Passenger Management & Directory</h1>
                <div class="admin-header-meta">
                    <span>Inspect registered passenger accounts, verify booking history, and manage authorization status</span>
                </div>
            </div>
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

        <!-- Search & Filter Bar -->
        <form method="GET" action="${pageContext.request.contextPath}/admin/passengers" class="admin-filter-bar">
            <input type="text" name="search" class="admin-form-control flex-grow-1" placeholder="Search by passenger name, email, or phone..." value="<c:out value='${search}' />">
            <select name="status" class="admin-form-control">
                <option value="ALL">All Account Statuses</option>
                <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                <option value="SUSPENDED" ${status == 'SUSPENDED' ? 'selected' : ''}>Suspended</option>
            </select>
            <select name="role" class="admin-form-control">
                <option value="ALL">All Roles</option>
                <option value="PASSENGER" ${role == 'PASSENGER' ? 'selected' : ''}>Passenger</option>
                <option value="ADMIN" ${role == 'ADMIN' ? 'selected' : ''}>Administrator</option>
            </select>
            <button type="submit" class="admin-btn admin-btn-secondary">
                <i class="bi bi-search"></i> Search
            </button>
            <a href="${pageContext.request.contextPath}/admin/passengers" class="admin-btn admin-btn-outline">Reset</a>
        </form>

        <!-- Passenger Detail Inspection Card if viewing specific passenger -->
        <c:if test="${not empty passengerDetails}">
            <div class="admin-card border-primary mb-4">
                <div class="admin-card-header bg-light">
                    <h2 class="admin-card-title text-navy">
                        <i class="bi bi-person-lines-fill text-primary"></i> Passenger Record: <c:out value="${passengerDetails.firstName}" /> <c:out value="${passengerDetails.lastName}" />
                    </h2>
                    <a href="${pageContext.request.contextPath}/admin/passengers" class="btn btn-sm btn-outline-secondary">Close View</a>
                </div>
                <div class="row g-3 p-3">
                    <div class="col-md-3">
                        <div class="text-muted small">Account ID</div>
                        <div class="fw-bold">#${passengerDetails.userId}</div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small">Email Address</div>
                        <div class="fw-semibold"><c:out value="${passengerDetails.email}" /></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small">Phone Number</div>
                        <div><c:out value="${not empty passengerDetails.phone ? passengerDetails.phone : 'Not Registered'}" /></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small">Passport Reference</div>
                        <div><code class="text-dark"><c:out value="${passengerDetails.passportNumber}" /></code></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small">Account Role</div>
                        <div><span class="badge bg-navy text-white"><c:out value="${passengerDetails.role}" /></span></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small">Account Status</div>
                        <div><span class="badge-status badge-status-${passengerDetails.status.toLowerCase()}"><c:out value="${passengerDetails.status}" /></span></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small">Member Since</div>
                        <div><fmt:formatDate value="${passengerDetails.createdAt}" pattern="dd MMM yyyy" /></div>
                    </div>
                </div>

                <!-- Linked Booking History -->
                <div class="mt-4 border-top pt-3">
                    <h5 class="fs-6 fw-bold text-navy mb-3"><i class="bi bi-clock-history me-1"></i> Flight Reservation History</h5>
                    <c:choose>
                        <c:when test="${not empty passengerBookings}">
                            <div class="admin-table-wrap">
                                <table class="admin-table">
                                    <thead>
                                        <tr>
                                            <th>Booking Ref / PNR</th>
                                            <th>Flight</th>
                                            <th>Route</th>
                                            <th>Travel Date</th>
                                            <th>Total Fare</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="pb" items="${passengerBookings}">
                                            <tr>
                                                <td class="fw-bold"><c:out value="${not empty pb.pnr ? pb.pnr : pb.bookingReference}" /></td>
                                                <td><c:out value="${pb.flightNumber}" /></td>
                                                <td><c:out value="${pb.originCode}" /> → <c:out value="${pb.destCode}" /></td>
                                                <td><fmt:formatDate value="${pb.departureDate}" pattern="dd MMM yyyy" /></td>
                                                <td class="fw-semibold">₹<fmt:formatNumber value="${pb.totalAmount}" maxFractionDigits="0" /></td>
                                                <td><span class="badge-status badge-status-${pb.status.toLowerCase()}"><c:out value="${pb.status}" /></span></td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-muted p-3 text-center">No reservations found under this account.</div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>

        <!-- Passengers Directory Table -->
        <div class="admin-card">
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>User ID</th>
                            <th>Passenger Name</th>
                            <th>Email Address</th>
                            <th>Mobile</th>
                            <th>Passport</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Bookings</th>
                            <th>Confirmed Spend</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty passengers}">
                                <c:forEach var="u" items="${passengers}">
                                    <tr>
                                        <td>#${u.userId}</td>
                                        <td class="fw-bold text-navy">
                                            <c:out value="${u.firstName}" /> <c:out value="${u.lastName}" />
                                        </td>
                                        <td><c:out value="${u.email}" /></td>
                                        <td><c:out value="${not empty u.phone ? u.phone : '—'}" /></td>
                                        <td><small class="text-muted font-monospace"><c:out value="${u.passportNumber}" /></small></td>
                                        <td>
                                            <span class="badge ${u.role == 'ADMIN' ? 'bg-primary' : 'bg-light text-dark border'}">
                                                <c:out value="${u.role}" />
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge-status badge-status-${u.status.toLowerCase()}">
                                                <c:out value="${u.status}" />
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge bg-light text-navy border">${u.totalBookings}</span>
                                        </td>
                                        <td class="fw-semibold text-success">
                                            ₹<fmt:formatNumber value="${u.totalSpent}" maxFractionDigits="0" />
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-1">
                                                <a href="${pageContext.request.contextPath}/admin/passengers?action=view&userId=${u.userId}"
                                                   class="btn btn-sm btn-outline-primary py-0 px-2" style="font-size: 0.78rem;" title="View Details">
                                                    <i class="bi bi-eye"></i> View
                                                </a>

                                                <!-- Suspend / Activate toggle (safe check) -->
                                                <c:if test="${sessionScope.currentUser.userId != u.userId}">
                                                    <form method="POST" action="${pageContext.request.contextPath}/admin/passengers" class="d-inline">
                                                        <input type="hidden" name="action" value="toggle_status">
                                                        <input type="hidden" name="userId" value="${u.userId}">
                                                        <c:choose>
                                                            <c:when test="${u.status == 'ACTIVE'}">
                                                                <input type="hidden" name="newStatus" value="SUSPENDED">
                                                                <button type="submit" class="btn btn-sm btn-outline-danger py-0 px-2" style="font-size: 0.78rem;" title="Suspend Account" onclick="return confirm('Suspend user account #${u.userId}?');">
                                                                    Suspend
                                                                </button>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <input type="hidden" name="newStatus" value="ACTIVE">
                                                                <button type="submit" class="btn btn-sm btn-outline-success py-0 px-2" style="font-size: 0.78rem;" title="Activate Account">
                                                                    Activate
                                                                </button>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="10">
                                        <div class="admin-empty-state">
                                            <i class="bi bi-people admin-empty-icon"></i>
                                            <div class="admin-empty-title">No Passengers Found</div>
                                            <div class="admin-empty-desc">No accounts found matching the search criteria.</div>
                                        </div>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="admin-pagination">
                    <span>Showing page ${currentPage} of ${totalPages} (${totalCount} total passengers)</span>
                    <div class="admin-page-links">
                        <c:forEach var="p" begin="1" end="${totalPages}">
                            <a href="${pageContext.request.contextPath}/admin/passengers?page=${p}&search=${search}&status=${status}&role=${role}"
                               class="admin-page-btn ${currentPage == p ? 'active' : ''}">${p}</a>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
        </div>
    </main>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
