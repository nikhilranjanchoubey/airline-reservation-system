<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Aircraft & Seats | SkyTech Administration" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

<style>
/* Scoped styles for Aircraft & Cabin seat map presentation */
.aircraft-stat-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 20px;
    margin-bottom: 28px;
    width: 100%;
}

.cabin-fuselage-box {
    background: #FFFFFF;
    border: 1px solid var(--sky-border);
    border-radius: var(--sky-radius-md);
    padding: 24px;
    box-shadow: var(--sky-shadow-sm);
    margin-bottom: 28px;
}

.cabin-cockpit-nose {
    text-align: center;
    padding-bottom: 16px;
    margin-bottom: 16px;
    border-bottom: 2px dashed #E2E8F0;
}

.cabin-grid-scroll {
    max-height: 420px;
    overflow-y: auto;
    overflow-x: auto;
    padding: 16px;
    background: #F8FAFC;
    border-radius: var(--sky-radius-sm);
    border: 1px solid #E2E8F0;
    -webkit-overflow-scrolling: touch;
}

.cabin-row-line {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    margin-bottom: 8px;
    min-width: 480px;
}

.cabin-row-badge {
    width: 32px;
    font-size: 0.78rem;
    font-weight: 700;
    color: var(--sky-muted);
    text-align: center;
    flex-shrink: 0;
}

.cabin-seat-cell {
    width: 46px;
    height: 38px;
    border-radius: 6px;
    border: 1px solid #CBD5E1;
    background: #FFFFFF;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    font-size: 0.76rem;
    font-weight: 700;
    color: var(--sky-navy);
    box-shadow: 0 1px 2px rgba(0,0,0,0.04);
    transition: transform 0.15s ease;
    flex-shrink: 0;
}

.cabin-seat-cell:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.08);
}

.cabin-seat-cell.seat-extra {
    background: #EFF6FF;
    border-color: #93C5FD;
    color: #1D4ED8;
}

.cabin-seat-cell.seat-exit {
    background: #FEF3C7;
    border-color: #FCD34D;
    color: #B45309;
}

.cabin-seat-sub {
    font-size: 0.58rem;
    font-weight: 500;
    color: var(--sky-muted);
    line-height: 1;
}

.cabin-aisle-divider {
    width: 36px;
    text-align: center;
    font-size: 0.68rem;
    font-weight: 600;
    color: #94A3B8;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    flex-shrink: 0;
}

@media (max-width: 991.98px) {
    .aircraft-stat-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 16px;
    }
}

@media (max-width: 576px) {
    .aircraft-stat-grid {
        grid-template-columns: 1fr;
        gap: 14px;
    }
    .cabin-row-line {
        min-width: 420px;
    }
}
</style>

<body class="admin-body">
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<div class="admin-layout-wrapper">
    <c:set var="activeTab" value="aircraft" scope="request" />
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="admin-main">
        <!-- Page Header -->
        <div class="admin-page-header">
            <div>
                <h1 class="admin-header-title">Aircraft &amp; Seats</h1>
                <div class="admin-header-meta">
                    <span>Manage commercial aircraft fleet specifications, cabin row configurations, and passenger seat layouts.</span>
                </div>
            </div>
            <button type="button" class="admin-btn admin-btn-primary" data-bs-toggle="modal" data-bs-target="#addAircraftModal">
                <i class="bi bi-plus-lg"></i> Register Aircraft
            </button>
        </div>

        <!-- Flash alerts -->
        <c:if test="${not empty flashSuccess}">
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
                <i class="bi bi-check-circle-fill fs-5"></i>
                <div><c:out value="${flashSuccess}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${not empty flashError}">
            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                <div><c:out value="${flashError}" /></div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Fleet Metric Cards (Genuine Database-Derived Totals) -->
        <div class="aircraft-stat-grid">
            <!-- 1. Total Configured Aircraft -->
            <div class="admin-kpi-card">
                <div>
                    <div class="admin-kpi-label">Total Aircraft</div>
                    <div class="admin-kpi-value"><c:out value="${totalAircraft}" /></div>
                    <small class="text-muted">Registered models in fleet</small>
                </div>
                <div class="admin-kpi-icon kpi-icon-blue">
                    <i class="bi bi-airplane-fill"></i>
                </div>
            </div>

            <!-- 2. Total Fleet Seat Capacity -->
            <div class="admin-kpi-card">
                <div>
                    <div class="admin-kpi-label">Configured Seat Capacity</div>
                    <div class="admin-kpi-value"><c:out value="${totalConfiguredSeats}" /></div>
                    <small class="text-muted">Total passenger seats across fleet</small>
                </div>
                <div class="admin-kpi-icon kpi-icon-green">
                    <i class="bi bi-grid-3x3-gap-fill"></i>
                </div>
            </div>

            <!-- 3. Total Cabin Rows -->
            <div class="admin-kpi-card">
                <div>
                    <div class="admin-kpi-label">Total Cabin Rows</div>
                    <div class="admin-kpi-value"><c:out value="${totalRowsSum}" /></div>
                    <small class="text-muted">Configured rows across aircraft</small>
                </div>
                <div class="admin-kpi-icon kpi-icon-navy">
                    <i class="bi bi-layers-fill"></i>
                </div>
            </div>
        </div>

        <!-- Cabin Seat Map Visualizer (If an aircraft is selected) -->
        <c:if test="${not empty selectedAircraft}">
            <div class="cabin-fuselage-box" id="seatMapViewer">
                <div class="d-flex flex-wrap align-items-center justify-content-between gap-2 pb-3 mb-3 border-bottom">
                    <div>
                        <h2 class="admin-card-title text-navy fs-5">
                            <i class="bi bi-grid-3x3-gap-fill text-primary"></i>
                            Cabin Map: <c:out value="${selectedAircraft.modelName}" />
                        </h2>
                        <span class="text-muted small">
                            Manufacturer: <strong><c:out value="${selectedAircraft.manufacturer}" /></strong> &bull;
                            Capacity: <strong><c:out value="${selectedAircraft.totalCapacity}" /> Seats</strong> (${selectedAircraft.totalRows} Rows &times; ${selectedAircraft.seatsPerRow} Seats/Row)
                        </span>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/aircraft" class="admin-btn admin-btn-sm admin-btn-outline">
                        <i class="bi bi-x-lg me-1"></i> Close Seat Map
                    </a>
                </div>

                <!-- Seat Type Legend -->
                <div class="d-flex flex-wrap align-items-center gap-3 mb-3 p-2 bg-light rounded-3 small">
                    <div class="d-flex align-items-center gap-2">
                        <span class="d-inline-block rounded border bg-white shadow-sm" style="width: 18px; height: 18px;"></span>
                        <span>Standard Seat (Complimentary)</span>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <span class="d-inline-block rounded border bg-primary-subtle border-primary-subtle" style="width: 18px; height: 18px;"></span>
                        <span>Extra Legroom / Front Row (+₹500)</span>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <span class="d-inline-block rounded border bg-warning-subtle border-warning-subtle" style="width: 18px; height: 18px;"></span>
                        <span>Exit Row (+₹350)</span>
                    </div>
                </div>

                <!-- Fuselage Cabin Grid -->
                <div class="cabin-cockpit-nose">
                    <i class="bi bi-airplane-fill fs-3 text-primary"></i>
                    <div class="small text-muted fw-bold text-uppercase tracking-wider">Cockpit / Front of Aircraft &uarr;</div>
                </div>

                <div class="cabin-grid-scroll">
                    <!-- Column Header Row -->
                    <div class="cabin-row-line mb-3 pb-2 border-bottom fw-bold text-muted small">
                        <div class="cabin-row-badge">Row</div>
                        <div class="cabin-seat-cell bg-light border-0 shadow-none text-muted">A</div>
                        <div class="cabin-seat-cell bg-light border-0 shadow-none text-muted">B</div>
                        <div class="cabin-seat-cell bg-light border-0 shadow-none text-muted">C</div>
                        <div class="cabin-aisle-divider">Aisle</div>
                        <div class="cabin-seat-cell bg-light border-0 shadow-none text-muted">D</div>
                        <div class="cabin-seat-cell bg-light border-0 shadow-none text-muted">E</div>
                        <div class="cabin-seat-cell bg-light border-0 shadow-none text-muted">F</div>
                    </div>

                    <!-- Row-by-Row Seat Generation -->
                    <c:forEach var="rowNum" begin="1" end="${selectedAircraft.totalRows}">
                        <div class="cabin-row-line">
                            <div class="cabin-row-badge">${rowNum}</div>

                            <!-- Left Triple: A, B, C -->
                            <c:forEach var="col" items="${['A', 'B', 'C']}">
                                <c:set var="matchedSeat" value="${null}" />
                                <c:forEach var="s" items="${aircraftSeats}">
                                    <c:if test="${s.rowNumber == rowNum && s.columnLetter == col}">
                                        <c:set var="matchedSeat" value="${s}" />
                                    </c:if>
                                </c:forEach>
                                <c:choose>
                                    <c:when test="${not empty matchedSeat}">
                                        <div class="cabin-seat-cell ${matchedSeat.seatType == 'EXTRA_LEGROOM' ? 'seat-extra' : (matchedSeat.seatType == 'EXIT_ROW' ? 'seat-exit' : '')}"
                                             title="Seat ${matchedSeat.seatNumber} (${matchedSeat.seatType}) - Fee: ₹${matchedSeat.premiumFee}">
                                            <span>${matchedSeat.seatNumber}</span>
                                            <span class="cabin-seat-sub">${matchedSeat.premiumFee > 0 ? '+₹' += matchedSeat.premiumFee.intValue() : 'STD'}</span>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="cabin-seat-cell" title="Seat ${rowNum}${col}">
                                            <span>${rowNum}${col}</span>
                                            <span class="cabin-seat-sub">STD</span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <!-- Center Aisle -->
                            <div class="cabin-aisle-divider">|</div>

                            <!-- Right Triple: D, E, F -->
                            <c:forEach var="col" items="${['D', 'E', 'F']}">
                                <c:set var="matchedSeat" value="${null}" />
                                <c:forEach var="s" items="${aircraftSeats}">
                                    <c:if test="${s.rowNumber == rowNum && s.columnLetter == col}">
                                        <c:set var="matchedSeat" value="${s}" />
                                    </c:if>
                                </c:forEach>
                                <c:choose>
                                    <c:when test="${not empty matchedSeat}">
                                        <div class="cabin-seat-cell ${matchedSeat.seatType == 'EXTRA_LEGROOM' ? 'seat-extra' : (matchedSeat.seatType == 'EXIT_ROW' ? 'seat-exit' : '')}"
                                             title="Seat ${matchedSeat.seatNumber} (${matchedSeat.seatType}) - Fee: ₹${matchedSeat.premiumFee}">
                                            <span>${matchedSeat.seatNumber}</span>
                                            <span class="cabin-seat-sub">${matchedSeat.premiumFee > 0 ? '+₹' += matchedSeat.premiumFee.intValue() : 'STD'}</span>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="cabin-seat-cell" title="Seat ${rowNum}${col}">
                                            <span>${rowNum}${col}</span>
                                            <span class="cabin-seat-sub">STD</span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <!-- Aircraft Fleet Specifications Table -->
        <div class="admin-card">
            <div class="admin-card-header">
                <div>
                    <h2 class="admin-card-title">
                        <i class="bi bi-airplane-fill text-primary"></i> Registered Aircraft Fleet
                    </h2>
                </div>
                <span class="badge bg-light text-navy border px-3 py-2 fw-semibold">
                    <i class="bi bi-check-circle-fill text-success me-1"></i> <c:out value="${fleet.size()}" /> Active Models
                </span>
            </div>

            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th style="width: 70px;">ID</th>
                            <th>Model Identifier</th>
                            <th>Manufacturer</th>
                            <th>Total Rows</th>
                            <th>Seats Per Row</th>
                            <th>Total Capacity</th>
                            <th>Cabin Layout</th>
                            <th style="text-align: right; width: 160px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="a" items="${fleet}">
                            <tr class="${selectedAircraft.aircraftId == a.aircraftId ? 'table-primary bg-primary-subtle' : ''}">
                                <td class="fw-semibold text-muted">#<c:out value="${a.aircraftId}" /></td>
                                <td>
                                    <div class="fw-bold text-navy d-flex align-items-center gap-2">
                                        <i class="bi bi-airplane text-primary fs-6"></i>
                                        <c:out value="${a.modelName}" />
                                    </div>
                                </td>
                                <td>
                                    <span class="badge bg-light text-navy border px-2 py-1">
                                        <c:out value="${a.manufacturer}" />
                                    </span>
                                </td>
                                <td><c:out value="${a.totalRows}" /> Rows</td>
                                <td><c:out value="${a.seatsPerRow}" /> Seats</td>
                                <td>
                                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle fw-bold px-2 py-1">
                                        <c:out value="${a.totalCapacity}" /> Seats
                                    </span>
                                </td>
                                <td class="text-muted small">
                                    <i class="bi bi-columns-gap me-1"></i> 3-3 Standard (A-C | D-F)
                                </td>
                                <td style="text-align: right;">
                                    <a href="${pageContext.request.contextPath}/admin/aircraft?aircraftId=${a.aircraftId}#seatMapViewer"
                                       class="admin-btn admin-btn-sm ${selectedAircraft.aircraftId == a.aircraftId ? 'admin-btn-primary' : 'admin-btn-outline'} d-inline-flex align-items-center gap-1"
                                       title="View Cabin Seat Map for ${a.modelName}">
                                        <i class="bi bi-grid-3x3"></i>
                                        <span>View Seat Map</span>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Fleet Configuration Guidelines Card -->
        <div class="row g-4 mt-1">
            <div class="col-lg-6">
                <div class="admin-card h-100 mb-0">
                    <h3 class="admin-card-title fs-6 mb-3">
                        <i class="bi bi-info-circle-fill text-primary"></i> Cabin Configuration Rules
                    </h3>
                    <ul class="text-muted small d-flex flex-column gap-2 ps-3 mb-0">
                        <li><strong>Standard 3-3 Configuration:</strong> Rows feature seats A, B, C on the left and D, E, F on the right separated by a central aisle walkway.</li>
                        <li><strong>Row 1 Extra Legroom:</strong> Configured as front row seats with premium comfort and dedicated overhead bin accessibility.</li>
                        <li><strong>Row 12 Overwing Exit Rows:</strong> Configured as emergency exit rows requiring able-bodied passenger occupancy with premium spacing (+₹350).</li>
                        <li><strong>Window &amp; Aisle Seats:</strong> Automatic categorization across column letters (A, F = Window; C, D = Aisle; B, E = Middle).</li>
                    </ul>
                </div>
            </div>
            <div class="col-lg-6">
                <div class="admin-card h-100 mb-0">
                    <h3 class="admin-card-title fs-6 mb-3">
                        <i class="bi bi-shield-check text-success"></i> Flight Schedule Integration
                    </h3>
                    <p class="text-muted small mb-2">
                        Aircraft models registered here are linked directly to scheduled flight routes in the <strong>Flight Operations &amp; Scheduling</strong> console.
                    </p>
                    <p class="text-muted small mb-0">
                        Each scheduled flight dynamically builds its live passenger seat availability inventory from the aircraft's configured seat matrix.
                    </p>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- Modal: Add Aircraft -->
<div class="modal fade" id="addAircraftModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content border-0 shadow">
            <form method="POST" action="${pageContext.request.contextPath}/admin/aircraft">
                <input type="hidden" name="action" value="add">
                <div class="modal-header bg-light">
                    <h5 class="modal-title fw-bold text-navy">
                        <i class="bi bi-airplane-fill text-primary me-2"></i> Register Aircraft Type
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Model Name <span class="text-danger">*</span></label>
                        <input type="text" name="modelName" class="form-control" placeholder="e.g. Airbus A321neo" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Manufacturer <span class="text-danger">*</span></label>
                        <input type="text" name="manufacturer" class="form-control" placeholder="e.g. Airbus" required>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label fw-semibold">Total Cabin Rows</label>
                            <input type="number" name="totalRows" class="form-control" value="20" min="5" max="70" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold">Seats Per Row</label>
                            <input type="number" name="seatsPerRow" class="form-control" value="6" min="2" max="10" required>
                        </div>
                    </div>
                    <div class="p-3 bg-light rounded-3 text-muted small">
                        <i class="bi bi-info-circle me-1 text-primary"></i> A standard 3-3 seat layout (A, B, C, D, E, F) with row pricing tiers will be generated automatically for all cabin rows.
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="admin-btn admin-btn-primary">Register Aircraft</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
