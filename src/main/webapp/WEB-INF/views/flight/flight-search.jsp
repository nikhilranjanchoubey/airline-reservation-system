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
                <div class="booking-form-grid-row-1 ${tripType == 'round-trip' ? 'is-round-trip' : ''}" id="standardRouteRow">
                    <!-- FROM (Origin) -->
                    <div id="fromCol">
                        <div class="search-field-box position-relative" id="fromBoxContainer">
                            <label class="field-label" for="fromAirportDisplay">
                                <i class="bi bi-geo-alt-fill text-primary"></i> FROM
                            </label>
                            <input type="text" class="field-input fw-bold" id="fromAirportDisplay" 
                                   placeholder="City or Airport (e.g. DEL, Mumbai)" 
                                   value="${not empty sourceAirport ? sourceAirport.city.concat(' (').concat(sourceAirport.airportCode).concat(')') : (not empty selectedSource ? selectedSource : 'Jaipur (JAI)')}" 
                                   autocomplete="off" required onfocus="openAirportDropdown('from')" oninput="onAirportSearchInput('from')">
                            <small class="field-subtext text-muted text-truncate d-block" id="fromSubtext">
                                <c:choose>
                                    <c:when test="${not empty sourceAirport}">${sourceAirport.city} &bull; ${sourceAirport.airportName}</c:when>
                                    <c:otherwise>Jaipur &bull; Jaipur International Airport</c:otherwise>
                                </c:choose>
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
                    <div class="swap-grid-col text-center d-flex justify-content-center" id="swapCol">
                        <button type="button" class="btn-swap-airports" id="btnSwapAirports" title="Swap departure and arrival airports" onclick="swapAirports()" aria-label="Swap departure and arrival airports">
                            <i class="bi bi-arrow-left-right"></i>
                        </button>
                    </div>

                    <!-- TO (Destination) -->
                    <div id="toCol">
                        <div class="search-field-box position-relative" id="toBoxContainer">
                            <label class="field-label" for="toAirportDisplay">
                                <i class="bi bi-geo-fill text-danger"></i> TO
                            </label>
                            <input type="text" class="field-input fw-bold" id="toAirportDisplay" 
                                   placeholder="City or Airport (e.g. BOM, Delhi)" 
                                   value="${not empty destAirport ? destAirport.city.concat(' (').concat(destAirport.airportCode).concat(')') : (not empty selectedDestination ? selectedDestination : 'Delhi (DEL)')}" 
                                   autocomplete="off" required onfocus="openAirportDropdown('to')" oninput="onAirportSearchInput('to')">
                            <small class="field-subtext text-muted text-truncate d-block" id="toSubtext">
                                <c:choose>
                                    <c:when test="${not empty destAirport}">${destAirport.city} &bull; ${destAirport.airportName}</c:when>
                                    <c:otherwise>Delhi &bull; Indira Gandhi International Airport</c:otherwise>
                                </c:choose>
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
                    <div class="dep-grid-col" id="depCol">
                        <div class="search-field-box date-picker-box position-relative" id="depFieldBox"
                             onclick="openSearchPageCalendar('departure')" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();openSearchPageCalendar('departure');}"
                             role="button" tabindex="0" aria-label="Departure Date Picker">
                            <label class="field-label" style="pointer-events: none;">
                                <i class="bi bi-calendar-event text-primary"></i> DEPARTURE
                            </label>
                            <div class="d-flex align-items-center justify-content-between" id="departureDateDisplay" style="pointer-events: none;">
                                <div class="text-truncate">
                                    <span class="field-input-text fw-bold text-dark d-block text-truncate" id="departureDatePrimary">
                                        <c:choose>
                                            <c:when test="${not empty formattedDepartureDate}">${formattedDepartureDate}</c:when>
                                            <c:when test="${not empty selectedDepartureDate}">${selectedDepartureDate}</c:when>
                                            <c:when test="${not empty todayFormatted}">${todayFormatted}</c:when>
                                            <c:otherwise>Select Date</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <small class="field-subtext text-muted text-truncate d-block" id="departureDaySubtext">
                                        <c:choose>
                                            <c:when test="${not empty departureDayOfWeek}">&bull; ${departureDayOfWeek}</c:when>
                                            <c:when test="${not empty todayDayOfWeek}">&bull; ${todayDayOfWeek}</c:when>
                                        </c:choose>
                                    </small>
                                </div>
                                <i class="bi bi-calendar3 text-primary fs-5 ms-2 flex-shrink-0" aria-hidden="true"></i>
                            </div>
                            <input type="hidden" id="departureDateInput" name="departureDate"
                                   value="${not empty selectedDepartureDate ? selectedDepartureDate : (not empty todayDate ? todayDate : minDate)}">
                        </div>
                    </div>

                    <!-- Return Date (Hidden in One Way) -->
                    <div class="return-grid-col ${tripType == 'round-trip' ? '' : 'd-none'}" id="returnDateContainer">
                        <div class="search-field-box date-picker-box position-relative" id="returnFieldBox"
                             onclick="openSearchPageCalendar('return')" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();openSearchPageCalendar('return');}"
                             role="button" tabindex="0" aria-label="Return Date Picker">
                            <label class="field-label" style="pointer-events: none;">
                                <i class="bi bi-calendar2-check text-primary"></i> RETURN
                            </label>
                            <div class="d-flex align-items-center justify-content-between" id="returnDateDisplay" style="pointer-events: none;">
                                <div class="text-truncate">
                                    <span class="field-input-text fw-bold text-dark d-block text-truncate" id="returnDatePrimary">
                                        <c:choose>
                                            <c:when test="${not empty formattedReturnDate}">${formattedReturnDate}</c:when>
                                            <c:when test="${not empty selectedReturnDate}">${selectedReturnDate}</c:when>
                                            <c:otherwise>Select Return</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <small class="field-subtext text-muted text-truncate d-block" id="returnDaySubtext">
                                        <c:if test="${not empty returnDayOfWeek}">&bull; ${returnDayOfWeek}</c:if>
                                    </small>
                                </div>
                                <i class="bi bi-calendar3 text-primary fs-5 ms-2 flex-shrink-0" aria-hidden="true"></i>
                            </div>
                            <input type="hidden" id="returnDateInput" 
                                   ${tripType == 'round-trip' ? 'name="returnDate"' : ''}
                                   value="${selectedReturnDate}" 
                                   ${tripType == 'round-trip' ? '' : 'disabled'}>
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
            <div class="booking-form-grid-row-2">
                <!-- Passengers Selector Dropdown -->
                <div id="passengerCol">
                    <div class="search-field-box dropdown position-relative" id="passengerBoxContainer">
                        <label class="field-label" id="passengerDropdownLabel">
                            <i class="bi bi-people-fill text-primary"></i> TRAVELLERS
                        </label>
                        <button type="button" class="field-select-trigger btn p-0 text-start w-100 d-flex justify-content-between align-items-center"
                                id="passengerDropdownBtn" data-bs-toggle="dropdown" data-bs-auto-close="outside" data-bs-display="static" aria-expanded="false" aria-labelledby="passengerDropdownLabel passengerDropdownBtn">
                            <div class="text-truncate">
                                <span id="passengerSummaryText" class="field-input-text fw-bold text-dark d-block text-truncate">
                                    <c:choose>
                                        <c:when test="${not empty passengers && passengers > 1}">${passengers} Travellers</c:when>
                                        <c:otherwise>1 Traveller</c:otherwise>
                                    </c:choose>
                                </span>
                                <small id="passengerSubtext" class="field-subtext text-muted text-truncate d-block">
                                    <c:choose>
                                        <c:when test="${not empty adults}">${adults} Adult<c:if test="${adults > 1}">s</c:if><c:if test="${not empty children && children > 0}">, ${children} Child</c:if><c:if test="${not empty infants && infants > 0}">, ${infants} Infant</c:if></c:when>
                                        <c:otherwise>1 Adult</c:otherwise>
                                    </c:choose>
                                </small>
                            </div>
                            <i class="bi bi-chevron-down text-muted small ms-2 field-chevron flex-shrink-0"></i>
                        </button>

                        <div class="dropdown-menu passenger-dropdown-menu shadow-lg p-3" aria-labelledby="passengerDropdownBtn">
                            <!-- Adults -->
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div>
                                    <div class="fw-bold">Adults</div>
                                    <small class="text-muted">12+ years</small>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <button type="button" class="counter-btn" id="adultMinusBtn" onclick="updatePassenger('adults', -1)" ${empty adults || adults <= 1 ? 'disabled' : ''} aria-label="Decrease adult passengers">&minus;</button>
                                    <span id="adultCountDisplay" class="fw-bold px-2">${empty adults ? 1 : adults}</span>
                                    <button type="button" class="counter-btn" id="adultPlusBtn" onclick="updatePassenger('adults', 1)" aria-label="Increase adult passengers">&#43;</button>
                                </div>
                            </div>

                            <!-- Children -->
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div>
                                    <div class="fw-bold">Children</div>
                                    <small class="text-muted">2 - 11 years</small>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <button type="button" class="counter-btn" id="childMinusBtn" onclick="updatePassenger('children', -1)" ${empty children || children <= 0 ? 'disabled' : ''} aria-label="Decrease child passengers">&minus;</button>
                                    <span id="childCountDisplay" class="fw-bold px-2">${empty children ? 0 : children}</span>
                                    <button type="button" class="counter-btn" id="childPlusBtn" onclick="updatePassenger('children', 1)" aria-label="Increase child passengers">&#43;</button>
                                </div>
                            </div>

                            <!-- Infants -->
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div>
                                    <div class="fw-bold">Infants</div>
                                    <small class="text-muted">Under 2 years (on lap)</small>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <button type="button" class="counter-btn" id="infantMinusBtn" onclick="updatePassenger('infants', -1)" ${empty infants || infants <= 0 ? 'disabled' : ''} aria-label="Decrease infant passengers">&minus;</button>
                                    <span id="infantCountDisplay" class="fw-bold px-2">${empty infants ? 0 : infants}</span>
                                    <button type="button" class="counter-btn" id="infantPlusBtn" onclick="updatePassenger('infants', 1)" aria-label="Increase infant passengers">&#43;</button>
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
                <div id="cabinCol">
                    <div class="search-field-box dropdown position-relative" id="cabinClassBoxContainer">
                        <label id="travelClassDropdownLabel" class="field-label">
                            <i class="bi bi-award-fill text-primary"></i> CABIN CLASS
                        </label>
                        <button type="button" 
                                class="field-select-trigger btn p-0 text-start w-100 d-flex justify-content-between align-items-center cabin-class-btn"
                                id="travelClassDropdownBtn" 
                                data-bs-toggle="dropdown" 
                                data-bs-display="static"
                                aria-expanded="false" 
                                aria-haspopup="listbox" 
                                aria-labelledby="travelClassDropdownLabel travelClassDropdownBtn">
                            <div class="text-truncate">
                                <span id="travelClassDisplayText" class="field-input-text fw-bold text-dark d-block text-truncate">${not empty travelClass ? travelClass : 'Economy'}</span>
                                <small id="travelClassSubtext" class="field-subtext text-muted text-truncate d-block">
                                    <c:choose>
                                        <c:when test="${travelClass == 'Premium Economy'}">Extra legroom</c:when>
                                        <c:when test="${travelClass == 'Business'}">Spacious seating</c:when>
                                        <c:when test="${travelClass == 'First Class'}">Luxury suite</c:when>
                                        <c:otherwise>Standard seating</c:otherwise>
                                    </c:choose>
                                </small>
                            </div>
                            <i class="bi bi-chevron-down text-muted small ms-2 field-chevron flex-shrink-0"></i>
                        </button>

                        <ul class="dropdown-menu cabin-class-dropdown-menu shadow-lg p-2" 
                            id="travelClassMenuList"
                            aria-labelledby="travelClassDropdownBtn"
                            role="listbox">
                            <li role="option" aria-selected="${empty travelClass || travelClass == 'Economy' ? 'true' : 'false'}">
                                <button type="button" class="dropdown-item cabin-option-item rounded-2 py-2 px-3 d-flex align-items-center justify-content-between ${empty travelClass || travelClass == 'Economy' ? 'active' : ''}" 
                                        data-value="Economy"
                                        data-subtext="Standard seating &amp; value fares"
                                        onclick="selectCabinClass('Economy', 'Standard seating &amp; value fares')">
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="cabin-icon-box text-primary">
                                            <i class="bi bi-person-fill"></i>
                                        </div>
                                        <div>
                                            <div class="fw-bold cabin-option-title">Economy</div>
                                            <small class="text-muted d-block cabin-option-sub">Standard seating and value fares</small>
                                        </div>
                                    </div>
                                    <i class="bi bi-check-lg text-primary fw-bold cabin-check-icon ${empty travelClass || travelClass == 'Economy' ? '' : 'd-none'}"></i>
                                </button>
                            </li>
                            <li role="option" aria-selected="${travelClass == 'Premium Economy' ? 'true' : 'false'}">
                                <button type="button" class="dropdown-item cabin-option-item rounded-2 py-2 px-3 d-flex align-items-center justify-content-between ${travelClass == 'Premium Economy' ? 'active' : ''}" 
                                        data-value="Premium Economy"
                                        data-subtext="Extra space &amp; added comfort"
                                        onclick="selectCabinClass('Premium Economy', 'Extra space &amp; added comfort')">
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="cabin-icon-box text-primary">
                                            <i class="bi bi-gem"></i>
                                        </div>
                                        <div>
                                            <div class="fw-bold cabin-option-title">Premium Economy</div>
                                            <small class="text-muted d-block cabin-option-sub">Extra space and added comfort</small>
                                        </div>
                                    </div>
                                    <i class="bi bi-check-lg text-primary fw-bold cabin-check-icon ${travelClass == 'Premium Economy' ? '' : 'd-none'}"></i>
                                </button>
                            </li>
                            <li role="option" aria-selected="${travelClass == 'Business' ? 'true' : 'false'}">
                                <button type="button" class="dropdown-item cabin-option-item rounded-2 py-2 px-3 d-flex align-items-center justify-content-between ${travelClass == 'Business' ? 'active' : ''}" 
                                        data-value="Business"
                                        data-subtext="More space &amp; premium services"
                                        onclick="selectCabinClass('Business', 'More space &amp; premium services')">
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="cabin-icon-box text-primary">
                                            <i class="bi bi-briefcase-fill"></i>
                                        </div>
                                        <div>
                                            <div class="fw-bold cabin-option-title">Business</div>
                                            <small class="text-muted d-block cabin-option-sub">More space and premium services</small>
                                        </div>
                                    </div>
                                    <i class="bi bi-check-lg text-primary fw-bold cabin-check-icon ${travelClass == 'Business' ? '' : 'd-none'}"></i>
                                </button>
                            </li>
                            <li role="option" aria-selected="${travelClass == 'First Class' ? 'true' : 'false'}">
                                <button type="button" class="dropdown-item cabin-option-item rounded-2 py-2 px-3 d-flex align-items-center justify-content-between ${travelClass == 'First Class' ? 'active' : ''}" 
                                        data-value="First Class"
                                        data-subtext="Premium cabin experience"
                                        onclick="selectCabinClass('First Class', 'Premium cabin experience')">
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="cabin-icon-box text-primary">
                                            <i class="bi bi-stars"></i>
                                        </div>
                                        <div>
                                            <div class="fw-bold cabin-option-title">First Class</div>
                                            <small class="text-muted d-block cabin-option-sub">Premium cabin experience</small>
                                        </div>
                                    </div>
                                    <i class="bi bi-check-lg text-primary fw-bold cabin-check-icon ${travelClass == 'First Class' ? '' : 'd-none'}"></i>
                                </button>
                            </li>
                        </ul>

                        <!-- Hidden form field ensuring robust form submission & Modify Search preservation -->
                        <input type="hidden" name="travelClass" id="travelClassInput" value="${not empty travelClass ? travelClass : 'Economy'}">
                    </div>
                </div>

                <!-- Search CTA Button -->
                <div class="search-cta-grid-col" id="searchCtaCol">
                    <button type="submit" class="btn btn-search-flights shadow-sm" id="btnSearchSubmit">
                        <span id="btnSearchText" class="d-flex align-items-center justify-content-center gap-2">
                            <i class="bi bi-search"></i> SEARCH FLIGHTS
                        </span>
                        <span id="btnSearchSpinner" class="spinner-border spinner-border-sm d-none ms-2" role="status" aria-hidden="true"></span>
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

    function getClientTodayIso() {
        const now = new Date();
        const y = now.getFullYear();
        const m = String(now.getMonth() + 1).padStart(2, '0');
        const d = String(now.getDate()).padStart(2, '0');
        return y + '-' + m + '-' + d;
    }

    function parseIsoParts(isoStr) {
        if (!isoStr || !isoStr.includes('-')) return null;
        const parts = isoStr.split('-');
        if (parts.length !== 3) return null;
        return new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
    }

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
        const stdRow = document.getElementById('standardRouteRow');
        const mcContainer = document.getElementById('multiCityContainer');

        [btnOneWay, btnRoundTrip, btnMultiCity].forEach(b => { if (b) b.classList.remove('active'); });

        if (type === 'round-trip') {
            btnRoundTrip.classList.add('active');
            stdContainer.classList.remove('d-none');
            mcContainer.classList.add('d-none');
            if (stdRow) stdRow.classList.add('is-round-trip');
            returnContainer.classList.remove('d-none');
            returnInput.disabled = false;
            returnInput.setAttribute('name', 'returnDate');
            returnInput.required = true;

            const depDate = document.getElementById('departureDateInput').value;
            if (depDate) {
                returnInput.min = depDate;
                if (!returnInput.value || returnInput.value < depDate) {
                    const parsed = parseIsoParts(depDate);
                    if (parsed) {
                        parsed.setDate(parsed.getDate() + 3);
                        const y = parsed.getFullYear();
                        const m = String(parsed.getMonth() + 1).padStart(2, '0');
                        const d = String(parsed.getDate()).padStart(2, '0');
                        returnInput.value = y + '-' + m + '-' + d;
                    }
                }
            }
            onReturnDateChange();
        } else if (type === 'multi-city') {
            btnMultiCity.classList.add('active');
            stdContainer.classList.add('d-none');
            mcContainer.classList.remove('d-none');
            if (stdRow) stdRow.classList.remove('is-round-trip');
            returnContainer.classList.add('d-none');
            returnInput.disabled = true;
            returnInput.removeAttribute('name');
            returnInput.value = '';
            returnInput.required = false;
            renderMultiCitySegments();
        } else {
            // One Way: completely clear and hide return date field
            btnOneWay.classList.add('active');
            stdContainer.classList.remove('d-none');
            mcContainer.classList.add('d-none');
            if (stdRow) stdRow.classList.remove('is-round-trip');
            returnContainer.classList.add('d-none');
            returnInput.disabled = true;
            returnInput.removeAttribute('name');
            returnInput.value = '';
            returnInput.required = false;
        }
    }

    function renderMultiCitySegments() {
        const wrapper = document.getElementById('multiCitySegmentsWrapper');
        if (!wrapper) return;
        wrapper.innerHTML = '';

        const todayIso = getClientTodayIso();
        const baseDate = parseIsoParts(todayIso) || new Date();
        baseDate.setDate(baseDate.getDate() + 1);

        multiCitySegments.forEach((seg, idx) => {
            const num = idx + 1;
            if (!seg.date) {
                const d = new Date(baseDate);
                d.setDate(d.getDate() + (idx * 2));
                const y = d.getFullYear();
                const m = String(d.getMonth() + 1).padStart(2, '0');
                const dd = String(d.getDate()).padStart(2, '0');
                seg.date = y + '-' + m + '-' + dd;
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
                        '<input type="date" class="form-control form-select-sm fw-bold" name="segDate_' + num + '" id="segDate_' + num + '" value="' + seg.date + '" min="' + todayIso + '" onchange="onMultiCityDateChange(' + idx + ', this.value)">' +
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
                const parsed = parseIsoParts(last.date);
                if (parsed) {
                    parsed.setDate(parsed.getDate() + 2);
                    const y = parsed.getFullYear();
                    const m = String(parsed.getMonth() + 1).padStart(2, '0');
                    const d = String(parsed.getDate()).padStart(2, '0');
                    nextDate = y + '-' + m + '-' + d;
                }
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
            const nextEl = document.getElementById('segDate_' + (i + 1));
            if (nextEl) {
                nextEl.min = newDate;
                if (nextEl.value && nextEl.value < newDate) {
                    nextEl.value = newDate;
                    multiCitySegments[i].date = newDate;
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

    function updateDateLabel(dateStr, primaryId, subId) {
        const primary = document.getElementById(primaryId);
        const sub = document.getElementById(subId);
        if (!primary) return;
        if (!dateStr) {
            primary.textContent = 'Select Date';
            if (sub) sub.textContent = '';
            return;
        }
        const parts = dateStr.split('-');
        if (parts.length === 3) {
            const y = parseInt(parts[0], 10);
            const m = parseInt(parts[1], 10) - 1;
            const d = parseInt(parts[2], 10);
            const dt = new Date(y, m, d);
            const dayStr = String(d).padStart(2, '0');
            const monthStr = dt.toLocaleDateString('en-US', { month: 'short' });
            const weekday = dt.toLocaleDateString('en-US', { weekday: 'long' });
            primary.textContent = dayStr + ' ' + monthStr + ' ' + y;
            if (sub) sub.textContent = '\u2022 ' + weekday;
            return;
        }
    }
    const SERVER_TODAY_ISO = '${todayDate}' || getClientTodayIso();

    function openSearchPageCalendar(type) {
        if (!window.SkyTechCalendar) return;

        const isReturn = (type === 'return');
        const triggerBox = isReturn ? document.getElementById('returnFieldBox') : document.getElementById('depFieldBox');
        const inputEl = isReturn ? document.getElementById('returnDateInput') : document.getElementById('departureDateInput');
        const primaryDisplayEl = isReturn ? document.getElementById('returnDatePrimary') : document.getElementById('departureDatePrimary');
        const subtextDisplayEl = isReturn ? document.getElementById('returnDaySubtext') : document.getElementById('departureDaySubtext');

        const depVal = document.getElementById('departureDateInput').value;
        const minIso = isReturn ? (depVal || SERVER_TODAY_ISO) : SERVER_TODAY_ISO;

        SkyTechCalendar.open(triggerBox, {
            inputEl: inputEl,
            primaryDisplayEl: primaryDisplayEl,
            subtextDisplayEl: subtextDisplayEl,
            placeholderText: isReturn ? 'Select Return' : 'Select Date',
            minDateIso: minIso,
            onSelect: function(selectedDateStr) {
                if (!isReturn) {
                    const retInput = document.getElementById('returnDateInput');
                    if (retInput && retInput.value && retInput.value < selectedDateStr) {
                        retInput.value = '';
                        const retPrimary = document.getElementById('returnDatePrimary');
                        const retSub = document.getElementById('returnDaySubtext');
                        if (retPrimary) retPrimary.textContent = 'Select Return';
                        if (retSub) retSub.textContent = '';
                        if (window.showToast) {
                            window.showToast("Return date must be on or after the departure date.", "warning", "Return Date Reset");
                        }
                    }
                }
            },
            onClear: function() {
                if (!isReturn) {
                    const retInput = document.getElementById('returnDateInput');
                    if (retInput) {
                        retInput.value = '';
                        const retPrimary = document.getElementById('returnDatePrimary');
                        const retSub = document.getElementById('returnDaySubtext');
                        if (retPrimary) retPrimary.textContent = 'Select Return';
                        if (retSub) retSub.textContent = '';
                    }
                }
            }
        });
    }

    function updatePassenger(type, delta) {
        const adultInput = document.getElementById('adultsInput');
        const childInput = document.getElementById('childrenInput');
        const infantInput = document.getElementById('infantsInput');

        let a = parseInt(adultInput.value) || 1;
        let c = parseInt(childInput.value) || 0;
        let i = parseInt(infantInput.value) || 0;

        if (type === 'adults') {
            const nextA = a + delta;
            if (nextA >= 1 && (nextA + c) <= 9) {
                a = nextA;
                if (i > a) i = a; // Infants cannot exceed accompanying adults
            }
        } else if (type === 'children') {
            const nextC = c + delta;
            if (nextC >= 0 && (a + nextC) <= 9) {
                c = nextC;
            }
        } else if (type === 'infants') {
            const nextI = i + delta;
            if (nextI >= 0 && nextI <= a) {
                i = nextI;
            }
        }

        adultInput.value = a;
        childInput.value = c;
        infantInput.value = i;

        const adultDisplay = document.getElementById('adultCountDisplay');
        const childDisplay = document.getElementById('childCountDisplay');
        const infantDisplay = document.getElementById('infantCountDisplay');
        if (adultDisplay) adultDisplay.textContent = a;
        if (childDisplay) childDisplay.textContent = c;
        if (infantDisplay) infantDisplay.textContent = i;

        // Stepper buttons disabled state
        const adultMinus = document.getElementById('adultMinusBtn');
        const childMinus = document.getElementById('childMinusBtn');
        const infantMinus = document.getElementById('infantMinusBtn');
        const adultPlus = document.getElementById('adultPlusBtn');
        const childPlus = document.getElementById('childPlusBtn');
        const infantPlus = document.getElementById('infantPlusBtn');

        if (adultMinus) adultMinus.disabled = (a <= 1);
        if (childMinus) childMinus.disabled = (c <= 0);
        if (infantMinus) infantMinus.disabled = (i <= 0);

        const totalSeated = a + c;
        if (adultPlus) adultPlus.disabled = (totalSeated >= 9);
        if (childPlus) childPlus.disabled = (totalSeated >= 9);
        if (infantPlus) infantPlus.disabled = (i >= a);

        const total = a + c + i;
        const summaryText = document.getElementById('passengerSummaryText');
        const subtext = document.getElementById('passengerSubtext');

        if (summaryText) {
            summaryText.textContent = total + (total === 1 ? ' Traveller' : ' Travellers');
        }
        if (subtext) {
            let parts = [a + (a === 1 ? ' Adult' : ' Adults')];
            if (c > 0) parts.push(c + (c === 1 ? ' Child' : ' Children'));
            if (i > 0) parts.push(i + (i === 1 ? ' Infant' : ' Infants'));
            subtext.textContent = parts.join(', ');
        }
    }

    function closePassengerDropdown() {
        const dropdownBtn = document.getElementById('passengerDropdownBtn');
        const dropdownInstance = bootstrap.Dropdown.getInstance(dropdownBtn);
        if (dropdownInstance) dropdownInstance.hide();
    }

    function selectCabinClass(className, subtext) {
        const input = document.getElementById('travelClassInput');
        const display = document.getElementById('travelClassDisplayText');
        const sub = document.getElementById('travelClassSubtext');
        if (input) input.value = className;
        if (display) display.textContent = className;

        let displaySub = subtext;
        if (!displaySub) {
            if (className === 'Premium Economy') displaySub = 'Extra space & added comfort';
            else if (className === 'Business') displaySub = 'More space & premium services';
            else if (className === 'First Class') displaySub = 'Premium cabin experience';
            else displaySub = 'Standard seating & value fares';
        }
        if (sub) sub.textContent = displaySub;

        const items = document.querySelectorAll('#travelClassMenuList .cabin-option-item');
        items.forEach(item => {
            const val = item.getAttribute('data-value');
            const check = item.querySelector('.cabin-check-icon');
            const li = item.closest('li');
            if (val === className) {
                item.classList.add('active');
                if (check) check.classList.remove('d-none');
                if (li) li.setAttribute('aria-selected', 'true');
            } else {
                item.classList.remove('active');
                if (check) check.classList.add('d-none');
                if (li) li.setAttribute('aria-selected', 'false');
            }
        });

        const btn = document.getElementById('travelClassDropdownBtn');
        if (btn && window.bootstrap && bootstrap.Dropdown) {
            const instance = bootstrap.Dropdown.getInstance(btn) || new bootstrap.Dropdown(btn);
            if (instance) instance.hide();
            btn.focus();
        }
    }

    // Keyboard navigation support for cabin class options
    document.addEventListener('keydown', function(e) {
        const menu = document.getElementById('travelClassMenuList');
        if (!menu || !menu.classList.contains('show')) return;

        const options = Array.from(menu.querySelectorAll('.cabin-option-item'));
        const currentIndex = options.indexOf(document.activeElement);

        if (e.key === 'ArrowDown') {
            e.preventDefault();
            const nextIndex = (currentIndex + 1) % options.length;
            options[nextIndex].focus();
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            const prevIndex = (currentIndex - 1 + options.length) % options.length;
            options[prevIndex].focus();
        } else if (e.key === 'Escape') {
            const btn = document.getElementById('travelClassDropdownBtn');
            if (btn && window.bootstrap && bootstrap.Dropdown) {
                const instance = bootstrap.Dropdown.getInstance(btn);
                if (instance) instance.hide();
                btn.focus();
            }
        }
    });

    // Form submission validation (Strict Order of Verification)
    document.getElementById('flightSearchForm').addEventListener('submit', function (e) {
        const alertBox = document.getElementById('clientValidationAlert');
        const alertText = document.getElementById('clientValidationText');
        if (alertBox) alertBox.classList.add('d-none');

        const src = document.getElementById('sourceCodeInput').value;
        const dst = document.getElementById('destCodeInput').value;
        const dep = document.getElementById('departureDateInput').value;
        const tripType = document.getElementById('tripTypeInput').value;
        const ret = document.getElementById('returnDateInput').value;
        const todayIso = SERVER_TODAY_ISO;

        function showError(msg) {
            if (alertText && alertBox) {
                alertText.textContent = msg;
                alertBox.classList.remove('d-none');
                alertBox.classList.add('d-flex');
            }
            if (window.showToast) {
                window.showToast(msg, "warning", "Validation Notice");
            }
            // Restore normal submit button state - DO NOT leave stuck in loading
            const submitBtn = document.getElementById('btnSearchSubmit');
            if (submitBtn) {
                submitBtn.disabled = false;
                submitBtn.classList.remove('disabled');
            }
            const submitText = document.getElementById('btnSearchText');
            if (submitText) {
                submitText.innerHTML = '<i class="bi bi-search me-2"></i> SEARCH FLIGHTS';
            }
            if (alertBox) {
                window.scrollTo({ top: alertBox.offsetTop - 80, behavior: 'smooth' });
            }
            e.preventDefault();
            return false;
        }

        if (tripType === 'multi-city') {
            if (multiCitySegments.length < 2) {
                return showError('Multi-City travel requires at least 2 flight segments.');
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
                    return showError('Flight ' + segNum + ': Departure and Arrival airports are required.');
                }
                if (srcVal.toUpperCase() === dstVal.toUpperCase()) {
                    return showError('Flight ' + segNum + ': Departure and Arrival airports cannot be the same.');
                }
                if (!dateVal) {
                    return showError('Flight ' + segNum + ': Flight date is required.');
                }
                if (dateVal < todayIso) {
                    return showError('Flight ' + segNum + ': Please select today or a future date.');
                }
                if (i > 0) {
                    const prevDateEl = document.getElementById('segDate_' + i);
                    if (prevDateEl && dateVal < prevDateEl.value) {
                        return showError('Flight ' + segNum + ' date must be on or after Flight ' + i + ' date.');
                    }
                }
            }
        } else {
            if (!src) {
                return showError('Please select a departure airport.');
            }

            if (!dst) {
                return showError('Please select an arrival airport.');
            }

            if (src.toUpperCase() === dst.toUpperCase()) {
                return showError('Departure and arrival airports cannot be the same.');
            }

            if (!dep) {
                return showError('Please select a departure date.');
            }

            if (dep < todayIso) {
                return showError('Please select today or a future date.');
            }

            if (tripType === 'round-trip') {
                if (!ret) {
                    return showError('Please select a return date for round trip.');
                }
                if (ret < dep) {
                    return showError('Return date must be on or after the departure date.');
                }
            }
        }

        // ALL VALIDATIONS PASSED -> ONLY NOW start loading state
        const submitBtn = document.getElementById('btnSearchSubmit');
        if (submitBtn) {
            submitBtn.disabled = true;
            submitBtn.classList.add('disabled');
        }
        const btnText = document.getElementById('btnSearchText');
        if (btnText) {
            btnText.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Searching Flights...';
        }
    });

    // Restore search button state on bfcache/pageshow
    window.addEventListener('pageshow', function() {
        const submitBtn = document.getElementById('btnSearchSubmit');
        const btnText = document.getElementById('btnSearchText');
        if (submitBtn) {
            submitBtn.disabled = false;
            submitBtn.classList.remove('disabled');
        }
        if (btnText) {
            btnText.innerHTML = '<i class="bi bi-search me-2"></i> Search Flights';
        }
    });

    // Run dynamic date & prefill initialization on page load
    document.addEventListener('DOMContentLoaded', function () {
        if (window.SkyTechCalendar) {
            SkyTechCalendar.init({ todayIso: SERVER_TODAY_ISO });
        }
        const depInput = document.getElementById('departureDateInput');
        if (depInput && !depInput.value) {
            depInput.value = SERVER_TODAY_ISO;
        }

        // If tripType is round-trip, ensure return container is displayed and active
        const currentTripType = document.getElementById('tripTypeInput')?.value;
        if (currentTripType === 'round-trip') {
            const retContainer = document.getElementById('returnDateContainer');
            if (retContainer) retContainer.classList.remove('d-none');
            const retInput = document.getElementById('returnDateInput');
            if (retInput) {
                retInput.disabled = false;
                retInput.setAttribute('name', 'returnDate');
            }
        }

        // Sync airport names & subtexts from AIRPORTS_DATA if codes exist
        const srcCode = document.getElementById('sourceCodeInput')?.value;
        if (srcCode) {
            const apt = AIRPORTS_DATA.find(a => a.code === srcCode);
            if (apt) {
                const disp = document.getElementById('fromAirportDisplay');
                const sub = document.getElementById('fromSubtext');
                if (disp && (!disp.value || disp.value === srcCode)) disp.value = apt.city + ' (' + apt.code + ')';
                if (sub) sub.textContent = apt.city + ' \u2022 ' + apt.name;
            }
        }
        const dstCode = document.getElementById('destCodeInput')?.value;
        if (dstCode) {
            const apt = AIRPORTS_DATA.find(a => a.code === dstCode);
            if (apt) {
                const disp = document.getElementById('toAirportDisplay');
                const sub = document.getElementById('toSubtext');
                if (disp && (!disp.value || disp.value === dstCode)) disp.value = apt.city + ' (' + apt.code + ')';
                if (sub) sub.textContent = apt.city + ' \u2022 ' + apt.name;
            }
        }

        // Sync passenger summary text & subtext
        const aVal = parseInt(document.getElementById('adultsInput')?.value || '1', 10);
        const cVal = parseInt(document.getElementById('childrenInput')?.value || '0', 10);
        const iVal = parseInt(document.getElementById('infantsInput')?.value || '0', 10);
        const totalPass = aVal + cVal + iVal;
        const pSummary = document.getElementById('passengerSummaryText');
        const pSub = document.getElementById('passengerSubtext');
        if (pSummary) {
            pSummary.textContent = totalPass + (totalPass === 1 ? ' Traveller' : ' Travellers');
        }
        if (pSub) {
            let parts = [aVal + (aVal === 1 ? ' Adult' : ' Adults')];
            if (cVal > 0) parts.push(cVal + (cVal === 1 ? ' Child' : ' Children'));
            if (iVal > 0) parts.push(iVal + (iVal === 1 ? ' Infant' : ' Infants'));
            pSub.textContent = parts.join(', ');
        }
    });
</script>

<jsp:include page="../common/footer.jsp" />
