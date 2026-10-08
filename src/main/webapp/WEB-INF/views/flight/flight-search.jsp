<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="container my-4">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb small">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home" class="text-decoration-none">Home</a></li>
            <li class="breadcrumb-item active" aria-current="page">Search Flights</li>
        </ol>
    </nav>

    <!-- Hero Header Banner -->
    <div class="flight-hero mb-4">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <span class="badge bg-light text-primary fw-bold text-uppercase px-3 py-1 mb-2 rounded-pill tracking-wide">
                    <i class="bi bi-airplane-engines me-1"></i> Flight Search Engine
                </span>
                <h1 class="display-5 fw-bold mb-2">Search Flights</h1>
                <p class="lead mb-0 text-white-75">
                    Compare flights, real-time fares, seat availability, and interactive cabin maps.
                </p>
            </div>
            <div class="col-lg-4 text-lg-end mt-3 mt-lg-0">
                <span class="badge bg-white-subtle text-white border border-light-subtle px-3 py-2 rounded-pill">
                    <i class="bi bi-airplane-fill me-1"></i> Domestic &amp; Regional Network
                </span>
            </div>
        </div>
    </div>

    <!-- Search Card Container -->
    <div class="search-container-card mb-5">
        <!-- Validation Error Alerts (Server-Side) -->
        <c:if test="${not empty validationErrors}">
            <div class="alert alert-danger d-flex align-items-start gap-2 mb-4" role="alert">
                <i class="bi bi-exclamation-octagon-fill fs-5 mt-1"></i>
                <div>
                    <h6 class="alert-heading fw-bold mb-1">Please correct the following:</h6>
                    <ul class="mb-0 ps-3">
                        <c:forEach var="err" items="${validationErrors}">
                            <li><c:out value="${err}" /></li>
                        </c:forEach>
                    </ul>
                </div>
            </div>
        </c:if>

        <!-- Client-Side Validation Alert Placeholder -->
        <div id="clientValidationAlert" class="alert alert-danger d-none align-items-center gap-2 mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill fs-5"></i>
            <span id="clientValidationText"></span>
        </div>

        <form id="flightSearchForm" action="${pageContext.request.contextPath}/search-flights" method="GET" novalidate>
            <!-- Trip Type Selector -->
            <div class="d-flex flex-wrap align-items-center gap-2 mb-4">
                <button type="button" class="trip-type-btn ${tripType == 'one-way' ? 'active' : ''}" id="btnOneWay" onclick="selectTripType('one-way')">
                    <i class="bi bi-arrow-right me-1"></i> One Way
                </button>
                <button type="button" class="trip-type-btn ${tripType == 'round-trip' ? 'active' : ''}" id="btnRoundTrip" onclick="selectTripType('round-trip')">
                    <i class="bi bi-arrow-left-right me-1"></i> Round Trip
                </button>
                <button type="button" class="trip-type-btn ${tripType == 'multi-city' ? 'active' : ''}" id="btnMultiCity" onclick="selectTripType('multi-city')">
                    <i class="bi bi-signpost-split me-1"></i> Multi City
                </button>
                <input type="hidden" name="tripType" id="tripTypeInput" value="${empty tripType ? 'one-way' : tripType}">
            </div>

            <!-- Main Route & Date Selector Grid -->
            <!-- Standard Route Grid Container -->
            <div id="standardRouteContainer" class="${tripType == 'multi-city' ? 'd-none' : ''}">
                <div class="row g-3 align-items-center" id="standardRouteRow">
                    <!-- FROM (Origin) -->
                    <div class="col-lg-${tripType == 'round-trip' ? '3' : '4'} col-md-5" id="fromCol">
                        <div class="search-field-box position-relative" id="fromBoxContainer">
                            <label class="field-label">
                                <i class="bi bi-geo-alt-fill text-primary"></i> FROM
                            </label>
                            <input type="text" class="field-input fw-bold" id="fromAirportDisplay" 
                                   placeholder="City or Airport (e.g. DEL, Mumbai)" 
                                   value="${not empty selectedSource ? selectedSource : 'JAI'}" 
                                   autocomplete="off" required onfocus="openAirportDropdown('from')" oninput="onAirportSearchInput('from')">
                            <small class="text-muted d-block text-truncate" id="fromSubtext">
                                Jaipur &bull; Jaipur International Airport
                            </small>
                            <input type="hidden" name="source" id="sourceCodeInput" value="${not empty selectedSource ? selectedSource : 'JAI'}">

                            <!-- Autocomplete Dropdown List -->
                            <div class="airport-autocomplete-list shadow-lg d-none" id="fromAirportList">
                                <div class="p-2 border-bottom bg-light">
                                    <small class="fw-bold text-muted text-uppercase">Select Departure Airport</small>
                                </div>
                                <div class="autocomplete-items" id="fromAirportItems">
                                    <!-- Populated dynamically by JS -->
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Swap Button -->
                    <div class="col-lg-auto col-md-2 text-center d-flex justify-content-center" id="swapCol">
                        <button type="button" class="btn-swap-airports" id="btnSwapAirports" title="Swap departure and arrival airports" onclick="swapAirports()">
                            <i class="bi bi-arrow-left-right"></i>
                        </button>
                    </div>

                    <!-- TO (Destination) -->
                    <div class="col-lg-${tripType == 'round-trip' ? '3' : '4'} col-md-5" id="toCol">
                        <div class="search-field-box position-relative" id="toBoxContainer">
                            <label class="field-label">
                                <i class="bi bi-geo-fill text-danger"></i> TO
                            </label>
                            <input type="text" class="field-input fw-bold" id="toAirportDisplay" 
                                   placeholder="City or Airport (e.g. BOM, Delhi)" 
                                   value="${not empty selectedDestination ? selectedDestination : 'DEL'}" 
                                   autocomplete="off" required onfocus="openAirportDropdown('to')" oninput="onAirportSearchInput('to')">
                            <small class="text-muted d-block text-truncate" id="toSubtext">
                                Delhi &bull; Indira Gandhi International Airport
                            </small>
                            <input type="hidden" name="destination" id="destCodeInput" value="${not empty selectedDestination ? selectedDestination : 'DEL'}">

                            <!-- Autocomplete Dropdown List -->
                            <div class="airport-autocomplete-list shadow-lg d-none" id="toAirportList">
                                <div class="p-2 border-bottom bg-light">
                                    <small class="fw-bold text-muted text-uppercase">Select Arrival Airport</small>
                                </div>
                                <div class="autocomplete-items" id="toAirportItems">
                                    <!-- Populated dynamically by JS -->
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Departure Date -->
                    <div class="col-lg-3 col-md-6" id="depCol">
                        <div class="search-field-box">
                            <label for="departureDateInput" class="field-label">
                                <i class="bi bi-calendar-event text-primary"></i> DEPARTURE
                            </label>
                            <input type="date" class="form-control field-input" id="departureDateInput" name="departureDate"
                                   min="${minDate}" value="${not empty selectedDepartureDate ? selectedDepartureDate : minDate}" required
                                   onchange="onDepartureDateChange()">
                            <small class="text-muted d-block" id="departureDayLabel">Select date</small>
                        </div>
                    </div>

                    <!-- Return Date (Hidden in One Way) -->
                    <div class="col-lg-2 col-md-6 ${tripType == 'round-trip' ? '' : 'd-none'}" id="returnDateContainer">
                        <div class="search-field-box">
                            <label for="returnDateInput" class="field-label">
                                <i class="bi bi-calendar2-check text-primary"></i> RETURN
                            </label>
                            <input type="date" class="form-control field-input" id="returnDateInput" 
                                   ${tripType == 'round-trip' ? 'name="returnDate"' : ''}
                                   min="${minDate}" value="${selectedReturnDate}" 
                                   ${tripType == 'round-trip' ? '' : 'disabled'}
                                   onchange="onReturnDateChange()">
                            <small class="text-muted d-block" id="returnDayLabel">${tripType == 'round-trip' ? 'Select return' : 'Select return date'}</small>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Multi-City Dynamic Builder Container -->
            <div id="multiCityContainer" class="${tripType == 'multi-city' ? '' : 'd-none'}">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <span class="small text-muted fw-bold text-uppercase">
                        <i class="bi bi-signpost-2 me-1 text-primary"></i> Multi-City Flight Segments (Up to 5)
                    </span>
                    <small class="text-muted">Dates must be consecutive</small>
                </div>
                <div id="multiCitySegmentsWrapper">
                    <!-- Populated dynamically via JS -->
                </div>
                <div class="d-flex align-items-center gap-2 mb-3">
                    <button type="button" class="btn btn-outline-primary btn-sm rounded-pill px-3" id="btnAddSegmentBtn" onclick="addMultiCitySegment()">
                        <i class="bi bi-plus-circle me-1"></i> Add Another Flight
                    </button>
                    <small class="text-muted" id="segmentCountNotice">Maximum 5 flight segments</small>
                </div>
                <input type="hidden" name="segmentCount" id="segmentCountInput" value="2">
            </div>

            <!-- Row 2: Passengers, Cabin & CTA -->
            <div class="row g-3 mt-1 align-items-center">
                <!-- Passengers Selector Dropdown -->
                <div class="col-lg-4 col-md-6">
                    <div class="search-field-box dropdown">
                        <label class="field-label">
                            <i class="bi bi-people-fill text-primary"></i> TRAVELLERS
                        </label>
                        <button type="button" class="btn p-0 text-start w-100 fw-bold d-flex justify-content-between align-items-center"
                                id="passengerDropdownBtn" data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false">
                            <span id="passengerSummaryText">${empty passengers ? '1 Adult' : passengers} ${empty passengers ? '' : (passengers > 1 ? 'Passengers' : 'Passenger')}</span>
                            <i class="bi bi-chevron-down text-muted small"></i>
                        </button>

                        <div class="dropdown-menu passenger-dropdown-menu" aria-labelledby="passengerDropdownBtn">
                            <!-- Adults -->
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div>
                                    <div class="fw-bold">Adults</div>
                                    <small class="text-muted">12+ years</small>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <button type="button" class="counter-btn" onclick="updatePassenger('adults', -1)">&minus;</button>
                                    <span id="adultCountDisplay" class="fw-bold px-2">${empty adults ? 1 : adults}</span>
                                    <button type="button" class="counter-btn" onclick="updatePassenger('adults', 1)">&#43;</button>
                                </div>
                            </div>

                            <!-- Children -->
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div>
                                    <div class="fw-bold">Children</div>
                                    <small class="text-muted">2 - 11 years</small>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <button type="button" class="counter-btn" onclick="updatePassenger('children', -1)">&minus;</button>
                                    <span id="childCountDisplay" class="fw-bold px-2">${empty children ? 0 : children}</span>
                                    <button type="button" class="counter-btn" onclick="updatePassenger('children', 1)">&#43;</button>
                                </div>
                            </div>

                            <!-- Infants -->
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div>
                                    <div class="fw-bold">Infants</div>
                                    <small class="text-muted">Under 2 years (on lap)</small>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <button type="button" class="counter-btn" onclick="updatePassenger('infants', -1)">&minus;</button>
                                    <span id="infantCountDisplay" class="fw-bold px-2">${empty infants ? 0 : infants}</span>
                                    <button type="button" class="counter-btn" onclick="updatePassenger('infants', 1)">&#43;</button>
                                </div>
                            </div>

                            <hr class="my-2">
                            <div class="d-flex justify-content-between align-items-center">
                                <small class="text-muted" id="passengerTotalRuleNote">Max 9 travellers</small>
                                <button type="button" class="btn btn-primary btn-sm px-3 rounded-pill" onclick="closePassengerDropdown()">Apply</button>
                            </div>
                        </div>

                        <!-- Hidden fields storing passenger counts -->
                        <input type="hidden" name="adults" id="adultsInput" value="${empty adults ? 1 : adults}">
                        <input type="hidden" name="children" id="childrenInput" value="${empty children ? 0 : children}">
                        <input type="hidden" name="infants" id="infantsInput" value="${empty infants ? 0 : infants}">
                    </div>
                </div>

                <!-- Cabin Class Selector -->
                <div class="col-lg-4 col-md-6">
                    <div class="search-field-box">
                        <label for="travelClassSelect" class="field-label">
                            <i class="bi bi-award-fill text-primary"></i> CABIN CLASS
                        </label>
                        <select class="form-select field-input fw-bold" id="travelClassSelect" name="travelClass">
                            <option value="Economy" ${empty travelClass || travelClass == 'Economy' ? 'selected' : ''}>Economy</option>
                            <option value="Premium Economy" ${travelClass == 'Premium Economy' ? 'selected' : ''}>Premium Economy</option>
                            <option value="Business" ${travelClass == 'Business' ? 'selected' : ''}>Business</option>
                            <option value="First Class" ${travelClass == 'First Class' ? 'selected' : ''}>First Class</option>
                        </select>
                    </div>
                </div>

                <!-- Search CTA Button -->
                <div class="col-lg-4 col-md-12">
                    <button type="submit" class="btn btn-search-flights w-100 py-3" id="btnSubmitSearch">
                        <span id="btnSearchText"><i class="bi bi-search me-1"></i> SEARCH FLIGHTS</span>
                        <span id="btnSearchSpinner" class="spinner-border spinner-border-sm d-none" role="status" aria-hidden="true"></span>
                    </button>
                </div>
            </div>
        </form>

        <!-- Quick Route Chips -->
        <div class="mt-4 pt-3 border-top d-flex flex-wrap align-items-center gap-2">
            <span class="text-muted small fw-semibold me-2">Frequent routes:</span>
            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill" onclick="setQuickRoute('JAI', 'DEL', 'Jaipur', 'Delhi')">
                Jaipur (JAI) &rarr; Delhi (DEL)
            </button>
            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill" onclick="setQuickRoute('DEL', 'BOM', 'Delhi', 'Mumbai')">
                Delhi (DEL) &rarr; Mumbai (BOM)
            </button>
            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill" onclick="setQuickRoute('BOM', 'BLR', 'Mumbai', 'Bengaluru')">
                Mumbai (BOM) &rarr; Bengaluru (BLR)
            </button>
            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill" onclick="setQuickRoute('DEL', 'GOI', 'Delhi', 'Goa')">
                Delhi (DEL) &rarr; Goa (GOI)
            </button>
        </div>
    </div>
</main>

<!-- Airport Autocomplete Dataset & Client Script -->
<script>
    const AIRPORTS_DATA = [
        { code: 'JAI', city: 'Jaipur', name: 'Jaipur International Airport', terminal: 'Terminal 2' },
        { code: 'DEL', city: 'Delhi', name: 'Indira Gandhi International Airport', terminal: 'Terminal 3' },
        { code: 'BOM', city: 'Mumbai', name: 'Chhatrapati Shivaji Maharaj International Airport', terminal: 'Terminal 2' },
        { code: 'BLR', city: 'Bengaluru', name: 'Kempegowda International Airport', terminal: 'Terminal 1' },
        { code: 'HYD', city: 'Hyderabad', name: 'Rajiv Gandhi International Airport', terminal: 'Main Terminal' },
        { code: 'CCU', city: 'Kolkata', name: 'Netaji Subhash Chandra Bose International Airport', terminal: 'Terminal 2' },
        { code: 'MAA', city: 'Chennai', name: 'Chennai International Airport', terminal: 'Terminal 1' },
        { code: 'AMD', city: 'Ahmedabad', name: 'Sardar Vallabhbhai Patel International Airport', terminal: 'Terminal 1' },
        { code: 'PNQ', city: 'Pune', name: 'Pune Airport', terminal: 'Main Terminal' },
        { code: 'GOI', city: 'Goa', name: 'Dabolim Airport', terminal: 'Terminal 1' }
    ];

    let multiCitySegments = [
        { source: 'JAI', dest: 'DEL', date: '' },
        { source: 'DEL', dest: 'BOM', date: '' }
    ];

    function selectTripType(type) {
        document.getElementById('tripTypeInput').value = type;
        const btnOneWay = document.getElementById('btnOneWay');
        const btnRoundTrip = document.getElementById('btnRoundTrip');
        const btnMultiCity = document.getElementById('btnMultiCity');
        const returnContainer = document.getElementById('returnDateContainer');
        const returnInput = document.getElementById('returnDateInput');
        const returnLabel = document.getElementById('returnDayLabel');
        const stdContainer = document.getElementById('standardRouteContainer');
        const mcContainer = document.getElementById('multiCityContainer');

        const fromCol = document.getElementById('fromCol');
        const toCol = document.getElementById('toCol');
        const depCol = document.getElementById('depCol');

        [btnOneWay, btnRoundTrip, btnMultiCity].forEach(b => { if (b) b.classList.remove('active'); });

        if (type === 'round-trip') {
            btnRoundTrip.classList.add('active');
            stdContainer.classList.remove('d-none');
            mcContainer.classList.add('d-none');
            returnContainer.classList.remove('d-none');
            returnInput.disabled = false;
            returnInput.setAttribute('name', 'returnDate');
            returnInput.required = true;

            if (fromCol) fromCol.className = 'col-lg-3 col-md-5';
            if (toCol) toCol.className = 'col-lg-3 col-md-5';
            if (depCol) depCol.className = 'col-lg-3 col-md-6';
            if (returnContainer) returnContainer.className = 'col-lg-2 col-md-6';

            const depDate = document.getElementById('departureDateInput').value;
            if (depDate) {
                returnInput.min = depDate;
                if (!returnInput.value || returnInput.value < depDate) {
                    const d = new Date(depDate);
                    d.setDate(d.getDate() + 3);
                    returnInput.value = d.toISOString().split('T')[0];
                }
            }
            returnLabel.textContent = 'Select return';
        } else if (type === 'multi-city') {
            btnMultiCity.classList.add('active');
            stdContainer.classList.add('d-none');
            mcContainer.classList.remove('d-none');
            returnContainer.classList.add('d-none');
            returnInput.disabled = true;
            returnInput.removeAttribute('name');
            returnInput.value = '';
            returnInput.required = false;
            renderMultiCitySegments();
        } else {
            // One Way: completely hide return date field
            btnOneWay.classList.add('active');
            stdContainer.classList.remove('d-none');
            mcContainer.classList.add('d-none');
            returnContainer.classList.add('d-none');
            returnInput.disabled = true;
            returnInput.removeAttribute('name');
            returnInput.value = '';
            returnInput.required = false;

            if (fromCol) fromCol.className = 'col-lg-4 col-md-5';
            if (toCol) toCol.className = 'col-lg-4 col-md-5';
            if (depCol) depCol.className = 'col-lg-3 col-md-6';
        }
    }

    function renderMultiCitySegments() {
        const wrapper = document.getElementById('multiCitySegmentsWrapper');
        if (!wrapper) return;
        wrapper.innerHTML = '';

        const today = new Date();
        const baseDate = new Date(today);
        baseDate.setDate(baseDate.getDate() + 2);

        multiCitySegments.forEach((seg, idx) => {
            const num = idx + 1;
            if (!seg.date) {
                const d = new Date(baseDate);
                d.setDate(d.getDate() + (idx * 3));
                seg.date = d.toISOString().split('T')[0];
            }

            const card = document.createElement('div');
            card.className = 'multi-city-segment-card';
            card.innerHTML =
                '<div class="segment-badge-header">' +
                    '<span><i class="bi bi-airplane me-1"></i> Flight ' + num + '</span>' +
                    (idx >= 2 ? '<button type="button" class="btn-remove-segment" onclick="removeMultiCitySegment(' + idx + ')"><i class="bi bi-trash me-1"></i>Remove</button>' : '') +
                '</div>' +
                '<div class="row g-2 align-items-center">' +
                    '<div class="col-md-4">' +
                        '<label class="field-label small text-muted">FROM</label>' +
                        '<select class="form-select form-select-sm fw-bold" name="segSource_' + num + '" id="segSrc_' + num + '" onchange="multiCitySegments[' + idx + '].source = this.value">' +
                            buildAirportOptions(seg.source) +
                        '</select>' +
                    '</div>' +
                    '<div class="col-md-4">' +
                        '<label class="field-label small text-muted">TO</label>' +
                        '<select class="form-select form-select-sm fw-bold" name="segDest_' + num + '" id="segDst_' + num + '" onchange="multiCitySegments[' + idx + '].dest = this.value">' +
                            buildAirportOptions(seg.dest) +
                        '</select>' +
                    '</div>' +
                    '<div class="col-md-4">' +
                        '<label class="field-label small text-muted">DATE</label>' +
                        '<input type="date" class="form-control form-select-sm fw-bold" name="segDate_' + num + '" id="segDate_' + num + '" value="' + seg.date + '" min="' + today.toISOString().split('T')[0] + '" onchange="onMultiCityDateChange(' + idx + ', this.value)">' +
                    '</div>' +
                '</div>';

            wrapper.appendChild(card);
        });

        document.getElementById('segmentCountInput').value = multiCitySegments.length;
        document.getElementById('btnAddSegmentBtn').disabled = (multiCitySegments.length >= 5);
        document.getElementById('segmentCountNotice').textContent = multiCitySegments.length + ' of 5 flights added';
    }

    function buildAirportOptions(selectedCode) {
        return AIRPORTS_DATA.map(a =>
            '<option value="' + a.code + '" ' + (a.code === selectedCode ? 'selected' : '') + '>' + a.city + ' (' + a.code + ')</option>'
        ).join('');
    }

    function addMultiCitySegment() {
        if (multiCitySegments.length < 5) {
            const last = multiCitySegments[multiCitySegments.length - 1];
            const nextSrc = last ? last.dest : 'DEL';
            let nextDst = 'BOM';
            if (nextSrc === 'BOM') nextDst = 'BLR';
            if (nextSrc === 'BLR') nextDst = 'HYD';

            let nextDate = '';
            if (last && last.date) {
                const d = new Date(last.date);
                d.setDate(d.getDate() + 3);
                nextDate = d.toISOString().split('T')[0];
            }

            multiCitySegments.push({ source: nextSrc, dest: nextDst, date: nextDate });
            renderMultiCitySegments();
        }
    }

    function removeMultiCitySegment(index) {
        if (multiCitySegments.length > 2) {
            multiCitySegments.splice(index, 1);
            renderMultiCitySegments();
        }
    }

    function onMultiCityDateChange(index, newDate) {
        multiCitySegments[index].date = newDate;
        for (let i = index + 1; i < multiCitySegments.length; i++) {
            if (multiCitySegments[i].date && multiCitySegments[i].date < newDate) {
                multiCitySegments[i].date = newDate;
                const dateEl = document.getElementById('segDate_' + (i + 1));
                if (dateEl) {
                    dateEl.value = newDate;
                    dateEl.min = newDate;
                }
            }
        }
    }

    function swapAirports() {
        const srcCode = document.getElementById('sourceCodeInput');
        const dstCode = document.getElementById('destCodeInput');
        const srcDisplay = document.getElementById('fromAirportDisplay');
        const dstDisplay = document.getElementById('toAirportDisplay');
        const srcSub = document.getElementById('fromSubtext');
        const dstSub = document.getElementById('toSubtext');

        const tempCode = srcCode.value;
        const tempDisp = srcDisplay.value;
        const tempSub = srcSub.textContent;

        srcCode.value = dstCode.value;
        srcDisplay.value = dstDisplay.value;
        srcSub.textContent = dstSub.textContent;

        dstCode.value = tempCode;
        dstDisplay.value = tempDisp;
        dstSub.textContent = tempSub;
    }

    function openAirportDropdown(target) {
        const list = document.getElementById(target + 'AirportList');
        const items = document.getElementById(target + 'AirportItems');
        renderAirportList(target, '', items);
        list.classList.remove('d-none');
    }

    function onAirportSearchInput(target) {
        const input = document.getElementById(target + 'AirportDisplay').value;
        const items = document.getElementById(target + 'AirportItems');
        renderAirportList(target, input, items);
    }

    function renderAirportList(target, filterText, container) {
        container.innerHTML = '';
        const q = filterText.toLowerCase().trim();

        const filtered = AIRPORTS_DATA.filter(a => 
            !q || a.code.toLowerCase().includes(q) || a.city.toLowerCase().includes(q) || a.name.toLowerCase().includes(q)
        );

        if (filtered.length === 0) {
            container.innerHTML = '<div class="p-3 text-muted text-center small">No matching airports found</div>';
            return;
        }

        filtered.forEach(a => {
            const row = document.createElement('div');
            row.className = 'autocomplete-item p-2 d-flex justify-content-between align-items-center';
            row.style.cursor = 'pointer';
            row.innerHTML = '<div>' +
                '<strong class="d-block text-dark">' + a.city + ' (' + a.code + ')</strong>' +
                '<small class="text-muted">' + a.name + '</small>' +
                '</div>' +
                '<span class="badge bg-light text-primary border">' + a.code + '</span>';

            row.addEventListener('click', () => {
                selectAirport(target, a);
            });
            container.appendChild(row);
        });
    }

    function selectAirport(target, airport) {
        if (target === 'from') {
            document.getElementById('sourceCodeInput').value = airport.code;
            document.getElementById('fromAirportDisplay').value = airport.city + ' (' + airport.code + ')';
            document.getElementById('fromSubtext').textContent = airport.city + ' • ' + airport.name;
            document.getElementById('fromAirportList').classList.add('d-none');
        } else {
            document.getElementById('destCodeInput').value = airport.code;
            document.getElementById('toAirportDisplay').value = airport.city + ' (' + airport.code + ')';
            document.getElementById('toSubtext').textContent = airport.city + ' • ' + airport.name;
            document.getElementById('toAirportList').classList.add('d-none');
        }
    }

    // Close autocomplete when clicking outside
    document.addEventListener('click', function (e) {
        const fromBox = document.getElementById('fromBoxContainer');
        const toBox = document.getElementById('toBoxContainer');
        if (fromBox && !fromBox.contains(e.target)) {
            document.getElementById('fromAirportList').classList.add('d-none');
        }
        if (toBox && !toBox.contains(e.target)) {
            document.getElementById('toAirportList').classList.add('d-none');
        }
    });

    function setQuickRoute(srcCode, dstCode, srcCity, dstCity) {
        const srcApt = AIRPORTS_DATA.find(a => a.code === srcCode);
        const dstApt = AIRPORTS_DATA.find(a => a.code === dstCode);
        if (srcApt) selectAirport('from', srcApt);
        if (dstApt) selectAirport('to', dstApt);
    }

    function onDepartureDateChange() {
        const dep = document.getElementById('departureDateInput').value;
        const ret = document.getElementById('returnDateInput');
        const retLabel = document.getElementById('returnDayLabel');
        if (dep) {
            ret.min = dep;
            if (ret.value && ret.value < dep) {
                ret.value = '';
                if (retLabel) retLabel.textContent = 'Please select a valid return date';
            }
            const dateObj = new Date(dep + 'T00:00:00');
            document.getElementById('departureDayLabel').textContent = dateObj.toLocaleDateString('en-US', { weekday: 'long' });
        }
    }

    function onReturnDateChange() {
        const dep = document.getElementById('departureDateInput').value;
        const ret = document.getElementById('returnDateInput');
        const retLabel = document.getElementById('returnDayLabel');
        if (ret && ret.value) {
            if (dep && ret.value < dep) {
                ret.value = '';
                if (retLabel) retLabel.textContent = 'Return cannot be before departure';
            }
        }
    }

    function updatePassenger(type, delta) {
        const adultInput = document.getElementById('adultsInput');
        const childInput = document.getElementById('childrenInput');
        const infantInput = document.getElementById('infantsInput');

        let a = parseInt(adultInput.value) || 1;
        let c = parseInt(childInput.value) || 0;
        let i = parseInt(infantInput.value) || 0;

        if (type === 'adults') a = Math.max(1, Math.min(9, a + delta));
        if (type === 'children') c = Math.max(0, Math.min(8, c + delta));
        if (type === 'infants') {
            i = Math.max(0, Math.min(a, i + delta)); // Infants cannot exceed adults
        }

        if (a + c + i > 9) return; // Total limit 9

        adultInput.value = a;
        childInput.value = c;
        infantInput.value = i;

        document.getElementById('adultCountDisplay').textContent = a;
        document.getElementById('childCountDisplay').textContent = c;
        document.getElementById('infantCountDisplay').textContent = i;

        let summary = a + (a === 1 ? ' Adult' : ' Adults');
        if (c > 0) summary += ', ' + c + (c === 1 ? ' Child' : ' Children');
        if (i > 0) summary += ', ' + i + (i === 1 ? ' Infant' : ' Infants');

        document.getElementById('passengerSummaryText').textContent = summary;
    }

    function closePassengerDropdown() {
        const dropdownBtn = document.getElementById('passengerDropdownBtn');
        const dropdownInstance = bootstrap.Dropdown.getInstance(dropdownBtn);
        if (dropdownInstance) dropdownInstance.hide();
    }

    // Form submission validation
    document.getElementById('flightSearchForm').addEventListener('submit', function (e) {
        const alertBox = document.getElementById('clientValidationAlert');
        const alertText = document.getElementById('clientValidationText');
        alertBox.classList.add('d-none');

        const src = document.getElementById('sourceCodeInput').value;
        const dst = document.getElementById('destCodeInput').value;
        const dep = document.getElementById('departureDateInput').value;
        const tripType = document.getElementById('tripTypeInput').value;
        const ret = document.getElementById('returnDateInput').value;

        if (tripType === 'multi-city') {
            if (multiCitySegments.length < 2) {
                showError('Multi-City travel requires at least 2 flight segments.');
                e.preventDefault();
                return;
            }
            for (let i = 0; i < multiCitySegments.length; i++) {
                const segNum = i + 1;
                const srcEl = document.getElementById('segSrc_' + segNum);
                const dstEl = document.getElementById('segDst_' + segNum);
                const dateEl = document.getElementById('segDate_' + segNum);

                const srcVal = srcEl ? srcEl.value : '';
                const dstVal = dstEl ? dstEl.value : '';
                const dateVal = dateEl ? dateEl.value : '';

                if (!srcVal || !dstVal) {
                    showError('Flight ' + segNum + ': Departure and Arrival airports are required.');
                    e.preventDefault();
                    return;
                }
                if (srcVal.toUpperCase() === dstVal.toUpperCase()) {
                    showError('Flight ' + segNum + ': Departure and Arrival airports cannot be the same.');
                    e.preventDefault();
                    return;
                }
                if (!dateVal) {
                    showError('Flight ' + segNum + ': Flight date is required.');
                    e.preventDefault();
                    return;
                }
                const today = new Date().toISOString().split('T')[0];
                if (dateVal < today) {
                    showError('Flight ' + segNum + ': Departure date cannot be in the past.');
                    e.preventDefault();
                    return;
                }
                if (i > 0) {
                    const prevDateEl = document.getElementById('segDate_' + i);
                    if (prevDateEl && dateVal < prevDateEl.value) {
                        showError('Flight ' + segNum + ' date cannot be before Flight ' + i + ' date.');
                        e.preventDefault();
                        return;
                    }
                }
            }
        } else {
            if (!src) {
                showError('Please select a departure airport.');
                e.preventDefault();
                return;
            }

            if (!dst) {
                showError('Please select an arrival airport.');
                e.preventDefault();
                return;
            }

            if (src.toUpperCase() === dst.toUpperCase()) {
                showError('Departure and arrival airports cannot be the same.');
                e.preventDefault();
                return;
            }

            if (!dep) {
                showError('Please select a departure date.');
                e.preventDefault();
                return;
            }

            const today = new Date().toISOString().split('T')[0];
            if (dep < today) {
                showError('Departure date cannot be in the past.');
                e.preventDefault();
                return;
            }

            if (tripType === 'round-trip') {
                if (!ret) {
                    showError('Please select a return date for round trip.');
                    e.preventDefault();
                    return;
                }
                if (ret < dep) {
                    showError('Return date cannot be before departure date.');
                    e.preventDefault();
                    return;
                }
            }
        }

        // Show loading spinner
        document.getElementById('btnSearchText').textContent = 'Searching Flights...';
        document.getElementById('btnSearchSpinner').classList.remove('d-none');

        function showError(msg) {
            alertText.textContent = msg;
            alertBox.classList.remove('d-none');
            alertBox.classList.add('d-flex');
            window.scrollTo({ top: alertBox.offsetTop - 80, behavior: 'smooth' });
        }
    });

    // Run date sync on page load
    onDepartureDateChange();
</script>

<jsp:include page="../common/footer.jsp" />
