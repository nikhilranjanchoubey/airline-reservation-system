<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="About SkyTech - Modern Airline Travel Experience" />
<c:set var="activePage" value="about" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="about-page-wrapper">
    <!-- =========================================================
         1. AIRLINE ABOUT HERO SECTION
         ========================================================= -->
    <section class="about-hero-section position-relative overflow-hidden py-5 text-white" style="min-height: 480px; display: flex; align-items: center;">
        <!-- Aviation Airplane Photography Background Layer -->
        <div class="position-absolute top-0 start-0 w-100 h-100" style="z-index: 0; pointer-events: none;">
            <img src="${pageContext.request.contextPath}/images/hero-cinematic.jpg"
                 alt="SkyTech Flying at Sunset"
                 class="w-100 h-100"
                 style="object-fit: cover; object-position: center 30%; filter: brightness(0.92);"
                 loading="eager" />
            <div class="position-absolute top-0 start-0 w-100 h-100"
                 style="background: linear-gradient(180deg, rgba(7, 26, 53, 0.76) 0%, rgba(11, 45, 82, 0.52) 50%, rgba(7, 26, 53, 0.90) 100%);"></div>
        </div>

        <div class="container position-relative py-4 py-lg-5 text-center" style="z-index: 2; max-width: 860px;">
            <span class="badge bg-sky-cyan-glow text-dark text-uppercase font-monospace fw-bold px-3 py-2 rounded-pill mb-3">
                <i class="bi bi-airplane-fill me-1"></i> ABOUT SKYTECH
            </span>
            <h1 class="display-4 fw-extrabold text-white mb-3 font-heading" style="letter-spacing: -0.5px;">
                Every Journey Begins with <span class="text-sky-cyan">SkyTech</span>
            </h1>
            <p class="lead text-cloud-white opacity-90 mb-4 mx-auto" style="font-size: 1.18rem; line-height: 1.65; max-width: 720px;">
                Discover a simpler way to plan your travels. Explore flight options, manage your bookings, and access your journey details through one convenient travel experience.
            </p>
            <div class="d-flex flex-wrap justify-content-center align-items-center gap-3">
                <a href="${pageContext.request.contextPath}/search-flights"
                   class="btn btn-sky-electric btn-lg rounded-pill px-4 shadow-sm fw-bold d-inline-flex align-items-center gap-2">
                    <i class="bi bi-search"></i> Explore Flights
                </a>
                <a href="${pageContext.request.contextPath}/manage-booking"
                   class="btn btn-outline-light btn-lg rounded-pill px-4 fw-bold d-inline-flex align-items-center gap-2"
                   style="backdrop-filter: blur(8px); background: rgba(7, 26, 53, 0.45); border-color: rgba(255, 255, 255, 0.5); font-family: 'Manrope', sans-serif;">
                    <i class="bi bi-ticket-perforated"></i> Manage My Booking
                </a>
            </div>
        </div>

        <!-- Glowing Curved Divider Line -->
        <div class="skytech-cyan-divider" aria-hidden="true">
            <svg viewBox="0 0 1440 48" fill="none" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="none">
                <path d="M0 48C360 0 1080 0 1440 48H0Z" fill="#071A35"/>
                <path d="M0 46C360 -2 1080 -2 1440 46" stroke="#56CCF2" stroke-width="2.5" filter="drop-shadow(0px 0px 8px #56CCF2)"/>
            </svg>
        </div>
    </section>

    <!-- =========================================================
         2. OUR APPROACH SECTION
         ========================================================= -->
    <section class="py-5 bg-midnight-navy position-relative">
        <div class="container py-3">
            <div class="text-center mb-5 mx-auto" style="max-width: 780px;">
                <span class="text-sky-cyan font-monospace text-uppercase fs-7 tracking-widest fw-bold">OUR APPROACH</span>
                <h2 class="display-6 text-white font-heading fw-bold mt-2 mb-3">Travel Planning, Made Simpler</h2>
                <p class="text-muted-slate mb-0" style="font-size: 1.05rem; line-height: 1.6;">
                    SkyTech brings essential travel planning tools together in one place, helping passengers explore flights, review journey details, and manage their reservations with greater convenience.
                </p>
            </div>

            <div class="row g-4">
                <!-- Feature Card 1: Explore Flights -->
                <div class="col-lg-4 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 hover-lift d-flex flex-column">
                        <div class="goal-icon-box mb-3">
                            <i class="bi bi-airplane-engines-fill fs-4"></i>
                        </div>
                        <h4 class="text-white font-heading fw-bold mb-2">Explore Flights</h4>
                        <p class="text-muted-slate small mb-3 flex-grow-1" style="line-height: 1.6;">
                            Search available flight options by origin, destination, travel date, and cabin preference.
                        </p>
                        <div>
                            <a href="${pageContext.request.contextPath}/search-flights" class="text-sky-cyan text-decoration-none fw-semibold small d-inline-flex align-items-center gap-1">
                                Search Flights <i class="bi bi-arrow-right"></i>
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Feature Card 2: Manage Your Journey -->
                <div class="col-lg-4 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 hover-lift d-flex flex-column">
                        <div class="goal-icon-box mb-3">
                            <i class="bi bi-ticket-perforated-fill fs-4"></i>
                        </div>
                        <h4 class="text-white font-heading fw-bold mb-2">Manage Your Journey</h4>
                        <p class="text-muted-slate small mb-3 flex-grow-1" style="line-height: 1.6;">
                            Access eligible booking details and review your reservation information from one convenient place.
                        </p>
                        <div>
                            <a href="${pageContext.request.contextPath}/manage-booking" class="text-sky-cyan text-decoration-none fw-semibold small d-inline-flex align-items-center gap-1">
                                Manage Reservation <i class="bi bi-arrow-right"></i>
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Feature Card 3: Passenger Support -->
                <div class="col-lg-4 col-md-12">
                    <div class="glass-card p-4 h-100 rounded-4 hover-lift d-flex flex-column">
                        <div class="goal-icon-box mb-3">
                            <i class="bi bi-shield-check fs-4"></i>
                        </div>
                        <h4 class="text-white font-heading fw-bold mb-2">Passenger Support</h4>
                        <p class="text-muted-slate small mb-3 flex-grow-1" style="line-height: 1.6;">
                            Find useful travel information, booking guidance, and answers to common passenger questions.
                        </p>
                        <div>
                            <a href="${pageContext.request.contextPath}/travel-information" class="text-sky-cyan text-decoration-none fw-semibold small d-inline-flex align-items-center gap-1">
                                View Travel Guidelines <i class="bi bi-arrow-right"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         3. PROFESSIONAL TRAVEL EXPERIENCE SECTION
         ========================================================= -->
    <section class="py-5 bg-deep-aviation position-relative">
        <div class="container py-3">
            <div class="row align-items-center g-5">
                <div class="col-lg-6">
                    <div class="position-relative overflow-hidden rounded-4 shadow-cyan-lg hover-lift">
                        <img src="${pageContext.request.contextPath}/images/plane-hero.jpg"
                             alt="Commercial Airliner In Flight"
                             class="img-fluid w-100 rounded-4 d-block"
                             style="max-height: 440px; object-fit: cover;"
                             loading="lazy" />
                        <div class="position-absolute bottom-0 start-0 w-100 p-3 p-md-4" style="background: linear-gradient(180deg, transparent 0%, rgba(7, 26, 53, 0.88) 100%);">
                            <span class="badge bg-sky-cyan-glow text-dark text-uppercase font-monospace fw-bold px-3 py-1 mb-1">SkyTech Aviation</span>
                            <div class="text-white fw-bold fs-5">Comfortable Travel Planning</div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <span class="text-sky-cyan font-monospace text-uppercase fs-7 tracking-widest fw-bold">YOUR JOURNEY, YOUR WAY</span>
                    <h2 class="display-6 text-white font-heading fw-bold mt-2 mb-3">From Flight Search to Your Next Destination</h2>
                    <p class="text-muted-slate mb-4" style="font-size: 1.05rem; line-height: 1.65;">
                        Find suitable flight options, review your itinerary, and keep your booking information accessible throughout your travel-planning experience.
                    </p>

                    <div class="d-flex flex-column gap-3 mb-4">
                        <div class="d-flex align-items-start gap-3">
                            <div class="badge bg-primary-subtle text-sky-cyan p-2 rounded-circle fs-6">
                                <i class="bi bi-compass-fill"></i>
                            </div>
                            <div>
                                <h6 class="text-white fw-bold mb-1 font-heading">Convenient Flight Discovery</h6>
                                <p class="text-muted-slate small mb-0">Compare available departures, schedules, and fares across major flight routes.</p>
                            </div>
                        </div>

                        <div class="d-flex align-items-start gap-3">
                            <div class="badge bg-primary-subtle text-sky-cyan p-2 rounded-circle fs-6">
                                <i class="bi bi-file-earmark-text-fill"></i>
                            </div>
                            <div>
                                <h6 class="text-white fw-bold mb-1 font-heading">Clear Booking Information</h6>
                                <p class="text-muted-slate small mb-0">View essential reservation details, passenger seat assignments, and baggage allowances.</p>
                            </div>
                        </div>

                        <div class="d-flex align-items-start gap-3">
                            <div class="badge bg-primary-subtle text-sky-cyan p-2 rounded-circle fs-6">
                                <i class="bi bi-check2-circle"></i>
                            </div>
                            <div>
                                <h6 class="text-white fw-bold mb-1 font-heading">Easy Reservation Management</h6>
                                <p class="text-muted-slate small mb-0">Retrieve your electronic ticket receipt and manage travel changes whenever eligible.</p>
                            </div>
                        </div>
                    </div>

                    <a href="${pageContext.request.contextPath}/search-flights" class="btn btn-sky-electric rounded-pill px-4 fw-bold d-inline-flex align-items-center gap-2">
                        <i class="bi bi-search"></i> Search Flights
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         4. TRAVEL SERVICES SECTION
         ========================================================= -->
    <section class="py-5 bg-midnight-navy position-relative">
        <div class="container py-3">
            <div class="text-center mb-5 mx-auto" style="max-width: 760px;">
                <span class="text-sky-cyan font-monospace text-uppercase fs-7 tracking-widest fw-bold">TRAVEL SERVICES</span>
                <h2 class="display-6 text-white font-heading fw-bold mt-2 mb-3">Everything You Need for Your Journey</h2>
                <p class="text-muted-slate mb-0" style="font-size: 1.05rem; line-height: 1.6;">
                    Explore dedicated passenger services designed to keep your journey clear, organized, and straightforward.
                </p>
            </div>

            <div class="row g-4">
                <!-- Service A: Flight Search -->
                <div class="col-lg-3 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 hover-lift d-flex flex-column text-center text-md-start">
                        <div class="goal-icon-box mb-3 mx-auto mx-md-0">
                            <i class="bi bi-search fs-4"></i>
                        </div>
                        <h5 class="text-white font-heading fw-bold mb-2">Flight Search</h5>
                        <p class="text-muted-slate small mb-4 flex-grow-1" style="line-height: 1.6;">
                            Discover available flight options, compare departure times, and select preferred cabins.
                        </p>
                        <a href="${pageContext.request.contextPath}/search-flights" class="btn btn-outline-light btn-sm rounded-pill px-3 fw-semibold">
                            Find Flights &rarr;
                        </a>
                    </div>
                </div>

                <!-- Service B: Flight Information -->
                <div class="col-lg-3 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 hover-lift d-flex flex-column text-center text-md-start">
                        <div class="goal-icon-box mb-3 mx-auto mx-md-0">
                            <i class="bi bi-clock-history fs-4"></i>
                        </div>
                        <h5 class="text-white font-heading fw-bold mb-2">Flight Information</h5>
                        <p class="text-muted-slate small mb-4 flex-grow-1" style="line-height: 1.6;">
                            Check live flight status, departure terminals, and estimated arrival schedules in real time.
                        </p>
                        <a href="${pageContext.request.contextPath}/flight-status" class="btn btn-outline-light btn-sm rounded-pill px-3 fw-semibold">
                            Check Status &rarr;
                        </a>
                    </div>
                </div>

                <!-- Service C: Booking Management -->
                <div class="col-lg-3 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 hover-lift d-flex flex-column text-center text-md-start">
                        <div class="goal-icon-box mb-3 mx-auto mx-md-0">
                            <i class="bi bi-pencil-square fs-4"></i>
                        </div>
                        <h5 class="text-white font-heading fw-bold mb-2">Booking Management</h5>
                        <p class="text-muted-slate small mb-4 flex-grow-1" style="line-height: 1.6;">
                            Retrieve existing reservation details with your PNR, review passengers, or cancel eligible tickets.
                        </p>
                        <a href="${pageContext.request.contextPath}/manage-booking" class="btn btn-outline-light btn-sm rounded-pill px-3 fw-semibold">
                            Manage Booking &rarr;
                        </a>
                    </div>
                </div>

                <!-- Service D: Passenger Account -->
                <div class="col-lg-3 col-md-6">
                    <div class="glass-card p-4 h-100 rounded-4 hover-lift d-flex flex-column text-center text-md-start">
                        <div class="goal-icon-box mb-3 mx-auto mx-md-0">
                            <i class="bi bi-person-circle fs-4"></i>
                        </div>
                        <h5 class="text-white font-heading fw-bold mb-2">Passenger Account</h5>
                        <p class="text-muted-slate small mb-4 flex-grow-1" style="line-height: 1.6;">
                            Access your personal travel dashboard, view past and upcoming trips, and download e-tickets.
                        </p>
                        <c:choose>
                            <c:when test="${not empty sessionScope.currentUser}">
                                <a href="${pageContext.request.contextPath}/my-bookings" class="btn btn-outline-light btn-sm rounded-pill px-3 fw-semibold">
                                    My Trips &rarr;
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-light btn-sm rounded-pill px-3 fw-semibold">
                                    Sign In &rarr;
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         5. CALL-TO-ACTION SECTION
         ========================================================= -->
    <section class="py-5 bg-deep-aviation position-relative overflow-hidden text-center text-white border-top border-sky-dark">
        <div class="container py-4 position-relative z-2" style="max-width: 760px;">
            <div class="badge bg-sky-cyan-glow text-dark text-uppercase font-monospace fw-bold mb-3 px-3 py-2 rounded-pill">
                <i class="bi bi-airplane-fill me-1"></i> PLAN WITH SKYTECH
            </div>
            <h2 class="display-5 fw-extrabold text-white mb-3 font-heading">Ready for Your Next Journey?</h2>
            <p class="lead text-cloud-white opacity-85 mb-4 mx-auto" style="max-width: 600px; font-size: 1.15rem; line-height: 1.6;">
                Explore available flights and start planning your next trip with SkyTech.
            </p>
            <div class="d-flex flex-wrap justify-content-center align-items-center gap-3">
                <a href="${pageContext.request.contextPath}/search-flights"
                   class="btn btn-sky-electric btn-lg rounded-pill px-4 shadow-cyan-glow fw-bold d-inline-flex align-items-center gap-2">
                    <i class="bi bi-search"></i> Search Flights
                </a>
                <a href="${pageContext.request.contextPath}/manage-booking"
                   class="btn btn-outline-light btn-lg rounded-pill px-4 fw-bold d-inline-flex align-items-center gap-2"
                   style="backdrop-filter: blur(8px); background: rgba(7, 26, 53, 0.45); border-color: rgba(255, 255, 255, 0.5); font-family: 'Manrope', sans-serif;">
                    <i class="bi bi-ticket-perforated"></i> Manage Booking
                </a>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
