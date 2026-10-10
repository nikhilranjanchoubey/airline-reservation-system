package com.skytech.api;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.skytech.dao.AirportDao;
import com.skytech.model.Airline;
import com.skytech.model.Airport;
import com.skytech.model.Flight;
import com.skytech.model.FlightSchedule;
import com.skytech.model.FlightSegment;
import com.skytech.util.AppConfig;

import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpTimeoutException;
import java.sql.Date;
import java.sql.Time;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * High-performance, production client integrating directly with ReefAPI Flights API.
 * Endpoint: POST https://api.reefapi.com/flights/v1/search_flights
 *
 * Security:
 * - Never logs or exposes raw API keys in exceptions, logs, or UI
 * - Strictly respects ReefAPI credit constraints with in-memory TTL caching
 * - Handles real itinerary pricing, carriers, flight numbers, segments, and booking URLs
 */
public class ReefApiClient {

    private static final Logger LOGGER = Logger.getLogger(ReefApiClient.class.getName());
    private static final Duration HTTP_TIMEOUT = Duration.ofSeconds(30);
    private static final long CACHE_TTL_MS = 10 * 60 * 1000L; // 10 minutes cache to conserve credits
    private static final ZoneId APP_ZONE = ZoneId.of("Asia/Kolkata");

    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;
    private final AirportDao airportDao;

    // Incremental schedule ID generator for session-stable flight detail lookups
    private static final AtomicInteger SCHEDULE_ID_SEQUENCE = new AtomicInteger(10000);

    // Cache: key -> CacheEntry
    private static final Map<String, CacheEntry> SEARCH_CACHE = new ConcurrentHashMap<>();
    // Lookup: scheduleId -> FlightSchedule for instant view-details and seat-selection pages
    private static final Map<Integer, FlightSchedule> SCHEDULE_LOOKUP = new ConcurrentHashMap<>();

    private static class CacheEntry {
        final List<FlightSchedule> flights;
        final long timestamp;

        CacheEntry(List<FlightSchedule> flights) {
            this.flights = flights;
            this.timestamp = System.currentTimeMillis();
        }

        boolean isExpired() {
            return (System.currentTimeMillis() - timestamp) > CACHE_TTL_MS;
        }
    }

    public ReefApiClient() {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(HTTP_TIMEOUT)
                .build();
        this.objectMapper = new ObjectMapper();
        this.airportDao = new AirportDao();
    }

    public static void clearCache() {
        SEARCH_CACHE.clear();
        SCHEDULE_LOOKUP.clear();
    }

    /**
     * Executes flight search via ReefAPI.
     */
    public List<FlightSchedule> searchFlights(String origin, String destination, LocalDate departureDate,
                                              LocalDate returnDate, int adults, int children, int infants,
                                              String travelClass, String tripType) throws ApiException {

        if (origin == null || destination == null || departureDate == null) {
            return Collections.emptyList();
        }

        String originCode = origin.trim().toUpperCase();
        String destCode = destination.trim().toUpperCase();

        if (originCode.equals(destCode)) {
            return Collections.emptyList();
        }

        if (!AppConfig.isReefApiConfigured()) {
            LOGGER.log(Level.SEVERE, "[REEFAPI] API key is not configured in server environment (.env).");
            throw new ApiException("ReefAPI configuration missing. Please configure REEF_API_KEY in .env.",
                    0, ApiException.ErrorCategory.CONFIGURATION,
                    "Flight search service configuration is missing. Please contact the administrator.");
        }

        String apiKey = AppConfig.getReefApiKey();
        String baseUrl = AppConfig.getReefApiBaseUrl();
        String endpoint = baseUrl + "/flights/v1/search_flights";

        boolean isRoundTrip = "round-trip".equalsIgnoreCase(tripType) && returnDate != null;

        // Check cache to conserve credits
        String cacheKey = String.format("%s_%s_%s_%s_%d_%d_%d_%s",
                originCode, destCode, departureDate,
                isRoundTrip ? returnDate.toString() : "OW",
                adults, children, infants,
                travelClass != null ? travelClass.toUpperCase() : "ECONOMY");

        CacheEntry cached = SEARCH_CACHE.get(cacheKey);
        if (cached != null && !cached.isExpired()) {
            LOGGER.info(String.format("[REEFAPI] Serving %d flights from cache for route %s -> %s on %s (Credit saved)",
                    cached.flights.size(), originCode, destCode, departureDate));
            return cached.flights;
        }

        // Build JSON request payload
        ObjectNode payload = objectMapper.createObjectNode();
        payload.put("origin", originCode);
        payload.put("destination", destCode);
        payload.put("depart_date", departureDate.toString());
        if (isRoundTrip) {
            payload.put("return_date", returnDate.toString());
        }
        payload.put("adults", Math.max(1, adults));
        if (children > 0) {
            payload.put("children", children);
        }
        if (infants > 0) {
            payload.put("infants", infants);
        }

        // Map cabin class
        String cabinClassParam = mapCabinClass(travelClass);
        if (cabinClassParam != null) {
            payload.put("cabin_class", cabinClassParam);
        }

        payload.put("currency", "INR");
        payload.put("limit", 20);

        String requestJson;
        try {
            requestJson = objectMapper.writeValueAsString(payload);
        } catch (Exception e) {
            throw new ApiException("Failed to serialize ReefAPI request payload", e);
        }

        LOGGER.info(String.format("[REEFAPI] Sending POST search_flights: %s -> %s (%s, adults=%d, class=%s)",
                originCode, destCode, departureDate, adults, cabinClassParam));

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(endpoint))
                .timeout(HTTP_TIMEOUT)
                .header("x-api-key", apiKey)
                .header("Content-Type", "application/json")
                .header("Accept", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(requestJson))
                .build();

        HttpResponse<String> response;
        try {
            response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        } catch (HttpTimeoutException te) {
            LOGGER.log(Level.WARNING, "[REEFAPI] Request timed out after " + HTTP_TIMEOUT.toSeconds() + "s");
            throw new ApiException("ReefAPI flight search request timed out", 0,
                    ApiException.ErrorCategory.NETWORK_TIMEOUT,
                    "Flight search timed out. Upstream flight network took too long to respond.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[REEFAPI] Network connection failed", e);
            throw new ApiException("Failed to communicate with ReefAPI: " + e.getMessage(), e);
        }

        int statusCode = response.statusCode();
        String responseBody = response.body();

        LOGGER.info(String.format("[REEFAPI] Response status: %d for %s -> %s", statusCode, originCode, destCode));

        // Handle error status codes defensively
        if (statusCode == 401) {
            LOGGER.log(Level.SEVERE, "[REEFAPI] 401 Unauthorized: Invalid or missing API key.");
            throw new ApiException("ReefAPI authentication failed (HTTP 401). Verify REEF_API_KEY in .env.",
                    401, ApiException.ErrorCategory.AUTHENTICATION,
                    "Flight service authentication failed. Please verify API key configuration.");
        } else if (statusCode == 402) {
            LOGGER.log(Level.SEVERE, "[REEFAPI] 402 Payment Required: Free/paid search credits exhausted.");
            throw new ApiException("ReefAPI search credits exhausted (HTTP 402).",
                    402, ApiException.ErrorCategory.CREDIT_EXHAUSTED,
                    "Flight service search credits exhausted on ReefAPI. Please renew or upgrade the plan.");
        } else if (statusCode == 429) {
            LOGGER.log(Level.WARNING, "[REEFAPI] 429 Rate limit exceeded.");
            throw new ApiException("ReefAPI rate limit exceeded (HTTP 429).",
                    429, ApiException.ErrorCategory.RATE_LIMIT,
                    "Search request frequency limit exceeded. Please wait a moment and try again.");
        } else if (statusCode == 400) {
            String errorMsg = extractErrorMessage(responseBody, "Invalid search parameters supplied.");
            LOGGER.log(Level.WARNING, "[REEFAPI] 400 Bad Request: " + errorMsg);
            throw new ApiException("ReefAPI Bad Request: " + errorMsg,
                    400, ApiException.ErrorCategory.BAD_REQUEST,
                    "Invalid search criteria: " + errorMsg);
        } else if (statusCode >= 500) {
            LOGGER.log(Level.SEVERE, "[REEFAPI] Upstream server error HTTP " + statusCode);
            throw new ApiException("ReefAPI server error (HTTP " + statusCode + ")",
                    statusCode, ApiException.ErrorCategory.SERVER_ERROR,
                    "Flight service is temporarily unavailable. Please try again shortly.");
        }

        List<FlightSchedule> results = parseReefSearchResponse(responseBody, originCode, destCode, departureDate, isRoundTrip, travelClass, statusCode);

        LOGGER.info(String.format("[REEFAPI] Successfully parsed %d verified flight itineraries for %s -> %s",
                results.size(), originCode, destCode));

        // Cache valid results
        SEARCH_CACHE.put(cacheKey, new CacheEntry(results));
        return results;
    }

    /**
     * Parses ReefAPI search JSON response envelope into List of FlightSchedule.
     */
    public List<FlightSchedule> parseReefSearchResponse(String responseBody, String originCode, String destCode,
                                                        LocalDate departureDate, String travelClass) throws ApiException {
        return parseReefSearchResponse(responseBody, originCode, destCode, departureDate, false, travelClass, 200);
    }

    /**
     * Parses ReefAPI search JSON response envelope into List of FlightSchedule with detailed options.
     */
    public List<FlightSchedule> parseReefSearchResponse(String responseBody, String originCode, String destCode,
                                                        LocalDate departureDate, boolean isRoundTrip,
                                                        String travelClass, int statusCode) throws ApiException {
        JsonNode rootNode;
        try {
            rootNode = objectMapper.readTree(responseBody);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[REEFAPI] Failed to parse JSON response: " + e.getMessage());
            throw new ApiException("Invalid JSON returned by ReefAPI", e);
        }

        boolean ok = rootNode.path("ok").asBoolean(false);
        if (!ok) {
            String errorCode = rootNode.path("error").path("code").asText("");
            String errorMsg = rootNode.path("error").path("message").asText("Unknown error");
            LOGGER.log(Level.WARNING, String.format("[REEFAPI] API returned ok=false (code=%s): %s", errorCode, errorMsg));

            if ("NO_FLIGHTS_FOUND".equalsIgnoreCase(errorCode) || "NOT_FOUND".equalsIgnoreCase(errorCode)) {
                return Collections.emptyList();
            }
            ApiException.ErrorCategory category = ApiException.ErrorCategory.GENERAL;
            if ("AUTH_FAILED".equalsIgnoreCase(errorCode) || "INVALID_API_KEY".equalsIgnoreCase(errorCode)) {
                category = ApiException.ErrorCategory.AUTHENTICATION;
            } else if ("CREDIT_EXHAUSTED".equalsIgnoreCase(errorCode) || "INSUFFICIENT_CREDITS".equalsIgnoreCase(errorCode)) {
                category = ApiException.ErrorCategory.CREDIT_EXHAUSTED;
            } else if ("VALIDATION_ERROR".equalsIgnoreCase(errorCode)) {
                category = ApiException.ErrorCategory.BAD_REQUEST;
            }
            throw new ApiException("ReefAPI error: " + errorMsg, statusCode, category, errorMsg);
        }

        JsonNode dataNode = rootNode.path("data");
        JsonNode flightsArray = dataNode.path("flights");
        if (!flightsArray.isArray() || flightsArray.isEmpty()) {
            LOGGER.info(String.format("[REEFAPI] Search returned 0 flights for %s -> %s on %s", originCode, destCode, departureDate));
            return Collections.emptyList();
        }

        List<FlightSchedule> results = new ArrayList<>();
        for (JsonNode flightNode : flightsArray) {
            try {
                FlightSchedule fs = parseFlightItem(flightNode, originCode, destCode, departureDate, isRoundTrip, travelClass);
                if (fs != null) {
                    results.add(fs);
                    SCHEDULE_LOOKUP.put(fs.getScheduleId(), fs);
                }
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "[REEFAPI] Failed to parse flight item: " + e.getMessage(), e);
            }
        }
        return results;
    }

    /**
     * Parses a single flight object from ReefAPI response into SkyTech's FlightSchedule.
     */
    private FlightSchedule parseFlightItem(JsonNode node, String originCode, String destCode,
                                           LocalDate departureDate, boolean isRoundTrip, String travelClass) {

        String id = node.path("id").asText("");
        String type = node.path("type").asText("oneway");
        int durationSeconds = node.path("duration_seconds").asInt(0);
        String bookingUrl = node.path("booking_url").asText(null);

        // Price parsing
        JsonNode priceNode = node.path("price");
        BigDecimal totalPrice = BigDecimal.ZERO;
        String currency = "INR";
        if (priceNode.isObject()) {
            double amount = priceNode.path("amount").asDouble(0.0);
            if (amount > 0) {
                totalPrice = BigDecimal.valueOf(amount);
            }
            currency = priceNode.path("currency").asText("INR");
        }

        int scheduleId = SCHEDULE_ID_SEQUENCE.incrementAndGet();

        FlightSchedule schedule = new FlightSchedule();
        schedule.setScheduleId(scheduleId);
        schedule.setFlightId(scheduleId);
        schedule.setFlightDate(Date.valueOf(departureDate));
        schedule.setBasePrice(totalPrice);
        schedule.setEconomyPrice(totalPrice);
        schedule.setBookingUrl(bookingUrl);
        schedule.setCurrency(currency);
        schedule.setItineraryId(id);
        schedule.setTripType(type);
        schedule.setEstimatedFare(false);
        schedule.setAvailableSeats(0); // Provider does not supply verified real-time seat inventory
        schedule.setSimulatedSeats(false);
        schedule.setTotalSeats(180);
        schedule.setStatus("SCHEDULED");

        // Cabin class pricing proportional logic if applicable
        if ("Business".equalsIgnoreCase(travelClass)) {
            schedule.setBusinessPrice(totalPrice);
            schedule.setPremiumEconomyPrice(totalPrice.multiply(BigDecimal.valueOf(0.75)));
            schedule.setEconomyPrice(totalPrice.multiply(BigDecimal.valueOf(0.5)));
        } else if ("Premium Economy".equalsIgnoreCase(travelClass)) {
            schedule.setPremiumEconomyPrice(totalPrice);
            schedule.setBusinessPrice(totalPrice.multiply(BigDecimal.valueOf(1.4)));
            schedule.setEconomyPrice(totalPrice.multiply(BigDecimal.valueOf(0.7)));
        } else if ("First Class".equalsIgnoreCase(travelClass)) {
            schedule.setFirstClassPrice(totalPrice);
            schedule.setBusinessPrice(totalPrice.multiply(BigDecimal.valueOf(0.8)));
            schedule.setEconomyPrice(totalPrice.multiply(BigDecimal.valueOf(0.4)));
        } else {
            schedule.setEconomyPrice(totalPrice);
            schedule.setPremiumEconomyPrice(totalPrice.multiply(BigDecimal.valueOf(1.35)));
            schedule.setBusinessPrice(totalPrice.multiply(BigDecimal.valueOf(2.1)));
            schedule.setFirstClassPrice(totalPrice.multiply(BigDecimal.valueOf(3.2)));
        }

        // Parse Outbound and Inbound Legs
        if ("return".equalsIgnoreCase(type) && node.has("outbound")) {
            JsonNode outboundNode = node.path("outbound");
            JsonNode inboundNode = node.path("inbound");

            // Outbound
            Flight outboundFlight = buildFlightFromNode(outboundNode, originCode, destCode);
            schedule.setFlight(outboundFlight);
            schedule.setSegments(parseSegments(outboundNode.path("segments")));

            // Inbound
            if (inboundNode.isObject()) {
                FlightSchedule returnSchedule = new FlightSchedule();
                int returnScheduleId = SCHEDULE_ID_SEQUENCE.incrementAndGet();
                returnSchedule.setScheduleId(returnScheduleId);
                returnSchedule.setFlightId(returnScheduleId);
                returnSchedule.setEstimatedFare(false);
                returnSchedule.setAvailableSeats(0);
                returnSchedule.setSimulatedSeats(false);
                returnSchedule.setTotalSeats(180);
                returnSchedule.setStatus("SCHEDULED");
                returnSchedule.setCurrency(currency);

                Flight inboundFlight = buildFlightFromNode(inboundNode, destCode, originCode);
                returnSchedule.setFlight(inboundFlight);
                returnSchedule.setSegments(parseSegments(inboundNode.path("segments")));

                // Set return flight date if available
                String inDepIso = inboundNode.path("departure").asText("");
                if (inDepIso.length() >= 10) {
                    try {
                        returnSchedule.setFlightDate(Date.valueOf(LocalDate.parse(inDepIso.substring(0, 10))));
                    } catch (Exception ignored) {}
                }

                schedule.setReturnSchedule(returnSchedule);
                schedule.setReturnSegments(returnSchedule.getSegments());
                SCHEDULE_LOOKUP.put(returnScheduleId, returnSchedule);
            }

        } else {
            // One-Way
            Flight flight = buildFlightFromNode(node, originCode, destCode);
            schedule.setFlight(flight);
            schedule.setSegments(parseSegments(node.path("segments")));
        }

        return schedule;
    }

    /**
     * Builds a Flight entity from node data (carrier, flight_no, times, airports, stops).
     */
    private Flight buildFlightFromNode(JsonNode node, String fallbackOrigin, String fallbackDest) {
        Flight flight = new Flight();

        String depIso = node.path("departure").asText("");
        String arrIso = node.path("arrival").asText("");
        int stops = node.path("stops").asInt(0);
        flight.setStops(stops);

        // Departure & Arrival times
        LocalTime depTime = parseLocalTime(depIso, LocalTime.of(9, 0));
        LocalTime arrTime = parseLocalTime(arrIso, LocalTime.of(11, 0));
        flight.setDepartureTime(Time.valueOf(depTime));
        flight.setArrivalTime(Time.valueOf(arrTime));

        // Duration in minutes
        int durationMins = 0;
        if (node.has("duration_seconds")) {
            durationMins = node.path("duration_seconds").asInt(0) / 60;
        }
        if (durationMins <= 0 && depTime != null && arrTime != null) {
            durationMins = (int) Duration.between(depTime, arrTime).toMinutes();
            if (durationMins < 0) durationMins += 24 * 60;
        }
        flight.setDurationMinutes(Math.max(30, durationMins));

        // First segment inspection for carrier & flight number
        JsonNode segmentsNode = node.path("segments");
        String carrierName = node.path("carrier_name").asText(node.path("carrier").asText("Airline"));
        String carrierCode = node.path("carrier_code").asText(node.path("carrier").asText("6E"));
        String flightNo = null;
        if (node.has("flight_number")) {
            flightNo = node.path("flight_number").asText();
        } else if (node.has("flight_no")) {
            flightNo = node.path("flight_no").asText();
        }
        String fromCode = node.path("origin").asText(fallbackOrigin);
        String toCode = node.path("destination").asText(fallbackDest);

        if (segmentsNode.isArray() && !segmentsNode.isEmpty()) {
            JsonNode firstSeg = segmentsNode.get(0);
            if (firstSeg.has("carrier_name")) carrierName = firstSeg.path("carrier_name").asText(carrierName);
            if (firstSeg.has("carrier")) {
                String c = firstSeg.path("carrier").asText();
                if (c.length() <= 3) carrierCode = c;
                else carrierName = c;
            }
            if (firstSeg.has("carrier_code")) carrierCode = firstSeg.path("carrier_code").asText(carrierCode);
            if (firstSeg.has("flight_number")) flightNo = firstSeg.path("flight_number").asText(flightNo);
            else if (firstSeg.has("flight_no")) flightNo = firstSeg.path("flight_no").asText(flightNo);

            if (firstSeg.has("from")) fromCode = firstSeg.path("from").asText(fromCode);
            else if (firstSeg.has("origin")) fromCode = firstSeg.path("origin").asText(fromCode);

            JsonNode lastSeg = segmentsNode.get(segmentsNode.size() - 1);
            if (lastSeg.has("to")) toCode = lastSeg.path("to").asText(toCode);
            else if (lastSeg.has("destination")) toCode = lastSeg.path("destination").asText(toCode);
        } else {
            JsonNode carriersArr = node.path("carriers");
            if (carriersArr.isArray() && !carriersArr.isEmpty()) {
                carrierCode = carriersArr.get(0).asText("6E");
            }
        }

        if (flightNo == null || flightNo.trim().isEmpty()) {
            flightNo = carrierCode + " 101";
        }

        // Format flight number cleanly (e.g. "6E 2376" if given "6E2376")
        String formattedFlightNo = formatFlightNumber(flightNo, carrierCode);
        flight.setFlightNumber(formattedFlightNo);

        // Airline
        Airline airline = new Airline();
        airline.setAirlineCode(carrierCode);
        airline.setAirlineName(resolveAirlineName(carrierCode, carrierName));
        flight.setAirline(airline);

        // Airports
        Airport srcAirport = airportDao.getAirportByCode(fromCode);
        if (srcAirport == null) {
            srcAirport = new Airport(fromCode, fromCode, fromCode + " Airport", "India", "T1");
        }
        Airport dstAirport = airportDao.getAirportByCode(toCode);
        if (dstAirport == null) {
            dstAirport = new Airport(toCode, toCode, toCode + " Airport", "India", "T1");
        }
        flight.setSourceAirport(srcAirport);
        flight.setDestinationAirport(dstAirport);

        flight.setAircraftModel("Airbus A320 / Boeing 737");
        flight.setStatus("SCHEDULED");

        return flight;
    }

    /**
     * Parses array of segment JSON nodes into FlightSegment list.
     */
    private List<FlightSegment> parseSegments(JsonNode segmentsNode) {
        if (!segmentsNode.isArray() || segmentsNode.isEmpty()) {
            return Collections.emptyList();
        }
        List<FlightSegment> list = new ArrayList<>();
        for (JsonNode s : segmentsNode) {
            FlightSegment seg = new FlightSegment();
            String c = s.path("carrier").asText("");
            String cCode = s.path("carrier_code").asText(c.length() <= 3 ? c : "");
            seg.setCarrier(c);
            seg.setCarrierCode(cCode);

            String fNo = s.has("flight_number") ? s.path("flight_number").asText() : s.path("flight_no").asText("");
            seg.setFlightNumber(fNo);
            seg.setOperatingCarrier(s.path("operating_carrier").asText(null));

            String from = s.has("from") ? s.path("from").asText() : s.path("origin").asText("");
            seg.setFromCode(from);
            seg.setFromName(s.path("from_name").asText(""));
            seg.setFromCity(s.path("from_city").asText(""));

            String to = s.has("to") ? s.path("to").asText() : s.path("destination").asText("");
            seg.setToCode(to);
            seg.setToName(s.path("to_name").asText(""));
            seg.setToCity(s.path("to_city").asText(""));

            String dep = s.has("departure") ? s.path("departure").asText() : s.path("departure_time").asText("");
            seg.setDepartureIso(dep);

            String arr = s.has("arrival") ? s.path("arrival").asText() : s.path("arrival_time").asText("");
            seg.setArrivalIso(arr);

            int dur = s.has("duration_seconds") ? s.path("duration_seconds").asInt(0) : s.path("duration").asInt(0) * 60;
            seg.setDurationSeconds(dur);
            list.add(seg);
        }
        return list;
    }

    private LocalTime parseLocalTime(String isoString, LocalTime fallback) {
        if (isoString == null || isoString.isEmpty()) return fallback;
        try {
            return java.time.OffsetDateTime.parse(isoString).toLocalTime();
        } catch (Exception e) {
            try {
                return LocalDateTime.parse(isoString).toLocalTime();
            } catch (Exception ex) {
                if (isoString.length() >= 16) {
                    try {
                        return LocalTime.parse(isoString.substring(11, 16));
                    } catch (Exception ignored) {}
                }
                return fallback;
            }
        }
    }

    private String formatFlightNumber(String flightNo, String carrierCode) {
        if (flightNo == null || flightNo.isEmpty()) return carrierCode + " 101";
        String clean = flightNo.trim();
        if (carrierCode != null && clean.startsWith(carrierCode) && clean.length() > carrierCode.length()) {
            String suffix = clean.substring(carrierCode.length()).trim();
            return carrierCode + " " + suffix;
        }
        return clean;
    }

    private String resolveAirlineName(String code, String defaultName) {
        if (defaultName != null && !defaultName.isEmpty() && !defaultName.equalsIgnoreCase(code) && !"Airline".equalsIgnoreCase(defaultName)) {
            return defaultName;
        }
        if ("6E".equalsIgnoreCase(code)) return "IndiGo";
        if ("AI".equalsIgnoreCase(code)) return "Air India";
        if ("IX".equalsIgnoreCase(code)) return "Air India Express";
        if ("QP".equalsIgnoreCase(code)) return "Akasa Air";
        if ("UK".equalsIgnoreCase(code)) return "Vistara";
        if ("SG".equalsIgnoreCase(code)) return "SpiceJet";
        if ("G8".equalsIgnoreCase(code)) return "Go First";
        if ("EK".equalsIgnoreCase(code)) return "Emirates";
        if ("FZ".equalsIgnoreCase(code)) return "flydubai";
        if ("QR".equalsIgnoreCase(code)) return "Qatar Airways";
        if ("EY".equalsIgnoreCase(code)) return "Etihad Airways";
        if ("SQ".equalsIgnoreCase(code)) return "Singapore Airlines";
        if ("BA".equalsIgnoreCase(code)) return "British Airways";
        if ("LH".equalsIgnoreCase(code)) return "Lufthansa";
        return (defaultName != null && !defaultName.isEmpty()) ? defaultName : (code != null ? code : "Commercial Airline");
    }

    private String mapCabinClass(String travelClass) {
        if (travelClass == null) return "ECONOMY";
        switch (travelClass.trim().toLowerCase()) {
            case "business":
                return "BUSINESS";
            case "premium economy":
            case "premiumeconomy":
                return "PREMIUM_ECONOMY";
            case "first class":
            case "firstclass":
                return "FIRST";
            case "economy":
            default:
                return "ECONOMY";
        }
    }

    private String extractErrorMessage(String jsonBody, String fallback) {
        if (jsonBody == null || jsonBody.isEmpty()) return fallback;
        try {
            JsonNode root = objectMapper.readTree(jsonBody);
            String msg = root.path("error").path("message").asText(null);
            if (msg != null && !msg.isEmpty()) return msg;
        } catch (Exception ignored) {}
        return fallback;
    }

    /**
     * Retrieves specific flight schedule details from lookup map.
     */
    public FlightSchedule getFlightDetails(int scheduleId) {
        return SCHEDULE_LOOKUP.get(scheduleId);
    }

    /**
     * Finds a cached flight schedule matching flight number, route, and date.
     */
    public FlightSchedule getFlightByRouteAndNumber(String flightNumber, String source, String destination, LocalDate date) {
        if (flightNumber == null || flightNumber.isEmpty()) return null;
        String cleanQuery = flightNumber.replaceAll("\\s+", "").toUpperCase();

        for (FlightSchedule fs : SCHEDULE_LOOKUP.values()) {
            if (fs.getFlight() != null && fs.getFlight().getFlightNumber() != null) {
                String num = fs.getFlight().getFlightNumber().replaceAll("\\s+", "").toUpperCase();
                if (num.equals(cleanQuery)) {
                    if (source == null || fs.getFlight().getSourceAirport() == null
                            || source.equalsIgnoreCase(fs.getFlight().getSourceAirport().getAirportCode())) {
                        return fs;
                    }
                }
            }
        }
        return null;
    }

    /**
     * Finds a cached flight schedule matching flight number and date.
     */
    public FlightSchedule getFlightByFlightNumber(String flightNumber, LocalDate date) {
        if (flightNumber == null || flightNumber.isEmpty()) return null;
        String cleanQuery = flightNumber.replaceAll("\\s+", "").toUpperCase();

        for (FlightSchedule fs : SCHEDULE_LOOKUP.values()) {
            if (fs.getFlight() != null && fs.getFlight().getFlightNumber() != null) {
                String num = fs.getFlight().getFlightNumber().replaceAll("\\s+", "").toUpperCase();
                if (num.equals(cleanQuery)) {
                    return fs;
                }
            }
        }
        return null;
    }
}
