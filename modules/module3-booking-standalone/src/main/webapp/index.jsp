<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.skytech.airlines.booking.integration.DatabaseFlightProvider" %>
<%@ page import="com.skytech.airlines.booking.integration.FlightSummary" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    DatabaseFlightProvider flightProvider = new DatabaseFlightProvider();
    List<FlightSummary> flights = flightProvider.getSampleFlights();
    NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    int totalAvailableSeats = 0;
    for (FlightSummary f : flights) {
        totalAvailableSeats += f.getAvailableSeats();
    }
%>
<jsp:include page="/includes/header.jsp" />

<!-- Hero Section with Aviation Styling -->
<section class="py-5 text-white position-relative" style="background: linear-gradient(135deg, #071629 0%, #0B2545 100%);">
    <div class="container py-4">
        <div class="row align-items-center">
            <div class="col-lg-7">
                <span class="badge bg-primary mb-3 px-3 py-2 fs-6">
                    <i class="bi bi-airplane-engines-fill me-1"></i> Official Flight Booking Portal
                </span>
                <h1 class="display-5 fw-bold mb-3">Fly Beyond Expectations with SKYTECH</h1>
                <p class="lead text-white-50 mb-4">
                    Experience seamless flight reservations, intelligent aircraft seat selection, authoritative fare computation, and secure 256-bit Razorpay payments.
                </p>
                <div class="d-flex gap-3 flex-wrap">
                    <a href="#availableFlights" class="btn btn-skytech-primary btn-lg">
                        <i class="bi bi-airplane-fill me-2"></i> Select Flight &amp; Book
                    </a>
                    <a href="${pageContext.request.contextPath}/booking/my-bookings" class="btn btn-outline-light btn-lg">
                        <i class="bi bi-journal-check me-2"></i> View My Bookings
                    </a>
                </div>
            </div>
            <div class="col-lg-5 d-none d-lg-block text-center">
                <div class="p-4 bg-white bg-opacity-10 rounded-4 border border-white border-opacity-10 shadow-lg">
                    <i class="bi bi-airplane text-info display-1"></i>
                    <h4 class="text-white fw-bold mt-3"><%= flights.size() %> Active Scheduled Flights</h4>
                    <p class="small text-white-50 mb-0"><%= totalAvailableSeats %> Total Seats Available &bull; Modern Airbus &amp; Boeing Fleet</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Available Flights Selection Section -->
<section id="availableFlights" class="py-5">
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
            <div>
                <h3 class="fw-bold text-navy mb-1">
                    <i class="bi bi-send-fill text-primary me-2"></i> All Scheduled Flights
                </h3>
                <p class="text-muted small mb-0">Browse all <%= flights.size() %> available flights with real-time seat availability.</p>
            </div>
            <span class="badge bg-light text-dark border p-2">
                <i class="bi bi-check-circle-fill text-success me-1"></i> Real-Time Seat Availability (<%= totalAvailableSeats %> Seats)
            </span>
        </div>

        <!-- Real-Time Search & Route Filter Controls -->
        <div class="card border-0 shadow-sm mb-4" style="background: white; border-radius: 12px;">
            <div class="card-body p-3 p-md-4">
                <div class="row g-3 align-items-center">
                    <div class="col-md-5">
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                            <input type="text" id="flightSearchInput" class="form-control border-start-0" 
                                   placeholder="Search by city or airport (e.g. Delhi, Mumbai, Goa, Dubai, London...)" 
                                   onkeyup="filterFlights()">
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="btn-group w-100" role="group">
                            <button type="button" class="btn btn-outline-primary active" id="filterAll" onclick="setCategoryFilter('all')">All (<%= flights.size() %>)</button>
                            <button type="button" class="btn btn-outline-primary" id="filterDomestic" onclick="setCategoryFilter('domestic')">Domestic</button>
                            <button type="button" class="btn btn-outline-primary" id="filterInternational" onclick="setCategoryFilter('international')">International</button>
                        </div>
                    </div>
                    <div class="col-md-3 text-md-end">
                        <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 p-2">
                            <i class="bi bi-airplane-engines-fill me-1"></i> Showing <span id="visibleFlightCount"><%= flights.size() %></span> of <%= flights.size() %> Flights
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4" id="flightCardsContainer">
            <% for (FlightSummary f : flights) { 
                int total = f.getTotalSeats() > 0 ? f.getTotalSeats() : 180;
                int avail = f.getAvailableSeats();
                int pct = Math.min(100, Math.max(0, (avail * 100) / total));
                boolean isIntl = "DXB".equalsIgnoreCase(f.getDestAirportCode()) || 
                                 "SIN".equalsIgnoreCase(f.getDestAirportCode()) || 
                                 "LHR".equalsIgnoreCase(f.getDestAirportCode()) || 
                                 "BKK".equalsIgnoreCase(f.getDestAirportCode());
                String category = isIntl ? "international" : "domestic";
                String seatBadgeClass = avail < 50 ? "bg-warning text-dark border-warning" : "bg-success text-success bg-opacity-10 border-success border-opacity-25";
                String seatIcon = avail < 50 ? "bi-fire" : "bi-person-check-fill";
            %>
            <div class="col-md-6 col-lg-4 flight-card-item" 
                 data-category="<%= category %>" 
                 data-origin="<%= f.getOriginAirportCode().toLowerCase() %> <%= f.getOriginCity().toLowerCase() %>" 
                 data-dest="<%= f.getDestAirportCode().toLowerCase() %> <%= f.getDestCity().toLowerCase() %>" 
                 data-flight="<%= f.getFlightNumber().toLowerCase() %>"
                 data-captain="<%= f.getCaptainName().toLowerCase() %>"
                 data-ff="<%= f.getFrequentFlyerTier().toLowerCase() %>">
                <div class="skytech-card h-100 d-flex flex-column shadow-sm">
                    <div class="skytech-card-header">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-airplane-fill text-primary"></i>
                            <span class="fw-bold text-navy"><%= f.getFlightNumber() %></span>
                            <% if (isIntl) { %>
                                <span class="badge bg-info bg-opacity-10 text-info border border-info border-opacity-25 small">International</span>
                            <% } %>
                        </div>
                        <span class="badge bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25">
                            <%= f.getAircraftModel() %>
                        </span>
                    </div>
                    <div class="skytech-card-body flex-grow-1 d-flex flex-column">
                        <div class="mb-2 text-muted small">
                            <i class="bi bi-person-badge-fill text-primary me-1"></i><strong>Commander:</strong> <span class="text-navy fw-semibold"><%= f.getCaptainName() %></span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <h4 class="fw-bold text-navy mb-0"><%= f.getOriginAirportCode() %></h4>
                                <small class="text-muted"><%= f.getOriginCity() %></small>
                            </div>
                            <div class="text-center px-2">
                                <small class="text-muted fw-semibold"><%= f.getFormattedDuration() %></small>
                                <div class="text-primary"><i class="bi bi-arrow-right fs-4"></i></div>
                                <span class="badge bg-success bg-opacity-10 text-success small">Direct</span>
                            </div>
                            <div class="text-end">
                                <h4 class="fw-bold text-navy mb-0"><%= f.getDestAirportCode() %></h4>
                                <small class="text-muted"><%= f.getDestCity() %></small>
                            </div>
                        </div>

                        <div class="bg-light p-2 rounded border mb-3 small">
                            <div class="d-flex justify-content-between mb-1 text-muted">
                                <span><i class="bi bi-clock me-1"></i>Departure:</span>
                                <span class="fw-semibold text-dark"><%= f.getFormattedDeparture() %></span>
                            </div>
                            <div class="d-flex justify-content-between text-muted">
                                <span><i class="bi bi-clock-history me-1"></i>Arrival:</span>
                                <span class="fw-semibold text-dark"><%= f.getFormattedArrival() %></span>
                            </div>
                        </div>

                        <!-- Prominent Seat Availability Section -->
                        <div class="p-2 rounded border mb-3" style="background: #F8FAFC;">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <small class="text-muted fw-bold"><i class="bi bi-grid-3x3-gap-fill text-primary me-1"></i>Available Seats:</small>
                                <span class="badge <%= seatBadgeClass %> border px-2 py-1">
                                    <i class="bi <%= seatIcon %> me-1"></i><%= avail %> / <%= total %> Seats Left
                                </span>
                            </div>
                            <div class="progress" style="height: 6px;">
                                <div class="progress-bar bg-primary" role="progressbar" style="width: <%= pct %>%;"></div>
                            </div>
                        </div>

                        <!-- Dedicated Frequent Flyer Option & Perks -->
                        <div class="p-2 rounded border mb-3" style="background: #F0F7FF; border-color: #BAE6FD;">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <small class="text-navy fw-bold"><i class="bi bi-award-fill text-primary me-1"></i>Frequent Flyer:</small>
                                <span class="badge bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25"><%= f.getFrequentFlyerTier() %></span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center small">
                                <span class="text-primary fw-bold"><i class="bi bi-stars text-warning me-1"></i>+<%= f.getFrequentFlyerMiles() %> SkyPoints</span>
                                <span class="text-muted small text-truncate ms-2" style="max-width: 160px;" title="<%= f.getFrequentFlyerPerks() %>"><%= f.getFrequentFlyerPerks() %></span>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between align-items-center mt-auto pt-2 border-top">
                            <div>
                                <small class="text-muted d-block">Starting from</small>
                                <span class="fs-4 fw-bold text-primary"><%= nf.format(f.getBaseFare()) %></span>
                            </div>
                            <a href="${pageContext.request.contextPath}/booking?flightId=<%= f.getFlightId() %>" 
                               class="btn btn-skytech-primary px-3 fw-semibold">
                                Book Now <i class="bi bi-arrow-right ms-1"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</section>

<script>
let currentCategory = 'all';

function setCategoryFilter(category) {
    currentCategory = category;
    document.getElementById('filterAll').classList.toggle('active', category === 'all');
    document.getElementById('filterDomestic').classList.toggle('active', category === 'domestic');
    document.getElementById('filterInternational').classList.toggle('active', category === 'international');
    filterFlights();
}

function filterFlights() {
    const query = (document.getElementById('flightSearchInput').value || '').trim().toLowerCase();
    const cards = document.querySelectorAll('.flight-card-item');
    let visible = 0;
    cards.forEach(card => {
        const cat = card.getAttribute('data-category');
        const origin = card.getAttribute('data-origin') || '';
        const dest = card.getAttribute('data-dest') || '';
        const flight = card.getAttribute('data-flight') || '';
        const captain = card.getAttribute('data-captain') || '';
        const ff = card.getAttribute('data-ff') || '';

        const matchesCat = (currentCategory === 'all' || cat === currentCategory);
        const matchesQuery = (!query || origin.includes(query) || dest.includes(query) || flight.includes(query) || captain.includes(query) || ff.includes(query));

        if (matchesCat && matchesQuery) {
            card.style.display = '';
            visible++;
        } else {
            card.style.display = 'none';
        }
    });

    const countElem = document.getElementById('visibleFlightCount');
    if (countElem) {
        countElem.textContent = visible;
    }
}
</script>

<jsp:include page="/includes/footer.jsp" />
