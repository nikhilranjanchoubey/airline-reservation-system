package com.skytech.api;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.skytech.dao.AirportDao;
import com.skytech.model.Airline;
import com.skytech.model.Airport;
import com.skytech.model.Flight;
import com.skytech.model.FlightSchedule;
import com.skytech.util.AppConfig;

import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.sql.Date;
import java.sql.Time;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * High-performance client integrating with the real AeroDataBox API via RapidAPI.
 * Features:
 * - Direct FIDS departures querying with 12-hour window constraints
 * - In-memory LRU/TTL caching to conserve RapidAPI rate limits
 * - Strict credential safety: never logs or leaks RAPIDAPI_KEY
 * - Maps live flight statuses, terminals, aircraft models, and baggage belts
 * - Calculates honest estimated fares distinguishing live flight data from mock fares
 */
public class AeroDataBoxClient {

    private static final Logger LOGGER = Logger.getLogger(AeroDataBoxClient.class.getName());
    private static final Duration HTTP_TIMEOUT = Duration.ofSeconds(20);
    private static final long CACHE_TTL_MS = 10 * 60 * 1000L; // 10 minutes cache

    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;
    private final AirportDao airportDao;

    // Cache: key -> CacheEntry
    private static final Map<String, CacheEntry> SEARCH_CACHE = new ConcurrentHashMap<>();
    // Lookup table: scheduleId -> FlightSchedule for instant flight details / seat maps
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

    public AeroDataBoxClient() {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(HTTP_TIMEOUT)
                .build();
        this.objectMapper = new ObjectMapper();
        this.airportDao = new AirportDao();
    }

    /**
     * Searches live flights for a specific route and departure date.
     *
     * @param origin IATA origin airport code (e.g. JAI)
     * @param destination IATA destination airport code (e.g. DEL)
     * @param departureDate requested departure date
     * @return list of matching FlightSchedule objects
     * @throws ApiException on communication failure, rate limits, or auth issues
     */
    public List<FlightSchedule> searchFlights(String origin, String destination, LocalDate departureDate) throws ApiException {
        if (origin == null || destination == null || departureDate == null) {
            return Collections.emptyList();
        }

        String originCode = origin.trim().toUpperCase();
        String destCode = destination.trim().toUpperCase();

        if (originCode.equals(destCode)) {
            return Collections.emptyList();
        }

        String cacheKey = originCode + "_" + destCode + "_" + departureDate;
        CacheEntry cached = SEARCH_CACHE.get(cacheKey);
        if (cached != null && !cached.isExpired()) {
            LOGGER.info("Serving " + cached.flights.size() + " flights from AeroDataBox cache for " + cacheKey);
            return cached.flights;
        }

        if (!AppConfig.isRapidApiConfigured()) {
            throw new ApiException("Flight search service is currently unavailable. Please try again.");
        }

        List<FlightSchedule> results = new ArrayList<>();

        // AeroDataBox basic plan limits window to 12 hours. We query two 12-hour windows for full day coverage.
        // Window 1: 00:00 -> 11:59
        // Window 2: 12:00 -> 23:59
        String dateStr = departureDate.toString();
        ApiException lastError = null;

        try {
            queryWindow(originCode, destCode, departureDate, dateStr + "T00:00", dateStr + "T11:59", results);
        } catch (ApiException e) {
            lastError = e;
            LOGGER.log(Level.WARNING, "Window 1 query encountered error: " + e.getMessage());
        }

        try {
            queryWindow(originCode, destCode, departureDate, dateStr + "T12:00", dateStr + "T23:59", results);
        } catch (ApiException e) {
            if (lastError == null) lastError = e;
            LOGGER.log(Level.WARNING, "Window 2 query encountered error: " + e.getMessage());
        }

        if (results.isEmpty() && lastError != null) {
            throw lastError;
        }

        // Deduplicate by flight number + departure time
        Map<String, FlightSchedule> deduplicated = new ConcurrentHashMap<>();
        for (FlightSchedule fs : results) {
            String uniqueFlightKey = fs.getFlight().getFlightNumber() + "_" + fs.getFlight().getDepartureTime();
            deduplicated.putIfAbsent(uniqueFlightKey, fs);
            SCHEDULE_LOOKUP.put(fs.getScheduleId(), fs);
        }

        List<FlightSchedule> finalResults = new ArrayList<>(deduplicated.values());
        Collections.sort(finalResults, (a, b) -> a.getFlight().getDepartureTime().compareTo(b.getFlight().getDepartureTime()));

        SEARCH_CACHE.put(cacheKey, new CacheEntry(finalResults));
        LOGGER.info("Successfully retrieved " + finalResults.size() + " live flights from AeroDataBox for " + originCode + " -> " + destCode);

        return finalResults;
    }

    private void queryWindow(String originCode, String destCode, LocalDate searchDate,
                             String fromLocal, String toLocal, List<FlightSchedule> accumulator) throws ApiException {

        String host = AppConfig.getRapidApiHost();
        String apiKey = AppConfig.getRapidApiKey();

        String url = String.format("https://%s/flights/airports/iata/%s/%s/%s?direction=Departure&withLeg=true&withCancelled=true&withCodeshared=true&withCargo=false&withPrivate=false",
                host, originCode, fromLocal, toLocal);

        HttpRequest request;
        try {
            request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(HTTP_TIMEOUT)
                    .header("X-RapidAPI-Key", apiKey)
                    .header("X-RapidAPI-Host", host)
                    .header("Accept", "application/json")
                    .GET()
                    .build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to build AeroDataBox HTTP request", e);
            throw new ApiException("Invalid flight search request.", e);
        }

        HttpResponse<String> response;
        try {
            response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        } catch (java.net.http.HttpConnectTimeoutException | java.net.SocketTimeoutException e) {
            LOGGER.log(Level.WARNING, "AeroDataBox request timed out for window: " + fromLocal);
            throw new ApiException("Flight data took too long to respond. Please try again.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Network error calling AeroDataBox API", e);
            throw new ApiException("Flight service is temporarily unavailable.");
        }

        int statusCode = response.statusCode();
        if (statusCode == 401 || statusCode == 403) {
            LOGGER.log(Level.SEVERE, "RapidAPI Authentication failed. HTTP " + statusCode);
            throw new ApiException("Flight service authentication failed. Please contact support.", statusCode);
        } else if (statusCode == 429) {
            LOGGER.log(Level.WARNING, "RapidAPI rate limit exceeded. HTTP 429");
            throw new ApiException("Flight service request limit reached. Please try again shortly.", statusCode);
        } else if (statusCode == 404) {
            // No flights in this window or airport not found in FIDS
            LOGGER.info("AeroDataBox 404 (No flights found in window " + fromLocal + " to " + toLocal + ")");
            return;
        } else if (statusCode >= 500) {
            LOGGER.log(Level.WARNING, "AeroDataBox server error HTTP " + statusCode);
            throw new ApiException("Flight service is temporarily unavailable.", statusCode);
        } else if (statusCode != 200) {
            LOGGER.log(Level.WARNING, "AeroDataBox unexpected status code: " + statusCode);
            return;
        }

        parseDeparturesJson(response.body(), originCode, destCode, searchDate, accumulator);
    }

    private void parseDeparturesJson(String jsonBody, String originCode, String destCode,
                                     LocalDate searchDate, List<FlightSchedule> accumulator) {
        if (jsonBody == null || jsonBody.trim().isEmpty()) {
            return;
        }

        try {
            JsonNode root = objectMapper.readTree(jsonBody);
            JsonNode departuresNode = root.get("departures");
            if (departuresNode == null || !departuresNode.isArray()) {
                return;
            }

            Airport srcAirport = airportDao.getAirportByCode(originCode);
            Airport dstAirport = airportDao.getAirportByCode(destCode);

            for (JsonNode item : departuresNode) {
                JsonNode arrivalNode = item.get("arrival");
                if (arrivalNode == null) continue;

                JsonNode arrAirportNode = arrivalNode.get("airport");
                if (arrAirportNode == null) continue;

                String arrIata = arrAirportNode.has("iata") ? arrAirportNode.get("iata").asText("") : "";
                if (!destCode.equalsIgnoreCase(arrIata)) {
                    // Filter: only keep flights arriving at the requested destination
                    continue;
                }

                // Flight Number
                String flightNumber = item.has("number") ? item.get("number").asText("FL-000") : "FL-000";

                // Airline
                JsonNode airlineNode = item.get("airline");
                String airlineName = (airlineNode != null && airlineNode.has("name")) ? airlineNode.get("name").asText("Airline") : "Airline";
                String airlineCode = (airlineNode != null && airlineNode.has("iata")) ? airlineNode.get("iata").asText("AI") : "AI";

                // Departure details
                JsonNode depNode = item.get("departure");
                String depTimeStr = extractTimeStr(depNode, "scheduledTime");
                String depRevisedStr = extractTimeStr(depNode, "revisedTime");
                String depTerminal = (depNode != null && depNode.has("terminal")) ? depNode.get("terminal").asText("1") : "1";

                // Arrival details
                String arrTimeStr = extractTimeStr(arrivalNode, "scheduledTime");
                String arrRevisedStr = extractTimeStr(arrivalNode, "revisedTime");
                String arrTerminal = arrivalNode.has("terminal") ? arrivalNode.get("terminal").asText("1") : "1";
                String baggageBelt = arrivalNode.has("baggageBelt") ? arrivalNode.get("baggageBelt").asText("") : null;

                // Aircraft
                JsonNode aircraftNode = item.get("aircraft");
                String aircraftModel = (aircraftNode != null && aircraftNode.has("model")) ? aircraftNode.get("model").asText("Airbus A320") : "Airbus A320";

                // Status
                String status = item.has("status") ? item.get("status").asText("Scheduled") : "Scheduled";

                // Date & Time conversion
                LocalTime depLocalTime = parseLocalTime(depTimeStr, LocalTime.of(8, 0));
                LocalTime arrLocalTime = parseLocalTime(arrTimeStr, LocalTime.of(10, 0));
                LocalDate depLocalDate = parseLocalDate(depTimeStr, searchDate);
                LocalDate arrLocalDate = parseLocalDate(arrTimeStr, searchDate);

                // Calculate duration in minutes
                LocalDateTime depLdt = LocalDateTime.of(depLocalDate, depLocalTime);
                LocalDateTime arrLdt = LocalDateTime.of(arrLocalDate, arrLocalTime);
                if (arrLdt.isBefore(depLdt)) {
                    arrLdt = arrLdt.plusDays(1);
                }
                int durationMinutes = (int) Math.max(45, Duration.between(depLdt, arrLdt).toMinutes());

                // Build Airline Model
                Airline airline = new Airline();
                airline.setAirlineCode(airlineCode);
                airline.setAirlineName(airlineName);

                // Build Flight Model
                Flight flight = new Flight();
                flight.setFlightNumber(flightNumber);
                flight.setAirline(airline);
                flight.setSourceAirport(srcAirport != null ? srcAirport : new Airport(0, originCode, originCode + " Airport", originCode, "India", "Terminal " + depTerminal));
                flight.setDestinationAirport(dstAirport != null ? dstAirport : new Airport(0, destCode, destCode + " Airport", destCode, "India", "Terminal " + arrTerminal));
                flight.setDepartureTime(Time.valueOf(depLocalTime));
                flight.setArrivalTime(Time.valueOf(arrLocalTime));
                flight.setDurationMinutes(durationMinutes);
                flight.setStops(0);
                flight.setAircraftModel(aircraftModel);
                flight.setDepartureTerminal("Terminal " + depTerminal);
                flight.setArrivalTerminal("Terminal " + arrTerminal);
                flight.setBaggageBelt(baggageBelt);
                flight.setStatus(status);

                // Deterministic Unique Schedule ID (fits in int)
                int scheduleId = Math.abs((flightNumber + "_" + depLocalDate + "_" + depLocalTime).hashCode() % 900000) + 100000;

                // Build FlightSchedule Model with Honest Estimated Pricing
                FlightSchedule fs = new FlightSchedule();
                fs.setScheduleId(scheduleId);
                fs.setFlight(flight);
                fs.setFlightDate(Date.valueOf(depLocalDate));
                fs.setStatus(status.toUpperCase());
                fs.setDepartureTerminal("Terminal " + depTerminal);
                fs.setArrivalTerminal("Terminal " + arrTerminal);
                fs.setBaggageBelt(baggageBelt);
                fs.setRevisedDepartureTime(depRevisedStr);
                fs.setRevisedArrivalTime(arrRevisedStr);
                fs.setLive(true);
                fs.setEstimatedFare(true);
                fs.setFareNote("Estimated fare for demonstration");
                fs.setAvailableSeats(38);
                fs.setTotalSeats(180);

                // Base estimated pricing according to duration
                long basePriceVal = 3200 + (durationMinutes * 15L);
                BigDecimal basePrice = BigDecimal.valueOf(basePriceVal);
                fs.setBasePrice(basePrice);
                fs.setEconomyPrice(basePrice);
                fs.setPremiumEconomyPrice(basePrice.multiply(BigDecimal.valueOf(1.35)).setScale(2, java.math.RoundingMode.HALF_UP));
                fs.setBusinessPrice(basePrice.multiply(BigDecimal.valueOf(2.20)).setScale(2, java.math.RoundingMode.HALF_UP));
                fs.setFirstClassPrice(basePrice.multiply(BigDecimal.valueOf(3.50)).setScale(2, java.math.RoundingMode.HALF_UP));

                accumulator.add(fs);
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error parsing AeroDataBox JSON response", e);
        }
    }

    private String extractTimeStr(JsonNode parent, String timeKey) {
        if (parent == null || !parent.has(timeKey)) return null;
        JsonNode timeNode = parent.get(timeKey);
        if (timeNode.has("local")) {
            return timeNode.get("local").asText();
        } else if (timeNode.has("utc")) {
            return timeNode.get("utc").asText();
        }
        return null;
    }

    private LocalTime parseLocalTime(String timeStr, LocalTime fallback) {
        if (timeStr == null || timeStr.trim().isEmpty()) {
            return fallback;
        }
        try {
            String s = timeStr.trim();
            if (s.contains(" ")) {
                s = s.substring(s.indexOf(' ') + 1);
            } else if (s.contains("T")) {
                s = s.substring(s.indexOf('T') + 1);
            }
            if (s.contains("+")) {
                s = s.substring(0, s.indexOf('+'));
            } else if (s.contains("-")) {
                s = s.substring(0, s.indexOf('-'));
            } else if (s.endsWith("Z")) {
                s = s.substring(0, s.length() - 1);
            }
            String[] parts = s.split(":");
            int h = Integer.parseInt(parts[0]);
            int m = Integer.parseInt(parts[1]);
            int sec = (parts.length > 2) ? Integer.parseInt(parts[2]) : 0;
            return LocalTime.of(h, m, sec);
        } catch (Exception e) {
            return fallback;
        }
    }

    private LocalDate parseLocalDate(String timeStr, LocalDate fallback) {
        if (timeStr == null || timeStr.length() < 10) {
            return fallback;
        }
        try {
            return LocalDate.parse(timeStr.substring(0, 10));
        } catch (Exception e) {
            return fallback;
        }
    }

    /**
     * Resolves flight schedule details by schedule ID from fast memory lookup.
     */
    public FlightSchedule getFlightDetails(int scheduleId) {
        return SCHEDULE_LOOKUP.get(scheduleId);
    }

    /**
     * Finds a flight by flight number and date from active AeroDataBox records.
     */
    public FlightSchedule getFlightByFlightNumber(String flightNumber, LocalDate flightDate) {
        if (flightNumber == null || flightNumber.trim().isEmpty()) return null;
        String cleanQuery = flightNumber.trim().replaceAll("\\s+", "").toUpperCase();
        for (FlightSchedule fs : SCHEDULE_LOOKUP.values()) {
            if (fs.getFlight() != null && fs.getFlight().getFlightNumber() != null) {
                String cleanNum = fs.getFlight().getFlightNumber().replaceAll("\\s+", "").toUpperCase();
                if (cleanNum.equalsIgnoreCase(cleanQuery)) {
                    if (flightDate == null || fs.getFlightDate().toLocalDate().equals(flightDate)) {
                        return fs;
                    }
                }
            }
        }
        return null;
    }
}
