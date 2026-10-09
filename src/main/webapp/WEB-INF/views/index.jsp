<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="common/header.jsp" />
<jsp:include page="common/navbar.jsp" />

<main>
    <!-- =========================================================================
         1. HERO SECTION & INTEGRATED AIRLINE SEARCH ENGINE
         ========================================================================= -->
    <section class="home-hero-section py-5 text-white" id="heroSearchSection">
        <div class="container py-3">
            <div class="text-center mb-4">
                <span class="badge bg-light text-primary fw-bold text-uppercase px-3 py-2 mb-2 rounded-pill tracking-wide shadow-sm">
                    <i class="bi bi-airplane-engines me-1"></i> SkyTech &bull; Premier Booking Engine
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

                    <!-- ================= STANDARD ONE-WAY & ROUND-TRIP CONTAINER ================= -->
                    <div id="standardRouteContainer">
                        <div class="row g-3 align-items-center" id="standardRouteRow">
                            <!-- FROM (Origin) -->
                            <div class="col-lg-4 col-md-5" id="fromCol">
                                <div class="search-field-box position-relative" id="fromBoxContainer">
                                    <label class="field-label">
                                        <i class="bi bi-geo-alt-fill text-primary"></i> FROM
                                    </label>
                                    <input type="text" class="field-input fw-bold" id="fromAirportDisplay"
                                           placeholder="City or Airport (e.g. JAI, Delhi)"
                                           value="Jaipur (JAI)"
                                           autocomplete="off" required onfocus="openAirportDropdown('from')" oninput="onAirportSearchInput('from')">
                                    <small class="text-muted d-block text-truncate" id="fromSubtext">
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
                            <div class="col-lg-auto col-md-2 text-center d-flex justify-content-center" id="swapCol">
                                <button type="button" class="btn-swap-airports" id="btnSwapAirports" title="Swap origin and destination" onclick="swapAirports()">
                                    <i class="bi bi-arrow-left-right"></i>
                                </button>
                            </div>

                            <!-- TO (Destination) -->
                            <div class="col-lg-4 col-md-5" id="toCol">
                                <div class="search-field-box position-relative" id="toBoxContainer">
                                    <label class="field-label">
                                        <i class="bi bi-geo-fill text-danger"></i> TO
                                    </label>
                                    <input type="text" class="field-input fw-bold" id="toAirportDisplay"
                                           placeholder="City or Airport (e.g. DEL, Mumbai)"
                                           value="Delhi (DEL)"
                                           autocomplete="off" required onfocus="openAirportDropdown('to')" oninput="onAirportSearchInput('to')">
                                    <small class="text-muted d-block text-truncate" id="toSubtext">
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
                            <div class="col-lg-3 col-md-6" id="depCol">
                                <div class="search-field-box date-picker-box position-relative" id="depFieldBox"
                                     onclick="openHomepageCalendar('departure')" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();openHomepageCalendar('departure');}"
                                     role="button" tabindex="0" aria-label="Departure Date Picker">
                                    <label class="field-label mb-1" style="pointer-events: none;">
                                        <i class="bi bi-calendar-event text-primary"></i> DEPARTURE
                                    </label>
                                    <div class="date-custom-display d-flex align-items-center justify-content-between" id="departureDateDisplay">
                                        <div class="d-flex align-items-baseline gap-2">
                                            <span class="date-main-text" id="departureDatePrimary">
                                                <c:choose>
                                                    <c:when test="${not empty todayFormatted}">${todayFormatted}</c:when>
                                                    <c:otherwise>Select Date</c:otherwise>
                                                </c:choose>
                                            </span>
                                            <span class="date-sub-text" id="departureDaySubtext">
                                                <c:if test="${not empty todayDayOfWeek}">&bull; ${todayDayOfWeek}</c:if>
                                            </span>
                                        </div>
                                        <i class="bi bi-calendar3 text-primary fs-5" aria-hidden="true"></i>
                                    </div>
                                    <input type="hidden" id="departureDateInput" name="departureDate"
                                           value="${not empty todayDate ? todayDate : minDate}">
                                </div>
                            </div>

                            <!-- RETURN DATE (Hidden by default in One Way) -->
                            <div class="col-lg-2 col-md-6 d-none" id="returnDateContainer">
                                <div class="search-field-box date-picker-box position-relative" id="returnFieldBox"
                                     onclick="openHomepageCalendar('return')" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();openHomepageCalendar('return');}"
                                     role="button" tabindex="0" aria-label="Return Date Picker">
                                    <label class="field-label mb-1" style="pointer-events: none;">
                                        <i class="bi bi-calendar2-check text-primary" id="returnIcon"></i> RETURN
                                    </label>
                                    <div class="date-custom-display d-flex align-items-center justify-content-between" id="returnDateDisplay">
                                        <div class="d-flex align-items-baseline gap-2">
                                            <span class="date-main-text" id="returnDatePrimary">Select Return</span>
                                            <span class="date-sub-text" id="returnDaySubtext"></span>
                                        </div>
                                        <i class="bi bi-calendar3 text-primary fs-5" aria-hidden="true"></i>
                                    </div>
                                    <input type="hidden" id="returnDateInput" name="returnDate" value="" disabled>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ================= MULTI-CITY BUILDER CONTAINER ================= -->
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
                    <div class="row g-3 mt-2 align-items-center">
                        <!-- Passengers Selector Dropdown -->
                        <div class="col-lg-4 col-md-6">
                            <div class="search-field-box dropdown">
                                <label class="field-label">
                                    <i class="bi bi-people-fill text-primary"></i> TRAVELLERS
                                </label>
                                <button type="button" class="btn p-0 text-start w-100 fw-bold d-flex justify-content-between align-items-center"
                                        id="passengerDropdownBtn" data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false">
                                    <span id="passengerSummaryText">1 Adult</span>
                                    <i class="bi bi-chevron-down text-muted small"></i>
                                </button>

                                <div class="dropdown-menu passenger-dropdown-menu shadow-lg p-3" aria-labelledby="passengerDropdownBtn" style="min-width: 280px;">
                                    <!-- Adults -->
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <div>
                                            <div class="fw-bold">Adults</div>
                                            <small class="text-muted">12+ years</small>
                                        </div>
                                        <div class="d-flex align-items-center gap-2">
                                            <button type="button" class="counter-btn" onclick="updatePassenger('adults', -1)">&minus;</button>
                                            <span id="adultCountDisplay" class="fw-bold px-2">1</span>
                                            <button type="button" class="counter-btn" onclick="updatePassenger('adults', 1)">&#43;</button>
                                        </div>
                                    </div>

                                    <!-- Children -->
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <div>
                                            <div class="fw-bold">Children</div>
                                            <small class="text-muted">2&ndash;11 years</small>
                                        </div>
                                        <div class="d-flex align-items-center gap-2">
                                            <button type="button" class="counter-btn" onclick="updatePassenger('children', -1)">&minus;</button>
                                            <span id="childCountDisplay" class="fw-bold px-2">0</span>
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
                                            <span id="infantCountDisplay" class="fw-bold px-2">0</span>
                                            <button type="button" class="counter-btn" onclick="updatePassenger('infants', 1)">&#43;</button>
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
                        <div class="col-lg-4 col-md-6">
                            <div class="search-field-box dropdown position-relative" id="homeCabinClassBoxContainer">
                                <label id="homeTravelClassDropdownLabel" class="field-label">
                                    <i class="bi bi-award-fill text-primary"></i> CABIN CLASS
                                </label>
                                <button type="button" 
                                        class="btn p-0 text-start w-100 fw-bold d-flex justify-content-between align-items-center cabin-class-btn"
                                        id="travelClassDropdownBtn" 
                                        data-bs-toggle="dropdown" 
                                        aria-expanded="false" 
                                        aria-haspopup="listbox" 
                                        aria-labelledby="homeTravelClassDropdownLabel travelClassDropdownBtn">
                                    <span class="d-flex flex-column text-truncate">
                                        <span id="travelClassDisplayText" class="field-input-text fw-bold text-dark">Economy</span>
                                        <small id="travelClassSubtext" class="text-muted text-truncate" style="font-size: 0.75rem;">Standard seating &amp; best value fares</small>
                                    </span>
                                    <i class="bi bi-chevron-down text-muted small ms-2 cabin-chevron"></i>
                                </button>

                                <ul class="dropdown-menu cabin-class-dropdown-menu shadow-lg p-2" 
                                    id="travelClassMenuList"
                                    aria-labelledby="travelClassDropdownBtn"
                                    role="listbox">
                                    <li role="option" aria-selected="true">
                                        <button type="button" class="dropdown-item cabin-option-item rounded-2 py-2 px-3 d-flex align-items-center justify-content-between active" 
                                                data-value="Economy"
                                                data-subtext="Standard seating &amp; best value fares"
                                                onclick="selectCabinClass('Economy', 'Standard seating &amp; best value fares')">
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="cabin-icon-box text-primary">
                                                    <i class="bi bi-person-fill"></i>
                                                </div>
                                                <div>
                                                    <div class="fw-bold cabin-option-title">Economy</div>
                                                    <small class="text-muted d-block cabin-option-sub">Standard seating &amp; best value fares</small>
                                                </div>
                                            </div>
                                            <i class="bi bi-check-lg text-primary fw-bold cabin-check-icon"></i>
                                        </button>
                                    </li>
                                    <li role="option" aria-selected="false">
                                        <button type="button" class="dropdown-item cabin-option-item rounded-2 py-2 px-3 d-flex align-items-center justify-content-between" 
                                                data-value="Premium Economy"
                                                data-subtext="Extra legroom &amp; priority boarding"
                                                onclick="selectCabinClass('Premium Economy', 'Extra legroom &amp; priority boarding')">
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="cabin-icon-box text-primary">
                                                    <i class="bi bi-gem"></i>
                                                </div>
                                                <div>
                                                    <div class="fw-bold cabin-option-title">Premium Economy</div>
                                                    <small class="text-muted d-block cabin-option-sub">Extra legroom &amp; priority boarding</small>
                                                </div>
                                            </div>
                                            <i class="bi bi-check-lg text-primary fw-bold cabin-check-icon d-none"></i>
                                        </button>
                                    </li>
                                    <li role="option" aria-selected="false">
                                        <button type="button" class="dropdown-item cabin-option-item rounded-2 py-2 px-3 d-flex align-items-center justify-content-between" 
                                                data-value="Business"
                                                data-subtext="Spacious seating &amp; gourmet dining"
                                                onclick="selectCabinClass('Business', 'Spacious seating &amp; gourmet dining')">
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="cabin-icon-box text-primary">
                                                    <i class="bi bi-briefcase-fill"></i>
                                                </div>
                                                <div>
                                                    <div class="fw-bold cabin-option-title">Business</div>
                                                    <small class="text-muted d-block cabin-option-sub">Spacious seating &amp; gourmet dining</small>
                                                </div>
                                            </div>
                                            <i class="bi bi-check-lg text-primary fw-bold cabin-check-icon d-none"></i>
                                        </button>
                                    </li>
                                    <li role="option" aria-selected="false">
                                        <button type="button" class="dropdown-item cabin-option-item rounded-2 py-2 px-3 d-flex align-items-center justify-content-between" 
                                                data-value="First Class"
                                                data-subtext="Luxury private suite &amp; personal care"
                                                onclick="selectCabinClass('First Class', 'Luxury private suite &amp; personal care')">
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="cabin-icon-box text-primary">
                                                    <i class="bi bi-stars"></i>
                                                </div>
                                                <div>
                                                    <div class="fw-bold cabin-option-title">First Class</div>
                                                    <small class="text-muted d-block cabin-option-sub">Luxury private suite &amp; personal care</small>
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
                        <div class="col-lg-4 col-md-12">
                            <button type="submit" class="btn btn-search-flights w-100 py-3 shadow-sm" id="btnSearchSubmit">
                                <span id="btnSearchText"><i class="bi bi-search me-1"></i> SEARCH FLIGHTS</span>
                                <span id="btnSearchSpinner" class="spinner-border spinner-border-sm d-none ms-2" role="status" aria-hidden="true"></span>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </section>

    <!-- =========================================================================
         2. POPULAR DESTINATIONS / FLIGHT DEALS SECTION
         ========================================================================= -->
    <section class="py-5 bg-white fade-in-on-scroll" id="popularRoutesSection">
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

    <!-- =========================================================================
         3. WHY FLY WITH SKYTECH (FEATURE VALUE PROPOSITION)
         ========================================================================= -->
    <section class="py-5 fade-in-on-scroll" style="background-color: var(--skytech-light-bg);" id="whySkyTechSection">
        <div class="container py-2">
            <div class="text-center mb-5">
                <span class="badge bg-primary text-white fw-bold text-uppercase px-3 py-1 mb-2 rounded-pill">
                    Aviation Excellence
                </span>
                <h2 class="fw-bold">Why Fly with SkyTech</h2>
                <p class="text-muted">An airline reservation engine designed for speed, transparent fares, and intuitive seating</p>
            </div>

            <div class="row g-4">
                <div class="col-md-6 col-lg-3">
                    <div class="p-4 bg-white rounded-4 shadow-sm h-100 text-center journey-step-card">
                        <div class="d-inline-flex p-3 rounded-circle bg-primary-subtle text-primary mb-3 fs-3">
                            <i class="bi bi-speedometer2"></i>
                        </div>
                        <h5 class="fw-bold mb-2">Fast Flight Search</h5>
                        <p class="text-muted small mb-0">High-speed schedule querying comparing multi-carrier inventory and best route timings across India.</p>
                    </div>
                </div>

                <div class="col-md-6 col-lg-3">
                    <div class="p-4 bg-white rounded-4 shadow-sm h-100 text-center journey-step-card">
                        <div class="d-inline-flex p-3 rounded-circle bg-success-subtle text-success mb-3 fs-3">
                            <i class="bi bi-tag-fill"></i>
                        </div>
                        <h5 class="fw-bold mb-2">Transparent Fares</h5>
                        <p class="text-muted small mb-0">Clear itemized breakdown of base fares, GST, and airport fees with zero hidden charges before booking.</p>
                    </div>
                </div>

                <div class="col-md-6 col-lg-3">
                    <div class="p-4 bg-white rounded-4 shadow-sm h-100 text-center journey-step-card">
                        <div class="d-inline-flex p-3 rounded-circle bg-info-subtle text-info-emphasis mb-3 fs-3">
                            <i class="bi bi-grid-3x3"></i>
                        </div>
                        <h5 class="fw-bold mb-2">Smart Seat Selection</h5>
                        <p class="text-muted small mb-0">Interactive 20-row aircraft cabin map with real-time availability, extra legroom, and window seat selection.</p>
                    </div>
                </div>

                <div class="col-md-6 col-lg-3">
                    <div class="p-4 bg-white rounded-4 shadow-sm h-100 text-center journey-step-card">
                        <div class="d-inline-flex p-3 rounded-circle bg-warning-subtle text-warning-emphasis mb-3 fs-3">
                            <i class="bi bi-signpost-split-fill"></i>
                        </div>
                        <h5 class="fw-bold mb-2">Flexible Travel</h5>
                        <p class="text-muted small mb-0">Seamless support for One Way, Round Trip, and dynamic Multi-City multi-segment flight planning.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================================
         4. TRAVEL EXPERIENCE SECTION ("YOUR JOURNEY, SIMPLIFIED")
         ========================================================================= -->
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

    <!-- =========================================================================
         5. TRAVEL INSPIRATION SECTION ("GET INSPIRED")
         ========================================================================= -->
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

    <!-- =========================================================================
         6. TRAVEL HELP / QUICK ACTION SECTION
         ========================================================================= -->
    <section class="py-5 bg-white fade-in-on-scroll" id="helpSection">
        <div class="container py-2">
            <div class="text-center mb-5">
                <span class="badge bg-primary-subtle text-primary fw-bold text-uppercase px-3 py-1 mb-2 rounded-pill">
                    Passenger Care
                </span>
                <h2 class="fw-bold">How Can We Help?</h2>
                <p class="text-muted">Quick access to essential flight planning and travel support services</p>
            </div>

            <div class="row g-4">
                <div class="col-md-6 col-lg-3">
                    <a href="${pageContext.request.contextPath}/search-flights" class="help-action-card">
                        <div class="d-inline-flex p-3 rounded-circle bg-primary-subtle text-primary mb-3 fs-4">
                            <i class="bi bi-search"></i>
                        </div>
                        <h5 class="fw-bold text-dark mb-1">Flight Search</h5>
                        <p class="text-muted small mb-0">Search available domestic flights across IndiGo, Air India, and Akasa Air.</p>
                    </a>
                </div>

                <div class="col-md-6 col-lg-3">
                    <a href="${pageContext.request.contextPath}/manage-booking" class="help-action-card">
                        <div class="d-inline-flex p-3 rounded-circle bg-secondary-subtle text-secondary fs-4 mb-3">
                            <i class="bi bi-journal-bookmark"></i>
                        </div>
                        <h5 class="fw-bold text-dark mb-1">Manage Booking</h5>
                        <p class="text-muted small mb-0">View reservations, retrieve passenger itineraries, or request flight upgrades.</p>
                    </a>
                </div>

                <div class="col-md-6 col-lg-3">
                    <a href="${pageContext.request.contextPath}/flight-status" class="help-action-card">
                        <div class="d-inline-flex p-3 rounded-circle bg-warning-subtle text-warning-emphasis fs-4 mb-3">
                            <i class="bi bi-clock-history"></i>
                        </div>
                        <h5 class="fw-bold text-dark mb-1">Flight Status</h5>
                        <p class="text-muted small mb-0">Check real-time departure and arrival schedules for any active flight number.</p>
                    </a>
                </div>

                <div class="col-md-6 col-lg-3">
                    <a href="${pageContext.request.contextPath}/travel-information" class="help-action-card">
                        <div class="d-inline-flex p-3 rounded-circle bg-info-subtle text-info-emphasis mb-3 fs-4">
                            <i class="bi bi-briefcase"></i>
                        </div>
                        <h5 class="fw-bold text-dark mb-1">Travel Guidelines</h5>
                        <p class="text-muted small mb-0">Review cabin baggage allowances (7kg), check-in limits (15kg), and photo ID rules.</p>
                    </a>
                </div>
            </div>
        </div>
    </section>





    <!-- =========================================================================
         9. TRAVEL GUIDELINES MODAL
         ========================================================================= -->
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

<!-- =========================================================================
     JAVASCRIPT LOGIC (AIRPORTS, DATES, MULTI-CITY, POPULAR DEALS, VALIDATION)
     ========================================================================= -->
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
        const mcContainer = document.getElementById('multiCityContainer');

        const retContainer = document.getElementById('returnDateContainer');
        const retInput = document.getElementById('returnDateInput');
        const retLabel = document.getElementById('returnDayLabel');
        const retIcon = document.getElementById('returnIcon');

        const fromCol = document.getElementById('fromCol');
        const toCol = document.getElementById('toCol');
        const depCol = document.getElementById('depCol');

        [btnOneWay, btnRoundTrip, btnMultiCity].forEach(b => { if (b) b.classList.remove('active'); });

        if (type === 'round-trip') {
            btnRoundTrip.classList.add('active');
            stdContainer.classList.remove('d-none');
            mcContainer.classList.add('d-none');

            // Show Return Date container
            retContainer.classList.remove('d-none');
            retInput.disabled = false;
            retInput.setAttribute('name', 'returnDate');
            retInput.required = true;
            if (retIcon) retIcon.classList.replace('text-muted', 'text-primary');

            // Responsive column widths for 4 items
            if (fromCol) fromCol.className = 'col-lg-3 col-md-5';
            if (toCol) toCol.className = 'col-lg-3 col-md-5';
            if (depCol) depCol.className = 'col-lg-3 col-md-6';
            if (retContainer) retContainer.className = 'col-lg-2 col-md-6';

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

            retContainer.classList.add('d-none');
            retInput.disabled = true;
            retInput.removeAttribute('name');
            retInput.value = '';
            retInput.required = false;
            if (retLabel) retLabel.textContent = 'Select return date';

            // Expand column widths when Return Date is hidden
            if (fromCol) fromCol.className = 'col-lg-4 col-md-5';
            if (toCol) toCol.className = 'col-lg-4 col-md-5';
            if (depCol) depCol.className = 'col-lg-3 col-md-6';
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

        if (type === 'adults') a = Math.max(1, Math.min(9, a + delta));
        if (type === 'children') c = Math.max(0, Math.min(8, c + delta));
        if (type === 'infants') {
            i = Math.max(0, Math.min(a, i + delta)); // Infants cannot exceed adults
        }

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

    function selectCabinClass(className, subtext) {
        const input = document.getElementById('travelClassInput');
        const display = document.getElementById('travelClassDisplayText');
        const sub = document.getElementById('travelClassSubtext');
        if (input) input.value = className;
        if (display) display.textContent = className;
        if (sub) sub.textContent = subtext || '';

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
        const depInput = document.getElementById('departureDateInput');
        if (depInput && !depInput.value) {
            depInput.value = SERVER_TODAY_ISO;
        }
    });
</script>

<jsp:include page="common/footer.jsp" />
