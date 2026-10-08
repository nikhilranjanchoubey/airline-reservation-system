<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="container my-4">
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
                <c:when test="${isLiveProvider}">
                    <span class="badge bg-success-subtle text-success border border-success-subtle px-3 py-1 rounded-pill">
                        <i class="bi bi-broadcast me-1"></i> Live Flights
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="badge bg-light text-muted border px-3 py-1 rounded-pill small">
                        <i class="bi bi-check2-circle text-success me-1"></i> Flights Available
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
                        <span><i class="bi bi-calendar-event me-1"></i> ${selectedDepartureDate}</span>
                        <span>&bull;</span>
                        <span><i class="bi bi-people me-1"></i> ${passengers} ${passengers == 1 ? 'Passenger' : 'Passengers'}</span>
                        <span>&bull;</span>
                        <span class="badge bg-primary-subtle text-primary">${travelClass}</span>
                    </div>
                </div>
            </div>

            <div class="col-lg-4 text-lg-end">
                <a href="${pageContext.request.contextPath}/search-flights?source=${selectedSource}&destination=${selectedDestination}&departureDate=${selectedDepartureDate}&tripType=${tripType}&returnDate=${selectedReturnDate}&adults=${adults}&children=${children}&infants=${infants}&travelClass=${travelClass}"
                   class="btn btn-outline-primary btn-sm rounded-pill px-3">
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

    <!-- Flight Search Availability Notice -->
    <c:if test="${not empty dbError}">
        <div class="alert alert-warning border-warning-subtle shadow-sm mb-4 rounded-3" role="alert">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-info-circle-fill text-warning fs-5"></i>
                <div>
                    <h6 class="alert-heading fw-bold mb-0">Flight search is temporarily unavailable</h6>
                    <p class="small mb-0 text-muted">Please try your search again in a few moments.</p>
                </div>
            </div>
        </div>
    </c:if>

    <!-- Main Results Section -->
    <c:choose>
        <%-- NO FLIGHTS FOUND EMPTY STATE --%>
        <c:when test="${empty flights}">
            <div class="empty-state-box my-4">
                <div class="empty-state-icon">
                    <i class="bi bi-airplane"></i>
                </div>
                <h3 class="fw-bold text-dark mb-2">No flights found</h3>
                <p class="text-muted mx-auto mb-4" style="max-width: 500px;">
                    We couldn't find any flights operating from 
                    <strong>${not empty sourceAirport ? sourceAirport.city : selectedSource}</strong> to 
                    <strong>${not empty destinationAirport ? destinationAirport.city : selectedDestination}</strong> 
                    on <strong>${selectedDepartureDate}</strong>.
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
                    <a href="${pageContext.request.contextPath}/search-flights" class="btn btn-primary px-4 rounded-pill">
                        <i class="bi bi-arrow-left me-1"></i> Search Different Route
                    </a>
                </div>
            </div>
        </c:when>

        <%-- FLIGHT RESULTS FOUND --%>
        <c:otherwise>
            <div class="row g-4">
                <!-- Left Sidebar Filters -->
                <div class="col-lg-3">
                    <div class="filter-card">
                        <div class="filter-title">
                            <span><i class="bi bi-funnel-fill text-primary me-1"></i> Filters</span>
                            <button type="button" class="btn btn-link btn-sm text-decoration-none p-0 text-muted" onclick="resetAllFilters()">Reset</button>
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
                            <div class="form-check mb-1">
                                <input class="form-check-input airline-filter" type="checkbox" value="6E" id="airline6E" checked onchange="applyFilters()">
                                <label class="form-check-label small" for="airline6E">IndiGo</label>
                            </div>
                            <div class="form-check mb-1">
                                <input class="form-check-input airline-filter" type="checkbox" value="AI" id="airlineAI" checked onchange="applyFilters()">
                                <label class="form-check-label small" for="airlineAI">Air India</label>
                            </div>
                            <div class="form-check mb-1">
                                <input class="form-check-input airline-filter" type="checkbox" value="UK" id="airlineUK" checked onchange="applyFilters()">
                                <label class="form-check-label small" for="airlineUK">Vistara</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input airline-filter" type="checkbox" value="QP" id="airlineQP" checked onchange="applyFilters()">
                                <label class="form-check-label small" for="airlineQP">Akasa Air</label>
                            </div>
                        </div>

                        <!-- Price Cap Slider -->
                        <div class="filter-section">
                            <div class="filter-subtitle d-flex justify-content-between">
                                <span>Max Price</span>
                                <span id="priceDisplay" class="fw-bold text-dark">&#8377;15,000</span>
                            </div>
                            <input type="range" class="form-range" id="priceRangeSlider" min="2000" max="15000" step="500" value="15000" oninput="updatePriceFilter(this.value)">
                        </div>
                    </div>
                </div>

                <!-- Right Results List Column -->
                <div class="col-lg-9">
                    <!-- Results Header & Sorting Bar -->
                    <div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-3">
                        <div>
                            <span class="fw-bold fs-5 text-dark" id="visibleFlightCount">${flightCount}</span>
                            <span class="text-muted"> flights available</span>
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

                                <div class="row align-items-center gy-3">
                                    <!-- Airline Section -->
                                    <div class="col-md-3 col-12">
                                        <div class="airline-badge d-flex align-items-center gap-3">
                                            <c:set var="aCode" value="${item.flight.airline.airlineCode}" />
                                            <div class="airline-logo-box" style="width: 46px; height: 46px; min-width: 46px; border-radius: 10px; overflow: hidden; display: flex; align-items: center; justify-content: center; background: #ffffff; border: 1px solid #e2e8f0; padding: 4px;">
                                                <c:choose>
                                                    <c:when test="${aCode eq '6E' || aCode eq 'AI' || aCode eq 'QP' || aCode eq 'UK'}">
                                                        <img src="${pageContext.request.contextPath}/assets/images/airlines/${aCode}.svg" alt="${item.flight.airline.airlineName}" style="max-width: 100%; max-height: 100%; object-fit: contain;">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="fw-bold text-primary small">${aCode}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div>
                                                <div class="fw-bold text-dark">${item.flight.airline.airlineName}</div>
                                                <div class="small text-muted">${item.flight.flightNumber}</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Flight Route & Timeline -->
                                    <div class="col-md-5 col-12">
                                        <div class="d-flex align-items-center justify-content-between">
                                            <!-- Departure Info -->
                                            <div class="text-start">
                                                <div class="flight-time">${item.flight.formattedDepartureTime}</div>
                                                <div class="flight-code">${item.flight.sourceAirport.airportCode}</div>
                                                <div class="flight-city">${item.flight.sourceAirport.city}</div>
                                            </div>

                                            <!-- Duration Timeline -->
                                            <div class="flight-duration-container flex-grow-1 px-3">
                                                <div class="duration-text">${item.flight.formattedDuration}</div>
                                                <div class="flight-timeline-line">
                                                    <i class="bi bi-airplane-fill plane-mid-icon"></i>
                                                </div>
                                                <div class="stop-type ${item.flight.stops > 0 ? 'text-secondary' : 'text-success'}">
                                                    ${item.flight.stopsDescription}
                                                </div>
                                            </div>

                                            <!-- Arrival Info -->
                                            <div class="text-end">
                                                <div class="flight-time">${item.flight.formattedArrivalTime}</div>
                                                <div class="flight-code">${item.flight.destinationAirport.airportCode}</div>
                                                <div class="flight-city">${item.flight.destinationAirport.city}</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Fare and Booking Actions -->
                                    <div class="col-md-4 col-12 border-start-md">
                                        <div class="d-flex flex-md-column flex-row justify-content-between align-items-md-end align-items-center gap-2">
                                            <div class="text-md-end">
                                                <div class="price-tag">&#8377;<fmt:formatNumber value="${fare}" type="number" maxFractionDigits="0" /></div>
                                                <div class="price-subtext">per passenger &bull; ${travelClass}</div>
                                            </div>

                                            <div class="text-md-end mt-md-2 d-flex flex-column align-items-md-end gap-2">
                                                <span class="badge ${item.seatsBadgeClass} badge-seats">
                                                    <i class="bi bi-person-check me-1"></i> ${item.seatsAvailabilityText}
                                                </span>
                                                <div class="d-flex gap-2">
                                                    <a href="${pageContext.request.contextPath}/flight-details?id=${item.scheduleId}&travelClass=${travelClass}&passengers=${passengers}"
                                                       class="btn btn-view-details">
                                                        VIEW FLIGHT
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/seat-selection?id=${item.scheduleId}&travelClass=${travelClass}&passengers=${passengers}"
                                                       class="btn btn-outline-primary btn-sm px-2 d-flex align-items-center" title="Select Seats">
                                                        <i class="bi bi-grid-3x3"></i>
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
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
                        <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" onclick="resetAllFilters()">Reset Filters</button>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<!-- Client-side Interactive Filter & Sort Script -->
<script>
    function updatePriceFilter(val) {
        document.getElementById('priceDisplay').textContent = '\u20B9' + Number(val).toLocaleString('en-IN');
        applyFilters();
    }

    function applyFilters() {
        const nonStop = document.getElementById('filterNonStop').checked;
        const onePlusStop = document.getElementById('filter1Stop').checked;
        const maxPrice = parseFloat(document.getElementById('priceRangeSlider').value);

        const activeAirlines = Array.from(document.querySelectorAll('.airline-filter:checked')).map(cb => cb.value);
        const activeTimes = Array.from(document.querySelectorAll('.time-filter:checked')).map(cb => cb.value);

        const cards = document.querySelectorAll('.flight-card');
        let visibleCount = 0;

        cards.forEach(card => {
            const airline = card.getAttribute('data-airline');
            const stops = parseInt(card.getAttribute('data-stops'));
            const price = parseFloat(card.getAttribute('data-price'));
            const depTime = card.getAttribute('data-departure');

            let matchesStops = (stops === 0 && nonStop) || (stops > 0 && onePlusStop);
            let matchesAirline = activeAirlines.length === 0 || activeAirlines.includes(airline);
            let matchesPrice = isNaN(price) || price <= maxPrice;

            let hour = parseInt(depTime.split(':')[0]);
            let timeCategory = hour < 12 ? 'morning' : (hour < 18 ? 'afternoon' : 'evening');
            let matchesTime = activeTimes.length === 0 || activeTimes.includes(timeCategory);

            if (matchesStops && matchesAirline && matchesPrice && matchesTime) {
                card.style.display = 'block';
                visibleCount++;
            } else {
                card.style.display = 'none';
            }
        });

        const countDisplay = document.getElementById('visibleFlightCount');
        if (countDisplay) countDisplay.textContent = visibleCount;

        const emptyBox = document.getElementById('filterEmptyState');
        if (emptyBox) {
            if (visibleCount === 0 && cards.length > 0) {
                emptyBox.classList.remove('d-none');
            } else {
                emptyBox.classList.add('d-none');
            }
        }
    }

    function resetAllFilters() {
        document.querySelectorAll('.filter-checkbox, .airline-filter, .time-filter').forEach(cb => cb.checked = true);
        const slider = document.getElementById('priceRangeSlider');
        if (slider) {
            slider.value = 15000;
            document.getElementById('priceDisplay').textContent = '\u20B915,000';
        }
        applyFilters();
    }

    function sortFlightCards(criteria) {
        const container = document.getElementById('flightListContainer');
        if (!container) return;
        const cards = Array.from(container.getElementsByClassName('flight-card'));

        cards.sort((a, b) => {
            const priceA = parseFloat(a.getAttribute('data-price')) || 0;
            const priceB = parseFloat(b.getAttribute('data-price')) || 0;
            const depA = a.getAttribute('data-departure');
            const depB = b.getAttribute('data-departure');
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
</script>

<jsp:include page="../common/footer.jsp" />
