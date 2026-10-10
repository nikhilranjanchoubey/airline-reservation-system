<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<div class="results-container results-page-container my-4">
    <!-- Breadcrumb & Mode Status -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-3">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb small mb-0">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home" class="text-decoration-none">Home</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/search-flights" class="text-decoration-none">Search</a></li>
                <li class="breadcrumb-item active" aria-current="page">Results</li>
            </ol>
        </nav>

        <!-- Availability Status -->
        <div>
            <c:choose>
                <c:when test="${not empty apiError}">
                    <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-3 py-1 rounded-pill small">
                        <i class="bi bi-exclamation-triangle-fill me-1"></i> Service Notice
                    </span>
                </c:when>
                <c:when test="${empty flights}">
                    <span class="badge bg-light text-muted border px-3 py-1 rounded-pill small">
                        <i class="bi bi-info-circle me-1"></i> 0 Flights
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="badge bg-light text-muted border px-3 py-1 rounded-pill small">
                        <i class="bi bi-check2-circle text-success me-1"></i> ${flightCount} Flights Available
                    </span>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Search Summary Top Bar -->
    <div class="search-summary-bar">
        <div class="row align-items-center gy-3">
            <div class="col-lg-8">
                <div class="d-flex flex-wrap align-items-center gap-3">
                    <div class="d-flex align-items-center gap-2">
                        <span class="fs-4 fw-bold text-dark">${not empty sourceAirport ? sourceAirport.city : selectedSource}</span>
                        <span class="badge bg-secondary-subtle text-secondary">${selectedSource}</span>
                        <i class="bi bi-arrow-right fs-5 text-primary"></i>
                        <span class="fs-4 fw-bold text-dark">${not empty destinationAirport ? destinationAirport.city : selectedDestination}</span>
                        <span class="badge bg-secondary-subtle text-secondary">${selectedDestination}</span>
                    </div>

                    <div class="vr d-none d-md-block" style="height: 28px;"></div>

                    <div class="d-flex flex-wrap align-items-center gap-2 text-muted small">
                        <span><i class="bi bi-calendar-event me-1 text-primary"></i> <strong class="text-dark">${not empty formattedDepartureDate ? formattedDepartureDate : selectedDepartureDate}</strong><c:if test="${not empty departureDayOfWeek}"> &bull; ${departureDayOfWeek}</c:if></span>
                        <span>&bull;</span>
                        <span><i class="bi bi-people me-1"></i> ${passengers} ${passengers == 1 ? 'Passenger' : 'Passengers'}</span>
                        <span>&bull;</span>
                        <span class="badge bg-primary-subtle text-primary">${travelClass}</span>
                    </div>
                </div>
            </div>

            <div class="col-lg-4 text-lg-end">
                <a href="${pageContext.request.contextPath}/search-flights?modify=true&tripType=${tripType}&source=${selectedSource}&destination=${selectedDestination}&departureDate=${selectedDepartureDate}&returnDate=${selectedReturnDate}&adults=${adults}&children=${children}&infants=${infants}&travelClass=${travelClass}"
                   id="btnModifySearch"
                   class="btn btn-outline-primary btn-sm rounded-pill px-3"
                   role="button"
                   style="cursor: pointer;"
                   aria-label="Modify flight search parameters">
                    <i class="bi bi-pencil-square me-1"></i> MODIFY SEARCH
                </a>
            </div>
        </div>
    </div>

    <!-- Multi-City Journey Itinerary Banner (If Applicable) -->
    <c:if test="${tripType == 'multi-city' && not empty multiSegments}">
        <div class="card shadow-sm border-0 mb-4 bg-white rounded-4">
            <div class="card-body p-3">
                <div class="d-flex align-items-center justify-content-between mb-2 pb-2 border-bottom">
                    <span class="small fw-bold text-uppercase text-primary">
                        <i class="bi bi-signpost-split-fill me-1"></i> Complete Multi-City Journey Itinerary (${multiSegments.size()} Legs)
                    </span>
                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-1 rounded-pill">
                        Showing Leg 1 Schedules Below
                    </span>
                </div>
                <div class="row g-2">
                    <c:forEach var="seg" items="${multiSegments}" varStatus="status">
                        <div class="col-md">
                            <div class="p-2 rounded-3 border ${status.first ? 'border-primary bg-primary-subtle bg-opacity-25' : 'bg-light'}">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span class="badge ${status.first ? 'bg-primary text-white' : 'bg-secondary text-white'} rounded-pill" style="font-size: 0.65rem;">
                                        Flight ${seg.segmentNumber} ${status.first ? '&bull; Selecting Now' : '&bull; Next Leg'}
                                    </span>
                                    <small class="text-muted fw-semibold">${seg.departureDate}</small>
                                </div>
                                <div class="fw-bold small text-dark">${seg.sourceCode} &rarr; ${seg.destinationCode}</div>
                                <small class="text-muted text-truncate d-block" style="font-size: 0.75rem;">
                                    ${not empty seg.sourceAirport ? seg.sourceAirport.city : seg.sourceCode} to ${not empty seg.destinationAirport ? seg.destinationAirport.city : seg.destinationCode}
                                </small>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </c:if>

    <!-- Main Results Section -->
    <c:choose>
        <%-- 1. API ERROR STATE (Differentiate from 'no flights found' per specification) --%>
        <c:when test="${not empty apiError}">
            <div class="empty-state-box my-4">
                <div class="empty-state-icon text-danger">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                </div>
                <h3 class="fw-bold text-dark mb-2">Flight Service Notice</h3>
                <p class="text-muted mx-auto mb-3" style="max-width: 550px;">
                    ${apiError}
                </p>
                <c:if test="${not empty apiStatusCode}">
                    <div class="mb-3">
                        <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-3 py-1 rounded-pill">
                            Service Status: HTTP ${apiStatusCode} &bull; ${apiErrorCategory}
                        </span>
                    </div>
                </c:if>
                <div class="card border-0 bg-light mx-auto mb-4 text-start p-3" style="max-width: 480px;">
                    <div class="fw-semibold text-dark mb-2"><i class="bi bi-info-circle text-primary me-1"></i> Diagnostic Information:</div>
                    <ul class="text-muted small mb-0 ps-3">
                        <li>Route queried: <strong>${selectedSource} &rarr; ${selectedDestination}</strong></li>
                        <li>Date queried: <strong>${not empty formattedDepartureDate ? formattedDepartureDate : selectedDepartureDate}</strong></li>
                        <c:choose>
                            <c:when test="${apiErrorCategory eq 'CREDIT_EXHAUSTED' || apiErrorCategory eq 'QUOTA_EXCEEDED' || apiErrorCategory eq 'RATE_LIMIT'}">
                                <li>The ReefAPI flight search request limit or credit balance has been reached on the configured account.</li>
                                <li>Please check your ReefAPI subscription credits at reefapi.com.</li>
                            </c:when>
                            <c:when test="${apiErrorCategory eq 'AUTHENTICATION' || apiErrorCategory eq 'AUTHORIZATION'}">
                                <li>The server could not authenticate with ReefAPI. Please verify REEF_API_KEY in server configuration.</li>
                            </c:when>
                            <c:when test="${apiErrorCategory eq 'INVALID_INPUT'}">
                                <li>ReefAPI rejected search parameters. Please verify airport codes and future departure dates.</li>
                            </c:when>
                            <c:otherwise>
                                <li>The upstream ReefAPI flight feed is temporarily unreachable.</li>
                            </c:otherwise>
                        </c:choose>
                    </ul>
                </div>
                <div class="d-flex justify-content-center gap-2">
                    <button type="button" class="btn btn-primary px-4 rounded-pill" onclick="window.location.reload()">
                        <i class="bi bi-arrow-clockwise me-1"></i> Retry Search
                    </button>
                    <a href="${pageContext.request.contextPath}/search-flights?modify=true&tripType=${tripType}&source=${selectedSource}&destination=${selectedDestination}&departureDate=${selectedDepartureDate}&returnDate=${selectedReturnDate}&adults=${adults}&children=${children}&infants=${infants}&travelClass=${travelClass}"
                       id="btnSearchDiffRoute"
                       class="btn btn-outline-secondary px-4 rounded-pill">
                        <i class="bi bi-pencil-square me-1"></i> Modify Search
                    </a>
                </div>
            </div>
        </c:when>

        <%-- 2. NO FLIGHTS FOUND EMPTY STATE (Only when no API error occurred) --%>
        <c:when test="${empty flights}">
            <div class="empty-state-box my-4">
                <div class="empty-state-icon">
                    <i class="bi bi-airplane"></i>
                </div>
                <h3 class="fw-bold text-dark mb-2">No matching flights were found for this route and date.</h3>
                <p class="text-muted mx-auto mb-4" style="max-width: 500px;">
                    No flights found for your selected route and date. Try another date or route.
                </p>
                <div class="card border-0 bg-light mx-auto mb-4 text-start p-3" style="max-width: 440px;">
                    <div class="fw-semibold text-dark mb-2"><i class="bi bi-lightbulb text-warning me-1"></i> Suggestions:</div>
                    <ul class="text-muted small mb-0 ps-3">
                        <li>Try another travel date or flexible dates.</li>
                        <li>Check popular active routes: <strong>Jaipur (JAI) &rarr; Delhi (DEL)</strong> or <strong>Delhi (DEL) &rarr; Mumbai (BOM)</strong>.</li>
                        <li>Verify that departure and arrival airports are not identical.</li>
                    </ul>
                </div>
                <div class="d-flex justify-content-center gap-2">
                    <a href="${pageContext.request.contextPath}/search-flights?modify=true&tripType=${tripType}&source=${selectedSource}&destination=${selectedDestination}&departureDate=${selectedDepartureDate}&returnDate=${selectedReturnDate}&adults=${adults}&children=${children}&infants=${infants}&travelClass=${travelClass}"
                       id="btnSearchDiffRoute"
                       class="btn btn-primary px-4 rounded-pill">
                        <i class="bi bi-arrow-left me-1"></i> Search Different Route
                    </a>
                </div>
            </div>
        </c:when>

        <%-- FLIGHT RESULTS FOUND --%>
        <c:otherwise>
            <!-- Mobile Filters Toggle Button -->
            <div class="d-lg-none mb-3">
                <button class="btn btn-outline-primary btn-sm rounded-pill w-100 py-2 d-flex align-items-center justify-content-center gap-2"
                        type="button" data-bs-toggle="collapse" data-bs-target="#mobileFilterCollapse" aria-expanded="false" aria-controls="mobileFilterCollapse">
                    <i class="bi bi-funnel"></i> <span>Filter &amp; Refine Flights</span>
                </button>
            </div>

            <div class="results-layout">
                <!-- Left Sidebar Filters (Sticky on Desktop) -->
                <aside class="filter-sidebar collapse d-lg-block" id="mobileFilterCollapse">
                    <div class="filter-card">
                        <div class="filter-title">
                            <span>
                                <i class="bi bi-funnel-fill text-primary me-1"></i> Filters
                                <span id="activeFilterBadge" class="badge bg-primary-subtle text-primary ms-1 d-none" style="font-size: 0.72rem;">0</span>
                            </span>
                            <button type="button" 
                                    id="btnResetFilters" 
                                    class="btn btn-link btn-sm text-decoration-none p-0 text-muted" 
                                    role="button"
                                    style="cursor: pointer;"
                                    title="Reset all filters to default"
                                    onclick="resetAllFilters()">Reset</button>
                        </div>

                        <!-- Stops Filter -->
                        <div class="filter-section">
                            <div class="filter-subtitle">Stops</div>
                            <div class="form-check mb-1">
                                <input class="form-check-input filter-checkbox" type="checkbox" value="0" id="filterNonStop" checked onchange="applyFilters()">
                                <label class="form-check-label small" for="filterNonStop">Non-stop</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input filter-checkbox" type="checkbox" value="1" id="filter1Stop" checked onchange="applyFilters()">
                                <label class="form-check-label small" for="filter1Stop">1+ Stops</label>
                            </div>
                        </div>

                        <!-- Departure Time Filter -->
                        <div class="filter-section">
                            <div class="filter-subtitle">Departure Time</div>
                            <div class="form-check mb-1">
                                <input class="form-check-input time-filter" type="checkbox" value="morning" id="timeMorning" checked onchange="applyFilters()">
                                <label class="form-check-label small" for="timeMorning">Morning (00:00 - 12:00)</label>
                            </div>
                            <div class="form-check mb-1">
                                <input class="form-check-input time-filter" type="checkbox" value="afternoon" id="timeAfternoon" checked onchange="applyFilters()">
                                <label class="form-check-label small" for="timeAfternoon">Afternoon (12:00 - 18:00)</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input time-filter" type="checkbox" value="evening" id="timeEvening" checked onchange="applyFilters()">
                                <label class="form-check-label small" for="timeEvening">Evening (18:00 - 24:00)</label>
                            </div>
                        </div>

                        <!-- Airlines Filter -->
                        <div class="filter-section">
                            <div class="filter-subtitle">Airlines</div>
                            <div id="airlineFilterContainer">
                                <c:choose>
                                    <c:when test="${not empty availableAirlines}">
                                        <c:forEach var="entry" items="${availableAirlines}">
                                            <div class="form-check mb-1">
                                                <input class="form-check-input airline-filter" type="checkbox" value="${entry.key}" id="airline_${entry.key}" checked onchange="applyFilters()">
                                                <label class="form-check-label small" for="airline_${entry.key}">${entry.value}</label>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="small text-muted fst-italic">No airline filters for this search</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Price Cap Slider -->
                        <div class="filter-section">
                            <div class="filter-subtitle d-flex justify-content-between">
                                <span>Max Price</span>
                                <span id="priceDisplay" class="fw-bold text-dark">&#8377;<fmt:formatNumber value="${maxFilterPrice > 0 ? maxFilterPrice : 15000}" type="number" maxFractionDigits="0" /></span>
                            </div>
                            <input type="range" class="form-range" id="priceRangeSlider" 
                                   min="${minFilterPrice > 0 ? minFilterPrice : 2000}" 
                                   max="${maxFilterPrice > 0 ? maxFilterPrice : 15000}" 
                                   step="100" 
                                   value="${maxFilterPrice > 0 ? maxFilterPrice : 15000}" 
                                   data-default-max="${maxFilterPrice > 0 ? maxFilterPrice : 15000}"
                                   oninput="updatePriceFilter(this.value)">
                        </div>
                    </div>
                </aside>

                <!-- Right Results List Column -->
                <main class="flight-results-column results-main-col">
                    <!-- Results Header & Sorting Bar -->
                    <div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-3">
                        <div>
                            <div>
                                <span class="fw-bold fs-5 text-dark" id="visibleFlightCount">${flightCount}</span>
                                <span class="text-muted"> flights available</span>
                            </div>
                            <small class="text-muted" style="font-size: 0.8rem;"><i class="bi bi-info-circle me-1"></i>Final price may change when booking.</small>
                        </div>

                        <div class="d-flex align-items-center gap-2">
                            <label for="sortSelector" class="small text-muted fw-semibold text-nowrap">Sort by:</label>
                            <select class="form-select form-select-sm" id="sortSelector" style="width: auto;" onchange="sortFlightCards(this.value)">
                                <option value="recommended">Recommended</option>
                                <option value="price-asc">Price: Low to High</option>
                                <option value="price-desc">Price: High to Low</option>
                                <option value="departure-asc">Departure: Earliest</option>
                                <option value="duration-asc">Duration: Shortest</option>
                            </select>
                        </div>
                    </div>

                    <!-- Flight Cards Container -->
                    <div id="flightListContainer">
                        <c:forEach var="item" items="${flights}">
                            <c:set var="fare" value="${item.getPriceForClass(travelClass)}" />
                            
                            <div class="flight-card"
                                 data-airline="${item.flight.airline.airlineCode}"
                                 data-stops="${item.flight.stops}"
                                 data-price="${fare}"
                                 data-departure="${item.flight.formattedDepartureTime}"
                                 data-duration="${item.flight.durationMinutes}">

                                <!-- 1. Airline Column -->
                                <div class="flight-col-airline">
                                    <c:set var="aCode" value="${item.flight.airline.airlineCode}" />
                                    <div class="airline-logo-box">
                                        <c:choose>
                                            <c:when test="${aCode eq '6E' || aCode eq 'AI' || aCode eq 'QP' || aCode eq 'UK' || aCode eq 'IX'}">
                                                <img src="${pageContext.request.contextPath}/assets/images/airlines/${aCode eq 'IX' ? 'AI' : aCode}.svg" alt="${item.flight.airline.airlineName}" class="airline-logo-img">
                                            </c:when>
                                            <c:otherwise>
                                                <span class="airline-code-fallback">${aCode}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="airline-meta">
                                        <div class="airline-name">${item.flight.airline.airlineName}</div>
                                        <div class="flight-number">${item.flight.flightNumber}</div>
                                        <c:if test="${not empty item.flight.aircraftModel && item.flight.aircraftModel ne 'AeroDataBox' && item.flight.aircraftModel ne 'Unknown'}">
                                            <div class="aircraft-details" title="${item.flight.aircraftModel}">
                                                <i class="bi bi-airplane me-1"></i>${item.flight.aircraftModel}
                                            </div>
                                        </c:if>
                                    </div>
                                </div>

                                <!-- 2. Departure Column -->
                                <div class="flight-col-departure">
                                    <div class="flight-time">${item.flight.formattedDepartureTime}</div>
                                    <div class="airport-code">${item.flight.sourceAirport.airportCode}</div>
                                    <div class="airport-city">${item.flight.sourceAirport.city}</div>
                                    <c:if test="${not empty item.departureTerminal}">
                                        <div class="terminal-info">${item.departureTerminal}</div>
                                    </c:if>
                                </div>

                                <!-- 3. Journey Indicator Column -->
                                <div class="flight-col-journey flight-journey">
                                    <span class="journey-duration">${item.flight.formattedDuration}</span>
                                    <div class="journey-route" aria-hidden="true">
                                        <span class="journey-endpoint-dot"></span>
                                        <span class="journey-route-line"></span>
                                        <span class="journey-aircraft-icon"><i class="bi bi-airplane-fill"></i></span>
                                        <span class="journey-route-line"></span>
                                        <span class="journey-endpoint-dot"></span>
                                    </div>
                                    <span class="journey-stops ${item.flight.stops > 0 ? 'stops-connecting' : 'stops-direct'}">
                                        ${item.flight.stopsDescription}
                                    </span>
                                </div>

                                <!-- 4. Arrival Column -->
                                <div class="flight-col-arrival">
                                    <div class="flight-time">${item.flight.formattedArrivalTime}</div>
                                    <div class="airport-code">${item.flight.destinationAirport.airportCode}</div>
                                    <div class="airport-city">${item.flight.destinationAirport.city}</div>
                                    <c:if test="${not empty item.arrivalTerminal}">
                                        <div class="terminal-info">${item.arrivalTerminal}</div>
                                    </c:if>
                                    <c:if test="${not empty item.baggageBelt}">
                                        <div class="baggage-info"><i class="bi bi-luggage me-1"></i>Belt ${item.baggageBelt}</div>
                                    </c:if>
                                </div>

                                <!-- 5. Price & Actions Column -->
                                <div class="flight-col-pricing">
                                    <div class="pricing-text-block">
                                        <c:set var="numPax" value="${empty passengers || passengers le 0 ? 1 : passengers}" />
                                        <c:set var="totalPrice" value="${fare * numPax}" />
                                        <div class="flight-price">&#8377;<fmt:formatNumber value="${totalPrice}" type="number" maxFractionDigits="0" /></div>
                                        <div class="price-subtext">
                                            <c:choose>
                                                <c:when test="${numPax > 1}">
                                                    &#8377;<fmt:formatNumber value="${fare}" type="number" maxFractionDigits="0" /> per adult &bull; ${travelClass}
                                                </c:when>
                                                <c:otherwise>
                                                    per adult &bull; ${travelClass}
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                    <div class="flight-action-buttons">
                                        <a href="${pageContext.request.contextPath}/flight-details?id=${item.scheduleId}&flightNumber=${item.flight.flightNumber}&travelClass=${travelClass}&passengers=${passengers}&departureDate=${selectedDepartureDate}&source=${selectedSource}&destination=${selectedDestination}&tripType=${tripType}&returnDate=${selectedReturnDate}&adults=${adults}&children=${children}&infants=${infants}"
                                           class="btn btn-view-details" onclick="onViewFlightClick(this, event)">
                                            VIEW FLIGHT
                                        </a>
                                        <a href="${pageContext.request.contextPath}/seat-selection?id=${item.scheduleId}&flightNumber=${item.flight.flightNumber}&travelClass=${travelClass}&passengers=${passengers}&departureDate=${selectedDepartureDate}&source=${selectedSource}&destination=${selectedDestination}&tripType=${tripType}&returnDate=${selectedReturnDate}&adults=${adults}&children=${children}&infants=${infants}"
                                           class="btn btn-seat-select" title="Select Seats" aria-label="Select Seats">
                                            <i class="bi bi-grid-3x3"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- Client-Side Filter Empty State -->
                    <div id="filterEmptyState" class="empty-state-box d-none my-3">
                        <i class="bi bi-funnel text-muted fs-1 mb-2"></i>
                        <h5 class="fw-bold text-dark">No flights match your filters</h5>
                        <p class="text-muted small mb-3">Try widening your price range, stop choices, or airline selections.</p>
                        <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" id="btnResetFiltersEmptyState" onclick="resetAllFilters()">Reset Filters</button>
                    </div>
                </main>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- Client-side Interactive Filter & Sort Script -->
<script>
    function updatePriceFilter(val) {
        const display = document.getElementById('priceDisplay');
        if (display) {
            display.textContent = '\u20B9' + Number(val).toLocaleString('en-IN');
        }
        applyFilters();
    }

    function applyFilters() {
        const nonStopCb = document.getElementById('filterNonStop');
        const onePlusStopCb = document.getElementById('filter1Stop');
        const nonStop = nonStopCb ? nonStopCb.checked : true;
        const onePlusStop = onePlusStopCb ? onePlusStopCb.checked : true;

        const slider = document.getElementById('priceRangeSlider');
        const maxPrice = slider ? parseFloat(slider.value) : Infinity;

        const allAirlineCbs = document.querySelectorAll('.airline-filter');
        const activeAirlines = Array.from(document.querySelectorAll('.airline-filter:checked')).map(cb => cb.value);

        const allTimeCbs = document.querySelectorAll('.time-filter');
        const activeTimes = Array.from(document.querySelectorAll('.time-filter:checked')).map(cb => cb.value);

        const cards = document.querySelectorAll('.flight-card');
        let visibleCount = 0;

        cards.forEach(card => {
            const airline = card.getAttribute('data-airline');
            const stops = parseInt(card.getAttribute('data-stops'));
            const price = parseFloat(card.getAttribute('data-price'));
            const depTime = card.getAttribute('data-departure') || '00:00';

            // Stops filter logic
            let matchesStops = false;
            if (stops === 0 && nonStop) matchesStops = true;
            if (stops > 0 && onePlusStop) matchesStops = true;

            // Airline filter logic: if any checkboxes exist, only checked airlines match; if all unchecked, 0 match
            let matchesAirline = true;
            if (allAirlineCbs.length > 0) {
                matchesAirline = activeAirlines.includes(airline);
            }

            // Price filter logic
            let matchesPrice = isNaN(price) || price <= maxPrice;

            // Departure time filter logic
            let hour = parseInt(depTime.split(':')[0], 10) || 0;
            let timeCategory = hour < 12 ? 'morning' : (hour < 18 ? 'afternoon' : 'evening');
            let matchesTime = true;
            if (allTimeCbs.length > 0) {
                matchesTime = activeTimes.includes(timeCategory);
            }

            if (matchesStops && matchesAirline && matchesPrice && matchesTime) {
                card.style.display = '';
                visibleCount++;
            } else {
                card.style.display = 'none';
            }
        });

        const countDisplay = document.getElementById('visibleFlightCount');
        if (countDisplay) {
            countDisplay.textContent = visibleCount;
        }

        const emptyBox = document.getElementById('filterEmptyState');
        if (emptyBox) {
            if (visibleCount === 0 && cards.length > 0) {
                emptyBox.classList.remove('d-none');
            } else {
                emptyBox.classList.add('d-none');
            }
        }

        // Active filter indicator tracking
        let activeModCount = 0;
        if (!nonStop || !onePlusStop) activeModCount++;
        if (allAirlineCbs.length > 0 && activeAirlines.length < allAirlineCbs.length) activeModCount++;
        if (allTimeCbs.length > 0 && activeTimes.length < allTimeCbs.length) activeModCount++;
        if (slider) {
            const defMax = parseFloat(slider.getAttribute('data-default-max') || slider.max || '15000');
            if (maxPrice < defMax) activeModCount++;
        }

        const filterBadge = document.getElementById('activeFilterBadge');
        if (filterBadge) {
            if (activeModCount > 0) {
                filterBadge.textContent = activeModCount;
                filterBadge.classList.remove('d-none');
            } else {
                filterBadge.classList.add('d-none');
            }
        }
    }

    function resetAllFilters() {
        // 1. Restore all checkbox controls to default state (all checked)
        document.querySelectorAll('.filter-checkbox, .airline-filter, .time-filter').forEach(cb => {
            cb.checked = true;
        });

        // 2. Reset price range slider to default maximum
        const slider = document.getElementById('priceRangeSlider');
        if (slider) {
            const defMax = slider.getAttribute('data-default-max') || slider.max || '15000';
            slider.value = defMax;
            const display = document.getElementById('priceDisplay');
            if (display) {
                display.textContent = '\u20B9' + Number(defMax).toLocaleString('en-IN');
            }
        }

        // 3. Clear active filter indicator badge
        const filterBadge = document.getElementById('activeFilterBadge');
        if (filterBadge) {
            filterBadge.classList.add('d-none');
        }

        // 4. Reset sort selector to recommended
        const sortSelect = document.getElementById('sortSelector');
        if (sortSelect) {
            sortSelect.value = 'recommended';
            sortFlightCards('recommended');
        }

        // 5. Re-evaluate filters and update visible flights immediately
        applyFilters();
    }

    function sortFlightCards(criteria) {
        const container = document.getElementById('flightListContainer');
        if (!container) return;
        const cards = Array.from(container.getElementsByClassName('flight-card'));

        cards.sort((a, b) => {
            const priceA = parseFloat(a.getAttribute('data-price')) || 0;
            const priceB = parseFloat(b.getAttribute('data-price')) || 0;
            const depA = a.getAttribute('data-departure') || '';
            const depB = b.getAttribute('data-departure') || '';
            const durA = parseInt(a.getAttribute('data-duration')) || 0;
            const durB = parseInt(b.getAttribute('data-duration')) || 0;

            switch (criteria) {
                case 'price-asc': return priceA - priceB;
                case 'price-desc': return priceB - priceA;
                case 'departure-asc': return depA.localeCompare(depB);
                case 'duration-asc': return durA - durB;
                default: return 0;
            }
        });

        cards.forEach(card => container.appendChild(card));
    }

    // View Flight Loading Feedback
    function onViewFlightClick(btn, event) {
        if (btn.classList.contains('disabled')) {
            event.preventDefault();
            return false;
        }
        btn.classList.add('disabled');
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span> Loading...';
    }

    // Restore view buttons on bfcache/pageshow
    window.addEventListener('pageshow', function() {
        document.querySelectorAll('.btn-view-details').forEach(function(b) {
            b.classList.remove('disabled');
            b.innerHTML = 'VIEW FLIGHT';
        });
    });

    // Wire up listeners and notices on DOM ready
    document.addEventListener('DOMContentLoaded', function() {
        const resetBtn = document.getElementById('btnResetFilters');
        if (resetBtn) {
            resetBtn.addEventListener('click', function(e) {
                e.preventDefault();
                resetAllFilters();
            });
        }
        const resetEmptyBtn = document.getElementById('btnResetFiltersEmptyState');
        if (resetEmptyBtn) {
            resetEmptyBtn.addEventListener('click', function(e) {
                e.preventDefault();
                resetAllFilters();
            });
        }

        <c:if test="${not empty apiError}">
            if (window.SkyTechToast) {
                SkyTechToast.error("Flight Service Notice", "${apiError}");
            }
        </c:if>
    });
</script>

<jsp:include page="../common/footer.jsp" />
