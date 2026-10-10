<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="SkyTech Airlines - Your Journey Begins Here" />
<c:set var="activePage" value="home" />

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main>
    <!-- =========================================================
         B. CINEMATIC HERO SECTION (Sunset Commercial Airliner)
         ========================================================= -->
    <section class="hero-cinematic">
        <div class="hero-overlay-gradient"></div>
        <div class="cloud-drift-layer" aria-hidden="true"></div>

        <div class="container hero-inner-container">
            <div class="row align-items-center g-4">
                <div class="col-lg-8">
                    <div class="hero-eyebrow">
                        <i class="bi bi-airplane-fill" style="transform: rotate(45deg);"></i>
                        <span>INDIA'S TRUSTED AIRLINE PARTNER</span>
                    </div>

                    <h1 class="hero-heading">
                        Your Journey<br>
                        Begins <span class="highlight-sky">Here</span>
                    </h1>

                    <p class="hero-lead-text">
                        Discover incredible destinations, book flights seamlessly, and experience a safer, smarter, and more comfortable way to travel.
                    </p>

                    <div class="hero-actions-group">
                        <a href="#searchPanelSection" class="btn-hero-primary">
                            <i class="bi bi-search"></i>
                            <span>Book a Flight &rarr;</span>
                        </a>

                        <button type="button" class="btn-hero-video" data-bs-toggle="modal" data-bs-target="#flightExperienceModal">
                            <i class="bi bi-play-circle-fill fs-5 text-white"></i>
                            <span>Watch Video</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         D. FLOATING FLIGHT-SEARCH PANEL (Overlapping Hero)
         ========================================================= -->
    <section class="container search-panel-wrapper" id="searchPanelSection">
        <div class="floating-search-card">
            <!-- Top Tab Bar -->
            <div class="search-tab-bar">
                <div class="search-trip-pills">
                    <button type="button" class="trip-tab-btn active-flights">
                        <i class="bi bi-airplane-fill"></i> Flights
                    </button>
                    <button type="button" class="trip-tab-btn active-roundtrip" id="tripTypeRound" onclick="setTripType('round')">
                        <i class="bi bi-arrow-left-right"></i> Round Trip
                    </button>
                    <button type="button" class="trip-tab-btn" id="tripTypeOneWay" onclick="setTripType('oneway')">
                        One Way
                    </button>
                    <button type="button" class="trip-tab-btn" id="tripTypeMulti" onclick="setTripType('multi')">
                        Multi-City
                    </button>
                </div>

                <a href="#destinationsSection" class="best-fares-guarantee">
                    <i class="bi bi-globe text-primary"></i> Best Fares Guaranteed &rarr;
                </a>
            </div>

            <!-- Validation Error Alert -->
            <div id="searchValidationAlert" class="alert alert-warning py-2 small d-none mb-3" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>
                <span id="searchValidationMsg"></span>
            </div>

            <!-- Horizontal Search Form -->
            <form id="skytechFlightForm" onsubmit="handleFlightSearch(event)" novalidate>
                <div class="search-controls-grid">
                    <!-- From -->
                    <div class="search-box-field" onclick="document.getElementById('searchFromAirport').focus()">
                        <div class="search-box-label">From</div>
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-geo-alt-fill text-primary"></i>
                            <div class="flex-grow-1">
                                <select class="search-input-heading" id="searchFromAirport" onchange="updateSubtext('from')" required>
                                    <option value="DEL" data-city="New Delhi (DEL)" data-country="India" selected>New Delhi (DEL)</option>
                                    <option value="BOM" data-city="Mumbai (BOM)" data-country="India">Mumbai (BOM)</option>
                                    <option value="BLR" data-city="Bengaluru (BLR)" data-country="India">Bengaluru (BLR)</option>
                                    <option value="GOI" data-city="Goa (GOI)" data-country="India">Goa (GOI)</option>
                                    <option value="IXL" data-city="Leh (IXL)" data-country="India">Leh (IXL)</option>
                                </select>
                                <div class="search-input-subtext" id="fromSubtext">India</div>
                            </div>
                        </div>
                    </div>

                    <!-- Airport Swap Button -->
                    <button type="button" class="btn-swap-airports" onclick="swapAirports()" title="Swap Origin and Destination" aria-label="Swap origin and destination">
                        <i class="bi bi-arrow-left-right"></i>
                    </button>

                    <!-- To -->
                    <div class="search-box-field" onclick="document.getElementById('searchToAirport').focus()">
                        <div class="search-box-label">To</div>
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-geo-fill text-danger"></i>
                            <div class="flex-grow-1">
                                <select class="search-input-heading" id="searchToAirport" onchange="updateSubtext('to')" required>
                                    <option value="BOM" data-city="Mumbai (BOM)" data-country="India" selected>Mumbai (BOM)</option>
                                    <option value="DEL" data-city="New Delhi (DEL)" data-country="India">New Delhi (DEL)</option>
                                    <option value="BLR" data-city="Bengaluru (BLR)" data-country="India">Bengaluru (BLR)</option>
                                    <option value="GOI" data-city="Goa (GOI)" data-country="India">Goa (GOI)</option>
                                    <option value="IXL" data-city="Leh (IXL)" data-country="India">Leh (IXL)</option>
                                </select>
                                <div class="search-input-subtext" id="toSubtext">India</div>
                            </div>
                        </div>
                    </div>

                    <!-- Departure Date -->
                    <div class="search-box-field">
                        <div class="search-box-label">Departure</div>
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-calendar3 text-primary"></i>
                            <div class="flex-grow-1">
                                <input type="date" class="search-input-heading" id="searchDepDate" onchange="updateDateSubtext('dep')" required>
                                <div class="search-input-subtext" id="depSubtext">Select date</div>
                            </div>
                        </div>
                    </div>

                    <!-- Return Date -->
                    <div class="search-box-field" id="returnDateFieldBox">
                        <div class="search-box-label">Return</div>
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-calendar3 text-primary"></i>
                            <div class="flex-grow-1">
                                <input type="date" class="search-input-heading" id="searchRetDate" onchange="updateDateSubtext('ret')">
                                <div class="search-input-subtext" id="retSubtext">Optional for return</div>
                            </div>
                        </div>
                    </div>

                    <!-- Passengers -->
                    <div class="search-box-field">
                        <div class="search-box-label">Passengers</div>
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-person-fill text-primary"></i>
                            <div class="flex-grow-1">
                                <select class="search-input-heading" id="searchPassengersSelect">
                                    <option value="1" selected>1 Passenger</option>
                                    <option value="2">2 Passengers</option>
                                    <option value="3">3 Passengers</option>
                                    <option value="4">4+ Passengers</option>
                                </select>
                                <div class="search-input-subtext">Economy</div>
                            </div>
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit" class="btn-search-flights-action">
                        <i class="bi bi-search"></i>
                        <span>Search Flights &rarr;</span>
                    </button>
                </div>
            </form>
        </div>

        <!-- =========================================================
             3. SERVICE BENEFITS SECTION (Directly Under Search)
             ========================================================= -->
        <div class="service-benefits-grid">
            <div class="benefit-feature-card">
                <div class="benefit-icon-circle">
                    <i class="bi bi-shield-check"></i>
                </div>
                <div>
                    <div class="benefit-title">Safe & Secure</div>
                    <p class="benefit-description">Your data and payments are fully protected.</p>
                </div>
            </div>

            <div class="benefit-feature-card">
                <div class="benefit-icon-circle">
                    <i class="bi bi-headset"></i>
                </div>
                <div>
                    <div class="benefit-title">24/7 Support</div>
                    <p class="benefit-description">We're here for you always.</p>
                </div>
            </div>

            <div class="benefit-feature-card">
                <div class="benefit-icon-circle">
                    <i class="bi bi-ticket-perforated-fill"></i>
                </div>
                <div>
                    <div class="benefit-title">Easy Booking</div>
                    <p class="benefit-description">Simple and seamless reservation process.</p>
                </div>
            </div>

            <div class="benefit-feature-card">
                <div class="benefit-icon-circle">
                    <i class="bi bi-airplane-engines-fill"></i>
                </div>
                <div>
                    <div class="benefit-title">Comfortable Travel</div>
                    <p class="benefit-description">Enjoy a world-class flying experience.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- =========================================================
         4. POPULAR DESTINATIONS SECTION
         ========================================================= -->
    <section class="destinations-section" id="destinationsSection">
        <div class="container">
            <div class="destinations-header">
                <div>
                    <h2 class="section-headline">Popular Destinations</h2>
                    <p class="section-subtext">Explore top routes and start your next adventure</p>
                </div>
                <a href="#searchPanelSection" class="view-all-dest-link">
                    View All Destinations &rarr;
                </a>
            </div>

            <div class="destinations-cards-row">
                <!-- Card 1: Delhi -> Mumbai -->
                <a href="javascript:void(0)" onclick="quickSelectRoute('DEL', 'BOM', '4599')" class="dest-flight-card">
                    <img src="${pageContext.request.contextPath}/images/dest-delhi.jpg" alt="Delhi to Mumbai Flights" class="dest-flight-bg">
                    <div class="dest-card-gradient">
                        <div class="dest-card-content">
                            <div>
                                <div class="dest-route-name">Delhi &rarr; Mumbai</div>
                                <div class="dest-fare-tag">from <strong>₹4,599</strong></div>
                            </div>
                            <div class="dest-arrow-btn">
                                <i class="bi bi-arrow-right"></i>
                            </div>
                        </div>
                    </div>
                </a>

                <!-- Card 2: Mumbai -> Goa -->
                <a href="javascript:void(0)" onclick="quickSelectRoute('BOM', 'GOI', '5199')" class="dest-flight-card">
                    <img src="${pageContext.request.contextPath}/images/dest-mumbai.jpg" alt="Mumbai to Goa Flights" class="dest-flight-bg">
                    <div class="dest-card-gradient">
                        <div class="dest-card-content">
                            <div>
                                <div class="dest-route-name">Mumbai &rarr; Goa</div>
                                <div class="dest-fare-tag">from <strong>₹5,199</strong></div>
                            </div>
                            <div class="dest-arrow-btn">
                                <i class="bi bi-arrow-right"></i>
                            </div>
                        </div>
                    </div>
                </a>

                <!-- Card 3: Delhi -> Bengaluru -->
                <a href="javascript:void(0)" onclick="quickSelectRoute('DEL', 'BLR', '4299')" class="dest-flight-card">
                    <img src="${pageContext.request.contextPath}/images/dest-bengaluru.jpg" alt="Delhi to Bengaluru Flights" class="dest-flight-bg">
                    <div class="dest-card-gradient">
                        <div class="dest-card-content">
                            <div>
                                <div class="dest-route-name">Delhi &rarr; Bengaluru</div>
                                <div class="dest-fare-tag">from <strong>₹4,299</strong></div>
                            </div>
                            <div class="dest-arrow-btn">
                                <i class="bi bi-arrow-right"></i>
                            </div>
                        </div>
                    </div>
                </a>

                <!-- Card 4: Delhi -> Leh -->
                <a href="javascript:void(0)" onclick="quickSelectRoute('DEL', 'IXL', '8999')" class="dest-flight-card">
                    <img src="${pageContext.request.contextPath}/images/dest-leh.jpg" alt="Delhi to Leh Ladakh Flights" class="dest-flight-bg">
                    <div class="dest-card-gradient">
                        <div class="dest-card-content">
                            <div>
                                <div class="dest-route-name">Delhi &rarr; Leh</div>
                                <div class="dest-fare-tag">from <strong>₹8,999</strong></div>
                            </div>
                            <div class="dest-arrow-btn">
                                <i class="bi bi-arrow-right"></i>
                            </div>
                        </div>
                    </div>
                </a>
            </div>
        </div>
    </section>

    <!-- =========================================================
         5. WHY FLY WITH SKYTECH? SECTION
         ========================================================= -->
    <section class="why-skytech-section" id="servicesSection">
        <div class="container">
            <div class="why-skytech-grid">
                <div>
                    <h3 class="section-headline fs-2">Why Fly with SkyTech?</h3>
                    <p class="section-subtext">More than a journey, a better travel experience</p>
                </div>

                <div class="why-skytech-feature">
                    <div class="why-feature-icon">
                        <i class="bi bi-airplane-fill"></i>
                    </div>
                    <div>
                        <div class="why-feature-name">Wide Network</div>
                        <p class="why-feature-sub">Destinations across India and worldwide</p>
                    </div>
                </div>

                <div class="why-skytech-feature">
                    <div class="why-feature-icon">
                        <i class="bi bi-trophy-fill"></i>
                    </div>
                    <div>
                        <div class="why-feature-name">Best Prices</div>
                        <p class="why-feature-sub">Lowest fares with no hidden charges</p>
                    </div>
                </div>

                <div class="why-skytech-feature">
                    <div class="why-feature-icon">
                        <i class="bi bi-star-fill"></i>
                    </div>
                    <div>
                        <div class="why-feature-name">Premium Service</div>
                        <p class="why-feature-sub">Comfort, safety and reliability</p>
                    </div>
                </div>

                <div class="why-skytech-feature">
                    <div class="why-feature-icon">
                        <i class="bi bi-heart-fill"></i>
                    </div>
                    <div>
                        <div class="why-feature-name">Customer First</div>
                        <p class="why-feature-sub">Your satisfaction is our priority</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Video Modal -->
    <div class="modal fade" id="flightExperienceModal" tabindex="-1" aria-labelledby="videoModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content bg-dark border-0 rounded-4 overflow-hidden">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title text-white fw-bold" id="videoModalLabel">SkyTech Airlines Experience</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 text-center">
                    <div class="p-5 text-white bg-black rounded-3">
                        <i class="bi bi-play-circle text-primary fs-1 mb-3 d-block"></i>
                        <h4 class="fw-bold">Experience SkyTech Aviation Hospitality</h4>
                        <p class="text-secondary small mb-0">From smooth check-in to comfortable cruising, explore how SkyTech connects you to India and the world.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    // Initialize default departure & return dates
    document.addEventListener("DOMContentLoaded", function() {
        const today = new Date();
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);
        const nextWeek = new Date(today);
        nextWeek.setDate(nextWeek.getDate() + 7);

        const depDateInput = document.getElementById("searchDepDate");
        const retDateInput = document.getElementById("searchRetDate");

        if (depDateInput) {
            depDateInput.min = today.toISOString().split("T")[0];
            depDateInput.value = tomorrow.toISOString().split("T")[0];
            updateDateSubtext('dep');
        }

        if (retDateInput) {
            retDateInput.min = tomorrow.toISOString().split("T")[0];
            retDateInput.value = nextWeek.toISOString().split("T")[0];
            updateDateSubtext('ret');
        }
    });

    function setTripType(type) {
        document.getElementById("tripTypeRound").className = (type === 'round') ? 'trip-tab-btn active-roundtrip' : 'trip-tab-btn';
        document.getElementById("tripTypeOneWay").className = (type === 'oneway') ? 'trip-tab-btn active-roundtrip' : 'trip-tab-btn';
        document.getElementById("tripTypeMulti").className = (type === 'multi') ? 'trip-tab-btn active-roundtrip' : 'trip-tab-btn';

        const retBox = document.getElementById("returnDateFieldBox");
        if (type === 'oneway') {
            retBox.style.opacity = '0.4';
            document.getElementById("searchRetDate").disabled = true;
        } else {
            retBox.style.opacity = '1';
            document.getElementById("searchRetDate").disabled = false;
        }
    }

    function swapAirports() {
        const fromSel = document.getElementById("searchFromAirport");
        const toSel = document.getElementById("searchToAirport");
        const temp = fromSel.value;
        fromSel.value = toSel.value;
        toSel.value = temp;
        updateSubtext('from');
        updateSubtext('to');
    }

    function updateSubtext(which) {
        const sel = (which === 'from') ? document.getElementById("searchFromAirport") : document.getElementById("searchToAirport");
        const sub = (which === 'from') ? document.getElementById("fromSubtext") : document.getElementById("toSubtext");
        const opt = sel.options[sel.selectedIndex];
        sub.textContent = opt.getAttribute("data-country") || "India";
    }

    function updateDateSubtext(which) {
        const input = (which === 'dep') ? document.getElementById("searchDepDate") : document.getElementById("searchRetDate");
        const sub = (which === 'dep') ? document.getElementById("depSubtext") : document.getElementById("retSubtext");
        if (input.value) {
            const d = new Date(input.value + "T00:00:00");
            const options = { weekday: 'short', day: 'numeric', month: 'short' };
            sub.textContent = d.toLocaleDateString('en-US', options);
        }
    }

    function quickSelectRoute(fromCode, toCode, price) {
        const fromSel = document.getElementById("searchFromAirport");
        const toSel = document.getElementById("searchToAirport");
        fromSel.value = fromCode;
        toSel.value = toCode;
        updateSubtext('from');
        updateSubtext('to');
        document.getElementById("searchPanelSection").scrollIntoView({ behavior: 'smooth' });
    }

    function handleFlightSearch(e) {
        e.preventDefault();
        const from = document.getElementById("searchFromAirport").value;
        const to = document.getElementById("searchToAirport").value;
        const depDate = document.getElementById("searchDepDate").value;
        const retDate = document.getElementById("searchRetDate").value;
        const alertBox = document.getElementById("searchValidationAlert");
        const alertMsg = document.getElementById("searchValidationMsg");

        if (from === to) {
            alertMsg.textContent = "Origin and Destination airports must be different.";
            alertBox.classList.remove("d-none");
            return;
        }

        if (!depDate) {
            alertMsg.textContent = "Please select a departure date.";
            alertBox.classList.remove("d-none");
            return;
        }

        if (retDate && retDate < depDate && !document.getElementById("searchRetDate").disabled) {
            alertMsg.textContent = "Return date cannot be earlier than departure date.";
            alertBox.classList.remove("d-none");
            return;
        }

        alertBox.classList.add("d-none");

        // Inform user of search results
        alert("Searching flights from " + from + " to " + to + " for " + depDate + ".\n\nDirecting to SkyTech booking manifest...");
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
