<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="SkyTech - Book Flights Seamlessly Across the Globe" />
<c:set var="activePage" value="home" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main>
    <!-- =========================================================
         1. HERO SECTION (With Flying Airplane & Search Bar)
         ========================================================= -->
    <section class="hero-skytech">
        <div class="container hero-content">
            <div class="row align-items-center g-4">
                <div class="col-lg-6">
                    <span class="section-badge">
                        <i class="bi bi-clouds-fill me-1"></i> Welcome to SkyTech Aviation
                    </span>
                    <h1 class="hero-title mb-3">
                        Book Flights Seamlessly Across the Globe
                    </h1>
                    <p class="hero-subtitle mb-4">
                        Fast, secure, and reliable airline and airport services. Elevate your travel with cutting-edge seat reservation and instant boarding passes.
                    </p>
                    <div class="d-flex flex-wrap gap-3">
                        <a href="#flightsSection" class="btn btn-primary-airline px-4 py-2">
                            <i class="bi bi-search me-1"></i> Search Flights
                        </a>
                        <c:choose>
                            <c:when test="${not empty sessionScope.currentUser}">
                                <a href="${pageContext.request.contextPath}/profile" class="btn btn-outline-primary rounded-pill px-4 py-2 fw-semibold">
                                    <i class="bi bi-person-circle me-1"></i> My Portal
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/register" class="btn btn-outline-primary rounded-pill px-4 py-2 fw-semibold">
                                    <i class="bi bi-person-plus-fill me-1"></i> Join SkyTech
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="col-lg-6 text-center hero-plane-wrap">
                    <img src="${pageContext.request.contextPath}/images/plane-hero.jpg" 
                         alt="SkyTech Commercial Jet Flying in Blue Sky" 
                         class="hero-plane-img img-fluid">
                </div>
            </div>

            <!-- Glassmorphism Flight Search Widget -->
            <div class="flight-search-glass" id="searchWidget">
                <form id="flightSearchForm" onsubmit="handleSearchSubmit(event)">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-3">
                            <div class="search-field-box">
                                <div class="search-field-label">From</div>
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-geo-alt text-primary"></i>
                                    <input type="text" class="search-field-input" id="searchOrigin" value="New York (JFK)" placeholder="Origin City or Airport" required>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-3">
                            <div class="search-field-box">
                                <div class="search-field-label">To</div>
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-geo-fill text-danger"></i>
                                    <input type="text" class="search-field-input" id="searchDest" value="London (LHR)" placeholder="Destination City or Airport" required>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-2">
                            <div class="search-field-box">
                                <div class="search-field-label">Departure</div>
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-calendar-event text-info"></i>
                                    <input type="date" class="search-field-input" id="searchDepDate" value="2026-10-15" required>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-2">
                            <div class="search-field-box">
                                <div class="search-field-label">Return</div>
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-calendar2-check text-info"></i>
                                    <input type="date" class="search-field-input" id="searchRetDate" value="2026-10-22">
                                </div>
                            </div>
                        </div>

                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary-airline w-100 py-3">
                                <i class="bi bi-airplane me-1"></i> Search
                            </button>
                        </div>
                    </div>
                </form>
            </div>

            <!-- 4 Fast Action Tiles (Matching Image: Flight Status, Check-In, Baggage Info, Airport Map) -->
            <div class="fast-tiles-grid">
                <a href="#flightsSection" class="fast-tile-card">
                    <div class="fast-tile-icon">
                        <i class="bi bi-speedometer2"></i>
                    </div>
                    <div>
                        <div class="fast-tile-title">Flight Status</div>
                        <p class="fast-tile-desc">Live radar track & schedule</p>
                    </div>
                </a>

                <a href="#checkinSection" class="fast-tile-card">
                    <div class="fast-tile-icon">
                        <i class="bi bi-qr-code-scan"></i>
                    </div>
                    <div>
                        <div class="fast-tile-title">Check-In</div>
                        <p class="fast-tile-desc">Select seat & get boarding pass</p>
                    </div>
                </a>

                <a href="#servicesSection" class="fast-tile-card">
                    <div class="fast-tile-icon">
                        <i class="bi bi-bag-check-fill"></i>
                    </div>
                    <div>
                        <div class="fast-tile-title">Baggage Info</div>
                        <p class="fast-tile-desc">Weight limits & luggage guide</p>
                    </div>
                </a>

                <a href="#servicesSection" class="fast-tile-card">
                    <div class="fast-tile-icon">
                        <i class="bi bi-map-fill"></i>
                    </div>
                    <div>
                        <div class="fast-tile-title">Airport Map</div>
                        <p class="fast-tile-desc">Terminals & duty free locator</p>
                    </div>
                </a>
            </div>
        </div>
    </section>

    <!-- =========================================================
         2. FLIGHT SEARCH RESULTS (Matching Top-Right Screen)
         ========================================================= -->
    <section class="py-5" id="flightsSection">
        <div class="container">
            <div class="text-center mb-5">
                <span class="section-badge">Live Inventory</span>
                <h2 class="section-title">Available Flights & Fares</h2>
                <p class="text-muted">Compare non-stop flights and premium cabin deals tailored for you.</p>
            </div>

            <div class="row g-4">
                <!-- Left Filter Panel -->
                <div class="col-lg-3">
                    <div class="card border-0 shadow-sm rounded-4 p-4 sticky-top" style="top: 90px;">
                        <h5 class="fw-bold text-dark mb-4"><i class="bi bi-sliders me-2 text-primary"></i>Filters</h5>
                        
                        <!-- Price Range -->
                        <div class="mb-4">
                            <label class="form-label d-flex justify-content-between">
                                <span>Price Range</span>
                                <span class="fw-bold text-primary" id="priceDisplay">$450 Max</span>
                            </label>
                            <input type="range" class="form-range" min="150" max="800" step="10" value="450" id="priceRange" oninput="updatePrice(this.value)">
                        </div>

                        <!-- Airlines Filter -->
                        <div class="mb-4">
                            <div class="form-label mb-2">Airlines</div>
                            <div class="form-check mb-2">
                                <input class="form-check-input" type="checkbox" checked id="airSkyTech">
                                <label class="form-check-label small" for="airSkyTech">SkyTech Express</label>
                            </div>
                            <div class="form-check mb-2">
                                <input class="form-check-input" type="checkbox" checked id="airGlobal">
                                <label class="form-check-label small" for="airGlobal">Global Airways</label>
                            </div>
                            <div class="form-check mb-2">
                                <input class="form-check-input" type="checkbox" checked id="airBlueAero">
                                <label class="form-check-label small" for="airBlueAero">Blue Horizon</label>
                            </div>
                        </div>

                        <!-- Stops Filter -->
                        <div class="mb-3">
                            <div class="form-label mb-2">Stops</div>
                            <div class="form-check mb-2">
                                <input class="form-check-input" type="checkbox" checked id="stopNonstop">
                                <label class="form-check-label small" for="stopNonstop">Non-stop</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="stopOneStop">
                                <label class="form-check-label small" for="stopOneStop">1 Stop</label>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Flights List -->
                <div class="col-lg-9">
                    <!-- Flight Card 1 -->
                    <div class="flight-card">
                        <div class="airline-badge">
                            <div class="airline-logo-box">
                                <i class="bi bi-airplane-engines text-primary"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold mb-0">SkyTech ST-101</h6>
                                <span class="small text-muted">Airbus A350-900</span>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-3">
                            <div class="text-center">
                                <div class="flight-time">08:00 AM</div>
                                <div class="flight-route-meta">JFK &bull; New York</div>
                            </div>
                            <div class="flight-duration-bar">
                                <span class="small text-muted fw-semibold">3h 15m</span>
                                <div class="flight-duration-line"></div>
                                <span class="badge bg-success-subtle text-success small px-2">Non-stop</span>
                            </div>
                            <div class="text-center">
                                <div class="flight-time">11:15 AM</div>
                                <div class="flight-route-meta">LHR &bull; London</div>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-3">
                            <div class="text-end">
                                <div class="flight-price-tag">$320</div>
                                <div class="small text-muted">Economy / person</div>
                            </div>
                            <a href="#bookingSection" class="btn btn-primary-airline px-3 py-2" onclick="selectFlight('ST-101', '$320')">
                                Select <i class="bi bi-arrow-right ms-1"></i>
                            </a>
                        </div>
                    </div>

                    <!-- Flight Card 2 -->
                    <div class="flight-card">
                        <div class="airline-badge">
                            <div class="airline-logo-box">
                                <i class="bi bi-send-check text-info"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold mb-0">Global Express GE-442</h6>
                                <span class="small text-muted">Boeing 787 Dreamliner</span>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-3">
                            <div class="text-center">
                                <div class="flight-time">07:00 AM</div>
                                <div class="flight-route-meta">JFK &bull; New York</div>
                            </div>
                            <div class="flight-duration-bar">
                                <span class="small text-muted fw-semibold">3h 15m</span>
                                <div class="flight-duration-line"></div>
                                <span class="badge bg-success-subtle text-success small px-2">Non-stop</span>
                            </div>
                            <div class="text-center">
                                <div class="flight-time">10:15 AM</div>
                                <div class="flight-route-meta">LHR &bull; London</div>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-3">
                            <div class="text-end">
                                <div class="flight-price-tag">$345</div>
                                <div class="small text-muted">Economy / person</div>
                            </div>
                            <a href="#bookingSection" class="btn btn-primary-airline px-3 py-2" onclick="selectFlight('GE-442', '$345')">
                                Select <i class="bi bi-arrow-right ms-1"></i>
                            </a>
                        </div>
                    </div>

                    <!-- Flight Card 3 -->
                    <div class="flight-card">
                        <div class="airline-badge">
                            <div class="airline-logo-box">
                                <i class="bi bi-compass text-primary"></i>
                            </div>
                            <div>
                                <h6 class="fw-bold mb-0">Blue Horizon BH-809</h6>
                                <span class="small text-muted">Boeing 777-300ER</span>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-3">
                            <div class="text-center">
                                <div class="flight-time">08:00 AM</div>
                                <div class="flight-route-meta">JFK &bull; New York</div>
                            </div>
                            <div class="flight-duration-bar">
                                <span class="small text-muted fw-semibold">3h 35m</span>
                                <div class="flight-duration-line"></div>
                                <span class="badge bg-success-subtle text-success small px-2">Non-stop</span>
                            </div>
                            <div class="text-center">
                                <div class="flight-time">11:35 AM</div>
                                <div class="flight-route-meta">LHR &bull; London</div>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-3">
                            <div class="text-end">
                                <div class="flight-price-tag">$310</div>
                                <div class="small text-muted">Economy / person</div>
                            </div>
                            <a href="#bookingSection" class="btn btn-primary-airline px-3 py-2" onclick="selectFlight('BH-809', '$310')">
                                Select <i class="bi bi-arrow-right ms-1"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         3. SEAT SELECTION & BOOKING (Matching Bottom-Left Screen)
         ========================================================= -->
    <section class="py-5 bg-white border-top border-bottom" id="bookingSection">
        <div class="container" id="checkinSection">
            <div class="text-center mb-5">
                <span class="section-badge">Seat Map & Checkout</span>
                <h2 class="section-title">Passenger Details & Aircraft Seat Picker</h2>
                <p class="text-muted">Select your favorite cabin seat and complete your booking seamlessly.</p>
            </div>

            <div class="row g-4">
                <!-- Passenger Information -->
                <div class="col-lg-4">
                    <div class="card border-0 shadow-sm rounded-4 p-4 h-100">
                        <h5 class="fw-bold text-dark mb-4"><i class="bi bi-person-lines-fill me-2 text-primary"></i>Passenger Details</h5>
                        <div class="mb-3">
                            <label class="form-label">Full Name</label>
                            <input type="text" class="form-control" id="bookName" 
                                   value="<c:out value='${sessionScope.currentUser.fullName != null ? sessionScope.currentUser.fullName : \"John Doe\"}' />" placeholder="Passenger Full Name">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email Address</label>
                            <input type="email" class="form-control" id="bookEmail" 
                                   value="<c:out value='${sessionScope.currentUser.email != null ? sessionScope.currentUser.email : \"passenger@airline.com\"}' />" placeholder="name@example.com">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Passport Number</label>
                            <input type="text" class="form-control" id="bookPassport" 
                                   value="<c:out value='${sessionScope.currentUser.passportNumber != null ? sessionScope.currentUser.passportNumber : \"P12345678\"}' />" placeholder="Passport No.">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Selected Flight</label>
                            <input type="text" class="form-control bg-light fw-semibold" id="selectedFlightCode" value="SkyTech ST-101 (JFK &rarr; LHR)" readonly>
                        </div>
                    </div>
                </div>

                <!-- Aircraft Seat Map Fuselage -->
                <div class="col-lg-4 text-center">
                    <div class="card border-0 shadow-sm rounded-4 p-4 h-100">
                        <h5 class="fw-bold text-dark mb-3"><i class="bi bi-grid-3x3-gap-fill me-2 text-primary"></i>Select Your Seat</h5>
                        <div class="d-flex justify-content-center gap-3 small text-muted mb-3">
                            <span class="d-flex align-items-center gap-1"><span class="badge bg-light border text-dark">&nbsp;</span> Available</span>
                            <span class="d-flex align-items-center gap-1"><span class="badge bg-primary">&nbsp;</span> Selected</span>
                            <span class="d-flex align-items-center gap-1"><span class="badge bg-secondary">&nbsp;</span> Occupied</span>
                        </div>

                        <div class="seat-map-fuselage">
                            <div class="cockpit-nose"></div>
                            
                            <!-- Seat rows -->
                            <div class="seat-row">
                                <div class="seat-item" onclick="toggleSeat(this, '1A')">1A</div>
                                <div class="seat-item" onclick="toggleSeat(this, '1B')">1B</div>
                                <div class="seat-item occupied">1C</div>
                                <div class="seat-aisle-num">1</div>
                                <div class="seat-item occupied">1D</div>
                                <div class="seat-item" onclick="toggleSeat(this, '1E')">1E</div>
                                <div class="seat-item" onclick="toggleSeat(this, '1F')">1F</div>
                            </div>
                            <div class="seat-row">
                                <div class="seat-item" onclick="toggleSeat(this, '2A')">2A</div>
                                <div class="seat-item occupied">2B</div>
                                <div class="seat-item" onclick="toggleSeat(this, '2C')">2C</div>
                                <div class="seat-aisle-num">2</div>
                                <div class="seat-item" onclick="toggleSeat(this, '2D')">2D</div>
                                <div class="seat-item occupied">2E</div>
                                <div class="seat-item" onclick="toggleSeat(this, '2F')">2F</div>
                            </div>
                            <div class="seat-row">
                                <div class="seat-item" onclick="toggleSeat(this, '3A')">3A</div>
                                <div class="seat-item" onclick="toggleSeat(this, '3B')">3B</div>
                                <div class="seat-item" onclick="toggleSeat(this, '3C')">3C</div>
                                <div class="seat-aisle-num">3</div>
                                <div class="seat-item" onclick="toggleSeat(this, '3D')">3D</div>
                                <div class="seat-item" onclick="toggleSeat(this, '3E')">3E</div>
                                <div class="seat-item" onclick="toggleSeat(this, '3F')">3F</div>
                            </div>
                            <div class="seat-row">
                                <div class="seat-item occupied">4A</div>
                                <div class="seat-item occupied">4B</div>
                                <div class="seat-item" onclick="toggleSeat(this, '4C')">4C</div>
                                <div class="seat-aisle-num">4</div>
                                <div class="seat-item" onclick="toggleSeat(this, '4D')">4D</div>
                                <div class="seat-item" onclick="toggleSeat(this, '4E')">4E</div>
                                <div class="seat-item" onclick="toggleSeat(this, '4F')">4F</div>
                            </div>
                            <div class="seat-row">
                                <div class="seat-item" onclick="toggleSeat(this, '5A')">5A</div>
                                <div class="seat-item" onclick="toggleSeat(this, '5B')">5B</div>
                                <div class="seat-item" onclick="toggleSeat(this, '5C')">5C</div>
                                <div class="seat-aisle-num">5</div>
                                <div class="seat-item selected" onclick="toggleSeat(this, '14A')">5D</div>
                                <div class="seat-item" onclick="toggleSeat(this, '5E')">5E</div>
                                <div class="seat-item" onclick="toggleSeat(this, '5F')">5F</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Payment Method & Summary -->
                <div class="col-lg-4">
                    <div class="card border-0 shadow-sm rounded-4 p-4 h-100 d-flex flex-column justify-content-between">
                        <div>
                            <h5 class="fw-bold text-dark mb-4"><i class="bi bi-credit-card-2-front-fill me-2 text-primary"></i>Payment Method</h5>
                            
                            <div class="list-group mb-4">
                                <label class="list-group-item d-flex align-items-center justify-content-between p-3 rounded-3 mb-2 border">
                                    <div class="d-flex align-items-center gap-2">
                                        <input class="form-check-input me-1" type="radio" name="paymentMethod" checked>
                                        <i class="bi bi-credit-card fs-5 text-primary"></i>
                                        <span class="fw-semibold">Credit / Debit Card</span>
                                    </div>
                                    <span class="badge bg-light text-muted border">Instant</span>
                                </label>
                                <label class="list-group-item d-flex align-items-center justify-content-between p-3 rounded-3 mb-2 border">
                                    <div class="d-flex align-items-center gap-2">
                                        <input class="form-check-input me-1" type="radio" name="paymentMethod">
                                        <i class="bi bi-currency-bitcoin fs-5 text-warning"></i>
                                        <span class="fw-semibold">Crypto (BTC/USDT)</span>
                                    </div>
                                    <span class="badge bg-light text-muted border">Web3</span>
                                </label>
                                <label class="list-group-item d-flex align-items-center justify-content-between p-3 rounded-3 border">
                                    <div class="d-flex align-items-center gap-2">
                                        <input class="form-check-input me-1" type="radio" name="paymentMethod">
                                        <i class="bi bi-bank fs-5 text-success"></i>
                                        <span class="fw-semibold">Bank Wire Transfer</span>
                                    </div>
                                    <span class="badge bg-light text-muted border">Direct</span>
                                </label>
                            </div>

                            <div class="p-3 bg-light rounded-3 mb-4">
                                <div class="d-flex justify-content-between text-muted small mb-2">
                                    <span>Base Airfare</span>
                                    <span>$290.00</span>
                                </div>
                                <div class="d-flex justify-content-between text-muted small mb-2">
                                    <span>Seat Reservation (5D)</span>
                                    <span>$15.00</span>
                                </div>
                                <div class="d-flex justify-content-between text-muted small mb-2">
                                    <span>Airport Taxes & Fees</span>
                                    <span>$15.00</span>
                                </div>
                                <hr class="my-2">
                                <div class="d-flex justify-content-between align-items-center fw-bold">
                                    <span class="text-dark">Total Price</span>
                                    <span class="fs-4 text-primary" id="summaryTotal">$320.00</span>
                                </div>
                            </div>
                        </div>

                        <button type="button" class="btn btn-primary-airline w-100 py-3" onclick="confirmBooking()">
                            <i class="bi bi-check2-circle me-1"></i> Confirm Booking
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         4. BOARDING PASS & PASSENGER DASHBOARD (Matching Center Tile)
         ========================================================= -->
    <section class="py-5" id="boardingSection">
        <div class="container">
            <div class="text-center mb-5">
                <span class="section-badge">Digital Boarding Pass</span>
                <h2 class="section-title">Upcoming Flight & Live Notifications</h2>
                <p class="text-muted">Instant mobile boarding pass and real-time gate departure reminders.</p>
            </div>

            <div class="row g-4 justify-content-center">
                <!-- Boarding Pass Widget -->
                <div class="col-lg-7">
                    <div class="boarding-pass-card">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div class="d-flex align-items-center gap-2">
                                <span class="brand-icon-wrap" style="width: 28px; height: 28px;">
                                    <i class="bi bi-airplane-fill" style="font-size: 0.8rem;"></i>
                                </span>
                                <span class="fw-bold">SkyTech Boarding Pass</span>
                            </div>
                            <span class="badge bg-info-subtle text-info px-3 py-2 rounded-pill">CONFIRMED</span>
                        </div>

                        <div class="row align-items-center mb-4">
                            <div class="col-5">
                                <div class="boarding-airport-code">NYC</div>
                                <div class="text-light small">JFK Terminal 4</div>
                                <div class="text-warning small mt-1"><i class="bi bi-clock me-1"></i>08:00 AM</div>
                            </div>
                            <div class="col-2 text-center">
                                <i class="bi bi-airplane text-info fs-3"></i>
                                <div class="small text-light opacity-75">3h 15m</div>
                            </div>
                            <div class="col-5 text-end">
                                <div class="boarding-airport-code">LHR</div>
                                <div class="text-light small">Heathrow Terminal 3</div>
                                <div class="text-warning small mt-1"><i class="bi bi-clock me-1"></i>11:15 AM</div>
                            </div>
                        </div>

                        <div class="row g-3 p-3 rounded-3" style="background: rgba(255, 255, 255, 0.08);">
                            <div class="col-3">
                                <span class="small text-light d-block">Flight</span>
                                <strong class="fs-6">SK322</strong>
                            </div>
                            <div class="col-3">
                                <span class="small text-light d-block">Gate</span>
                                <strong class="fs-6 text-warning">B14</strong>
                            </div>
                            <div class="col-3">
                                <span class="small text-light d-block">Seat</span>
                                <strong class="fs-6" id="boardingPassSeat">14A</strong>
                            </div>
                            <div class="col-3">
                                <span class="small text-light d-block">Class</span>
                                <strong class="fs-6">Economy</strong>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between align-items-center mt-4">
                            <div class="d-flex align-items-center gap-3">
                                <div class="boarding-qr-box">
                                    <i class="bi bi-qr-code text-dark" style="font-size: 2.8rem;"></i>
                                </div>
                                <div class="small text-light">
                                    <div>Scan at TSA checkpoint</div>
                                    <div class="opacity-75">Boarding group: <strong>ZONE 2</strong></div>
                                </div>
                            </div>
                            <button class="btn btn-outline-light rounded-pill px-4" onclick="window.print()">
                                <i class="bi bi-printer me-1"></i> Print Pass
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Live Notifications & Travel History Sidecards -->
                <div class="col-lg-5">
                    <div class="card border-0 shadow-sm rounded-4 p-4 mb-4">
                        <h6 class="fw-bold text-dark mb-3"><i class="bi bi-bell-fill text-primary me-2"></i>Flight Alerts</h6>
                        <div class="alert alert-warning d-flex align-items-center gap-3 mb-2" role="alert">
                            <i class="bi bi-exclamation-triangle-fill fs-4 text-warning"></i>
                            <div>
                                <strong class="d-block">Gate Change Announcement</strong>
                                <span class="small">Flight SK322 is now boarding at Gate B14 instead of Gate A02.</span>
                            </div>
                        </div>
                        <div class="alert alert-info d-flex align-items-center gap-3 mb-0" role="alert">
                            <i class="bi bi-info-circle-fill fs-4 text-info"></i>
                            <div>
                                <strong class="d-block">Check-In Window Open</strong>
                                <span class="small">Online bag drop open 2 hours before scheduled departure.</span>
                            </div>
                        </div>
                    </div>

                    <div class="card border-0 shadow-sm rounded-4 p-4">
                        <h6 class="fw-bold text-dark mb-3"><i class="bi bi-clock-history text-primary me-2"></i>Recent Travel History</h6>
                        <div class="d-flex justify-content-between align-items-center py-2 border-bottom">
                            <div>
                                <div class="fw-semibold text-dark">London (LHR) &rarr; Paris (CDG)</div>
                                <span class="small text-muted">Flight SK108 &bull; June 22, 2026</span>
                            </div>
                            <span class="badge bg-light text-success border">Completed</span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center pt-2">
                            <div>
                                <div class="fw-semibold text-dark">New York (JFK) &rarr; Tokyo (HND)</div>
                                <span class="small text-muted">Flight SK905 &bull; April 10, 2026</span>
                            </div>
                            <span class="badge bg-light text-success border">Completed</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         5. AIRPORT SERVICES (Matching Bottom-Right Screen)
         ========================================================= -->
    <section class="py-5 bg-white border-top" id="servicesSection">
        <div class="container">
            <div class="text-center mb-5">
                <span class="section-badge">Exclusive Amenities</span>
                <h2 class="section-title">Airport Services & Lounges</h2>
                <p class="text-muted">Enjoy luxury hospitality from curb to cabin with SkyTech privileges.</p>
            </div>

            <div class="row g-4">
                <!-- Lounge Access -->
                <div class="col-md-6 col-lg-3">
                    <div class="service-photo-card">
                        <div class="service-photo-wrap">
                            <img src="${pageContext.request.contextPath}/images/service-lounge.jpg" alt="SkyTech VIP Lounge Access">
                        </div>
                        <div class="service-photo-body">
                            <span>Lounge Access</span>
                            <i class="bi bi-check-circle-fill text-primary fs-5"></i>
                        </div>
                    </div>
                </div>

                <!-- Car Rental -->
                <div class="col-md-6 col-lg-3">
                    <div class="service-photo-card">
                        <div class="service-photo-wrap">
                            <img src="${pageContext.request.contextPath}/images/service-car.jpg" alt="Executive Car Rental">
                        </div>
                        <div class="service-photo-body">
                            <span>Car Rental</span>
                            <i class="bi bi-check-circle-fill text-primary fs-5"></i>
                        </div>
                    </div>
                </div>

                <!-- Nearby Hotels -->
                <div class="col-md-6 col-lg-3">
                    <div class="service-photo-card">
                        <div class="service-photo-wrap">
                            <img src="${pageContext.request.contextPath}/images/service-hotel.jpg" alt="Nearby Luxury Airport Hotels">
                        </div>
                        <div class="service-photo-body">
                            <span>Nearby Hotels</span>
                            <i class="bi bi-check-circle-fill text-primary fs-5"></i>
                        </div>
                    </div>
                </div>

                <!-- VIP Services -->
                <div class="col-md-6 col-lg-3">
                    <div class="service-photo-card">
                        <div class="service-photo-wrap">
                            <img src="${pageContext.request.contextPath}/images/service-vip.jpg" alt="Private Jet & VIP Tarmac Concierge">
                        </div>
                        <div class="service-photo-body">
                            <span>VIP Services</span>
                            <i class="bi bi-check-circle-fill text-primary fs-5"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</main>

<script>
    function updatePrice(val) {
        document.getElementById('priceDisplay').textContent = '$' + val + ' Max';
    }

    function selectFlight(code, price) {
        document.getElementById('selectedFlightCode').value = 'SkyTech ' + code + ' (JFK -> LHR)';
        document.getElementById('summaryTotal').textContent = price + '.00';
    }

    function toggleSeat(el, seatCode) {
        document.querySelectorAll('.seat-item.selected').forEach(s => s.classList.remove('selected'));
        el.classList.add('selected');
        document.getElementById('boardingPassSeat').textContent = seatCode;
    }

    function handleSearchSubmit(e) {
        e.preventDefault();
        const origin = document.getElementById('searchOrigin').value;
        const dest = document.getElementById('searchDest').value;
        const flightsSection = document.getElementById('flightsSection');
        flightsSection.scrollIntoView({ behavior: 'smooth' });
    }

    function confirmBooking() {
        const name = document.getElementById('bookName').value;
        const seat = document.getElementById('boardingPassSeat').textContent;
        alert('Booking Confirmed for ' + name + '! Your seat ' + seat + ' has been reserved on Flight SK322.');
        document.getElementById('boardingSection').scrollIntoView({ behavior: 'smooth' });
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
