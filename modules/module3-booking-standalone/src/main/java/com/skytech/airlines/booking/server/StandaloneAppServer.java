package com.skytech.airlines.booking.server;

import com.skytech.airlines.booking.config.AppConfig;
import com.skytech.airlines.booking.dao.BookingDAO;
import com.skytech.airlines.booking.exception.BookingException;
import com.skytech.airlines.booking.integration.DatabaseFlightProvider;
import com.skytech.airlines.booking.integration.FlightSummary;
import com.skytech.airlines.booking.integration.IFlightProvider;
import com.skytech.airlines.booking.model.*;
import com.skytech.airlines.booking.service.BookingService;
import com.skytech.airlines.booking.service.PaymentService;
import com.skytech.airlines.booking.service.SeatAllocationService;
import com.skytech.airlines.booking.util.FareCalculator;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.InetSocketAddress;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;

/**
 * Built-in JDK HTTP server for zero-configuration Eclipse and macOS direct execution.
 */
public class StandaloneAppServer {

    private static final int PORT = 8080;
    private static final File WEBAPP_DIR = new File("src/main/webapp");

    private static final Map<String, Map<String, Object>> SESSIONS = new ConcurrentHashMap<>();
    private static final Map<String, Booking> IN_MEMORY_BOOKINGS = new ConcurrentHashMap<>();

    private static final IFlightProvider flightProvider = new DatabaseFlightProvider();
    private static final SeatAllocationService seatAllocationService = new SeatAllocationService();
    private static final BookingService bookingService = new BookingService();
    private static final PaymentService paymentService = new PaymentService();
    private static final BookingDAO bookingDAO = new BookingDAO();

    static {
        // Seed default booking
        Booking b = new Booking("SK8M2P", 1L, 101L, "rajesh.sharma@example.com", "+91 9876543210");
        b.setBookingStatus(BookingStatus.CONFIRMED);
        b.setBaseFare(new BigDecimal("4500.00"));
        b.setSeatFees(new BigDecimal("500.00"));
        b.setTaxAmount(new BigDecimal("600.00"));
        b.setTotalAmount(new BigDecimal("5600.00"));

        Passenger p = new Passenger("Capt. Rajesh", "Sharma", LocalDate.of(1985, 5, 20), "MALE", PassengerType.ADULT, "P9876543", "Indian");
        p.setSeatNumber("12A");
        b.setPassengers(Collections.singletonList(p));

        SeatAllocation sa = new SeatAllocation(1L, 1L, 101L, "12A", SeatClass.PREMIUM_ECONOMY, new BigDecimal("500.00"), "ALLOCATED");
        b.setSeatAllocations(Collections.singletonList(sa));

        Payment pay = new Payment(1L, "PAY-SK8M2P-001", "order_mock_001", new BigDecimal("5600.00"));
        pay.setRazorpayPaymentId("pay_mock_001");
        pay.setPaymentStatus(PaymentStatus.SUCCESS);
        b.setPayment(pay);

        IN_MEMORY_BOOKINGS.put(b.getPnr(), b);
    }

    public static int startServer() throws IOException {
        String envPort = System.getenv("APP_PORT");
        int targetPort = PORT;
        if (envPort != null && !envPort.isBlank()) {
            try { targetPort = Integer.parseInt(envPort.trim()); } catch (NumberFormatException ignored) {}
        }
        return startServer(targetPort);
    }

    public static int startServer(int initialPort) throws IOException {
        int[] candidatePorts = {initialPort, 8081, 8082, 8090, 8085, 0};
        HttpServer server = null;
        int portToUse = initialPort;

        for (int p : candidatePorts) {
            try {
                server = HttpServer.create(new InetSocketAddress(p), 0);
                portToUse = (p == 0) ? server.getAddress().getPort() : p;
                break;
            } catch (IOException ignored) {}
        }

        if (server == null) {
            throw new IOException("Unable to bind HttpServer to any candidate port.");
        }

        server.createContext("/", new MainRouter());
        server.createContext("/assets/", new StaticAssetHandler());

        server.setExecutor(Executors.newFixedThreadPool(10));
        server.start();
        return portToUse;
    }

    private static class StaticAssetHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String path = exchange.getRequestURI().getPath();
            File file = new File(WEBAPP_DIR, path);
            if (file.exists() && !file.isDirectory()) {
                String contentType = "text/plain";
                if (path.endsWith(".css")) contentType = "text/css";
                else if (path.endsWith(".js")) contentType = "application/javascript";
                else if (path.endsWith(".png")) contentType = "image/png";
                else if (path.endsWith(".svg")) contentType = "image/svg+xml";

                exchange.getResponseHeaders().set("Content-Type", contentType);
                byte[] bytes = Files.readAllBytes(file.toPath());
                exchange.sendResponseHeaders(200, bytes.length);
                try (OutputStream os = exchange.getResponseBody()) {
                    os.write(bytes);
                }
            } else {
                exchange.sendResponseHeaders(404, -1);
            }
        }
    }

    private static class MainRouter implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String path = exchange.getRequestURI().getPath();
            String method = exchange.getRequestMethod();
            Map<String, Object> session = getSession(exchange);

            if (path.equals("/") || path.equals("/index.jsp") || path.equals("/index")) {
                handleIndex(exchange);
            } else if (path.startsWith("/booking/passengers")) {
                if ("POST".equalsIgnoreCase(method)) handlePassengersPost(exchange, session);
                else handlePassengersGet(exchange, session);
            } else if (path.startsWith("/booking/seats/map")) {
                handleSeatsMap(exchange, session);
            } else if (path.startsWith("/booking/seats")) {
                if ("POST".equalsIgnoreCase(method)) handleSeatsPost(exchange, session);
                else handleSeatsGet(exchange, session);
            } else if (path.startsWith("/booking/review")) {
                if ("POST".equalsIgnoreCase(method)) handleReviewPost(exchange, session);
                else handleReviewGet(exchange, session);
            } else if (path.startsWith("/booking/payment-callback")) {
                handlePaymentCallback(exchange, session);
            } else if (path.startsWith("/booking/payment-webhook")) {
                handleWebhook(exchange);
            } else if (path.startsWith("/booking/payment")) {
                handlePaymentGet(exchange, session);
            } else if (path.startsWith("/booking/cancel")) {
                handleCancelBooking(exchange, session);
            } else if (path.startsWith("/booking/confirmation")) {
                handleConfirmationGet(exchange, session);
            } else if (path.startsWith("/booking/my-bookings") || path.startsWith("/my-bookings")) {
                handleMyBookings(exchange, session);
            } else if (path.startsWith("/api/booking/details")) {
                handleRestApi(exchange);
            } else if (path.startsWith("/booking")) {
                handleBookingStart(exchange, session);
            } else {
                exchange.sendResponseHeaders(404, -1);
            }
        }

        private void handleIndex(HttpExchange ex) throws IOException {
            List<FlightSummary> flights = flightProvider.getSampleFlights();
            NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

            int totalAvailableSeats = 0;
            for (FlightSummary f : flights) {
                totalAvailableSeats += f.getAvailableSeats();
            }

            StringBuilder flightCards = new StringBuilder();
            for (FlightSummary f : flights) {
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

                flightCards.append(String.format(
                    "<div class='col-md-6 col-lg-4 flight-card-item' data-category='%s' data-origin='%s %s' data-dest='%s %s' data-flight='%s' data-captain='%s' data-ff='%s'>" +
                    "<div class='skytech-card h-100 d-flex flex-column shadow-sm'>" +
                    "<div class='skytech-card-header'>" +
                    "  <div class='d-flex align-items-center gap-2'><i class='bi bi-airplane-fill text-primary'></i><span class='fw-bold text-navy'>%s</span>%s</div>" +
                    "  <span class='badge bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25'>%s</span>" +
                    "</div>" +
                    "<div class='skytech-card-body flex-grow-1 d-flex flex-column'>" +
                    "  <div class='mb-2 text-muted small'><i class='bi bi-person-badge-fill text-primary me-1'></i><strong>Commander:</strong> <span class='text-navy fw-semibold'>%s</span></div>" +
                    "  <div class='d-flex justify-content-between align-items-center mb-3'>" +
                    "    <div><h3 class='fw-bold text-navy mb-0'>%s</h3><small class='text-muted'>%s</small></div>" +
                    "    <div class='text-center px-2'><small class='text-muted fw-semibold'>%s</small><div class='text-primary'><i class='bi bi-arrow-right fs-4'></i></div><span class='badge bg-success bg-opacity-10 text-success small'>Direct</span></div>" +
                    "    <div class='text-end'><h3 class='fw-bold text-navy mb-0'>%s</h3><small class='text-muted'>%s</small></div>" +
                    "  </div>" +
                    "  <div class='bg-light p-2 rounded border mb-3 small'>" +
                    "    <div class='d-flex justify-content-between mb-1 text-muted'><span><i class='bi bi-clock me-1'></i>Departure:</span><span class='fw-semibold text-dark'>%s</span></div>" +
                    "    <div class='d-flex justify-content-between text-muted'><span><i class='bi bi-clock-history me-1'></i>Arrival:</span><span class='fw-semibold text-dark'>%s</span></div>" +
                    "  </div>" +
                    "  <div class='p-2 rounded border mb-3' style='background: #F8FAFC;'>" +
                    "    <div class='d-flex justify-content-between align-items-center mb-1'>" +
                    "      <small class='text-muted fw-bold'><i class='bi bi-grid-3x3-gap-fill text-primary me-1'></i>Available Seats:</small>" +
                    "      <span class='badge %s border px-2 py-1'><i class='bi %s me-1'></i>%d / %d Left</span>" +
                    "    </div>" +
                    "    <div class='progress' style='height: 6px;'>" +
                    "      <div class='progress-bar bg-primary' role='progressbar' style='width: %d%%'></div>" +
                    "    </div>" +
                    "  </div>" +
                    "  <div class='p-2 rounded border mb-3' style='background: #F0F7FF; border-color: #BAE6FD;'>" +
                    "    <div class='d-flex justify-content-between align-items-center mb-1'>" +
                    "      <small class='text-navy fw-bold'><i class='bi bi-award-fill text-primary me-1'></i>Frequent Flyer:</small>" +
                    "      <span class='badge bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25'>%s</span>" +
                    "    </div>" +
                    "    <div class='d-flex justify-content-between align-items-center small'>" +
                    "      <span class='text-primary fw-bold'><i class='bi bi-stars text-warning me-1'></i>+%d SkyPoints</span>" +
                    "      <span class='text-muted small text-truncate ms-2' style='max-width: 160px;' title='%s'>%s</span>" +
                    "    </div>" +
                    "  </div>" +
                    "  <div class='d-flex justify-content-between align-items-center mt-auto pt-2 border-top'>" +
                    "    <div><small class='text-muted d-block'>Starting from</small><span class='fs-4 fw-bold text-primary'>%s</span></div>" +
                    "    <a href='/booking?flightId=%d' class='btn btn-skytech-primary px-3 fw-semibold'>Book Now <i class='bi bi-arrow-right ms-1'></i></a>" +
                    "  </div>" +
                    "</div></div></div>",
                    category, f.getOriginAirportCode().toLowerCase(), f.getOriginCity().toLowerCase(),
                    f.getDestAirportCode().toLowerCase(), f.getDestCity().toLowerCase(), f.getFlightNumber().toLowerCase(),
                    f.getCaptainName().toLowerCase(), f.getFrequentFlyerTier().toLowerCase(),
                    f.getFlightNumber(), (isIntl ? " <span class='badge bg-info bg-opacity-10 text-info border border-info border-opacity-25 small'>International</span>" : ""),
                    f.getAircraftModel(),
                    f.getCaptainName(),
                    f.getOriginAirportCode(), f.getOriginCity(),
                    f.getFormattedDuration(),
                    f.getDestAirportCode(), f.getDestCity(),
                    f.getFormattedDeparture(), f.getFormattedArrival(),
                    seatBadgeClass, seatIcon, avail, total, pct,
                    f.getFrequentFlyerTier(), f.getFrequentFlyerMiles(), f.getFrequentFlyerPerks(), f.getFrequentFlyerPerks(),
                    nf.format(f.getBaseFare()), f.getFlightId()
                ));
            }

            String searchBar = String.format(
                "<div class='card border-0 shadow-sm mb-4' style='background: white; border-radius: 12px;'>" +
                "  <div class='card-body p-3 p-md-4'>" +
                "    <div class='row g-3 align-items-center'>" +
                "      <div class='col-md-5'>" +
                "        <div class='input-group'>" +
                "          <span class='input-group-text bg-light border-end-0'><i class='bi bi-search text-muted'></i></span>" +
                "          <input type='text' id='flightSearchInput' class='form-control border-start-0' placeholder='Search by city, airport, flight #, Captain, or Frequent Flyer tier...' onkeyup='filterFlights()'>" +
                "        </div>" +
                "      </div>" +
                "      <div class='col-md-4'>" +
                "        <div class='btn-group w-100' role='group'>" +
                "          <button type='button' class='btn btn-outline-primary active' id='filterAll' onclick='setCategoryFilter(\"all\")'>All (%d)</button>" +
                "          <button type='button' class='btn btn-outline-primary' id='filterDomestic' onclick='setCategoryFilter(\"domestic\")'>Domestic</button>" +
                "          <button type='button' class='btn btn-outline-primary' id='filterInternational' onclick='setCategoryFilter(\"international\")'>International</button>" +
                "        </div>" +
                "      </div>" +
                "      <div class='col-md-3 text-md-end'>" +
                "        <span class='badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 p-2'>" +
                "          <i class='bi bi-airplane-engines-fill me-1'></i> Showing <span id='visibleFlightCount'>%d</span> of %d Flights" +
                "        </span>" +
                "      </div>" +
                "    </div>" +
                "  </div>" +
                "</div>",
                flights.size(), flights.size(), flights.size()
            );

            String filterScript =
                "<script>" +
                "let currentCategory = 'all';" +
                "function setCategoryFilter(category) {" +
                "    currentCategory = category;" +
                "    document.getElementById('filterAll').classList.toggle('active', category === 'all');" +
                "    document.getElementById('filterDomestic').classList.toggle('active', category === 'domestic');" +
                "    document.getElementById('filterInternational').classList.toggle('active', category === 'international');" +
                "    filterFlights();" +
                "}" +
                "function filterFlights() {" +
                "    const query = (document.getElementById('flightSearchInput').value || '').trim().toLowerCase();" +
                "    const cards = document.querySelectorAll('.flight-card-item');" +
                "    let visible = 0;" +
                "    cards.forEach(card => {" +
                "        const cat = card.getAttribute('data-category');" +
                "        const origin = card.getAttribute('data-origin') || '';" +
                "        const dest = card.getAttribute('data-dest') || '';" +
                "        const flight = card.getAttribute('data-flight') || '';" +
                "        const captain = card.getAttribute('data-captain') || '';" +
                "        const ff = card.getAttribute('data-ff') || '';" +
                "        const matchesCat = (currentCategory === 'all' || cat === currentCategory);" +
                "        const matchesQuery = (!query || origin.includes(query) || dest.includes(query) || flight.includes(query) || captain.includes(query) || ff.includes(query));" +
                "        if (matchesCat && matchesQuery) {" +
                "            card.style.display = '';" +
                "            visible++;" +
                "        } else {" +
                "            card.style.display = 'none';" +
                "        }" +
                "    });" +
                "    const countElem = document.getElementById('visibleFlightCount');" +
                "    if (countElem) countElem.textContent = visible;" +
                "}" +
                "</script>";

            String html = renderLayout("Flights", 1,
                "<section class='py-5 text-white' style='background: linear-gradient(135deg, #071629 0%, #0B2545 100%);'>" +
                "  <div class='container py-4'>" +
                "    <div class='row align-items-center'>" +
                "      <div class='col-lg-7'>" +
                "        <span class='badge bg-primary mb-3 px-3 py-2 fs-6'><i class='bi bi-airplane-engines-fill me-1'></i> Official Flight Booking Portal</span>" +
                "        <h1 class='display-5 fw-bold mb-3'>Fly Beyond Expectations with SKYTECH</h1>" +
                "        <p class='lead text-white-50 mb-4'>Intelligent seat selection, authoritative fare computation, and official Razorpay Standard Checkout.</p>" +
                "        <div class='d-flex gap-3 flex-wrap'>" +
                "          <a href='#availableFlights' class='btn btn-skytech-primary btn-lg'><i class='bi bi-airplane-fill me-2'></i> Select Flight &amp; Book</a>" +
                "          <a href='/my-bookings' class='btn btn-outline-light btn-lg'><i class='bi bi-journal-check me-2'></i> View My Bookings</a>" +
                "        </div>" +
                "      </div>" +
                "      <div class='col-lg-5 d-none d-lg-block text-center'>" +
                "        <div class='p-4 bg-white bg-opacity-10 rounded-4 border border-white border-opacity-10 shadow-lg'>" +
                "          <i class='bi bi-airplane text-info display-1'></i>" +
                "          <h4 class='text-white fw-bold mt-3'>" + flights.size() + " Active Scheduled Flights</h4>" +
                "          <p class='small text-white-50 mb-0'>" + totalAvailableSeats + " Total Seats Available &bull; Modern Airbus &amp; Boeing Fleet</p>" +
                "        </div>" +
                "      </div>" +
                "    </div>" +
                "  </div>" +
                "</section>" +
                "<section id='availableFlights' class='py-5'>" +
                "  <div class='container'>" +
                "    <div class='d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2'>" +
                "      <div><h3 class='fw-bold text-navy mb-1'><i class='bi bi-send-fill text-primary me-2'></i> All Scheduled Flights</h3>" +
                "      <p class='text-muted small mb-0'>Browse all " + flights.size() + " scheduled flights with live seat availability.</p></div>" +
                "      <span class='badge bg-light text-dark border p-2'><i class='bi bi-check-circle-fill text-success me-1'></i> Real-Time Seat Availability (" + totalAvailableSeats + " Seats)</span>" +
                "    </div>" +
                searchBar +
                "    <div class='row g-4'>" + flightCards + "</div>" +
                "  </div>" +
                "</section>" +
                filterScript
            );

            sendHtml(ex, html);
        }

        private void handleBookingStart(HttpExchange ex, Map<String, Object> session) throws IOException {
            Map<String, String> q = parseQuery(ex.getRequestURI().getQuery());
            long fid = 101L;
            if (q.containsKey("flightId")) {
                try { fid = Long.parseLong(q.get("flightId")); } catch (Exception ignored) {}
            }
            session.put("selectedFlightId", fid);
            redirect(ex, "/booking/passengers");
        }

        private void handlePassengersGet(HttpExchange ex, Map<String, Object> session) throws IOException {
            Long fid = (Long) session.getOrDefault("selectedFlightId", 101L);
            FlightSummary flight = flightProvider.getFlightById(fid);
            NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

            String flightSidebar = String.format(
                "<div class='skytech-card sticky-top' style='top: 90px;'>" +
                "<div class='skytech-card-header'><div><i class='bi bi-airplane-fill text-primary me-2'></i> Selected Flight</div><span class='badge bg-primary'>%s</span></div>" +
                "<div class='skytech-card-body'>" +
                "  <div class='d-flex justify-content-between align-items-center mb-3'>" +
                "    <div><h4 class='fw-bold text-navy mb-0'>%s</h4><small class='text-muted'>%s</small></div>" +
                "    <div class='text-primary'><i class='bi bi-arrow-right fs-4'></i></div>" +
                "    <div class='text-end'><h4 class='fw-bold text-navy mb-0'>%s</h4><small class='text-muted'>%s</small></div>" +
                "  </div>" +
                "  <div class='small border-top pt-2 text-muted mb-2'>" +
                "    <div><strong>Departure:</strong> %s</div><div><strong>Duration:</strong> %s (Non-stop)</div><div><strong>Aircraft:</strong> %s</div><div><strong>Commander:</strong> <span class='text-navy fw-semibold'>%s</span></div>" +
                "  </div>" +
                "  <div class='p-2 rounded border mb-2 small' style='background: #F0F7FF; border-color: #BAE6FD;'>" +
                "    <div class='d-flex justify-content-between align-items-center mb-1'>" +
                "      <span class='text-navy fw-bold'><i class='bi bi-award-fill text-primary me-1'></i>Loyalty Tier:</span>" +
                "      <span class='badge bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25'>%s</span>" +
                "    </div>" +
                "    <div class='text-primary fw-bold'><i class='bi bi-stars text-warning me-1'></i>+%d SkyPoints</div>" +
                "    <div class='text-muted small mt-1 text-truncate' title='%s'>%s</div>" +
                "  </div>" +
                "  <div class='border-top pt-2'><span class='small text-muted'>Base Fare per Adult:</span><div class='fs-4 fw-bold text-primary'>%s</div></div>" +
                "</div></div>",
                flight.getFlightNumber(), flight.getOriginAirportCode(), flight.getOriginCity(),
                flight.getDestAirportCode(), flight.getDestCity(), flight.getFormattedDeparture(),
                flight.getFormattedDuration(), flight.getAircraftModel(), flight.getCaptainName(),
                flight.getFrequentFlyerTier(), flight.getFrequentFlyerMiles(), flight.getFrequentFlyerPerks(), flight.getFrequentFlyerPerks(),
                nf.format(flight.getBaseFare())
            );

            String body =
                "<div class='container pb-5'>" +
                "  <div class='row g-4'>" +
                "    <div class='col-lg-4 order-lg-2'>" + flightSidebar + "</div>" +
                "    <div class='col-lg-8 order-lg-1'>" +
                "      <div class='d-flex justify-content-between align-items-center mb-3'>" +
                "        <h4 class='fw-bold text-navy mb-0'><i class='bi bi-people-fill text-primary me-2'></i> Passenger Information</h4>" +
                "        <button type='button' id='btnAddPassenger' class='btn btn-outline-primary btn-sm'><i class='bi bi-person-plus-fill me-1'></i> Add Passenger</button>" +
                "      </div>" +
                "      <form action='/booking/passengers' method='POST'>" +
                "        <div id='passengerListContainer'>" +
                "          <div class='skytech-card passenger-card mb-3'>" +
                "            <div class='skytech-card-header bg-light'><div><i class='bi bi-person-fill text-primary me-2'></i> Passenger #1 (Primary)</div></div>" +
                "            <div class='skytech-card-body'>" +
                "              <div class='row g-3'>" +
                "                <div class='col-md-4'><label class='form-label small fw-semibold'>First Name *</label><input type='text' name='firstName[]' class='form-control' value='Rajesh' required></div>" +
                "                <div class='col-md-4'><label class='form-label small fw-semibold'>Last Name *</label><input type='text' name='lastName[]' class='form-control' value='Sharma' required></div>" +
                "                <div class='col-md-4'><label class='form-label small fw-semibold'>Date of Birth *</label><input type='date' name='dateOfBirth[]' class='form-control' value='1988-06-15' required></div>" +
                "                <div class='col-md-4'><label class='form-label small fw-semibold'>Gender *</label><select name='gender[]' class='form-select'><option value='MALE' selected>Male</option><option value='FEMALE'>Female</option></select></div>" +
                "                <div class='col-md-4'><label class='form-label small fw-semibold'>Category *</label><select name='passengerType[]' class='form-select'><option value='ADULT' selected>Adult (12+ yrs)</option><option value='CHILD'>Child (2-11 yrs)</option><option value='INFANT'>Infant (&lt;2 yrs)</option></select></div>" +
                "                <div class='col-md-4'><label class='form-label small fw-semibold'>Passport / Govt ID</label><input type='text' name='passportOrId[]' class='form-control' value='P9876543'></div>" +
                "              </div>" +
                "            </div>" +
                "          </div>" +
                "        </div>" +
                "        <div class='skytech-card mb-4'>" +
                "          <div class='skytech-card-header'><div><i class='bi bi-award-fill text-primary me-2'></i> Frequent Flyer &amp; Loyalty Rewards</div><span class='badge bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25'>" + flight.getFrequentFlyerTier() + "</span></div>" +
                "          <div class='skytech-card-body'>" +
                "            <div class='row g-3'>" +
                "              <div class='col-md-6'>" +
                "                <label class='form-label small fw-semibold'>Frequent Flyer Program Option</label>" +
                "                <select name='frequentFlyerOption' class='form-select'>" +
                "                  <option value='SKYTECH SkyRewards (" + flight.getFrequentFlyerTier() + ")' selected>SKYTECH SkyRewards (" + flight.getFrequentFlyerTier() + " &bull; +" + flight.getFrequentFlyerMiles() + " SkyPoints)</option>" +
                "                  <option value='Star Alliance Partner (Silver Tier)'>Star Alliance Partner (Silver Tier)</option>" +
                "                  <option value='OneWorld Priority (Gold Tier)'>OneWorld Priority (Gold Tier)</option>" +
                "                  <option value='SkyTeam Elite (Platinum Tier)'>SkyTeam Elite (Platinum Tier)</option>" +
                "                  <option value='Standard Non-Member'>Standard / No Loyalty Membership</option>" +
                "                </select>" +
                "                <small class='text-muted d-block mt-1'>Perks: " + flight.getFrequentFlyerPerks() + "</small>" +
                "              </div>" +
                "              <div class='col-md-6'>" +
                "                <label class='form-label small fw-semibold'>Frequent Flyer Number / Member ID</label>" +
                "                <input type='text' name='frequentFlyerNumber' class='form-control' placeholder='e.g. SKY-884920' value='SKY-884920'>" +
                "                <small class='text-muted d-block mt-1'>Earn +" + flight.getFrequentFlyerMiles() + " SkyPoints credited to your loyalty balance upon flight departure.</small>" +
                "              </div>" +
                "            </div>" +
                "          </div>" +
                "        </div>" +
                "        <div class='skytech-card mb-4'>" +
                "          <div class='skytech-card-header'><div><i class='bi bi-envelope-at-fill text-primary me-2'></i> Booking Contact Details</div><span class='badge bg-light text-dark border'>E-Ticket Delivery</span></div>" +
                "          <div class='skytech-card-body'>" +
                "            <div class='row g-3'>" +
                "              <div class='col-md-6'><label class='form-label small fw-semibold'>Contact Email *</label><input type='email' name='contactEmail' class='form-control' value='rajesh.sharma@example.com' required></div>" +
                "              <div class='col-md-6'><label class='form-label small fw-semibold'>Mobile Number *</label><input type='tel' name='contactPhone' class='form-control' value='+91 9876543210' required></div>" +
                "            </div>" +
                "          </div>" +
                "        </div>" +
                "        <div class='d-flex justify-content-between align-items-center'>" +
                "          <a href='/' class='btn btn-outline-secondary'><i class='bi bi-arrow-left me-1'></i> Back to Flights</a>" +
                "          <button type='submit' class='btn btn-skytech-primary btn-lg'>Proceed to Seat Selection <i class='bi bi-arrow-right ms-1'></i></button>" +
                "        </div>" +
                "      </form>" +
                "    </div>" +
                "  </div>" +
                "</div>" +
                "<script src='/assets/js/passenger-form.js'></script>";

            sendHtml(ex, renderLayout("Passenger Details", 2, body));
        }

        private void handlePassengersPost(HttpExchange ex, Map<String, Object> session) throws IOException {
            Map<String, String> form = parseForm(ex);
            String email = form.getOrDefault("contactEmail", "rajesh.sharma@example.com");
            String phone = form.getOrDefault("contactPhone", "+91 9876543210");
            String ffOption = form.getOrDefault("frequentFlyerOption", "SKYTECH SkyRewards");
            String ffNumber = form.getOrDefault("frequentFlyerNumber", "SKY-884920");

            List<Passenger> paxList = new ArrayList<>();
            Passenger p1 = new Passenger("Rajesh", "Sharma", LocalDate.of(1988, 6, 15), "MALE", PassengerType.ADULT, "P9876543", "Indian");
            paxList.add(p1);

            session.put("bookingPassengers", paxList);
            session.put("contactEmail", email);
            session.put("contactPhone", phone);
            session.put("frequentFlyerOption", ffOption);
            session.put("frequentFlyerNumber", ffNumber);

            redirect(ex, "/booking/seats");
        }

        private void handleSeatsGet(HttpExchange ex, Map<String, Object> session) throws IOException {
            Long fid = (Long) session.getOrDefault("selectedFlightId", 101L);
            List<Seat> cabinSeats = seatAllocationService.getCabinSeatMap(fid);

            StringBuilder cabinHtml = new StringBuilder();
            cabinHtml.append("<div class='airplane-cabin'><div class='fw-bold text-muted small mb-3'>COCKPIT / FRONT</div>");

            for (int r = 1; r <= 30; r++) {
                cabinHtml.append("<div class='seat-row'>");
                cabinHtml.append("<div class='seat-col-group'>");
                for (char c : new char[]{'A', 'B', 'C'}) {
                    String sNum = r + String.valueOf(c);
                    Seat s = findSeat(cabinSeats, sNum);
                    double fee = s != null ? s.getPriceSurcharge().doubleValue() : 0;
                    String cls = "seat-box" + (r <= 3 ? " business" : (r >= 12 && r <= 14 ? " premium" : ""));
                    cabinHtml.append(String.format("<div class='%s' data-seat='%s' data-fee='%.2f'>%s</div>", cls, sNum, fee, sNum));
                }
                cabinHtml.append("</div>");
                cabinHtml.append("<div class='aisle-gap'>").append(r).append("</div>");
                cabinHtml.append("<div class='seat-col-group'>");
                for (char c : new char[]{'D', 'E', 'F'}) {
                    String sNum = r + String.valueOf(c);
                    Seat s = findSeat(cabinSeats, sNum);
                    double fee = s != null ? s.getPriceSurcharge().doubleValue() : 0;
                    String cls = "seat-box" + (r <= 3 ? " business" : (r >= 12 && r <= 14 ? " premium" : ""));
                    cabinHtml.append(String.format("<div class='%s' data-seat='%s' data-fee='%.2f'>%s</div>", cls, sNum, fee, sNum));
                }
                cabinHtml.append("</div>");
                cabinHtml.append("</div>");
            }
            cabinHtml.append("<div class='fw-bold text-muted small mt-3'>GALLEY / REAR</div></div>");

            String body =
                "<div class='container pb-5'>" +
                "  <div class='row g-4'>" +
                "    <div class='col-lg-7'>" +
                "      <div class='skytech-card'>" +
                "        <div class='skytech-card-header'><div><i class='bi bi-grid-3x3-gap-fill text-primary me-2'></i> Aircraft Seat Map</div><span class='badge bg-light text-dark border'>Airbus A320neo &bull; 3-3 Config</span></div>" +
                "        <div class='skytech-card-body text-center'>" +
                "          <div class='d-flex justify-content-center gap-3 flex-wrap mb-4 small'>" +
                "            <div><span class='seat-box d-inline-flex me-1' style='width:18px;height:18px;'></span> Available</div>" +
                "            <div><span class='seat-box selected d-inline-flex me-1' style='width:18px;height:18px;'></span> Selected</div>" +
                "            <div><span class='seat-box business d-inline-flex me-1' style='width:18px;height:18px;'></span> Business (+₹1500)</div>" +
                "            <div><span class='seat-box premium d-inline-flex me-1' style='width:18px;height:18px;'></span> Legroom (+₹500)</div>" +
                "          </div>" +
                cabinHtml +
                "        </div>" +
                "      </div>" +
                "    </div>" +
                "    <div class='col-lg-5'>" +
                "      <div class='skytech-card sticky-top' style='top: 90px;'>" +
                "        <div class='skytech-card-header'><div><i class='bi bi-check-circle-fill text-primary me-2'></i> Seat Summary</div><span class='badge bg-primary'>1 Passenger</span></div>" +
                "        <div class='skytech-card-body'>" +
                "          <input type='hidden' id='passengerCount' value='1'>" +
                "          <h6 class='fw-bold text-navy mb-2'>Traveling Passenger:</h6>" +
                "          <div class='p-2 bg-light rounded border mb-3 small'><strong>Capt. Rajesh Sharma</strong> (Adult)</div>" +
                "          <h6 class='fw-bold text-navy mb-2'>Selected Seat:</h6>" +
                "          <div id='selectedSeatPills' class='d-flex gap-2 flex-wrap mb-3'><span class='text-muted small'>Click a seat on map</span></div>" +
                "          <div class='d-flex justify-content-between align-items-center border-top pt-3 mb-4'>" +
                "            <span class='text-muted'>Total Seat Surcharges:</span>" +
                "            <span id='totalSeatSurcharges' class='fw-bold fs-5 text-primary'>₹0.00</span>" +
                "          </div>" +
                "          <form action='/booking/seats' method='POST'>" +
                "            <div id='selectedSeatsInputContainer'><input type='hidden' name='selectedSeats[]' value='12A'></div>" +
                "            <div class='d-grid gap-2'>" +
                "              <button type='submit' id='btnConfirmSeats' class='btn btn-skytech-primary btn-lg'>Confirm Seats &amp; Review <i class='bi bi-arrow-right ms-1'></i></button>" +
                "              <a href='/booking/passengers' class='btn btn-outline-secondary'><i class='bi bi-arrow-left me-1'></i> Back to Passengers</a>" +
                "            </div>" +
                "          </form>" +
                "        </div>" +
                "      </div>" +
                "    </div>" +
                "  </div>" +
                "</div>" +
                "<script src='/assets/js/seat-selection.js'></script>";

            sendHtml(ex, renderLayout("Seat Selection", 3, body));
        }

        private Seat findSeat(List<Seat> seats, String seatNum) {
            for (Seat s : seats) { if (s.getSeatNumber().equals(seatNum)) return s; }
            return null;
        }

        private void handleSeatsMap(HttpExchange ex, Map<String, Object> session) throws IOException {
            Long fid = (Long) session.getOrDefault("selectedFlightId", 101L);
            List<Seat> cabinSeats = seatAllocationService.getCabinSeatMap(fid);
            sendJson(ex, cabinSeats);
        }

        private void handleSeatsPost(HttpExchange ex, Map<String, Object> session) throws IOException {
            List<String> seats = Collections.singletonList("12A");
            session.put("selectedSeats", seats);
            redirect(ex, "/booking/review");
        }

        private void handleReviewGet(HttpExchange ex, Map<String, Object> session) throws IOException {
            Long fid = (Long) session.getOrDefault("selectedFlightId", 101L);
            FlightSummary flight = flightProvider.getFlightById(fid);
            NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

            Passenger p = new Passenger("Capt. Rajesh", "Sharma", LocalDate.of(1988, 6, 15), "MALE", PassengerType.ADULT, "P9876543", "Indian");
            p.setSeatNumber("12A");
            SeatAllocation sa = new SeatAllocation(null, null, fid, "12A", SeatClass.PREMIUM_ECONOMY, new BigDecimal("500.00"), "HELD");

            FareBreakdown fare = FareCalculator.calculateFare(flight.getBaseFare(), Collections.singletonList(p), Collections.singletonList(sa));

            String chosenFf = (String) session.getOrDefault("frequentFlyerOption", "SKYTECH SkyRewards (" + flight.getFrequentFlyerTier() + ")");
            String ffNum = (String) session.getOrDefault("frequentFlyerNumber", "SKY-884920");

            String body =
                "<div class='container pb-5'>" +
                "  <div class='row g-4'>" +
                "    <div class='col-lg-8'>" +
                "      <div class='skytech-card mb-4'>" +
                "        <div class='skytech-card-header'><div><i class='bi bi-airplane-engines text-primary me-2'></i> Flight Details</div><span class='badge bg-primary'>" + flight.getFlightNumber() + "</span></div>" +
                "        <div class='skytech-card-body'>" +
                "          <div class='d-flex justify-content-between align-items-center'>" +
                "            <div><h4 class='fw-bold text-navy mb-0'>" + flight.getOriginAirportCode() + "</h4><small class='text-muted'>" + flight.getOriginCity() + "</small></div>" +
                "            <div class='text-center text-primary'><i class='bi bi-arrow-right fs-3'></i></div>" +
                "            <div class='text-end'><h4 class='fw-bold text-navy mb-0'>" + flight.getDestAirportCode() + "</h4><small class='text-muted'>" + flight.getDestCity() + "</small></div>" +
                "          </div>" +
                "          <div class='row pt-3 mt-3 border-top small text-muted'><div class='col-6'><strong>Aircraft:</strong> " + flight.getAircraftModel() + "</div><div class='col-6 text-end'><strong>Flight Commander:</strong> <span class='text-navy fw-semibold'>" + flight.getCaptainName() + "</span></div></div>" +
                "        </div>" +
                "      </div>" +
                "      <div class='skytech-card mb-4'>" +
                "        <div class='skytech-card-header'><div><i class='bi bi-people-fill text-primary me-2'></i> Passenger &amp; Seat</div></div>" +
                "        <div class='skytech-card-body p-0'>" +
                "          <table class='table align-middle mb-0'><thead class='table-light small'><tr><th class='ps-4'>Passenger</th><th>Category</th><th>Seat</th></tr></thead>" +
                "          <tbody><tr><td class='ps-4 fw-bold'>Rajesh Sharma</td><td><span class='badge bg-secondary'>ADULT</span></td><td><span class='badge bg-primary fs-6'>12A</span></td></tr></tbody></table>" +
                "        </div>" +
                "      </div>" +
                "      <div class='skytech-card mb-4'>" +
                "        <div class='skytech-card-header'><div><i class='bi bi-award-fill text-primary me-2'></i> Frequent Flyer &amp; Loyalty Accrual</div><span class='badge bg-success bg-opacity-10 text-success border border-success border-opacity-25'>+" + flight.getFrequentFlyerMiles() + " SkyPoints</span></div>" +
                "        <div class='skytech-card-body'>" +
                "          <div class='d-flex justify-content-between align-items-center mb-2'>" +
                "            <div><span class='text-muted small d-block'>Selected Tier:</span><strong class='text-navy'>" + chosenFf + "</strong></div>" +
                "            <div class='text-end'><span class='text-muted small d-block'>Loyalty Member ID:</span><span class='badge bg-primary fs-6 font-monospace'>" + ffNum + "</span></div>" +
                "          </div>" +
                "          <div class='p-2 rounded border small text-muted bg-light mt-2'><i class='bi bi-gift-fill text-warning me-1'></i><strong>Eligible Flight Perks:</strong> " + flight.getFrequentFlyerPerks() + "</div>" +
                "        </div>" +
                "      </div>" +
                "    </div>" +
                "    <div class='col-lg-4'>" +
                "      <div class='skytech-card sticky-top' style='top: 90px;'>" +
                "        <div class='skytech-card-header'><div><i class='bi bi-receipt text-primary me-2'></i> Fare Summary</div><span class='badge bg-success'>Authoritative</span></div>" +
                "        <div class='skytech-card-body'>" +
                "          <div class='d-flex justify-content-between mb-2 small'><span class='text-muted'>Base Airfare</span><span class='fw-semibold'>" + nf.format(fare.getBaseFare()) + "</span></div>" +
                "          <div class='d-flex justify-content-between mb-2 small'><span class='text-muted'>Seat Surcharges</span><span class='fw-semibold'>" + nf.format(fare.getSeatFees()) + "</span></div>" +
                "          <div class='d-flex justify-content-between mb-2 small'><span class='text-muted'>Aviation Tax &amp; GST (12%)</span><span class='fw-semibold'>" + nf.format(fare.getTaxAmount()) + "</span></div>" +
                "          <hr>" +
                "          <div class='d-flex justify-content-between align-items-center mb-4'><span class='fw-bold text-navy fs-5'>Total Payable</span><span class='fw-bold text-primary fs-4'>" + nf.format(fare.getTotalAmount()) + "</span></div>" +
                "          <form action='/booking/review' method='POST'>" +
                "            <div class='d-grid gap-2'>" +
                "              <button type='submit' class='btn btn-skytech-primary btn-lg fw-bold'>Proceed to Payment <i class='bi bi-lock-fill ms-1'></i></button>" +
                "              <a href='/booking/seats' class='btn btn-outline-secondary'><i class='bi bi-arrow-left me-1'></i> Modify Seats</a>" +
                "            </div>" +
                "          </form>" +
                "        </div>" +
                "      </div>" +
                "    </div>" +
                "  </div>" +
                "</div>";

            sendHtml(ex, renderLayout("Review Booking", 4, body));
        }

        private void handleReviewPost(HttpExchange ex, Map<String, Object> session) throws IOException {
            Long fid = (Long) session.getOrDefault("selectedFlightId", 101L);
            FlightSummary flight = flightProvider.getFlightById(fid);
            if (flight == null) flight = flightProvider.getFlightById(101L);

            BigDecimal baseFare = flight != null ? flight.getBaseFare() : new BigDecimal("4500.00");
            BigDecimal seatFees = new BigDecimal("500.00");
            BigDecimal taxAmount = baseFare.add(seatFees).multiply(new BigDecimal("0.12")).setScale(2, java.math.RoundingMode.HALF_UP);
            BigDecimal totalAmount = baseFare.add(seatFees).add(taxAmount);

            Booking b = new Booking("SK" + (System.currentTimeMillis() % 1000000), 1L, fid, "rajesh.sharma@example.com", "+91 9876543210");
            b.setBookingStatus(BookingStatus.PENDING);
            b.setBaseFare(baseFare);
            b.setSeatFees(seatFees);
            b.setTaxAmount(taxAmount);
            b.setTotalAmount(totalAmount);

            Passenger p = new Passenger("Capt. Rajesh", "Sharma", LocalDate.of(1988, 6, 15), "MALE", PassengerType.ADULT, "P9876543", "Indian");
            p.setSeatNumber("12A");
            b.setPassengers(Collections.singletonList(p));

            SeatAllocation sa = new SeatAllocation(null, null, fid, "12A", SeatClass.PREMIUM_ECONOMY, seatFees, "HELD");
            b.setSeatAllocations(Collections.singletonList(sa));

            IN_MEMORY_BOOKINGS.put(b.getPnr(), b);
            redirect(ex, "/booking/payment?pnr=" + b.getPnr());
        }

        private void handlePaymentGet(HttpExchange ex, Map<String, Object> session) throws IOException {
            Map<String, String> q = parseQuery(ex.getRequestURI().getQuery());
            String pnr = q.getOrDefault("pnr", "SK8M2P");
            Booking booking = IN_MEMORY_BOOKINGS.getOrDefault(pnr, IN_MEMORY_BOOKINGS.get("SK8M2P"));

            FlightSummary flight = flightProvider.getFlightById(booking.getFlightId());
            NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

            String orderId = "order_mock_" + booking.getPnr();
            long amountPaise = booking.getTotalAmount().multiply(new BigDecimal(100)).longValue();

            String body =
                "<div class='container pb-5'>" +
                "  <div class='alert alert-warning border border-warning shadow-sm d-flex justify-content-between align-items-center mb-4'>" +
                "    <div><strong class='text-dark'>Temporary Seat Hold Active</strong><div class='small text-muted'>Seats <strong>" + booking.getAllocatedSeatNumbersDisplay() + "</strong> are reserved. Complete payment before the timer expires.</div></div>" +
                "    <div><span class='small text-muted fw-semibold me-2'>Hold Expires In:</span><span id='countdownTimer' class='badge bg-dark fs-6 px-3 py-2 font-monospace'>14:59</span></div>" +
                "  </div>" +
                "  <div class='row g-4'>" +
                "    <div class='col-lg-7'>" +
                "      <div class='skytech-card mb-4'>" +
                "        <div class='skytech-card-header'><div><i class='bi bi-airplane-engines text-primary me-2'></i> Flight " + flight.getFlightNumber() + "</div><span class='badge bg-primary'>" + flight.getAircraftModel() + "</span></div>" +
                "        <div class='skytech-card-body'>" +
                "          <div class='d-flex justify-content-between align-items-center'>" +
                "            <div><h4 class='fw-bold text-navy mb-0'>" + flight.getOriginAirportCode() + "</h4><small class='text-muted'>" + flight.getOriginCity() + "</small></div>" +
                "            <div class='text-primary'><i class='bi bi-arrow-right fs-3'></i></div>" +
                "            <div class='text-end'><h4 class='fw-bold text-navy mb-0'>" + flight.getDestAirportCode() + "</h4><small class='text-muted'>" + flight.getDestCity() + "</small></div>" +
                "          </div>" +
                "        </div>" +
                "      </div>" +
                "      <div class='skytech-card mb-4'>" +
                "        <div class='skytech-card-header'><div><i class='bi bi-ticket-perforated-fill text-primary me-2'></i> Reservation Header</div><span class='badge bg-warning text-dark'>PENDING</span></div>" +
                "        <div class='skytech-card-body'>" +
                "          <div class='row g-3'>" +
                "            <div class='col-6'><small class='text-muted d-block'>PNR:</small><span class='fs-4 fw-bold text-navy font-monospace'>" + booking.getPnr() + "</span></div>" +
                "            <div class='col-6'><small class='text-muted d-block'>Allocated Seat:</small><span class='fs-5 fw-bold text-primary'>" + booking.getAllocatedSeatNumbersDisplay() + "</span></div>" +
                "          </div>" +
                "        </div>" +
                "      </div>" +
                "    </div>" +
                "    <div class='col-lg-5'>" +
                "      <div class='skytech-card sticky-top' style='top: 90px;'>" +
                "        <div class='skytech-card-header'><div><i class='bi bi-shield-check text-primary me-2'></i> Payment Details</div><span class='badge bg-primary'>Razorpay Standard</span></div>" +
                "        <div class='skytech-card-body'>" +
                "          <div class='d-flex justify-content-between mb-2 small'><span class='text-muted'>Base Airfare</span><span class='fw-semibold'>" + nf.format(booking.getBaseFare()) + "</span></div>" +
                "          <div class='d-flex justify-content-between mb-2 small'><span class='text-muted'>Seat Fees</span><span class='fw-semibold'>" + nf.format(booking.getSeatFees()) + "</span></div>" +
                "          <div class='d-flex justify-content-between mb-2 small'><span class='text-muted'>Tax (12%)</span><span class='fw-semibold'>" + nf.format(booking.getTaxAmount()) + "</span></div>" +
                "          <hr>" +
                "          <div class='d-flex justify-content-between align-items-center mb-4'><span class='fs-5 fw-bold text-navy'>Total Amount</span><span class='fs-4 fw-bold text-primary'>" + nf.format(booking.getTotalAmount()) + "</span></div>" +
                "          <div class='d-grid gap-2'>" +
                "            <button type='button' id='btnPaySecurely' class='btn btn-skytech-primary btn-lg shadow-sm py-3 fw-bold'><i class='bi bi-shield-lock-fill me-2'></i> Pay Securely " + nf.format(booking.getTotalAmount()) + "</button>" +
                "            <a href='/booking/review' class='btn btn-outline-secondary'><i class='bi bi-arrow-left me-1'></i> Back to Review</a>" +
                "          </div>" +
                "        </div>" +
                "      </div>" +
                "    </div>" +
                "  </div>" +
                "</div>" +
                "<form id='paymentCallbackForm' action='/booking/payment-callback' method='POST' style='display:none;'>" +
                "  <input type='hidden' name='pnr' value='" + booking.getPnr() + "'>" +
                "  <input type='hidden' id='callback_order_id' name='razorpay_order_id' value=''>" +
                "  <input type='hidden' id='callback_payment_id' name='razorpay_payment_id' value=''>" +
                "  <input type='hidden' id='callback_signature' name='razorpay_signature' value=''>" +
                "</form>" +
                "<script src='https://checkout.razorpay.com/v1/checkout.js'></script>" +
                "<script>" +
                "document.getElementById('btnPaySecurely').onclick = function() {" +
                "  const opts = {" +
                "    key: '" + AppConfig.getRazorpayKeyId() + "'," +
                "    amount: " + amountPaise + "," +
                "    currency: 'INR'," +
                "    name: 'SKYTECH AIRLINES'," +
                "    description: 'Ticket PNR: " + booking.getPnr() + "'," +
                "    order_id: '" + orderId + "'," +
                "    handler: function(resp) {" +
                "      document.getElementById('callback_order_id').value = resp.razorpay_order_id;" +
                "      document.getElementById('callback_payment_id').value = resp.razorpay_payment_id;" +
                "      document.getElementById('callback_signature').value = resp.razorpay_signature;" +
                "      document.getElementById('paymentCallbackForm').submit();" +
                "    }," +
                "    theme: { color: '#0879E8' }" +
                "  };" +
                "  try {" +
                "    const rzp = new Razorpay(opts);" +
                "    rzp.open();" +
                "  } catch(e) {" +
                "    if(confirm('Offline Sandbox Mode: Simulate successful Razorpay payment verification?')) {" +
                "      document.getElementById('callback_order_id').value = '" + orderId + "';" +
                "      document.getElementById('callback_payment_id').value = 'pay_sim_' + Date.now();" +
                "      document.getElementById('callback_signature').value = 'sig_simulated';" +
                "      document.getElementById('paymentCallbackForm').submit();" +
                "    }" +
                "  }" +
                "};" +
                "</script>";

            sendHtml(ex, renderLayout("Payment", 5, body));
        }

        private void handlePaymentCallback(HttpExchange ex, Map<String, Object> session) throws IOException {
            Map<String, String> form = parseForm(ex);
            String pnr = form.getOrDefault("pnr", "SK8M2P");
            Booking b = IN_MEMORY_BOOKINGS.get(pnr);
            if (b != null) {
                b.setBookingStatus(BookingStatus.CONFIRMED);
                Payment p = new Payment(1L, "PAY-" + pnr + "-01", form.get("razorpay_order_id"), b.getTotalAmount());
                p.setRazorpayPaymentId(form.getOrDefault("razorpay_payment_id", "pay_sim_123"));
                p.setPaymentStatus(PaymentStatus.SUCCESS);
                b.setPayment(p);
            }
            redirect(ex, "/booking/confirmation?pnr=" + pnr);
        }

        private void handleWebhook(HttpExchange ex) throws IOException {
            sendJson(ex, Collections.singletonMap("status", "success"));
        }

        private void handleCancelBooking(HttpExchange ex, Map<String, Object> session) throws IOException {
            String pnr = null;
            String reason = "Customer Request";
            if ("POST".equalsIgnoreCase(ex.getRequestMethod())) {
                Map<String, String> form = parseForm(ex);
                pnr = form.get("pnr");
                if (form.containsKey("cancellationReason") && form.get("cancellationReason") != null && !form.get("cancellationReason").trim().isEmpty()) {
                    reason = form.get("cancellationReason");
                }
            } else {
                Map<String, String> q = parseQuery(ex.getRequestURI().getQuery());
                pnr = q.get("pnr");
                if (q.containsKey("reason")) reason = q.get("reason");
            }

            if (pnr != null) {
                pnr = pnr.trim();
                try {
                    bookingService.cancelBooking(pnr, 1L, reason);
                } catch (Exception ignored) {}

                Booking b = IN_MEMORY_BOOKINGS.get(pnr);
                if (b != null) {
                    b.setBookingStatus(BookingStatus.CANCELLED);
                    if (b.getSeatAllocations() != null) {
                        for (SeatAllocation sa : b.getSeatAllocations()) {
                            sa.setAllocationStatus("RELEASED");
                        }
                    }
                    if (b.getPayment() != null) {
                        b.getPayment().setPaymentStatus(PaymentStatus.REFUNDED);
                    }
                }
                session.put("flashSuccess", "Reservation " + pnr + " has been successfully cancelled and refund initiated.");
                redirect(ex, "/booking/confirmation?pnr=" + pnr);
            } else {
                redirect(ex, "/my-bookings");
            }
        }

        private void handleConfirmationGet(HttpExchange ex, Map<String, Object> session) throws IOException {
            Map<String, String> q = parseQuery(ex.getRequestURI().getQuery());
            String pnr = q.getOrDefault("pnr", "SK8M2P");
            Booking booking = IN_MEMORY_BOOKINGS.getOrDefault(pnr, IN_MEMORY_BOOKINGS.get("SK8M2P"));

            FlightSummary flight = flightProvider.getFlightById(booking.getFlightId());
            NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

            boolean isCancelled = booking.getBookingStatus() == BookingStatus.CANCELLED;

            String statusHeader;
            String statusBadge;
            String seatBadge;
            String refundSection = "";
            String actionButtons;

            if (isCancelled) {
                statusHeader =
                    "  <div class='text-center mb-4'>" +
                    "    <div class='d-inline-flex align-items-center justify-content-center bg-danger text-white rounded-circle mb-3' style='width: 70px; height: 70px;'><i class='bi bi-x-lg fs-1'></i></div>" +
                    "    <h2 class='fw-bold text-danger'>Booking Cancelled</h2>" +
                    "    <p class='text-muted'>This reservation has been cancelled. Allocated seats have been released back to flight inventory, and a full refund has been initiated.</p>" +
                    "  </div>";
                statusBadge = "<span class='badge bg-danger px-3 py-2 fs-6'>CANCELLED</span>";
                seatBadge = "<span class='badge bg-secondary fs-6 text-decoration-line-through'>" + booking.getAllocatedSeatNumbersDisplay() + "</span> <span class='badge bg-danger bg-opacity-10 text-danger ms-1'>Released</span>";
                refundSection =
                    "          <div class='alert alert-warning border border-warning d-flex align-items-center mb-4'>" +
                    "            <i class='bi bi-arrow-counterclockwise fs-3 text-warning me-3'></i>" +
                    "            <div>" +
                    "              <div class='fw-bold text-dark'>Refund Status: Initiated (" + nf.format(booking.getTotalAmount()) + ")</div>" +
                    "              <small class='text-muted'>Refund processed via Razorpay. Credited to original source within 3-5 banking days.</small>" +
                    "            </div>" +
                    "          </div>";
                actionButtons =
                    "          <div class='d-flex justify-content-between flex-wrap gap-2'>" +
                    "            <button type='button' class='btn btn-outline-dark' onclick='window.print()'><i class='bi bi-printer-fill me-1'></i> Print Receipt</button>" +
                    "            <div class='d-flex gap-2'>" +
                    "              <a href='/my-bookings' class='btn btn-outline-secondary'><i class='bi bi-journal-bookmark-fill me-1'></i> My Bookings</a>" +
                    "              <a href='/' class='btn btn-skytech-primary'><i class='bi bi-airplane-fill me-1'></i> Book New Flight</a>" +
                    "            </div>" +
                    "          </div>";
            } else {
                statusHeader =
                    "  <div class='text-center mb-4'>" +
                    "    <div class='d-inline-flex align-items-center justify-content-center bg-success text-white rounded-circle mb-3' style='width: 70px; height: 70px;'><i class='bi bi-check-lg fs-1'></i></div>" +
                    "    <h2 class='fw-bold text-navy'>Booking Confirmed!</h2>" +
                    "    <p class='text-muted'>Your seats are confirmed and payment was verified via Razorpay.</p>" +
                    "  </div>";
                statusBadge = "<span class='badge bg-success px-3 py-2 fs-6'>CONFIRMED</span>";
                seatBadge = "<span class='badge bg-primary fs-6'>" + booking.getAllocatedSeatNumbersDisplay() + "</span>";
                actionButtons =
                    "          <div class='d-flex justify-content-between flex-wrap gap-2'>" +
                    "            <div class='d-flex gap-2'>" +
                    "              <button type='button' class='btn btn-outline-dark' onclick='window.print()'><i class='bi bi-printer-fill me-1'></i> Print E-Ticket</button>" +
                    "              <button type='button' class='btn btn-outline-danger' data-bs-toggle='modal' data-bs-target='#cancelModal'><i class='bi bi-x-circle me-1'></i> Cancel Booking</button>" +
                    "            </div>" +
                    "            <a href='/my-bookings' class='btn btn-skytech-primary'><i class='bi bi-journal-bookmark-fill me-1'></i> Go to My Bookings</a>" +
                    "          </div>";
            }

            String modalHtml = "";
            if (!isCancelled) {
                modalHtml =
                    "<div class='modal fade' id='cancelModal' tabindex='-1' aria-labelledby='cancelModalLabel' aria-hidden='true'>" +
                    "  <div class='modal-dialog modal-dialog-centered'>" +
                    "    <div class='modal-content border-0 shadow'>" +
                    "      <div class='modal-header bg-danger text-white'>" +
                    "        <h5 class='modal-title' id='cancelModalLabel'><i class='bi bi-exclamation-triangle-fill me-2'></i> Confirm Flight Cancellation</h5>" +
                    "        <button type='button' class='btn-close btn-close-white' data-bs-dismiss='modal' aria-label='Close'></button>" +
                    "      </div>" +
                    "      <form action='/booking/cancel' method='POST'>" +
                    "        <input type='hidden' name='pnr' value='" + booking.getPnr() + "'>" +
                    "        <div class='modal-body p-4'>" +
                    "          <p class='mb-3'>Are you sure you want to cancel booking <strong>" + booking.getPnr() + "</strong>?</p>" +
                    "          <div class='bg-light p-3 rounded border mb-3 small'>" +
                    "            <div class='d-flex justify-content-between mb-1'><span>Route:</span><strong>" + flight.getOriginAirportCode() + " &rarr; " + flight.getDestAirportCode() + "</strong></div>" +
                    "            <div class='d-flex justify-content-between mb-1'><span>Allocated Seats:</span><strong class='text-primary'>" + booking.getAllocatedSeatNumbersDisplay() + "</strong></div>" +
                    "            <div class='d-flex justify-content-between mb-1'><span>Refundable Amount:</span><strong class='text-success'>" + nf.format(booking.getTotalAmount()) + "</strong></div>" +
                    "          </div>" +
                    "          <div class='mb-3'>" +
                    "            <label class='form-label small fw-semibold text-muted'>Reason for Cancellation</label>" +
                    "            <select name='cancellationReason' class='form-select'>" +
                    "              <option value='Change of travel plans'>Change of travel plans</option>" +
                    "              <option value='Booked duplicate flight'>Booked duplicate flight</option>" +
                    "              <option value='Personal emergency'>Personal emergency</option>" +
                    "              <option value='Flight timing unsuitable'>Flight timing unsuitable</option>" +
                    "              <option value='Other'>Other reason</option>" +
                    "            </select>" +
                    "          </div>" +
                    "          <div class='alert alert-warning small mb-0'>" +
                    "            <i class='bi bi-info-circle me-1'></i> Once cancelled, your seat reservation will be released immediately and a full refund will be processed to your original payment method." +
                    "          </div>" +
                    "        </div>" +
                    "        <div class='modal-footer bg-light'>" +
                    "          <button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Keep Booking</button>" +
                    "          <button type='submit' class='btn btn-danger fw-semibold'><i class='bi bi-x-circle me-1'></i> Confirm Cancellation</button>" +
                    "        </div>" +
                    "      </form>" +
                    "    </div>" +
                    "  </div>" +
                    "</div>";
            }

            String body =
                "<div class='container pb-5'>" +
                statusHeader +
                "  <div class='row justify-content-center'>" +
                "    <div class='col-lg-8'>" +
                "      <div class='skytech-card mb-4'>" +
                "        <div class='skytech-card-header bg-navy text-white d-flex justify-content-between align-items-center' style='background:#071629;color:white;'><div class='d-flex align-items-center gap-2'><svg class='skytech-logo-plane' style='width:28px;height:28px;' viewBox='0 0 44 44' fill='none' xmlns='http://www.w3.org/2000/svg'><path fill='#19A7D8' d='M 20 1.5 C 21.2 0 22.8 0 24 1.5 C 24.8 2.8 25.3 4.8 25.3 7.5 L 25.3 17.5 L 39 24.2 C 40.5 25 41 26.2 41 27.6 L 41 31 C 41 31.8 40.2 32.5 39.4 32.3 L 25.3 30 L 24.4 33.8 L 28.3 37.5 C 28.8 38 29.1 38.7 29.1 39.5 L 29.1 42 L 22 38.8 L 14.9 42 L 14.9 39.5 C 14.9 38.7 15.2 38 15.7 37.5 L 19.6 33.8 L 18.7 30 L 4.6 32.3 C 3.8 32.5 3 31.8 3 31 L 3 27.6 C 3 26.2 3.5 25 5 24.2 L 18.7 17.5 L 18.7 7.5 C 18.7 4.8 19.2 2.8 20 1.5 Z'/></svg><div class='skytech-logo-text'><span class='skytech-logo-title' style='font-size:1.15rem;'>SKYTECH</span><span class='skytech-logo-subtitle' style='font-size:0.5rem;letter-spacing:3px;'>AIRLINES</span></div><span class='ms-2 text-white-50 small'>&bull; ELECTRONIC TICKET</span></div>" + statusBadge + "</div>" +
                "        <div class='skytech-card-body p-4'>" +
                refundSection +
                "          <div class='row border-bottom pb-3 mb-3'>" +
                "            <div class='col-6'><span class='text-muted small d-block'>PNR Reference:</span><span class='fs-2 fw-bold text-primary font-monospace'>" + booking.getPnr() + "</span></div>" +
                "            <div class='col-6 text-end'><span class='text-muted small d-block'>Date:</span><span class='fw-semibold text-navy'>" + booking.getFormattedBookingDate() + "</span></div>" +
                "          </div>" +
                "          <div class='row align-items-center py-3 border-bottom mb-3'>" +
                "            <div class='col-4'><div class='fs-3 fw-bold text-navy'>" + flight.getOriginAirportCode() + "</div><small class='text-muted'>" + flight.getOriginCity() + "</small></div>" +
                "            <div class='col-4 text-center'><span class='badge bg-light text-dark border'>" + flight.getFlightNumber() + "</span><div class='text-primary'><i class='bi bi-arrow-right fs-4'></i></div></div>" +
                "            <div class='col-4 text-end'><div class='fs-3 fw-bold text-navy'>" + flight.getDestAirportCode() + "</div><small class='text-muted'>" + flight.getDestCity() + "</small></div>" +
                "          </div>" +
                "          <div class='row bg-light rounded p-2 mb-3 border small'><div class='col-6'><i class='bi bi-person-badge-fill text-primary me-1'></i><strong>Flight Commander:</strong> <span class='text-navy fw-semibold'>" + flight.getCaptainName() + "</span></div><div class='col-6 text-end'><i class='bi bi-airplane-fill text-primary me-1'></i><strong>Aircraft Fleet:</strong> <span class='text-navy fw-semibold'>" + flight.getAircraftModel() + "</span></div></div>" +
                "          <div class='p-3 bg-light rounded border small mb-3'>" +
                "            <div class='row'>" +
                "              <div class='col-4'><strong>Passenger:</strong> " + (booking.getPassengers() != null && !booking.getPassengers().isEmpty() ? booking.getPassengers().get(0).getFullName() : "Rajesh Sharma") + "</div>" +
                "              <div class='col-4'><strong>Seat:</strong> " + seatBadge + "</div>" +
                "              <div class='col-4'><strong>Total Amount:</strong> " + nf.format(booking.getTotalAmount()) + "</div>" +
                "            </div>" +
                "          </div>" +
                "          <div class='p-3 rounded border small mb-4' style='background: #F0F7FF; border-color: #BAE6FD;'>" +
                "            <div class='d-flex justify-content-between align-items-center mb-1'>" +
                "              <div><i class='bi bi-award-fill text-primary me-1'></i><strong>Frequent Flyer:</strong> <span class='badge bg-primary'>" + flight.getFrequentFlyerTier() + "</span> <span class='text-muted font-monospace ms-2'>ID: SKY-884920</span></div>" +
                "              <div class='text-end fw-bold text-primary'><i class='bi bi-stars text-warning me-1'></i>+" + flight.getFrequentFlyerMiles() + " SkyPoints Credited</div>" +
                "            </div>" +
                "            <div class='text-muted small mt-1'><i class='bi bi-check2-circle text-success me-1'></i>Tier Privileges: " + flight.getFrequentFlyerPerks() + "</div>" +
                "          </div>" +
                actionButtons +
                "        </div>" +
                "      </div>" +
                "    </div>" +
                "  </div>" +
                "</div>" +
                modalHtml;

            sendHtml(ex, renderLayout("Confirmation", 6, body));
        }

        private void handleMyBookings(HttpExchange ex, Map<String, Object> session) throws IOException {
            NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
            StringBuilder cards = new StringBuilder();
            StringBuilder modals = new StringBuilder();

            String flash = (String) session.remove("flashSuccess");
            String flashHtml = "";
            if (flash != null) {
                flashHtml = "<div class='alert alert-success alert-dismissible fade show mb-4' role='alert'>" +
                            "<i class='bi bi-check-circle-fill me-2'></i>" + flash +
                            "<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
            }

            for (Booking b : IN_MEMORY_BOOKINGS.values()) {
                FlightSummary f = flightProvider.getFlightById(b.getFlightId());
                boolean isCancelled = b.getBookingStatus() == BookingStatus.CANCELLED;

                String badge = isCancelled ? "<span class='badge bg-danger'>CANCELLED</span>" : "<span class='badge bg-success'>" + b.getBookingStatus() + "</span>";
                String seatsDisplay = isCancelled
                    ? "<span class='text-decoration-line-through'>" + b.getAllocatedSeatNumbersDisplay() + "</span> <span class='badge bg-danger bg-opacity-10 text-danger ms-1'>Released</span>"
                    : "<strong class='text-primary'>" + b.getAllocatedSeatNumbersDisplay() + "</strong>";
                String amountDisplay = isCancelled
                    ? "<span class='fs-6 text-muted text-decoration-line-through'>" + nf.format(b.getTotalAmount()) + "</span> <span class='badge bg-warning text-dark ms-1'>Refunded</span>"
                    : "<span class='fs-5 fw-bold text-primary'>" + nf.format(b.getTotalAmount()) + "</span>";

                String cancelBtn = "";
                if (!isCancelled && b.getBookingStatus() == BookingStatus.CONFIRMED) {
                    cancelBtn = "<button type='button' class='btn btn-outline-danger btn-sm' data-bs-toggle='modal' data-bs-target='#cancelModal_" + b.getPnr() + "'><i class='bi bi-x-circle me-1'></i> Cancel</button>";

                    modals.append(
                        "<div class='modal fade' id='cancelModal_" + b.getPnr() + "' tabindex='-1' aria-hidden='true'>" +
                        "  <div class='modal-dialog modal-dialog-centered'>" +
                        "    <div class='modal-content border-0 shadow'>" +
                        "      <div class='modal-header bg-danger text-white'>" +
                        "        <h5 class='modal-title'><i class='bi bi-exclamation-triangle-fill me-2'></i> Confirm Cancellation</h5>" +
                        "        <button type='button' class='btn-close btn-close-white' data-bs-dismiss='modal'></button>" +
                        "      </div>" +
                        "      <form action='/booking/cancel' method='POST'>" +
                        "        <input type='hidden' name='pnr' value='" + b.getPnr() + "'>" +
                        "        <div class='modal-body p-4'>" +
                        "          <p class='mb-3'>Are you sure you want to cancel booking <strong>" + b.getPnr() + "</strong>?</p>" +
                        "          <div class='bg-light p-3 rounded border mb-3 small'>" +
                        "            <div class='d-flex justify-content-between mb-1'><span>Route:</span><strong>" + f.getOriginAirportCode() + " &rarr; " + f.getDestAirportCode() + "</strong></div>" +
                        "            <div class='d-flex justify-content-between mb-1'><span>Allocated Seats:</span><strong class='text-primary'>" + b.getAllocatedSeatNumbersDisplay() + "</strong></div>" +
                        "            <div class='d-flex justify-content-between mb-1'><span>Refundable Amount:</span><strong class='text-success'>" + nf.format(b.getTotalAmount()) + "</strong></div>" +
                        "          </div>" +
                        "          <div class='mb-3'>" +
                        "            <label class='form-label small fw-semibold text-muted'>Reason for Cancellation</label>" +
                        "            <select name='cancellationReason' class='form-select'>" +
                        "              <option value='Change of travel plans'>Change of travel plans</option>" +
                        "              <option value='Booked duplicate flight'>Booked duplicate flight</option>" +
                        "              <option value='Personal emergency'>Personal emergency</option>" +
                        "              <option value='Flight timing unsuitable'>Flight timing unsuitable</option>" +
                        "              <option value='Other'>Other reason</option>" +
                        "            </select>" +
                        "          </div>" +
                        "          <div class='alert alert-warning small mb-0'>" +
                        "            <i class='bi bi-info-circle me-1'></i> Allocated seats will be released back to inventory and a full refund will be initiated." +
                        "          </div>" +
                        "        </div>" +
                        "        <div class='modal-footer bg-light'>" +
                        "          <button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Keep Booking</button>" +
                        "          <button type='submit' class='btn btn-danger fw-semibold'><i class='bi bi-x-circle me-1'></i> Confirm Cancellation</button>" +
                        "        </div>" +
                        "      </form>" +
                        "    </div>" +
                        "  </div>" +
                        "</div>"
                    );
                }

                cards.append(String.format(
                    "<div class='col-lg-6'>" +
                    "<div class='skytech-card h-100'>" +
                    "<div class='skytech-card-header'><div><span class='text-muted small'>PNR:</span><span class='fw-bold text-primary font-monospace fs-5 ms-1'>%s</span></div>%s</div>" +
                    "<div class='skytech-card-body'>" +
                    "  <div class='d-flex justify-content-between align-items-center mb-3'>" +
                    "    <div><h4 class='fw-bold text-navy mb-0'>%s</h4><small class='text-muted'>%s</small></div>" +
                    "    <div class='text-center'><small class='badge bg-light text-dark border'>%s</small><div class='text-primary'><i class='bi bi-arrow-right fs-4'></i></div></div>" +
                    "    <div class='text-end'><h4 class='fw-bold text-navy mb-0'>%s</h4><small class='text-muted'>%s</small></div>" +
                    "  </div>" +
                    "  <div class='border-top pt-2 small text-muted mb-3'>" +
                    "    <div class='d-flex justify-content-between mb-1'><span>Seats:</span> %s</div>" +
                    "    <div class='d-flex justify-content-between mb-1'><span>Date:</span> <span>%s</span></div>" +
                    "    <div class='d-flex justify-content-between mb-1'><span>Commander:</span> <span class='text-navy fw-semibold'>%s</span></div>" +
                    "    <div class='d-flex justify-content-between'><span>Frequent Flyer:</span> <span class='badge bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25'><i class='bi bi-award-fill me-1'></i>%s (+%d pts)</span></div>" +
                    "  </div>" +
                    "  <div class='d-flex justify-content-between align-items-center border-top pt-2'>" +
                    "    <div>%s</div>" +
                    "    <div class='d-flex gap-2'>" +
                    "      <a href='/booking/confirmation?pnr=%s' class='btn btn-outline-primary btn-sm'><i class='bi bi-ticket-perforated'></i> View Ticket</a>" +
                    "      %s" +
                    "    </div>" +
                    "  </div>" +
                    "</div></div></div>",
                    b.getPnr(), badge, f.getOriginAirportCode(), f.getOriginCity(),
                    f.getFlightNumber(), f.getDestAirportCode(), f.getDestCity(),
                    seatsDisplay, b.getFormattedBookingDate(), f.getCaptainName(),
                    f.getFrequentFlyerTier(), f.getFrequentFlyerMiles(),
                    amountDisplay, b.getPnr(), cancelBtn
                ));
            }

            String body =
                "<div class='container py-4'>" +
                flashHtml +
                "  <div class='d-flex justify-content-between align-items-center mb-4'>" +
                "    <div><h3 class='fw-bold text-navy mb-1'><i class='bi bi-journal-bookmark-fill text-primary me-2'></i> My Flight Bookings</h3><p class='text-muted small mb-0'>Passenger Portal &bull; Welcome, Rajesh Sharma.</p></div>" +
                "    <a href='/' class='btn btn-skytech-primary'><i class='bi bi-plus-lg me-1'></i> Book New Flight</a>" +
                "  </div>" +
                "  <div class='row g-4'>" + cards + "</div>" +
                "</div>" +
                modals;

            sendHtml(ex, renderLayout("My Bookings", 0, body));
        }

        private void handleRestApi(HttpExchange ex) throws IOException {
            Map<String, String> q = parseQuery(ex.getRequestURI().getQuery());
            String pnr = q.getOrDefault("pnr", "SK8M2P");
            Booking b = IN_MEMORY_BOOKINGS.get(pnr);
            if (b != null) {
                sendJson(ex, b);
            } else {
                ex.sendResponseHeaders(404, -1);
            }
        }

        private String renderLayout(String title, int step, String content) {
            String stepper = "";
            if (step > 0) {
                stepper =
                    "<div class='skytech-stepper-container'><div class='container'><div class='skytech-stepper'>" +
                    "  <div class='skytech-step-item " + (step == 1 ? "active" : (step > 1 ? "completed" : "")) + "'><div class='skytech-step-circle'>" + (step > 1 ? "<i class='bi bi-check-lg'></i>" : "1") + "</div><div class='skytech-step-label'>Flight Selected</div></div>" +
                    "  <div class='skytech-step-item " + (step == 2 ? "active" : (step > 2 ? "completed" : "")) + "'><div class='skytech-step-circle'>" + (step > 2 ? "<i class='bi bi-check-lg'></i>" : "2") + "</div><div class='skytech-step-label'>Passenger Details</div></div>" +
                    "  <div class='skytech-step-item " + (step == 3 ? "active" : (step > 3 ? "completed" : "")) + "'><div class='skytech-step-circle'>" + (step > 3 ? "<i class='bi bi-check-lg'></i>" : "3") + "</div><div class='skytech-step-label'>Seat Selection</div></div>" +
                    "  <div class='skytech-step-item " + (step == 4 ? "active" : (step > 4 ? "completed" : "")) + "'><div class='skytech-step-circle'>" + (step > 4 ? "<i class='bi bi-check-lg'></i>" : "4") + "</div><div class='skytech-step-label'>Review Booking</div></div>" +
                    "  <div class='skytech-step-item " + (step == 5 ? "active" : (step > 5 ? "completed" : "")) + "'><div class='skytech-step-circle'>" + (step > 5 ? "<i class='bi bi-check-lg'></i>" : "5") + "</div><div class='skytech-step-label'>Payment</div></div>" +
                    "  <div class='skytech-step-item " + (step == 6 ? "active" : "") + "'><div class='skytech-step-circle'>6</div><div class='skytech-step-label'>Confirmation</div></div>" +
                    "</div></div></div>";
            }

            return "<!DOCTYPE html><html lang='en'><head>" +
                   "<meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
                   "<title>SKYTECH AIRLINES &bull; " + title + "</title>" +
                   "<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css' rel='stylesheet'>" +
                   "<link href='https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css' rel='stylesheet'>" +
                   "<link href='/assets/css/booking.css' rel='stylesheet'>" +
                   "</head><body>" +
                   "<nav class='navbar navbar-expand-lg skytech-navbar sticky-top'><div class='container'>" +
                   "  <a class='skytech-brand' href='/'><div class='skytech-logo-container'><svg class='skytech-logo-plane' viewBox='0 0 44 44' fill='none' xmlns='http://www.w3.org/2000/svg'><path fill='#19A7D8' d='M 20 1.5 C 21.2 0 22.8 0 24 1.5 C 24.8 2.8 25.3 4.8 25.3 7.5 L 25.3 17.5 L 39 24.2 C 40.5 25 41 26.2 41 27.6 L 41 31 C 41 31.8 40.2 32.5 39.4 32.3 L 25.3 30 L 24.4 33.8 L 28.3 37.5 C 28.8 38 29.1 38.7 29.1 39.5 L 29.1 42 L 22 38.8 L 14.9 42 L 14.9 39.5 C 14.9 38.7 15.2 38 15.7 37.5 L 19.6 33.8 L 18.7 30 L 4.6 32.3 C 3.8 32.5 3 31.8 3 31 L 3 27.6 C 3 26.2 3.5 25 5 24.2 L 18.7 17.5 L 18.7 7.5 C 18.7 4.8 19.2 2.8 20 1.5 Z'/></svg><div class='skytech-logo-text'><span class='skytech-logo-title'>SKYTECH</span><span class='skytech-logo-subtitle'>AIRLINES</span></div></div></a>" +
                   "  <div class='collapse navbar-collapse'><ul class='navbar-nav ms-auto align-items-center gap-2'>" +
                   "    <li class='nav-item'><a class='nav-link skytech-nav-link' href='/'><i class='bi bi-compass me-1'></i> Flights</a></li>" +
                   "    <li class='nav-item'><a class='nav-link skytech-nav-link' href='/my-bookings'><i class='bi bi-journal-bookmark me-1'></i> My Bookings</a></li>" +
                   "    <li class='nav-item'><div class='d-flex align-items-center gap-2 bg-dark bg-opacity-50 px-3 py-1 rounded-pill border border-secondary border-opacity-25 text-white small'><i class='bi bi-person-circle text-primary'></i> Rajesh Sharma <span class='badge bg-primary'>Frequent Flyer</span></div></li>" +
                   "  </ul></div>" +
                   "</div></nav>" +
                   "<main>" + stepper + content + "</main>" +
                   "<footer class='skytech-footer'><div class='container text-center small text-muted'><div class='mb-1'>&copy; 2026 SKYTECH AIRLINES Ltd. All rights reserved. Official Passenger Reservation System.</div><div><span class='badge bg-dark border border-secondary border-opacity-50 text-secondary'><i class='bi bi-shield-check text-success me-1'></i> 256-Bit SSL Encrypted &bull; PCI-DSS Certified Checkout</span></div></div></footer>" +
                   "<script src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js'></script>" +
                   "</body></html>";
        }

        private Map<String, Object> getSession(HttpExchange ex) {
            String sid = "default-session";
            return SESSIONS.computeIfAbsent(sid, k -> new ConcurrentHashMap<>());
        }

        private Map<String, String> parseQuery(String query) {
            Map<String, String> map = new HashMap<>();
            if (query == null || query.isBlank()) return map;
            for (String pair : query.split("&")) {
                String[] parts = pair.split("=");
                if (parts.length == 2) {
                    map.put(URLDecoder.decode(parts[0], StandardCharsets.UTF_8), URLDecoder.decode(parts[1], StandardCharsets.UTF_8));
                }
            }
            return map;
        }

        private Map<String, String> parseForm(HttpExchange ex) throws IOException {
            byte[] bytes = ex.getRequestBody().readAllBytes();
            String formStr = new String(bytes, StandardCharsets.UTF_8);
            return parseQuery(formStr);
        }

        private void sendHtml(HttpExchange ex, String html) throws IOException {
            byte[] b = html.getBytes(StandardCharsets.UTF_8);
            ex.getResponseHeaders().set("Content-Type", "text/html; charset=UTF-8");
            ex.sendResponseHeaders(200, b.length);
            try (OutputStream os = ex.getResponseBody()) { os.write(b); }
        }

        private void sendJson(HttpExchange ex, Object obj) throws IOException {
            String json = new com.google.gson.Gson().toJson(obj);
            byte[] b = json.getBytes(StandardCharsets.UTF_8);
            ex.getResponseHeaders().set("Content-Type", "application/json; charset=UTF-8");
            ex.sendResponseHeaders(200, b.length);
            try (OutputStream os = ex.getResponseBody()) { os.write(b); }
        }

        private void redirect(HttpExchange ex, String location) throws IOException {
            ex.getResponseHeaders().set("Location", location);
            ex.sendResponseHeaders(302, -1);
        }
    }
}
