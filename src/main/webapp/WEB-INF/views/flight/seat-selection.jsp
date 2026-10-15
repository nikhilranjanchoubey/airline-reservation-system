<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/seat-selection.css?v=3.0">

<main class="seat-selection-page-wrap">
    <div class="container-xl py-3 py-lg-4">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="seat-breadcrumb-nav mb-3">
            <ol class="breadcrumb small mb-0">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home" class="text-decoration-none">Home</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/search-flights" class="text-decoration-none">Search Flights</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/flight-details?id=${schedule.scheduleId}&travelClass=${travelClass}&passengers=${passengers}&departureDate=${selectedDepartureDate}" class="text-decoration-none">Flight Details</a></li>
                <li class="breadcrumb-item active" aria-current="page">Select Seats</li>
            </ol>
        </nav>

        <!-- Redesigned Compact Premium Flight Header -->
        <c:set var="aCode" value="${schedule.flight.airline.airlineCode}" />
        <div class="seat-flight-header-card mb-4">
            <div class="header-card-inner">
                <!-- Flight Identity & Brand Block -->
                <div class="header-brand-section">
                    <div class="airline-brand-logo">
                        <c:choose>
                            <c:when test="${aCode eq '6E' || aCode eq 'AI' || aCode eq 'QP' || aCode eq 'UK'}">
                                <img src="${pageContext.request.contextPath}/assets/images/airlines/${aCode}.svg" alt="${schedule.flight.airline.airlineName}" class="airline-logo-img">
                            </c:when>
                            <c:otherwise>
                                <span class="airline-initials-text">${aCode}</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="header-titles">
                        <div class="page-action-label">Choose Your Seats</div>
                        <h1 class="flight-identity-heading">
                            <span class="airline-name">${schedule.flight.airline.airlineName}</span>
                            <span class="flight-no-badge">${schedule.flight.flightNumber}</span>
                        </h1>
                    </div>
                </div>

                <!-- Flight Route & Schedule Block -->
                <div class="header-route-section">
                    <div class="route-airports-line">
                        <span class="city-name">${schedule.flight.sourceAirport.city}</span>
                        <span class="airport-code">(${schedule.flight.sourceAirport.airportCode})</span>
                        <span class="route-arrow-icon" aria-hidden="true">→</span>
                        <span class="city-name">${schedule.flight.destinationAirport.city}</span>
                        <span class="airport-code">(${schedule.flight.destinationAirport.airportCode})</span>
                    </div>
                    <div class="route-schedule-meta">
                        <span class="meta-item"><i class="bi bi-calendar3 me-1 text-cyan"></i>${schedule.formattedFlightDate}</span>
                        <span class="meta-separator">·</span>
                        <span class="meta-item"><i class="bi bi-clock me-1 text-cyan"></i>Departure ${schedule.flight.formattedDepartureTime}</span>
                        <c:if test="${not empty schedule.flight.formattedArrivalTime}">
                            <span class="meta-separator">·</span>
                            <span class="meta-item">Arrival ${schedule.flight.formattedArrivalTime}</span>
                        </c:if>
                    </div>
                </div>

                <!-- Flight Metadata Pills -->
                <div class="header-pills-section">
                    <span class="flight-meta-pill class-pill">
                        <i class="bi bi-person-workspace me-1"></i>${travelClass} Class
                    </span>
                    <span class="flight-meta-pill aircraft-pill">
                        <i class="bi bi-airplane-engines me-1"></i>${aircraftModel}
                    </span>
                    <span class="flight-meta-pill pax-pill">
                        <i class="bi bi-people-fill me-1"></i>${passengers} ${passengers == 1 ? 'Passenger' : 'Passengers'}
                    </span>
                </div>
            </div>
        </div>

        <!-- Main Two-Column Layout (Seat Map 66% | Summary 34%) -->
        <div class="row g-4 seat-page-grid">
            <!-- LEFT COLUMN: Aircraft Cabin & Seat Map (~66%) -->
            <div class="col-lg-8">
                <div class="cabin-map-card">
                    <!-- Cabin Map Card Header & Actions -->
                    <div class="cabin-card-header">
                        <div>
                            <h2 class="cabin-card-title">Aircraft Cabin Map</h2>
                            <p class="cabin-card-subtitle">
                                Select preferred seat(s) for <strong class="text-dark">${passengers}</strong> ${passengers == 1 ? 'traveler' : 'travelers'}
                            </p>
                        </div>

                        <c:if test="${passengers >= 2}">
                            <button type="button" class="btn-find-together" id="btnFindTogether" onclick="autoAssignSeatsTogether()" title="Auto-select adjacent seats for your group">
                                <i class="bi bi-stars"></i> Find Seats Together
                            </button>
                        </c:if>
                    </div>

                    <!-- Clean Seat Legend -->
                    <div class="seat-legend-container" aria-label="Seat Legend">
                        <div class="legend-chip">
                            <span class="legend-swatch swatch-available"></span>
                            <span>Available</span>
                        </div>
                        <div class="legend-chip">
                            <span class="legend-swatch swatch-preferred"></span>
                            <span>Extra Legroom / Preferred</span>
                        </div>
                        <div class="legend-chip">
                            <span class="legend-swatch swatch-selected"><i class="bi bi-check2"></i></span>
                            <span>Selected</span>
                        </div>
                        <div class="legend-chip">
                            <span class="legend-swatch swatch-occupied"><i class="bi bi-person-fill"></i></span>
                            <span>Occupied</span>
                        </div>
                        <div class="legend-chip">
                            <span class="legend-swatch swatch-unavailable"></span>
                            <span>Unavailable</span>
                        </div>
                    </div>

                    <!-- Aircraft Fuselage Shell -->
                    <div class="aircraft-fuselage-wrapper">
                        <!-- Left Wing Silhouette -->
                        <div class="aircraft-wing wing-left" aria-hidden="true">
                            <span class="wing-text">Wing Area</span>
                        </div>
                        <!-- Right Wing Silhouette -->
                        <div class="aircraft-wing wing-right" aria-hidden="true">
                            <span class="wing-text">Wing Area</span>
                        </div>

                        <div class="aircraft-fuselage-body">
                            <!-- Cockpit Nose & Flight Deck -->
                            <div class="cockpit-nose-cone">
                                <div class="cockpit-windshield-frame" aria-hidden="true">
                                    <div class="cockpit-glass-pane"></div>
                                    <div class="cockpit-glass-pane"></div>
                                    <div class="cockpit-glass-pane"></div>
                                    <div class="cockpit-glass-pane"></div>
                                </div>
                                <div class="flight-deck-label">
                                    <i class="bi bi-compass text-primary me-1"></i> Front of Aircraft · Flight Deck
                                </div>
                            </div>

                            <!-- Forward Galley & L1/R1 Entry Doors -->
                            <div class="cabin-amenity-strip forward-strip">
                                <span class="door-marker marker-left"><i class="bi bi-box-arrow-left me-1"></i>L1 Door</span>
                                <span class="amenity-marker"><i class="bi bi-cup-hot me-1"></i>Galley / Lavatories</span>
                                <span class="door-marker marker-right">R1 Door<i class="bi bi-box-arrow-right ms-1"></i></span>
                            </div>

                            <!-- Column Letters Header -->
                            <div class="cabin-columns-header" aria-hidden="true">
                                <div class="seat-cols-group">
                                    <c:forEach var="colLetter" items="${cabinLayout.leftColumns}">
                                        <div class="col-letter-cell">${colLetter}</div>
                                    </c:forEach>
                                </div>

                                <div class="aisle-spacer-cell">Aisle</div>

                                <c:if test="${cabinLayout.twinAisle}">
                                    <div class="seat-cols-group">
                                        <c:forEach var="colLetter" items="${cabinLayout.centerColumns}">
                                            <div class="col-letter-cell">${colLetter}</div>
                                        </c:forEach>
                                    </div>
                                    <div class="aisle-spacer-cell">Aisle</div>
                                </c:if>

                                <div class="seat-cols-group">
                                    <c:forEach var="colLetter" items="${cabinLayout.rightColumns}">
                                        <div class="col-letter-cell">${colLetter}</div>
                                    </c:forEach>
                                </div>
                            </div>

                            <!-- Interactive Rows List -->
                            <div class="cabin-rows-list" id="cabinRowsList" role="region" aria-label="Seat Selection Grid">
                                <c:forEach var="rowObj" items="${cabinLayout.rows}">
                                    <!-- Cabin Section Divider -->
                                    <c:if test="${not empty rowObj.sectionTitle}">
                                        <div class="cabin-section-divider">
                                            <span class="section-divider-badge">
                                                <i class="bi bi-layers-half me-1"></i>${rowObj.sectionTitle}
                                            </span>
                                        </div>
                                    </c:if>

                                    <div class="cabin-row-row ${rowObj.exitRow ? 'is-exit-row' : ''}" data-row="${rowObj.rowNumber}">
                                        <!-- Emergency Exit Indicators -->
                                        <c:if test="${rowObj.exitRow}">
                                            <span class="exit-marker-badge marker-left" title="Emergency Exit">
                                                <i class="bi bi-arrow-left"></i> EXIT
                                            </span>
                                            <span class="exit-marker-badge marker-right" title="Emergency Exit">
                                                EXIT <i class="bi bi-arrow-right"></i>
                                            </span>
                                        </c:if>

                                        <!-- Left Seat Block -->
                                        <div class="seat-block left-block">
                                            <c:forEach var="s" items="${rowObj.leftSeats}">
                                                <div class="airline-seat state-${s.status.toLowerCase()} ${s.extraLegroom ? 'state-preferred' : ''}"
                                                     tabindex="${s.available ? '0' : '-1'}"
                                                     role="button"
                                                     aria-pressed="false"
                                                     aria-label="Seat ${s.seatNumber}, ${s.categoryLabel}, ${s.premiumFee > 0 ? '+₹' += s.premiumFee : 'Complimentary'}, ${s.status}"
                                                     data-seat="${s.seatNumber}"
                                                     data-row="${s.rowNumber}"
                                                     data-col="${s.columnLetter}"
                                                     data-type="${s.seatType}"
                                                     data-label="${s.categoryLabel}"
                                                     data-fee="${s.premiumFee}"
                                                     data-status="${s.status}"
                                                     data-legroom="${s.extraLegroom}"
                                                     onclick="handleSeatClick(this)"
                                                     onkeydown="handleSeatKeyDown(event, this)">
                                                    <div class="seat-headrest-contour"></div>
                                                    <span class="seat-letter">
                                                        <c:choose>
                                                            <c:when test="${s.occupied}">
                                                                <i class="bi bi-person-fill seat-occ-icon"></i>
                                                            </c:when>
                                                            <c:when test="${s.blocked}">
                                                                <i class="bi bi-dash seat-occ-icon"></i>
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${s.columnLetter}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                    <c:if test="${s.extraLegroom && s.available}">
                                                        <div class="seat-legroom-pip" title="Extra Legroom"></div>
                                                    </c:if>
                                                    <div class="seat-selected-check" aria-hidden="true">
                                                        <i class="bi bi-check2"></i>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>

                                        <!-- Center Aisle & Row Number Badge -->
                                        <div class="aisle-row-badge" aria-label="Row ${rowObj.rowNumber}">${rowObj.rowNumber}</div>

                                        <!-- Widebody Center Block (if applicable) -->
                                        <c:if test="${cabinLayout.twinAisle && rowObj.hasCenterSeats()}">
                                            <div class="seat-block center-block">
                                                <c:forEach var="s" items="${rowObj.centerSeats}">
                                                    <div class="airline-seat state-${s.status.toLowerCase()} ${s.extraLegroom ? 'state-preferred' : ''}"
                                                         tabindex="${s.available ? '0' : '-1'}"
                                                         role="button"
                                                         aria-pressed="false"
                                                         aria-label="Seat ${s.seatNumber}, ${s.categoryLabel}, ${s.premiumFee > 0 ? '+₹' += s.premiumFee : 'Complimentary'}, ${s.status}"
                                                         data-seat="${s.seatNumber}"
                                                         data-row="${s.rowNumber}"
                                                         data-col="${s.columnLetter}"
                                                         data-type="${s.seatType}"
                                                         data-label="${s.categoryLabel}"
                                                         data-fee="${s.premiumFee}"
                                                         data-status="${s.status}"
                                                         data-legroom="${s.extraLegroom}"
                                                         onclick="handleSeatClick(this)"
                                                         onkeydown="handleSeatKeyDown(event, this)">
                                                        <div class="seat-headrest-contour"></div>
                                                        <span class="seat-letter">
                                                            <c:choose>
                                                                <c:when test="${s.occupied}">
                                                                    <i class="bi bi-person-fill seat-occ-icon"></i>
                                                                </c:when>
                                                                <c:when test="${s.blocked}">
                                                                    <i class="bi bi-dash seat-occ-icon"></i>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    ${s.columnLetter}
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                        <c:if test="${s.extraLegroom && s.available}">
                                                            <div class="seat-legroom-pip" title="Extra Legroom"></div>
                                                        </c:if>
                                                        <div class="seat-selected-check" aria-hidden="true">
                                                            <i class="bi bi-check2"></i>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                            <div class="aisle-row-badge" aria-label="Row ${rowObj.rowNumber}">${rowObj.rowNumber}</div>
                                        </c:if>

                                        <!-- Right Seat Block -->
                                        <div class="seat-block right-block">
                                            <c:forEach var="s" items="${rowObj.rightSeats}">
                                                <div class="airline-seat state-${s.status.toLowerCase()} ${s.extraLegroom ? 'state-preferred' : ''}"
                                                     tabindex="${s.available ? '0' : '-1'}"
                                                     role="button"
                                                     aria-pressed="false"
                                                     aria-label="Seat ${s.seatNumber}, ${s.categoryLabel}, ${s.premiumFee > 0 ? '+₹' += s.premiumFee : 'Complimentary'}, ${s.status}"
                                                     data-seat="${s.seatNumber}"
                                                     data-row="${s.rowNumber}"
                                                     data-col="${s.columnLetter}"
                                                     data-type="${s.seatType}"
                                                     data-label="${s.categoryLabel}"
                                                     data-fee="${s.premiumFee}"
                                                     data-status="${s.status}"
                                                     data-legroom="${s.extraLegroom}"
                                                     onclick="handleSeatClick(this)"
                                                     onkeydown="handleSeatKeyDown(event, this)">
                                                    <div class="seat-headrest-contour"></div>
                                                    <span class="seat-letter">
                                                        <c:choose>
                                                            <c:when test="${s.occupied}">
                                                                <i class="bi bi-person-fill seat-occ-icon"></i>
                                                            </c:when>
                                                            <c:when test="${s.blocked}">
                                                                <i class="bi bi-dash seat-occ-icon"></i>
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${s.columnLetter}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                    <c:if test="${s.extraLegroom && s.available}">
                                                        <div class="seat-legroom-pip" title="Extra Legroom"></div>
                                                    </c:if>
                                                    <div class="seat-selected-check" aria-hidden="true">
                                                        <i class="bi bi-check2"></i>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <!-- Rear Cabin Station & Aft Doors -->
                            <div class="cabin-amenity-strip rear-strip">
                                <span class="door-marker marker-left"><i class="bi bi-box-arrow-left me-1"></i>L2 Door</span>
                                <span class="amenity-marker"><i class="bi bi-droplet me-1"></i>Lavatories (WC) · Aft Galley</span>
                                <span class="door-marker marker-right">R2 Door<i class="bi bi-box-arrow-right ms-1"></i></span>
                            </div>

                            <div class="tail-cone-indicator" aria-hidden="true">
                                <span class="tail-label">Tail Section · Rear of Aircraft</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- RIGHT COLUMN: Sticky Seat Selection Summary (~34%) -->
            <div class="col-lg-4">
                <div class="seat-summary-sidebar sticky-top" id="seatSummarySidebar">
                    <!-- Summary Card Header -->
                    <div class="summary-card-header">
                        <div>
                            <h3 class="summary-card-heading">YOUR SEAT SELECTION</h3>
                            <div class="summary-pax-subtitle">
                                Selecting for <strong class="text-dark">${passengers}</strong> ${passengers == 1 ? 'traveler' : 'travelers'}
                            </div>
                        </div>
                        <span class="selection-counter-badge" id="selectionCountBadge">
                            0 of ${passengers} Selected
                        </span>
                    </div>

                    <!-- Progress Bar -->
                    <div class="selection-progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">
                        <div class="selection-progress-fill" id="seatProgressFill" style="width: 0%;"></div>
                    </div>

                    <!-- Per-Passenger Assignment Cards -->
                    <div class="passenger-assignments-list" id="passengerSlotsContainer">
                        <c:forEach var="pNum" begin="1" end="${passengers}">
                            <div class="passenger-slot-card" id="pSlot_${pNum}">
                                <div class="slot-left-group">
                                    <div class="slot-avatar-circle">${pNum}</div>
                                    <div class="slot-text-content">
                                        <div class="slot-traveler-name">Traveler ${pNum}</div>
                                        <div class="slot-status-text" id="pSeatDetail_${pNum}">No seat selected</div>
                                    </div>
                                </div>
                                <div class="slot-right-action" id="pSeatAction_${pNum}">
                                    <span class="slot-pending-pill">Pending</span>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- Helpful Empty State Note -->
                    <div class="seat-empty-hint" id="seatEmptyHint">
                        <i class="bi bi-info-circle me-1 text-primary"></i>
                        Click any available seat on the cabin map to assign it to your travelers.
                    </div>

                    <div class="summary-divider-line"></div>

                    <!-- Financial Breakdown Table -->
                    <div class="financial-breakdown-panel mb-3">
                        <div class="breakdown-line-item">
                            <span class="line-label">Flight base fare (${passengers} × ₹<fmt:formatNumber value="${perPassengerFare}" type="number" maxFractionDigits="0" />)</span>
                            <span class="line-value">₹<fmt:formatNumber value="${baseFareTotal}" type="number" maxFractionDigits="0" /></span>
                        </div>

                        <div class="breakdown-line-item">
                            <span class="line-label">Seat selection fee</span>
                            <span class="line-value font-semibold" id="summarySeatFeeText">₹0</span>
                        </div>

                        <div class="breakdown-line-item">
                            <span class="line-label">Taxes and applicable fees</span>
                            <span class="line-value" id="summaryTaxesText">₹<fmt:formatNumber value="${initialTaxes}" type="number" maxFractionDigits="0" /></span>
                        </div>

                        <div class="summary-total-line">
                            <span class="total-title">Total</span>
                            <span class="total-currency-amount" id="summaryGrandTotalText">₹<fmt:formatNumber value="${initialGrandTotal}" type="number" maxFractionDigits="0" /></span>
                        </div>

                        <div class="summary-statutory-notice">
                            <i class="bi bi-shield-check text-success me-1"></i>All statutory taxes, seat fees, and carrier surcharges included
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="summary-actions-group">
                        <button type="button" class="btn-confirm-seats w-100" id="btnConfirmSeats" onclick="confirmSeatsAndContinue()">
                            Confirm Seats &amp; Continue <i class="bi bi-arrow-right ms-1"></i>
                        </button>

                        <button type="button" class="btn-skip-seats w-100" id="btnSkipSeats" onclick="skipSeatSelection()">
                            Skip Seat Selection <span class="skip-subtext">(Complimentary assignment at check-in)</span>
                        </button>

                        <div class="back-link-wrapper text-center mt-2">
                            <a href="${pageContext.request.contextPath}/flight-details?id=${schedule.scheduleId}&travelClass=${travelClass}&passengers=${passengers}&departureDate=${selectedDepartureDate}" class="back-nav-link">
                                ← Back to Flight Details
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Mobile Sticky Checkout Bar -->
    <div class="mobile-sticky-seat-bar" id="mobileStickyBar">
        <div class="mobile-bar-left">
            <div class="mobile-seats-count" id="mobileSelectedCountText">0 of ${passengers} seats selected</div>
            <div class="mobile-total-price" id="mobileTotalPriceText">₹<fmt:formatNumber value="${initialGrandTotal}" type="number" maxFractionDigits="0" /></div>
        </div>
        <button type="button" class="mobile-continue-btn" onclick="confirmSeatsAndContinue()">
            Continue <i class="bi bi-arrow-right ms-1"></i>
        </button>
    </div>

    <!-- Smart Floating Desktop Tooltip -->
    <div class="compact-seat-tooltip" id="seatTooltip" role="tooltip" aria-hidden="true">
        <div class="tooltip-header-row">
            <span class="tt-seat-id" id="ttSeatNum">Seat 12A</span>
            <span class="tt-category-badge" id="ttBadge">Preferred</span>
        </div>
        <div class="tt-legroom-text" id="ttFeatures">Standard Pitch</div>
        <div class="tt-fee-row">
            <span class="tt-fee-label">Additional fee:</span>
            <span class="tt-fee-val" id="ttPrice">Complimentary</span>
        </div>
    </div>
</main>

<script>
    const MAX_PASSENGERS = ${passengers};
    const BASE_FARE = Number('${baseFareTotal}');
    const PER_PASSENGER_FARE = Number('${perPassengerFare}');
    let selectedSeats = []; // Array of objects: { number, fee, type, label, legroom }

    // Tooltip Element Reference
    const tooltipEl = document.getElementById('seatTooltip');
    const ttSeatNum = document.getElementById('ttSeatNum');
    const ttBadge = document.getElementById('ttBadge');
    const ttFeatures = document.getElementById('ttFeatures');
    const ttPrice = document.getElementById('ttPrice');

    // Bind Hover & Focus Tooltips
    document.querySelectorAll('.airline-seat').forEach(seat => {
        seat.addEventListener('mouseenter', function(e) { showSeatTooltip(this, e); });
        seat.addEventListener('mouseleave', function() { hideSeatTooltip(); });
        seat.addEventListener('focus', function(e) { showSeatTooltip(this, e); });
        seat.addEventListener('blur', function() { hideSeatTooltip(); });
    });

    function showSeatTooltip(el, e) {
        if (window.innerWidth < 992) return; // Use native mobile layout on touch screens
        const status = el.getAttribute('data-status');
        const seatNum = el.getAttribute('data-seat');
        const fee = parseFloat(el.getAttribute('data-fee')) || 0;
        const label = el.getAttribute('data-label') || 'Standard';
        const isLegroom = el.getAttribute('data-legroom') === 'true';

        ttSeatNum.textContent = 'Seat ' + seatNum;
        ttBadge.textContent = label;

        if (isLegroom) {
            ttBadge.className = 'tt-category-badge badge-preferred';
            ttFeatures.textContent = 'Extra Legroom (Exit Row / Forward)';
        } else {
            ttBadge.className = 'tt-category-badge badge-standard';
            ttFeatures.textContent = 'Standard Airline Seat Pitch';
        }

        if (status === 'OCCUPIED') {
            ttPrice.textContent = 'Occupied';
            ttPrice.style.color = '#94A3B8';
        } else if (status === 'BLOCKED') {
            ttPrice.textContent = 'Unavailable';
            ttPrice.style.color = '#F59E0B';
        } else {
            ttPrice.textContent = fee > 0 ? '+₹' + fee.toLocaleString('en-IN') : 'Complimentary (₹0)';
            ttPrice.style.color = '#10B981';
        }

        const rect = el.getBoundingClientRect();
        let left = rect.left + rect.width / 2 - 95;
        let top = rect.top - 82;

        // Auto bounds check to prevent screen overflow
        if (left < 12) left = 12;
        if (left + 195 > window.innerWidth) left = window.innerWidth - 205;
        if (top < 10) top = rect.bottom + 10;

        tooltipEl.style.left = left + 'px';
        tooltipEl.style.top = top + 'px';
        tooltipEl.classList.add('is-visible');
        tooltipEl.setAttribute('aria-hidden', 'false');
    }

    function hideSeatTooltip() {
        tooltipEl.classList.remove('is-visible');
        tooltipEl.setAttribute('aria-hidden', 'true');
    }

    function handleSeatKeyDown(event, el) {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            handleSeatClick(el);
        }
    }

    function handleSeatClick(el) {
        const status = el.getAttribute('data-status');
        if (status === 'OCCUPIED' || status === 'BLOCKED') {
            if (typeof window.showToast === 'function') {
                window.showToast('Seat ' + el.getAttribute('data-seat') + ' is currently ' + status.toLowerCase() + ' and cannot be selected.', 'warning');
            }
            return;
        }

        const seatNum = el.getAttribute('data-seat');
        const fee = parseFloat(el.getAttribute('data-fee')) || 0;
        const type = el.getAttribute('data-type');
        const label = el.getAttribute('data-label') || 'Standard';
        const legroom = el.getAttribute('data-legroom') === 'true';

        const existingIdx = selectedSeats.findIndex(s => s.number === seatNum);

        if (existingIdx >= 0) {
            // Deselect seat
            selectedSeats.splice(existingIdx, 1);
            el.classList.remove('state-selected');
            el.setAttribute('aria-pressed', 'false');
            if (typeof window.showToast === 'function') {
                window.showToast('Seat ' + seatNum + ' removed from selection.', 'info');
            }
        } else {
            // Check passenger capacity
            if (selectedSeats.length >= MAX_PASSENGERS) {
                if (typeof window.showToast === 'function') {
                    if (MAX_PASSENGERS === 1) {
                        window.showToast('You have already selected 1 seat. Deselect it first to choose another seat.', 'warning');
                    } else {
                        window.showToast('All ' + MAX_PASSENGERS + ' seats selected. Remove one to choose a different seat.', 'warning');
                    }
                }
                return;
            }

            selectedSeats.push({
                number: seatNum,
                fee: fee,
                type: type,
                label: label,
                legroom: legroom
            });
            el.classList.add('state-selected');
            el.setAttribute('aria-pressed', 'true');
            if (typeof window.showToast === 'function') {
                const feeText = fee > 0 ? ' (+₹' + fee.toLocaleString('en-IN') + ')' : ' (Complimentary)';
                window.showToast('Seat ' + seatNum + ' (' + label + ')' + feeText + ' selected.', 'success');
            }
        }

        updateSummaryPanel();
    }

    function removeSeatByNumber(seatNum) {
        const el = document.querySelector('[data-seat="' + seatNum + '"]');
        if (el) {
            handleSeatClick(el);
        } else {
            selectedSeats = selectedSeats.filter(s => s.number !== seatNum);
            updateSummaryPanel();
        }
    }

    function updateSummaryPanel() {
        const count = selectedSeats.length;
        const percent = Math.min(100, Math.round((count / MAX_PASSENGERS) * 100));

        // Update Badge & Progress Bar
        const badge = document.getElementById('selectionCountBadge');
        if (badge) badge.textContent = count + ' of ' + MAX_PASSENGERS + ' Selected';

        const fill = document.getElementById('seatProgressFill');
        if (fill) fill.style.width = percent + '%';

        const mobileText = document.getElementById('mobileSelectedCountText');
        if (mobileText) mobileText.textContent = count + ' of ' + MAX_PASSENGERS + ' seats selected';

        const emptyHint = document.getElementById('seatEmptyHint');
        if (emptyHint) emptyHint.style.display = (count === 0) ? 'block' : 'none';

        // Update Traveler Slots
        let totalSeatFee = 0;
        for (let i = 1; i <= MAX_PASSENGERS; i++) {
            const slotEl = document.getElementById('pSlot_' + i);
            const detailEl = document.getElementById('pSeatDetail_' + i);
            const actionEl = document.getElementById('pSeatAction_' + i);

            if (i <= count) {
                const s = selectedSeats[i - 1];
                totalSeatFee += s.fee;

                if (slotEl) slotEl.classList.add('is-assigned');
                if (detailEl) {
                    const feeDesc = s.fee > 0 ? 'Additional fee: ₹' + s.fee.toLocaleString('en-IN') : 'Complimentary';
                    detailEl.innerHTML = '<strong class="text-primary fs-6">' + s.number + '</strong> · ' + s.label + '<div class="text-muted small mt-0.5">' + feeDesc + '</div>';
                }
                if (actionEl) {
                    actionEl.innerHTML = '<button type="button" class="btn-remove-slot-seat" onclick="removeSeatByNumber(\'' + s.number + '\')" title="Remove seat ' + s.number + '" aria-label="Remove seat ' + s.number + '">&times;</button>';
                }
            } else {
                if (slotEl) slotEl.classList.remove('is-assigned');
                if (detailEl) detailEl.textContent = 'No seat selected';
                if (actionEl) actionEl.innerHTML = '<span class="slot-pending-pill">Pending</span>';
            }
        }

        // Financial Calculation
        const summaryFee = document.getElementById('summarySeatFeeText');
        const summaryTaxes = document.getElementById('summaryTaxesText');
        const summaryGrand = document.getElementById('summaryGrandTotalText');
        const mobileTotal = document.getElementById('mobileTotalPriceText');

        if (count === 0) {
            if (summaryFee) summaryFee.textContent = '₹0';
            const baseTaxes = Math.round(BASE_FARE * 0.12);
            const baseTotal = BASE_FARE + baseTaxes;
            if (summaryTaxes) summaryTaxes.textContent = '₹' + baseTaxes.toLocaleString('en-IN');
            if (summaryGrand) summaryGrand.textContent = '₹' + baseTotal.toLocaleString('en-IN');
            if (mobileTotal) mobileTotal.textContent = '₹' + baseTotal.toLocaleString('en-IN');
        } else {
            if (summaryFee) summaryFee.textContent = '₹' + totalSeatFee.toLocaleString('en-IN');
            const subtotal = BASE_FARE + totalSeatFee;
            const taxes = Math.round(subtotal * 0.12);
            const grandTotal = subtotal + taxes;
            if (summaryTaxes) summaryTaxes.textContent = '₹' + taxes.toLocaleString('en-IN');
            if (summaryGrand) summaryGrand.textContent = '₹' + grandTotal.toLocaleString('en-IN');
            if (mobileTotal) mobileTotal.textContent = '₹' + grandTotal.toLocaleString('en-IN');
        }
    }

    /**
     * Smart contiguous seat allocation algorithm
     */
    function autoAssignSeatsTogether() {
        const rows = document.querySelectorAll('.cabin-row-row');
        let foundSeats = [];

        for (const row of rows) {
            const groups = row.querySelectorAll('.seat-block');
            for (const group of groups) {
                const availableSeatsInGroup = Array.from(group.querySelectorAll('.airline-seat.state-available'));
                if (availableSeatsInGroup.length >= MAX_PASSENGERS) {
                    const allSeatsInGroup = Array.from(group.querySelectorAll('.airline-seat'));
                    for (let i = 0; i <= allSeatsInGroup.length - MAX_PASSENGERS; i++) {
                        let consecutive = true;
                        let candidateGroup = [];
                        for (let j = 0; j < MAX_PASSENGERS; j++) {
                            const seatEl = allSeatsInGroup[i + j];
                            if (!seatEl.classList.contains('state-available') || seatEl.getAttribute('data-status') !== 'AVAILABLE') {
                                consecutive = false;
                                break;
                            }
                            candidateGroup.push(seatEl);
                        }
                        if (consecutive) {
                            foundSeats = candidateGroup;
                            break;
                        }
                    }
                }
                if (foundSeats.length > 0) break;
            }
            if (foundSeats.length > 0) break;
        }

        if (foundSeats.length === MAX_PASSENGERS) {
            // Deselect existing
            selectedSeats.forEach(s => {
                const el = document.querySelector('[data-seat="' + s.number + '"]');
                if (el) {
                    el.classList.remove('state-selected');
                    el.setAttribute('aria-pressed', 'false');
                }
            });
            selectedSeats = [];

            // Apply newly found seats
            foundSeats.forEach(el => {
                const seatNum = el.getAttribute('data-seat');
                const fee = parseFloat(el.getAttribute('data-fee')) || 0;
                const type = el.getAttribute('data-type');
                const label = el.getAttribute('data-label') || 'Standard';
                const legroom = el.getAttribute('data-legroom') === 'true';

                selectedSeats.push({
                    number: seatNum,
                    fee: fee,
                    type: type,
                    label: label,
                    legroom: legroom
                });
                el.classList.add('state-selected');
                el.setAttribute('aria-pressed', 'true');
            });

            updateSummaryPanel();

            if (typeof window.showToast === 'function') {
                window.showToast('✨ Found and selected adjacent seats ' + selectedSeats.map(s => s.number).join(', ') + ' together!', 'success');
            }
        } else {
            if (typeof window.showToast === 'function') {
                window.showToast('No ' + MAX_PASSENGERS + ' contiguous seats are currently available in the same cluster. Please select individual seats.', 'info');
            }
        }
    }

    /**
     * Confirm Seats & Continue
     */
    function confirmSeatsAndContinue() {
        if (selectedSeats.length === 0) {
            if (typeof window.showToast === 'function') {
                window.showToast('Please select at least 1 seat, or click "Skip Seat Selection" to have seats auto-assigned at check-in.', 'info');
            } else {
                alert('Please select at least 1 seat, or click "Skip Seat Selection" to have seats auto-assigned at check-in.');
            }
            return;
        }

        if (selectedSeats.length < MAX_PASSENGERS) {
            const remaining = MAX_PASSENGERS - selectedSeats.length;
            const msg = 'You have selected ' + selectedSeats.length + ' of ' + MAX_PASSENGERS + ' seat(s). Please choose ' + remaining + ' more seat(s) for your travelers, or click "Skip Seat Selection".';
            if (typeof window.showToast === 'function') {
                window.showToast(msg, 'warning');
            } else {
                alert(msg);
            }
            return;
        }

        // Validate and prevent duplicate submissions
        const btn = document.getElementById('btnConfirmSeats');
        if (btn) {
            btn.disabled = true;
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Securing Seats...';
        }

        const seatList = selectedSeats.map(s => s.number).join(',');
        const url = '${pageContext.request.contextPath}/book-flight?scheduleId=${schedule.scheduleId}&travelClass=${travelClass}&passengers=${passengers}&departureDate=${selectedDepartureDate}&selectedSeats=' + encodeURIComponent(seatList);
        window.location.href = url;
    }

    /**
     * Skip Seat Selection
     */
    function skipSeatSelection() {
        const btn = document.getElementById('btnSkipSeats');
        if (btn) {
            btn.disabled = true;
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Continuing...';
        }
        const url = '${pageContext.request.contextPath}/book-flight?scheduleId=${schedule.scheduleId}&travelClass=${travelClass}&passengers=${passengers}&departureDate=${selectedDepartureDate}';
        window.location.href = url;
    }

    // Auto-restore any preselected seats from URL query parameters
    (function initPreSelectedSeats() {
        const preParam = '${preSelectedSeatsParam}';
        if (preParam && preParam.trim() !== '') {
            const tokens = preParam.split(',');
            tokens.forEach(tok => {
                const clean = tok.trim().toUpperCase();
                const el = document.querySelector('[data-seat="' + clean + '"]');
                if (el && el.getAttribute('data-status') === 'AVAILABLE') {
                    handleSeatClick(el);
                }
            });
        }
    })();
</script>

<jsp:include page="../common/footer.jsp" />
