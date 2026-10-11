<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="common/header.jsp" />
<jsp:include page="common/navbar.jsp" />

<main>
    <!-- 1. Hero & Flight Search Engine -->
    <section class="home-hero-section py-5 text-white" id="heroSearchSection">
        <!-- High-Resolution Real Aviation Photography Background -->
        <div class="home-hero-bg" aria-hidden="true">
            <img src="${pageContext.request.contextPath}/assets/images/hero-aviation.jpg"
                 alt=""
                 class="home-hero-bg-img"
                 loading="eager" />
            <div class="home-hero-overlay"></div>
        </div>

        <div class="container py-3 hero-content-container">
            <div class="text-center mb-4">
                <span class="hero-premium-badge">
                    <i class="bi bi-airplane-engines me-1 badge-icon"></i>
                    <span>SKYTECH</span>
                    <span class="badge-divider">|</span>
                    <span>PREMIUM AIR TRAVEL</span>
                </span>
                <h1 class="display-4 fw-bold mb-2">Travel smarter with SkyTech</h1>
                <p class="lead text-white-75 mb-0">Search. Compare. Fly.</p>
            </div>

            <!-- Integrated Flight Search Widget -->
            <div class="search-container-card text-dark mx-auto shadow-lg" style="max-width: 1100px;">
                <!-- Server-Side Validation Errors If Present -->
                <c:if test="${not empty validationErrors}">
                    <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                        <div class="d-flex align-items-center gap-2 mb-1">
                            <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                            <h6 class="alert-heading fw-bold mb-0">Please check your search criteria:</h6>
                        </div>
                        <ul class="mb-0 ps-3 small">
                            <c:forEach var="err" items="${validationErrors}">
                                <li><c:out value="${err}" /></li>
                            </c:forEach>
                        </ul>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <!-- Client-Side Validation Alert Placeholder -->
                <div id="homeValidationAlert" class="alert alert-danger d-none align-items-center gap-2 mb-4" role="alert">
                    <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                    <span id="homeValidationText"></span>
                </div>

                <form action="${pageContext.request.contextPath}/search-flights" method="GET" id="homeSearchForm" novalidate onsubmit="return validateHomeSearchForm(event)">
                    <!-- Trip Type Switcher -->
                    <div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-4">
                        <div class="d-flex flex-wrap align-items-center gap-2">
                            <button type="button" class="trip-type-btn active" id="btnOneWay" onclick="setTripType('one-way')">
                                <i class="bi bi-arrow-right me-1"></i> One Way
                            </button>
                            <button type="button" class="trip-type-btn" id="btnRoundTrip" onclick="setTripType('round-trip')">
                                <i class="bi bi-arrow-left-right me-1"></i> Round Trip
                            </button>
                            <button type="button" class="trip-type-btn" id="btnMultiCity" onclick="setTripType('multi-city')">
                                <i class="bi bi-signpost-split me-1"></i> Multi City
                            </button>
                            <input type="hidden" name="tripType" id="tripTypeInput" value="one-way">
                        </div>

                        <!-- Live Status Indicator -->
                        <div class="d-none d-md-flex align-items-center gap-2 text-muted small">
                            <i class="bi bi-airplane-engines text-primary"></i>
                            <span>Search available flights</span>
                        </div>
                    </div>

                    <!-- Standard One-Way & Round-Trip Container -->
                    <div id="standardRouteContainer">
                        <div class="booking-form-grid-row-1" id="standardRouteRow">
                            <!-- FROM (Origin) -->
                            <div id="fromCol">
                                <div class="search-field-box position-relative" id="fromBoxContainer">
                                    <label class="field-label" for="fromAirportDisplay">
                                        <i class="bi bi-geo-alt-fill text-primary"></i> FROM
                                    </label>
                                    <input type="text" class="field-input fw-bold" id="fromAirportDisplay"
                                           placeholder="City or Airport (e.g. JAI, Delhi)"
                                           value="Jaipur (JAI)"
                                           autocomplete="off" required onfocus="openAirportDropdown('from')" oninput="onAirportSearchInput('from')">
                                    <small class="field-subtext text-muted text-truncate d-block" id="fromSubtext">
                                        Jaipur &bull; Jaipur International Airport
                                    </small>
                                    <input type="hidden" name="source" id="sourceCodeInput" value="JAI">

                                    <!-- Autocomplete Dropdown List -->
                                    <div class="airport-autocomplete-list shadow-lg d-none" id="fromAirportList">
                                        <div class="p-2 border-bottom bg-light">
                                            <small class="fw-bold text-muted text-uppercase">Select Departure Airport</small>
                                        </div>
                                        <div class="autocomplete-items" id="fromAirportItems"></div>
                                    </div>
                                </div>
                            </div>

                            <!-- Circular Swap Button -->
                            <div class="swap-grid-col text-center d-flex justify-content-center" id="swapCol">
                                <button type="button" class="btn-swap-airports" id="btnSwapAirports" title="Swap origin and destination" onclick="swapAirports()" aria-label="Swap origin and destination airports">
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
                                           placeholder="City or Airport (e.g. DEL, Mumbai)"
                                           value="Delhi (DEL)"
                                           autocomplete="off" required onfocus="openAirportDropdown('to')" oninput="onAirportSearchInput('to')">
                                    <small class="field-subtext text-muted text-truncate d-block" id="toSubtext">
                                        Delhi &bull; Indira Gandhi International Airport
                                    </small>
                                    <input type="hidden" name="destination" id="destCodeInput" value="DEL">

                                    <!-- Autocomplete Dropdown List -->
                                    <div class="airport-autocomplete-list shadow-lg d-none" id="toAirportList">
                                        <div class="p-2 border-bottom bg-light">
                                            <small class="fw-bold text-muted text-uppercase">Select Arrival Airport</small>
                                        </div>
                                        <div class="autocomplete-items" id="toAirportItems"></div>
                                    </div>
                                </div>
                            </div>

                            <!-- DEPARTURE DATE -->
                            <div class="dep-grid-col" id="depCol">
                                <div class="search-field-box date-picker-box position-relative" id="depFieldBox"
                                     onclick="openHomepageCalendar('departure')" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();openHomepageCalendar('departure');}"
                                     role="button" tabindex="0" aria-label="Departure Date Picker">
                                    <label class="field-label" style="pointer-events: none;">
                                        <i class="bi bi-calendar-event text-primary"></i> DEPARTURE
                                    </label>
                                    <div class="d-flex align-items-center justify-content-between" id="departureDateDisplay" style="pointer-events: none;">
                                        <div class="text-truncate">
                                            <span class="field-input-text fw-bold text-dark d-block text-truncate" id="departureDatePrimary">
                                                <c:choose>
                                                    <c:when test="${not empty todayFormatted}">${todayFormatted}</c:when>
                                                    <c:otherwise>Select Date</c:otherwise>
                                                </c:choose>
                                            </span>
                                            <small class="field-subtext text-muted text-truncate d-block" id="departureDaySubtext">
                                                <c:if test="${not empty todayDayOfWeek}">&bull; ${todayDayOfWeek}</c:if>
                                            </small>
                                        </div>
                                        <i class="bi bi-calendar3 text-primary fs-5 ms-2 flex-shrink-0" aria-hidden="true"></i>
                                    </div>
                                    <input type="hidden" id="departureDateInput" name="departureDate"
                                           value="${not empty todayDate ? todayDate : minDate}">
                                </div>
                            </div>

                            <!-- RETURN DATE (Hidden by default in One Way) -->
                            <div class="return-grid-col d-none" id="returnDateContainer">
                                <div class="search-field-box date-picker-box position-relative" id="returnFieldBox"
                                     onclick="openHomepageCalendar('return')" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();openHomepageCalendar('return');}"
                                     role="button" tabindex="0" aria-label="Return Date Picker">
                                    <label class="field-label" style="pointer-events: none;">
                                        <i class="bi bi-calendar2-check text-primary" id="returnIcon"></i> RETURN
                                    </label>
                                    <div class="d-flex align-items-center justify-content-between" id="returnDateDisplay" style="pointer-events: none;">
                                        <div class="text-truncate">
                                            <span class="field-input-text fw-bold text-dark d-block text-truncate" id="returnDatePrimary">Select Return</span>
                                            <small class="field-subtext text-muted text-truncate d-block" id="returnDaySubtext"></small>
                                        </div>
                                        <i class="bi bi-calendar3 text-primary fs-5 ms-2 flex-shrink-0" aria-hidden="true"></i>
                                    </div>
                                    <input type="hidden" id="returnDateInput" name="returnDate" value="" disabled>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Multi-City Builder Container -->
                    <div id="multiCityContainer" class="d-none">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <span class="small text-muted fw-bold text-uppercase">
                                <i class="bi bi-signpost-2 me-1 text-primary"></i> Multi-City Flight Itinerary (Up to 5 Segments)
                            </span>
                            <small class="text-muted">Dates must be consecutive</small>
                        </div>

                        <!-- Segment Rows Container -->
                        <div id="multiCitySegmentsWrapper">
                            <!-- Populated dynamically via JavaScript with minimum 2 segments -->
                        </div>

                        <div class="d-flex align-items-center gap-2 mb-3">
                            <button type="button" class="btn btn-outline-primary btn-sm rounded-pill px-3" id="btnAddSegmentBtn" onclick="addMultiCitySegment()">
                                <i class="bi bi-plus-circle me-1"></i> Add Another Flight
                            </button>
                            <small class="text-muted" id="segmentCountNotice">Maximum 5 flight segments</small>
                        </div>
                        <input type="hidden" name="segmentCount" id="segmentCountInput" value="2">
                    </div>

                    <!-- Row 2: Passengers, Cabin & Search CTA -->
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
                                        <span id="passengerSummaryText" class="field-input-text fw-bold text-dark d-block text-truncate">1 Traveller</span>
                                        <small id="passengerSubtext" class="field-subtext text-muted text-truncate d-block">1 Adult</small>
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
                                            <button type="button" class="counter-btn" id="adultMinusBtn" onclick="updatePassenger('adults', -1)" disabled aria-label="Decrease adult passengers">&minus;</button>
                                            <span id="adultCountDisplay" class="fw-bold px-2">1</span>
                                            <button type="button" class="counter-btn" id="adultPlusBtn" onclick="updatePassenger('adults', 1)" aria-label="Increase adult passengers">&#43;</button>
                                        </div>
                                    </div>

                                    <!-- Children -->
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <div>
                                            <div class="fw-bold">Children</div>
                                            <small class="text-muted">2&ndash;11 years</small>
                                        </div>
                                        <div class="d-flex align-items-center gap-2">
                                            <button type="button" class="counter-btn" id="childMinusBtn" onclick="updatePassenger('children', -1)" disabled aria-label="Decrease child passengers">&minus;</button>
                                            <span id="childCountDisplay" class="fw-bold px-2">0</span>
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
                                            <button type="button" class="counter-btn" id="infantMinusBtn" onclick="updatePassenger('infants', -1)" disabled aria-label="Decrease infant passengers">&minus;</button>
                                            <span id="infantCountDisplay" class="fw-bold px-2">0</span>
                                            <button type="button" class="counter-btn" id="infantPlusBtn" onclick="updatePassenger('infants', 1)" aria-label="Increase infant passengers">&#43;</button>
                                        </div>
                                    </div>

                                    <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                                        <small class="text-muted">Max 9 travellers</small>
                                        <button type="button" class="btn btn-primary btn-sm rounded-pill px-3" onclick="closePassengerDropdown()">Done</button>
                                    </div>
                                </div>

                                <input type="hidden" name="adults" id="adultsInput" value="1">
                                <input type="hidden" name="children" id="childrenInput" value="0">
                                <input type="hidden" name="infants" id="infantsInput" value="0">
                            </div>
                        </div>

                        <!-- Cabin Class Selector -->
                        <div id="cabinCol">
                            <div class="search-field-box dropdown position-relative" id="homeCabinClassBoxContainer">
                                <label id="homeTravelClassDropdownLabel" class="field-label">
                                    <i class="bi bi-award-fill text-primary"></i> CABIN CLASS
                                </label>
                                <button type="button" 
                                        class="field-select-trigger btn p-0 text-start w-100 d-flex justify-content-between align-items-center cabin-class-btn"
                                        id="travelClassDropdownBtn" 
                                        data-bs-toggle="dropdown" 
                                        data-bs-display="static"
                                        aria-expanded="false" 
                                        aria-haspopup="listbox" 
                                        aria-labelledby="homeTravelClassDropdownLabel travelClassDropdownBtn">
                                    <div class="text-truncate">
                                        <span id="travelClassDisplayText" class="field-input-text fw-bold text-dark d-block text-truncate">Economy</span>
                                        <small id="travelClassSubtext" class="field-subtext text-muted text-truncate d-block">Standard seating &amp; value fares</small>
                                    </div>
                                    <i class="bi bi-chevron-down text-muted small ms-2 field-chevron flex-shrink-0"></i>
                                </button>

                                <ul class="dropdown-menu cabin-class-dropdown-menu shadow-lg p-2" 
                                    id="travelClassMenuList"
                                    aria-labelledby="travelClassDropdownBtn"
                                    role="listbox">
                                    <li role="option" aria-selected="true">
                                        <button type="button" class="dropdown-item cabin-option-item rounded-2 py-2 px-3 d-flex align-items-center justify-content-between active" 
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
                                            <i class="bi bi-check-lg text-primary fw-bold cabin-check-icon"></i>
                                        </button>
                                    </li>
                                    <li role="option" aria-selected="false">
                                        <button type="button" class="dropdown-item cabin-option-item rounded-2 py-2 px-3 d-flex align-items-center justify-content-between" 
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
                                            <i class="bi bi-check-lg text-primary fw-bold cabin-check-icon d-none"></i>
                                        </button>
                                    </li>
                                    <li role="option" aria-selected="false">
                                        <button type="button" class="dropdown-item cabin-option-item rounded-2 py-2 px-3 d-flex align-items-center justify-content-between" 
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
                                            <i class="bi bi-check-lg text-primary fw-bold cabin-check-icon d-none"></i>
                                        </button>
                                    </li>
                                    <li role="option" aria-selected="false">
                                        <button type="button" class="dropdown-item cabin-option-item rounded-2 py-2 px-3 d-flex align-items-center justify-content-between" 
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
                                            <i class="bi bi-check-lg text-primary fw-bold cabin-check-icon d-none"></i>
                                        </button>
                                    </li>
                                </ul>

                                <!-- Hidden form input ensuring correct parameter submission -->
                                <input type="hidden" name="travelClass" id="travelClassInput" value="Economy">
                            </div>
                        </div>

                        <!-- Search Flights CTA Button -->
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
            </div>
        </div>
    </section>

    <!-- 2. Popular Destinations & Deals -->
    <section class="py-5 bg-white fade-in-on-scroll" id="popularRoutesSection" style="position: relative; z-index: 1;">
        <div class="container py-2">
            <div class="d-flex flex-wrap justify-content-between align-items-end mb-4">
                <div>
                    <span class="badge bg-primary-subtle text-primary fw-bold text-uppercase px-3 py-1 mb-2 rounded-pill">
                        Featured Routes
                    </span>
                    <h2 class="fw-bold mb-1">Popular Destinations</h2>
                    <p class="text-muted small mb-0">Explore popular routes and discover your next destination.</p>
                </div>
                <a href="${pageContext.request.contextPath}/search-flights" class="btn btn-outline-primary btn-sm rounded-pill px-3">
                    View All Schedules &rarr;
                </a>
            </div>

            <div class="destinations-grid">
                <c:choose>
                    <c:when test="${not empty popularDeals}">
                        <c:forEach items="${popularDeals}" var="deal">
                            <div class="destination-deal-card" onclick="window.location.href='${pageContext.request.contextPath}/search-flights?tripType=one-way&source=${deal.sourceCode}&destination=${deal.destinationCode}&departureDate=${deal.searchDate}&adults=1&travelClass=Economy'">
                                <div class="destination-img-wrapper">
                                    <img src="${pageContext.request.contextPath}/${deal.imageUrl}" 
                                         alt="${deal.imageAlt}" class="destination-img" loading="lazy"
                                         onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/destinations/default.jpg';">
                                    <c:choose>
                                        <c:when test="${deal.dailyShuffle}">
                                            <span class="destination-badge-tag badge-daily-shuffle"><i class="bi bi-shuffle me-1"></i>Daily Shuffle</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="destination-badge-tag"><i class="bi bi-airplane-fill text-skytech-accent me-1"></i>${deal.tag}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="p-4 d-flex flex-column flex-grow-1">
                                    <span class="text-uppercase small fw-bold text-muted mb-1" style="font-size: 0.75rem; letter-spacing: 0.05em;">${deal.sourceCode} &bull; ${deal.destinationCode}</span>
                                    <h5 class="fw-bold text-dark mb-1">${deal.sourceCity} &rarr; ${deal.destinationCity}</h5>
                                    <p class="text-muted small mb-3 text-truncate">${deal.airlineSummary}</p>
                                    
                                    <div class="mt-auto border-top pt-3">
                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <div>
                                                <c:choose>
                                                    <c:when test="${not empty deal.formattedPrice}">
                                                        <span class="text-muted d-block" style="font-size: 0.75rem;">From</span>
                                                        <span class="fs-4 fw-bold text-primary">&#8377;${deal.formattedPrice}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted d-block" style="font-size: 0.75rem;">Fares</span>
                                                        <span class="small text-muted fw-semibold">Check availability</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="text-end">
                                                <span class="text-muted d-block" style="font-size: 0.75rem;">Duration</span>
                                                <span class="badge bg-light text-secondary border">${deal.durationFormatted} &bull; ${deal.stopsDescription}</span>
                                            </div>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/search-flights?tripType=one-way&source=${deal.sourceCode}&destination=${deal.destinationCode}&departureDate=${deal.searchDate}&adults=1&travelClass=Economy" 
                                           class="btn btn-primary w-100 rounded-pill py-2 fw-semibold text-decoration-none">
                                            Explore Flights &rarr;
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="col-12 py-5 text-center text-muted">
                            <i class="bi bi-airplane fs-1 d-block mb-3 text-secondary"></i>
                            <p class="fw-semibold">No flight deals currently available.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </section>

    <!-- 3. Why Fly with SkyTech -->
    <section class="py-5 fade-in-on-scroll" style="background-color: var(--skytech-light-bg, #F5F8FC);" id="whySkyTechSection">
        <div class="container py-2">
            <div class="text-center mb-5">
                <span class="badge bg-primary-subtle text-primary fw-bold text-uppercase px-3 py-1 mb-2 rounded-pill">
                    Aviation Excellence
                </span>
                <h2 class="fw-bold mb-2">Why Fly with SkyTech</h2>
                <p class="text-muted mb-0 mx-auto" style="max-width: 620px;">An airline reservation engine designed for speed, transparent fares, and intuitive seating</p>
            </div>

            <div class="skytech-cards-grid">
                <div class="skytech-feature-card">
                    <div class="skytech-card-icon" style="background: #E0F2FE; color: #0284C7;">
                        <i class="bi bi-speedometer2"></i>
                    </div>
                    <h5 class="skytech-card-heading">Fast Flight Search</h5>
                    <p class="skytech-card-desc">High-speed schedule querying comparing multi-carrier inventory and flight route timings.</p>
                </div>

                <div class="skytech-feature-card">
                    <div class="skytech-card-icon" style="background: #DCFCE7; color: #16A34A;">
                        <i class="bi bi-tag-fill"></i>
                    </div>
                    <h5 class="skytech-card-heading">Transparent Fares</h5>
                    <p class="skytech-card-desc">Clear itemized breakdown of base fares, GST, and airport fees with zero hidden charges before booking.</p>
                </div>

                <div class="skytech-feature-card">
                    <div class="skytech-card-icon" style="background: #E0F2FE; color: #0284C7;">
                        <i class="bi bi-grid-3x3"></i>
                    </div>
                    <h5 class="skytech-card-heading">Smart Seat Selection</h5>
                    <p class="skytech-card-desc">Interactive aircraft cabin map with real-time seat availability, extra legroom, and window choices.</p>
                </div>

                <div class="skytech-feature-card">
                    <div class="skytech-card-icon" style="background: #FEF3C7; color: #D97706;">
                        <i class="bi bi-signpost-split-fill"></i>
                    </div>
                    <h5 class="skytech-card-heading">Flexible Travel</h5>
                    <p class="skytech-card-desc">Seamless support for One Way, Round Trip, and dynamic Multi-City multi-segment flight planning.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- 4. Travel Experience -->
    <section class="py-5 bg-white fade-in-on-scroll" id="travelExperienceSection">
        <div class="container py-2">
            <div class="text-center mb-5">
                <span class="badge bg-info-subtle text-info-emphasis fw-bold text-uppercase px-3 py-1 mb-2 rounded-pill">
                    How It Works
                </span>
                <h2 class="fw-bold">Your Journey, Simplified</h2>
                <p class="text-muted">A clear, modern 4-step path from inspiration to confirmed flight seating</p>
            </div>

            <div class="row g-4 journey-timeline-wrapper">
                <!-- Step 1 -->
                <div class="col-lg-3 col-md-6">
                    <div class="journey-step-card h-100 text-center">
                        <div class="journey-step-num">01</div>
                        <h5 class="fw-bold mb-2">Search</h5>
                        <p class="text-muted small mb-0">Enter your origin, destination, travel dates, passenger counts, and preferred cabin class.</p>
                    </div>
                </div>

                <!-- Step 2 -->
                <div class="col-lg-3 col-md-6">
                    <div class="journey-step-card h-100 text-center">
                        <div class="journey-step-num">02</div>
                        <h5 class="fw-bold mb-2">Compare</h5>
                        <p class="text-muted small mb-0">Compare timings, stops, seat counts, and transparent airline prices with live filters.</p>
                    </div>
                </div>

                <!-- Step 3 -->
                <div class="col-lg-3 col-md-6">
                    <div class="journey-step-card h-100 text-center">
                        <div class="journey-step-num">03</div>
                        <h5 class="fw-bold mb-2">Choose</h5>
                        <p class="text-muted small mb-0">Review flight details, aircraft equipment, baggage limits, and pick your preferred aircraft seat.</p>
                    </div>
                </div>

                <!-- Step 4 -->
                <div class="col-lg-3 col-md-6">
                    <div class="journey-step-card h-100 text-center">
                        <div class="journey-step-num">04</div>
                        <h5 class="fw-bold mb-2">Continue</h5>
                        <p class="text-muted small mb-0">Move seamlessly toward passenger details and reservation confirmation.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 5. Travel Inspiration -->
    <section class="py-5 fade-in-on-scroll" style="background-color: var(--skytech-light-bg);" id="inspirationSection">
        <div class="container py-2">
            <div class="text-center mb-5">
                <span class="badge bg-primary text-white fw-bold text-uppercase px-3 py-1 mb-2 rounded-pill">
                    Get Inspired
                </span>
                <h2 class="fw-bold">Discover Your Next Destination</h2>
                <p class="text-muted">Unforgettable holiday destinations waiting for your next adventure</p>
            </div>

            <div class="row g-4">
                <!-- Inspiration 1: Jaipur -->
                <div class="col-lg-4 col-md-6">
                    <div class="inspiration-card" onclick="selectDestinationOnly('JAI', 'Jaipur')">
                        <img src="https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=700&q=80" alt="Jaipur Heritage" loading="lazy">
                        <div class="inspiration-overlay">
                            <span class="badge bg-warning text-dark fw-bold px-2 py-1 mb-2 align-self-start rounded-pill">Heritage &amp; Culture</span>
                            <h3 class="fw-bold mb-1">Jaipur</h3>
                            <p class="small text-white-75 mb-3">Royal palaces, ancient forts, vibrant bazaars, and legendary Rajasthani hospitality.</p>
                            <button type="button" class="btn btn-sm btn-light rounded-pill px-3 inspiration-btn align-self-start fw-semibold">
                                Explore Flights to Jaipur &rarr;
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Inspiration 2: Goa -->
                <div class="col-lg-4 col-md-6">
                    <div class="inspiration-card" onclick="selectDestinationOnly('GOI', 'Goa')">
                        <img src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=700&q=80" alt="Goa Beaches" loading="lazy">
                        <div class="inspiration-overlay">
                            <span class="badge bg-info text-white fw-bold px-2 py-1 mb-2 align-self-start rounded-pill">Beaches &amp; Escapes</span>
                            <h3 class="fw-bold mb-1">Goa</h3>
                            <p class="small text-white-75 mb-3">Golden sand shorelines, serene coastal sunsets, colonial architecture, and lively nightlife.</p>
                            <button type="button" class="btn btn-sm btn-light rounded-pill px-3 inspiration-btn align-self-start fw-semibold">
                                Explore Flights to Goa &rarr;
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Inspiration 3: Kerala -->
                <div class="col-lg-4 col-md-12">
                    <div class="inspiration-card" onclick="selectDestinationOnly('BLR', 'Bengaluru / South India')">
                        <img src="https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=700&q=80" alt="Kerala Nature" loading="lazy">
                        <div class="inspiration-overlay">
                            <span class="badge bg-success text-white fw-bold px-2 py-1 mb-2 align-self-start rounded-pill">Nature &amp; Backwaters</span>
                            <h3 class="fw-bold mb-1">Kerala</h3>
                            <p class="small text-white-75 mb-3">Peaceful houseboats, emerald backwaters, misty tea plantations, and ayurvedic sanctuaries.</p>
                            <button type="button" class="btn btn-sm btn-light rounded-pill px-3 inspiration-btn align-self-start fw-semibold">
                                Explore Southern Routes &rarr;
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 6. Travel Help & Quick Actions -->
    <section class="py-5 bg-white fade-in-on-scroll" id="helpSection">
        <div class="container py-2">
            <div class="text-center mb-5">
                <span class="badge bg-primary-subtle text-primary fw-bold text-uppercase px-3 py-1 mb-2 rounded-pill">
                    Passenger Care
                </span>
                <h2 class="fw-bold mb-2">How Can We Help?</h2>
                <p class="text-muted mb-0 mx-auto" style="max-width: 620px;">Quick access to essential flight planning and travel support services</p>
            </div>

            <div class="skytech-cards-grid">
                <a href="${pageContext.request.contextPath}/search-flights" class="help-action-card">
                    <div class="skytech-card-icon" style="background: #E0F2FE; color: #0284C7;">
                        <i class="bi bi-search"></i>
                    </div>
                    <h5 class="skytech-card-heading">Flight Search</h5>
                    <p class="skytech-card-desc">Search schedules and live fares across domestic routes and leading airlines.</p>
                </a>

                <a href="${pageContext.request.contextPath}/manage-booking" class="help-action-card">
                    <div class="skytech-card-icon" style="background: #F1F5F9; color: #475569;">
                        <i class="bi bi-journal-bookmark"></i>
                    </div>
                    <h5 class="skytech-card-heading">Manage Booking</h5>
                    <p class="skytech-card-desc">Retrieve confirmed itineraries, view passenger details, or review flight reservations.</p>
                </a>

                <a href="${pageContext.request.contextPath}/flight-status" class="help-action-card">
                    <div class="skytech-card-icon" style="background: #FEF3C7; color: #D97706;">
                        <i class="bi bi-clock-history"></i>
                    </div>
                    <h5 class="skytech-card-heading">Flight Status</h5>
                    <p class="skytech-card-desc">Check real-time departure, arrival, and terminal schedules for active flight numbers.</p>
                </a>

                <a href="${pageContext.request.contextPath}/travel-information" class="help-action-card">
                    <div class="skytech-card-icon" style="background: #E0F2FE; color: #0284C7;">
                        <i class="bi bi-briefcase"></i>
                    </div>
                    <h5 class="skytech-card-heading">Travel Guidelines</h5>
                    <p class="skytech-card-desc">Review cabin baggage rules, check-in limits, and mandatory airport identification policies.</p>
                </a>
            </div>
        </div>
    </section>





    <!-- Travel Guidelines Modal -->
    <div class="modal fade" id="guidelinesModal" tabindex="-1" aria-labelledby="guidelinesModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content shadow-lg border-0 rounded-4">
                <div class="modal-header border-bottom">
                    <h5 class="modal-title fw-bold" id="guidelinesModalLabel">
                        <i class="bi bi-briefcase-fill text-primary me-2"></i>Baggage &amp; Travel Guidelines
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <ul class="list-group list-group-flush small">
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-handbag me-2 text-primary"></i>Cabin Baggage</span>
                            <strong>1 Piece &bull; Up to 7 kg</strong>
                        </li>
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-box-seam me-2 text-primary"></i>Check-In Baggage</span>
                            <strong>15 kg per passenger (Economy)</strong>
                        </li>
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-person-badge me-2 text-primary"></i>Valid Government ID</span>
                            <strong>Aadhaar / Passport / Driving Licence</strong>
                        </li>
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-clock me-2 text-primary"></i>Airport Arrival</span>
                            <strong>Recommended 2 hours prior</strong>
                        </li>
                    </ul>
                </div>
                <div class="modal-footer border-top">
                    <button type="button" class="btn btn-primary btn-sm rounded-pill px-4" data-bs-dismiss="modal">Got it</button>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Page Scripts -->
<script>
    // Verified Airport Master Dataset
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

    // Multi-City state management
    let multiCitySegments = [
        { source: 'JAI', dest: 'DEL', date: '' },
        { source: 'DEL', dest: 'BOM', date: '' }
    ];

    // 1. Trip Type Switcher
    function setTripType(type) {
        document.getElementById('tripTypeInput').value = type;

        const btnOneWay = document.getElementById('btnOneWay');
        const btnRoundTrip = document.getElementById('btnRoundTrip');
        const btnMultiCity = document.getElementById('btnMultiCity');

        const stdContainer = document.getElementById('standardRouteContainer');
        const stdRow = document.getElementById('standardRouteRow');
        const mcContainer = document.getElementById('multiCityContainer');

        const retContainer = document.getElementById('returnDateContainer');
        const retInput = document.getElementById('returnDateInput');
        const retLabel = document.getElementById('returnDayLabel');
        const retIcon = document.getElementById('returnIcon');

        [btnOneWay, btnRoundTrip, btnMultiCity].forEach(b => { if (b) b.classList.remove('active'); });

        if (type === 'round-trip') {
            btnRoundTrip.classList.add('active');
            stdContainer.classList.remove('d-none');
            mcContainer.classList.add('d-none');
            if (stdRow) stdRow.classList.add('is-round-trip');

            // Show Return Date container
            retContainer.classList.remove('d-none');
            retInput.disabled = false;
            retInput.setAttribute('name', 'returnDate');
            retInput.required = true;
            if (retIcon) retIcon.classList.replace('text-muted', 'text-primary');

            const depDate = document.getElementById('departureDateInput').value || getClientTodayIso();
            if (depDate) {
                retInput.min = depDate;
                if (!retInput.value || retInput.value < depDate) {
                    const d = parseIsoParts(depDate) || new Date();
                    d.setDate(d.getDate() + 3);
                    const ry = d.getFullYear();
                    const rm = String(d.getMonth() + 1).padStart(2, '0');
                    const rd = String(d.getDate()).padStart(2, '0');
                    retInput.value = `${ry}-${rm}-${rd}`;
                }
                updateDateLabel(retInput.value, 'returnDatePrimary', 'returnDaySubtext');
            }
        } else if (type === 'multi-city') {
            btnMultiCity.classList.add('active');
            stdContainer.classList.add('d-none');
            mcContainer.classList.remove('d-none');
            if (stdRow) stdRow.classList.remove('is-round-trip');

            // Hide and disable Return Date
            retContainer.classList.add('d-none');
            retInput.disabled = true;
            retInput.removeAttribute('name');
            retInput.value = '';
            retInput.required = false;

            renderMultiCitySegments();
        } else {
            // One Way: completely hide return date field and remove name attribute
            btnOneWay.classList.add('active');
            stdContainer.classList.remove('d-none');
            mcContainer.classList.add('d-none');
            if (stdRow) stdRow.classList.remove('is-round-trip');

            retContainer.classList.add('d-none');
            retInput.disabled = true;
            retInput.removeAttribute('name');
            retInput.value = '';
            retInput.required = false;
            if (retLabel) retLabel.textContent = 'Select return date';
        }
    }

    // 2. Dynamic IST Date Handlers & SkyTech Calendar Popover
    const SERVER_TODAY_ISO = '${todayDate}' || getClientTodayIso();

    function getClientTodayIso() {
        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0');
        const dd = String(today.getDate()).padStart(2, '0');
        return `${yyyy}-${mm}-${dd}`;
    }

    function parseIsoParts(dateStr) {
        if (!dateStr) return null;
        const parts = dateStr.split('-');
        if (parts.length !== 3) return null;
        const y = parseInt(parts[0], 10);
        const m = parseInt(parts[1], 10);
        const d = parseInt(parts[2], 10);
        return new Date(y, m - 1, d);
    }

    function openHomepageCalendar(type) {
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
                    // Update return date constraints if return date is enabled
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

    function showHomeInlineError(msg) {
        const alertBox = document.getElementById('homeValidationAlert');
        const alertText = document.getElementById('homeValidationText');
        if (alertBox && alertText) {
            alertText.textContent = msg;
            alertBox.classList.remove('d-none');
        }
    }

    // 3. Airport Autocomplete Dropdowns
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
        const q = (filterText || '').toLowerCase().trim();

        const filtered = AIRPORTS_DATA.filter(a =>
            !q || a.code.toLowerCase().includes(q) || a.city.toLowerCase().includes(q) || a.name.toLowerCase().includes(q)
        );

        if (filtered.length === 0) {
            container.innerHTML = '<div class="p-3 text-muted text-center small">No matching airports found</div>';
            return;
        }

        filtered.forEach(airport => {
            const row = document.createElement('div');
            row.className = 'autocomplete-item p-2 d-flex justify-content-between align-items-center';
            row.style.cursor = 'pointer';
            row.innerHTML =
                '<div>' +
                    '<div class="fw-bold text-dark">' + airport.city + ' <span class="badge bg-secondary-subtle text-secondary">' + airport.code + '</span></div>' +
                    '<small class="text-muted d-block">' + airport.name + '</small>' +
                '</div>' +
                '<span class="badge bg-light text-muted small border">' + airport.terminal + '</span>';

            row.onclick = function() {
                selectAirport(target, airport);
            };
            container.appendChild(row);
        });
    }

    function selectAirport(target, airport) {
        if (target === 'from') {
            document.getElementById('fromAirportDisplay').value = airport.city + ' (' + airport.code + ')';
            document.getElementById('fromSubtext').textContent = airport.city + ' \u2022 ' + airport.name;
            document.getElementById('sourceCodeInput').value = airport.code;
            document.getElementById('fromAirportList').classList.add('d-none');
        } else {
            document.getElementById('toAirportDisplay').value = airport.city + ' (' + airport.code + ')';
            document.getElementById('toSubtext').textContent = airport.city + ' \u2022 ' + airport.name;
            document.getElementById('destCodeInput').value = airport.code;
            document.getElementById('toAirportList').classList.add('d-none');
        }
    }

    // Close autocomplete on click outside
    document.addEventListener('click', function(e) {
        const fromBox = document.getElementById('fromBoxContainer');
        const toBox = document.getElementById('toBoxContainer');

        if (fromBox && !fromBox.contains(e.target)) {
            const list = document.getElementById('fromAirportList');
            if (list) list.classList.add('d-none');
        }
        if (toBox && !toBox.contains(e.target)) {
            const list = document.getElementById('toAirportList');
            if (list) list.classList.add('d-none');
        }
    });

    // 4. Swap Airports Button
    function swapAirports() {
        const btn = document.getElementById('btnSwapAirports');
        if (btn) {
            btn.classList.add('rotating');
            setTimeout(() => btn.classList.remove('rotating'), 350);
        }

        const srcCode = document.getElementById('sourceCodeInput');
        const dstCode = document.getElementById('destCodeInput');
        const srcDisplay = document.getElementById('fromAirportDisplay');
        const dstDisplay = document.getElementById('toAirportDisplay');
        const srcSub = document.getElementById('fromSubtext');
        const dstSub = document.getElementById('toSubtext');

        if (srcCode && dstCode && srcDisplay && dstDisplay) {
            const tempCode = srcCode.value;
            const tempDisp = srcDisplay.value;
            const tempSub = srcSub ? srcSub.textContent : '';

            srcCode.value = dstCode.value;
            srcDisplay.value = dstDisplay.value;
            if (srcSub && dstSub) srcSub.textContent = dstSub.textContent;

            dstCode.value = tempCode;
            dstDisplay.value = tempDisp;
            if (dstSub) dstSub.textContent = tempSub;
        }
    }

    // 5. Multi-City Dynamic Builder
    function renderMultiCitySegments() {
        const wrapper = document.getElementById('multiCitySegmentsWrapper');
        wrapper.innerHTML = '';

        const todayIso = getClientTodayIso();
        let runningDate = todayIso;

        multiCitySegments.forEach((seg, idx) => {
            const num = idx + 1;
            if (!seg.date || seg.date < runningDate) {
                if (idx === 0) {
                    seg.date = todayIso;
                } else {
                    const d = parseIsoParts(runningDate) || new Date();
                    d.setDate(d.getDate() + 2);
                    const ry = d.getFullYear();
                    const rm = String(d.getMonth() + 1).padStart(2, '0');
                    const rd = String(d.getDate()).padStart(2, '0');
                    seg.date = `${ry}-${rm}-${rd}`;
                }
            }
            runningDate = seg.date;

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
                        '<input type="date" class="form-control form-select-sm fw-bold" name="segDate_' + num + '" id="segDate_' + num + '" value="' + seg.date + '" min="' + (idx === 0 ? todayIso : multiCitySegments[idx - 1].date) + '" onchange="onMultiCityDateChange(' + idx + ', this.value)">' +
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
                const d = parseIsoParts(last.date) || new Date();
                d.setDate(d.getDate() + 2);
                const ry = d.getFullYear();
                const rm = String(d.getMonth() + 1).padStart(2, '0');
                const rd = String(d.getDate()).padStart(2, '0');
                nextDate = `${ry}-${rm}-${rd}`;
            } else {
                nextDate = getClientTodayIso();
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
        const todayIso = getClientTodayIso();
        if (newDate < todayIso) {
            showHomeInlineError('Please select today or a future date.');
            newDate = todayIso;
            const curEl = document.getElementById('segDate_' + (index + 1));
            if (curEl) curEl.value = newDate;
        }
        multiCitySegments[index].date = newDate;
        // Adjust subsequent segment min dates and values if they occur earlier
        let runningDate = newDate;
        for (let i = index + 1; i < multiCitySegments.length; i++) {
            const dateEl = document.getElementById('segDate_' + (i + 1));
            if (dateEl) {
                dateEl.min = runningDate;
            }
            if (multiCitySegments[i].date && multiCitySegments[i].date < runningDate) {
                multiCitySegments[i].date = runningDate;
                if (dateEl) {
                    dateEl.value = runningDate;
                }
            }
            if (multiCitySegments[i].date) {
                runningDate = multiCitySegments[i].date;
            }
        }
    }

    // 6. Passenger Stepper Logic
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

        // Button disabled state
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

    function initCabinClassDropdown() {
        const box = document.getElementById('homeCabinClassBoxContainer');
        const btn = document.getElementById('travelClassDropdownBtn');
        const menu = document.getElementById('travelClassMenuList');
        if (!box || !btn || !menu) return;

        // Dynamic positioning detection on open to prevent bottom or right clipping
        btn.addEventListener('show.bs.dropdown', function () {
            const rect = box.getBoundingClientRect();
            const menuHeight = 255;
            const spaceBelow = window.innerHeight - rect.bottom;
            const spaceAbove = rect.top;

            // If space below is restricted, position upwards (dropup)
            if (spaceBelow < menuHeight && spaceAbove > spaceBelow) {
                box.classList.add('dropup');
            } else {
                box.classList.remove('dropup');
            }

            // Prevent right-edge overflow on smaller desktop/tablet viewports
            const spaceRight = window.innerWidth - rect.left;
            if (spaceRight < 330 && window.innerWidth >= 576) {
                menu.style.left = 'auto';
                menu.style.right = '0';
            } else {
                menu.style.left = '';
                menu.style.right = '';
            }
        });

        // Accessible keyboard navigation
        const options = Array.from(menu.querySelectorAll('.cabin-option-item'));
        btn.addEventListener('keydown', function(e) {
            if (e.key === 'ArrowDown' || e.key === 'Down') {
                e.preventDefault();
                const instance = bootstrap.Dropdown.getInstance(btn) || new bootstrap.Dropdown(btn);
                instance.show();
                const activeOption = menu.querySelector('.cabin-option-item.active') || options[0];
                if (activeOption) setTimeout(() => activeOption.focus(), 10);
            }
        });

        options.forEach((opt, idx) => {
            opt.addEventListener('keydown', function(e) {
                if (e.key === 'ArrowDown' || e.key === 'Down') {
                    e.preventDefault();
                    const next = options[(idx + 1) % options.length];
                    if (next) next.focus();
                } else if (e.key === 'ArrowUp' || e.key === 'Up') {
                    e.preventDefault();
                    const prev = options[(idx - 1 + options.length) % options.length];
                    if (prev) prev.focus();
                } else if (e.key === 'Escape' || e.key === 'Esc') {
                    e.preventDefault();
                    const instance = bootstrap.Dropdown.getInstance(btn);
                    if (instance) instance.hide();
                    btn.focus();
                } else if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    opt.click();
                }
            });
        });
    }

    // 7. Deal Card & Inspiration Quick Selection
    function selectDealRoute(src, dst, srcCity, dstCity) {
        setTripType('one-way');
        const srcApt = AIRPORTS_DATA.find(a => a.code === src);
        const dstApt = AIRPORTS_DATA.find(a => a.code === dst);

        if (srcApt) selectAirport('from', srcApt);
        if (dstApt) selectAirport('to', dstApt);

        // Smooth scroll up to search widget
        const searchCard = document.getElementById('heroSearchSection');
        if (searchCard) {
            window.scrollTo({ top: searchCard.offsetTop - 20, behavior: 'smooth' });
        }
    }

    function selectDestinationOnly(dst, dstName) {
        setTripType('one-way');
        const dstApt = AIRPORTS_DATA.find(a => a.code === dst);
        if (dstApt) selectAirport('to', dstApt);

        const searchCard = document.getElementById('heroSearchSection');
        if (searchCard) {
            window.scrollTo({ top: searchCard.offsetTop - 20, behavior: 'smooth' });
        }
    }

    function showTravelGuidelinesModal() {
        const modal = new bootstrap.Modal(document.getElementById('guidelinesModal'));
        modal.show();
    }

    // 8. Form Submission & Client-Side Validation (Strict Order of Verification)
    function validateHomeSearchForm(event) {
        const alertBox = document.getElementById('homeValidationAlert');
        const alertText = document.getElementById('homeValidationText');
        if (alertBox) alertBox.classList.add('d-none');

        const tripType = document.getElementById('tripTypeInput').value;

        function showError(msg) {
            if (alertText && alertBox) {
                alertText.textContent = msg;
                alertBox.classList.remove('d-none');
            }
            if (window.showToast) {
                window.showToast(msg, "warning", "Search Notice");
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
            return false;
        }

        if (tripType === 'multi-city') {
            if (multiCitySegments.length < 2) {
                return showError('Multi-City travel requires at least 2 flight segments.');
            }
            const todayIso = SERVER_TODAY_ISO;
            for (let i = 0; i < multiCitySegments.length; i++) {
                const segNum = i + 1;
                const srcVal = document.getElementById('segSrc_' + segNum).value;
                const dstVal = document.getElementById('segDst_' + segNum).value;
                const dateVal = document.getElementById('segDate_' + segNum).value;

                if (!srcVal || !dstVal) {
                    return showError('Flight ' + segNum + ': Departure and Arrival airports are required.');
                }
                if (srcVal === dstVal) {
                    return showError('Flight ' + segNum + ': Departure and Arrival airports cannot be the same.');
                }
                if (!dateVal) {
                    return showError('Flight ' + segNum + ': Flight date is required.');
                }
                if (dateVal < todayIso) {
                    return showError('Flight ' + segNum + ': Please select today or a future date.');
                }
                if (i > 0) {
                    const prevDate = document.getElementById('segDate_' + i).value;
                    if (dateVal < prevDate) {
                        return showError('Flight ' + segNum + ' date must be on or after Flight ' + i + ' date.');
                    }
                }
            }
        } else {
            const src = document.getElementById('sourceCodeInput').value;
            const dst = document.getElementById('destCodeInput').value;
            const dep = document.getElementById('departureDateInput').value;
            const ret = document.getElementById('returnDateInput').value;

            if (!src) return showError('Please choose a departure airport.');
            if (!dst) return showError('Please choose an arrival airport.');
            if (src.toUpperCase() === dst.toUpperCase()) {
                return showError('Departure and arrival airports cannot be the same.');
            }
            if (!dep) {
                return showError('Please select a departure date.');
            }

            const todayIso = SERVER_TODAY_ISO;
            if (dep < todayIso) {
                return showError('Please select today or a future date.');
            }

            if (tripType === 'round-trip') {
                if (!ret) return showError('Please select a return date for round trip.');
                if (ret < dep) return showError('Return date must be on or after the departure date.');
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
        return true;
    }

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

    // Initialize labels on load without auto-searching
    document.addEventListener('DOMContentLoaded', function() {
        if (window.SkyTechCalendar) {
            SkyTechCalendar.init({ todayIso: SERVER_TODAY_ISO });
        }
        initCabinClassDropdown();
        const depInput = document.getElementById('departureDateInput');
        if (depInput && !depInput.value) {
            depInput.value = SERVER_TODAY_ISO;
        }
    });
</script>

<jsp:include page="common/footer.jsp" />
