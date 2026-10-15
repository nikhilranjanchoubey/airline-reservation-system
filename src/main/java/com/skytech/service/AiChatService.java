package com.skytech.service;

import com.airline.model.User;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.skytech.dao.BookingDao;
import com.skytech.model.Airport;
import com.skytech.model.Booking;
import com.skytech.model.Flight;
import com.skytech.model.FlightSchedule;
import com.skytech.util.AppConfig;

import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * SkyTech AI Flight Assistant Core Service.
 * Orchestrates conversational slot filling, real-time flight searches via ReefAPI/Database,
 * and authenticated booking inquiries.
 */
public class AiChatService {

    private static final Logger LOGGER = Logger.getLogger(AiChatService.class.getName());
    public static final ZoneId APP_ZONE = ZoneId.of("Asia/Kolkata");
    private static final Duration API_TIMEOUT = Duration.ofSeconds(15);
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private final HttpClient httpClient;
    private final FlightSearchService flightSearchService;
    private final BookingDao bookingDao;
    private final AirportResolutionService airportResolver;

    // Rate limiting tracker: session/IP -> list of request timestamps (epoch ms)
    private static final Map<String, List<Long>> RATE_LIMIT_TRACKER = new ConcurrentHashMap<>();
    private static final int MAX_REQUESTS_PER_MINUTE = 25;

    // In-memory fallback conversation states: clientId -> state
    private static final Map<String, AiConversationState> SESSION_STATES = new ConcurrentHashMap<>();

    public AiChatService() {
        this(HttpClient.newBuilder().connectTimeout(API_TIMEOUT).build(),
             new FlightSearchService(),
             new BookingDao());
    }

    public AiChatService(HttpClient httpClient, FlightSearchService flightSearchService, BookingDao bookingDao) {
        this.httpClient = httpClient;
        this.flightSearchService = flightSearchService;
        this.bookingDao = bookingDao;
        this.airportResolver = new AirportResolutionService();
    }

    /**
     * DTO representing a structured message in the conversation.
     */
    public static class ChatMessage {
        private String role; // "user" or "model" / "assistant"
        private String text;

        public ChatMessage() {}
        public ChatMessage(String role, String text) {
            this.role = role;
            this.text = text;
        }
        public String getRole() { return role; }
        public void setRole(String role) { this.role = role; }
        public String getText() { return text; }
        public void setText(String text) { this.text = text; }
    }

    /**
     * DTO for structured flight card rendering in the chatbot UI.
     */
    public static class FlightCard {
        public int scheduleId;
        public String flightNumber;
        public String airline;
        public String origin;
        public String originCity;
        public String destination;
        public String destinationCity;
        public String departureTime;
        public String arrivalTime;
        public String duration;
        public BigDecimal fare;
        public String formattedFare;
        public int availableSeats;
        public String flightDate;
        public String bookUrl;
    }

    /**
     * DTO for AI Chat Response.
     */
    public static class ChatResponse {
        public boolean success;
        public String reply;
        public List<FlightCard> flights;
        public List<Map<String, String>> actionButtons;
        public String error;
        @com.fasterxml.jackson.annotation.JsonIgnore
        public AiConversationState state;

        public ChatResponse() {
            this.flights = new ArrayList<>();
            this.actionButtons = new ArrayList<>();
        }
    }

    public boolean isRateLimited(String clientId) {
        if (clientId == null || clientId.trim().isEmpty()) return false;
        long now = System.currentTimeMillis();
        long windowStart = now - 60_000L;

        List<Long> timestamps = RATE_LIMIT_TRACKER.compute(clientId, (k, list) -> {
            if (list == null) list = new ArrayList<>();
            list.removeIf(ts -> ts < windowStart);
            list.add(now);
            return list;
        });

        return timestamps.size() > MAX_REQUESTS_PER_MINUTE;
    }

    public ChatResponse processChat(String userMessage, List<ChatMessage> history, User currentUser, String contextPath) {
        return processChat(userMessage, history, currentUser, contextPath, null);
    }

    /**
     * Main entry point to process a chat message with structured conversation state.
     */
    public ChatResponse processChat(String userMessage, List<ChatMessage> history, User currentUser, String contextPath, AiConversationState state) {
        ChatResponse response = new ChatResponse();

        if (userMessage == null || userMessage.trim().isEmpty()) {
            response.success = false;
            response.error = "Please enter a question or request.";
            return response;
        }

        if (state == null) {
            state = new AiConversationState();
        }
        response.state = state;

        String sanitizedMsg = userMessage.trim();
        if (sanitizedMsg.length() > 1000) {
            sanitizedMsg = sanitizedMsg.substring(0, 1000);
        }

        String baseContext = (contextPath != null && !contextPath.isEmpty()) ? contextPath : "";
        String lower = sanitizedMsg.toLowerCase(Locale.ENGLISH);

        // 1. Explicit Quick Actions & Commands
        if (isQuickActionCommand(lower, sanitizedMsg)) {
            return processQuickActionText(lower, currentUser, baseContext, state);
        }

        // 2. Check for PNR query
        String extractedPnr = extractPnr(sanitizedMsg);
        if (extractedPnr != null) {
            return handlePnrInquiry(extractedPnr, currentUser, baseContext);
        }

        // 3. Check for "my bookings" / "my trips"
        if (isMyBookingsInquiry(sanitizedMsg)) {
            return handleMyBookingsInquiry(currentUser, baseContext);
        }

        // 4. Flight Status Intent or Flight Number Lookup
        String extractedFlightNum = extractFlightNumber(sanitizedMsg);
        boolean isStatusIntent = "STATUS".equalsIgnoreCase(state.getActiveIntent());
        if (extractedFlightNum != null && (isStatusIntent || lower.contains("status") || lower.contains("flight") || sanitizedMsg.matches("(?i)^(?:6E|AI|QP|UK|SG|IX|I5|G8|[A-Z]{2})\\s*\\d{3,4}$"))) {
            return handleFlightNumberStatus(extractedFlightNum, sanitizedMsg, state, baseContext);
        }
        if (isStatusIntent || lower.equals("flight status") || lower.startsWith("flight status for") || lower.startsWith("status of")) {
            // Check if user specified route + date for status
            ChatResponse routeStatusResp = handleRouteStatusLookup(sanitizedMsg, state, baseContext);
            if (routeStatusResp != null) {
                return routeStatusResp;
            }
            if (isStatusIntent && extractedFlightNum == null && !lower.contains("find") && !lower.contains("book")) {
                ChatResponse statusPrompt = new ChatResponse();
                statusPrompt.success = true;
                statusPrompt.state = state;
                statusPrompt.reply = "Please enter your airline and flight number (e.g. *6E 204* or *AI 2762*), or tell me your route and travel date to check status.";
                addNavigationButton(statusPrompt, "Open Flight Status Tracker", baseContext + "/flight-status");
                return statusPrompt;
            }
        }

        // 5. Follow-up: Budget Filter on previous search results
        if (isBudgetFilterQuery(lower) && !state.getLastFlights().isEmpty()) {
            BigDecimal budget = extractBudgetAmount(sanitizedMsg);
            if (budget != null) {
                state.setMaxBudget(budget);
                return handleBudgetFilter(state, budget, baseContext);
            }
        }

        // 6. Follow-up: Destination change on existing search
        if (isDestinationChangeQuery(lower) && state.getOriginCode() != null) {
            String newDestQuery = extractNewDestination(sanitizedMsg);
            AirportResolutionService.ResolutionResult res = airportResolver.resolve(newDestQuery);
            if (res.resolved) {
                state.setDestination(res.getCode(), res.getCity(), res.airport.getAirportName());
                state.setAwaitingField(null);
                if (state.isReadyForSearch()) {
                    return executeFlightSearch(state, baseContext, state.isCheapestRequested());
                }
            }
        }

        // 7. Follow-up: Date change on existing search
        if (isDateChangeQuery(lower) && state.getOriginCode() != null && state.getDestCode() != null) {
            AiDateParser.DateParseResult dateRes = AiDateParser.parseDates(sanitizedMsg, LocalDate.now(APP_ZONE));
            if (dateRes.departureDate != null) {
                if (dateRes.isPastDate) {
                    response.success = true;
                    response.reply = "Travel dates in the past are not valid. Please select today (" + LocalDate.now(APP_ZONE) + ") or a future travel date.";
                    return response;
                }
                state.setDepartureDate(dateRes.departureDate);
                state.setAwaitingField(null);
                return executeFlightSearch(state, baseContext, state.isCheapestRequested());
            }
        }

        // 8. Follow-up: Sort by departure time
        if (isSortByDepartureQuery(lower) && !state.getLastFlights().isEmpty()) {
            return handleSortByDeparture(state, baseContext);
        }

        // 9. Follow-up: Cheapest three / top 3 options
        if (isCheapestThreeQuery(lower) && !state.getLastFlights().isEmpty()) {
            return handleCheapestThree(state, baseContext);
        }

        // 10. Follow-up: Direct flight inquiry
        if (isDirectFlightQuery(lower) && !state.getLastFlights().isEmpty()) {
            return handleDirectFlights(state, baseContext);
        }

        // 11. Follow-up: Passenger count change
        if (isPassengerChangeQuery(lower) && state.getOriginCode() != null && state.getDestCode() != null) {
            return handlePassengerChange(sanitizedMsg, state, baseContext);
        }

        // 12. Follow-up: Return flight request
        if (isReturnFlightQuery(lower) && state.getOriginCode() != null && state.getDestCode() != null) {
            return handleReturnFlight(state, baseContext);
        }

        // 13. General Flight Search / Conversational Slot Filling
        boolean handledBySlotFilling = handleSlotFilling(sanitizedMsg, state, response, baseContext);
        if (handledBySlotFilling) {
            return response;
        }

        // 14. General Travel FAQ / Gemini AI Query
        return handleGeminiChat(sanitizedMsg, history, currentUser, baseContext);
    }

    private boolean isQuickActionCommand(String lower, String raw) {
        return lower.equals("find flights") || lower.equals("search flights")
                || lower.equals("find cheapest flights") || lower.equals("cheapest")
                || lower.equals("manage my booking") || lower.equals("booking")
                || lower.equals("contact support") || lower.equals("support")
                || lower.equals("flight status") || lower.equals("status")
                || lower.equals("retry") || lower.equals("retry search")
                || lower.equals("new search") || lower.equals("start over") || lower.equals("reset")
                || lower.equals("search");
    }

    private ChatResponse processQuickActionText(String lower, User currentUser, String baseContext, AiConversationState state) {
        if (lower.contains("support") || lower.contains("contact")) {
            return handleSupportAction(state, baseContext);
        } else if (lower.contains("cheapest")) {
            return handleCheapestAction(state, baseContext);
        } else if (lower.contains("search") || lower.contains("find flight") || lower.equals("new search") || lower.equals("start over") || lower.equals("reset")) {
            return handleSearchAction(state, baseContext);
        } else if (lower.contains("booking")) {
            return handleBookingAction(currentUser, state, baseContext);
        } else if (lower.contains("status")) {
            return handleStatusAction(state, baseContext);
        } else if (lower.contains("retry")) {
            return handleRetryAction(state, baseContext);
        }
        return handleSearchAction(state, baseContext);
    }

    /**
     * Handles structured quick actions clicked by the user.
     */
    public ChatResponse processAction(String action, User currentUser, String contextPath, AiConversationState state) {
        String baseContext = (contextPath != null && !contextPath.isEmpty()) ? contextPath : "";
        if (state == null) {
            state = new AiConversationState();
        }
        String act = (action != null) ? action.trim().toLowerCase(Locale.ENGLISH) : "";

        switch (act) {
            case "cheapest":
                return handleCheapestAction(state, baseContext);
            case "search":
            case "find_flights":
                return handleSearchAction(state, baseContext);
            case "booking":
                return handleBookingAction(currentUser, state, baseContext);
            case "support":
                return handleSupportAction(state, baseContext);
            case "status":
                return handleStatusAction(state, baseContext);
            case "retry":
                return handleRetryAction(state, baseContext);
            default:
                return handleSearchAction(state, baseContext);
        }
    }

    public ChatResponse handleSupportAction(AiConversationState state, String baseContext) {
        state.setActiveIntent("SUPPORT");
        ChatResponse resp = new ChatResponse();
        resp.success = true;
        resp.state = state;

        String supportEmail = AppConfig.getSupportEmail();
        String supportPhone = AppConfig.getSupportPhone();
        String supportHours = AppConfig.getSupportHours();

        boolean hasContact = (supportEmail != null && !supportEmail.trim().isEmpty())
                || (supportPhone != null && !supportPhone.trim().isEmpty());

        if (!hasContact) {
            resp.reply = "CONTACT SKYTECH SUPPORT\n\nContact details are not configured yet.";
            addActionButton(resp, "Back to Chat", "Search Flights");
            return resp;
        }

        StringBuilder sb = new StringBuilder();
        sb.append("CONTACT SKYTECH SUPPORT\n\n");
        if (supportEmail != null && !supportEmail.trim().isEmpty()) {
            sb.append("• **Email:** ").append(supportEmail.trim()).append("\n");
        }
        if (supportPhone != null && !supportPhone.trim().isEmpty()) {
            sb.append("• **Phone:** ").append(supportPhone.trim()).append("\n");
        }
        if (supportHours != null && !supportHours.trim().isEmpty()) {
            sb.append("• **Support hours:** ").append(supportHours.trim()).append("\n");
        }

        resp.reply = sb.toString();

        if (supportEmail != null && !supportEmail.trim().isEmpty()) {
            addNavigationButton(resp, "Email Support", "mailto:" + supportEmail.trim());
        }
        if (supportPhone != null && !supportPhone.trim().isEmpty()) {
            String cleanTel = supportPhone.replaceAll("[^0-9+]", "");
            addNavigationButton(resp, "Call Support", "tel:" + cleanTel);
        }
        addNavigationButton(resp, "Travel Information", baseContext + "/travel-information");
        addActionButton(resp, "Back to Chat", "Search Flights");
        return resp;
    }

    public ChatResponse handleCheapestAction(AiConversationState state, String baseContext) {
        state.setActiveIntent("CHEAPEST");
        state.setCheapestRequested(true);
        ChatResponse resp = new ChatResponse();
        resp.success = true;
        resp.state = state;

        if (state.isReadyForSearch()) {
            return executeFlightSearch(state, baseContext, true);
        }

        if (state.getOriginCode() != null && state.getDestCode() == null) {
            state.setAwaitingField("destination");
            resp.reply = String.format("Let's find the lowest fares from **%s**! Where would you like to fly to, and on what date?", state.getOriginCity());
            return resp;
        }

        if (state.getOriginCode() != null && state.getDestCode() != null && state.getDepartureDate() == null) {
            state.setAwaitingField("date");
            resp.reply = String.format("When would you like to fly from **%s** to **%s** to get the best price?", state.getOriginCity(), state.getDestCity());
            return resp;
        }

        state.setAwaitingField("origin");
        resp.reply = "Let's find the lowest available fares! ✈️\n\n" +
                "Where are you flying from, where are you going, and when would you like to travel?\n\n" +
                "You can enter everything in one message, for example:\n" +
                "*'Cheapest flights from Jaipur to Mumbai tomorrow.'*";
        addNavigationButton(resp, "Open Flight Search", baseContext + "/search-flights");
        return resp;
    }

    public ChatResponse handleSearchAction(AiConversationState state, String baseContext) {
        state.setActiveIntent("SEARCH");
        state.setCheapestRequested(false);
        ChatResponse resp = new ChatResponse();
        resp.success = true;
        resp.state = state;

        if (state.isReadyForSearch()) {
            return executeFlightSearch(state, baseContext, false);
        }

        if (state.getOriginCode() != null && state.getDestCode() == null) {
            state.setAwaitingField("destination");
            resp.reply = String.format("Flying from **%s** — where would you like to go, and when?", state.getOriginCity());
            return resp;
        }

        if (state.getOriginCode() != null && state.getDestCode() != null && state.getDepartureDate() == null) {
            state.setAwaitingField("date");
            resp.reply = String.format("When would you like to travel from **%s** to **%s**?", state.getOriginCity(), state.getDestCity());
            return resp;
        }

        state.setAwaitingField("origin");
        resp.reply = "Where would you like to fly?\n\n" +
                "Enter your origin, destination, and travel date in one message.\n\n" +
                "Example:\n" +
                "*\"Flights from Bengaluru to Jaipur on 20 October 2026.\"*";
        addNavigationButton(resp, "Open Flight Search", baseContext + "/search-flights");
        return resp;
    }

    public ChatResponse handleBookingAction(User currentUser, AiConversationState state, String baseContext) {
        state.setActiveIntent("BOOKING");
        ChatResponse resp = new ChatResponse();
        resp.success = true;
        resp.state = state;

        if (currentUser != null) {
            return handleMyBookingsInquiry(currentUser, baseContext);
        }

        resp.reply = "Need help with an existing booking?\n\n" +
                "You can look up your booking to review its details and access the available booking-management options.";
        addNavigationButton(resp, "Open My Bookings", baseContext + "/manage-booking");
        addNavigationButton(resp, "Sign In to Account", baseContext + "/login");
        return resp;
    }

    public ChatResponse handleStatusAction(AiConversationState state, String baseContext) {
        state.setActiveIntent("STATUS");
        ChatResponse resp = new ChatResponse();
        resp.success = true;
        resp.state = state;

        resp.reply = "Check your flight status ✈️\n\n" +
                "Enter your airline and flight number, for example, 6E 204.\n\n" +
                "If you don't know the flight number, tell me your route and travel date.";
        addNavigationButton(resp, "Open Flight Status Tracker", baseContext + "/flight-status");
        return resp;
    }

    public ChatResponse handleRetryAction(AiConversationState state, String baseContext) {
        if (state.isReadyForSearch()) {
            return executeFlightSearch(state, baseContext, state.isCheapestRequested());
        }
        return handleSearchAction(state, baseContext);
    }

    public String extractFlightNumber(String text) {
        if (text == null) return null;
        Pattern p = Pattern.compile("(?i)\\b(6E|AI|QP|UK|SG|IX|I5|G8|[A-Z]{2})\\s*([0-9]{3,4})\\b");
        Matcher m = p.matcher(text.trim());
        if (m.find()) {
            return (m.group(1).toUpperCase() + " " + m.group(2)).trim();
        }
        return null;
    }

    private ChatResponse handleFlightNumberStatus(String flightNum, String text, AiConversationState state, String baseContext) {
        ChatResponse resp = new ChatResponse();
        resp.success = true;
        resp.state = state;
        state.setFlightNumber(flightNum);

        LocalDate today = LocalDate.now(APP_ZONE);
        AiDateParser.DateParseResult dateRes = AiDateParser.parseDates(text, today);
        LocalDate targetDate = (dateRes.departureDate != null && !dateRes.isPastDate) ? dateRes.departureDate : today;

        DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd MMM yyyy");

        try {
            FlightSchedule fs = flightSearchService.getFlightByFlightNumber(flightNum, targetDate);
            if (fs != null && fs.getFlight() != null) {
                Flight f = fs.getFlight();
                String airline = (f.getAirline() != null) ? f.getAirline().getAirlineName() : "SkyTech Partner";
                String flightNo = (f.getFlightNumber() != null) ? f.getFlightNumber() : flightNum;
                String src = (f.getSourceAirport() != null) ? f.getSourceAirport().getCity() + " (" + f.getSourceAirport().getAirportCode() + ")" : "Origin";
                String dst = (f.getDestinationAirport() != null) ? f.getDestinationAirport().getCity() + " (" + f.getDestinationAirport().getAirportCode() + ")" : "Destination";
                String dep = (f.getDepartureTime() != null) ? f.getDepartureTime().toString().substring(0, 5) : "--:--";
                String arr = (f.getArrivalTime() != null) ? f.getArrivalTime().toString().substring(0, 5) : "--:--";
                String status = (fs.getStatus() != null && !fs.getStatus().trim().isEmpty()) ? fs.getStatus().toUpperCase() : "ON TIME";
                String aircraft = (f.getAircraftModel() != null) ? f.getAircraftModel() : "Commercial Aircraft";
                String terminal = (f.getSourceAirport() != null && f.getSourceAirport().getTerminal() != null) ? f.getSourceAirport().getTerminal() : "Terminal 1";

                resp.reply = String.format("✈️ **Flight Status: %s — %s**\n" +
                        "Date: **%s**\n\n" +
                        "• **Route:** %s → %s\n" +
                        "• **Scheduled Departure:** %s (%s)\n" +
                        "• **Scheduled Arrival:** %s\n" +
                        "• **Operational Status:** `%s`\n" +
                        "• **Aircraft:** %s\n\n" +
                        "*Published schedule information.*",
                        flightNo, airline, targetDate.format(dateFmt), src, dst, dep, terminal, arr, status, aircraft);

                String encodedFlightNum = "";
                try {
                    encodedFlightNum = java.net.URLEncoder.encode(flightNo, java.nio.charset.StandardCharsets.UTF_8);
                } catch (Exception ignored) {}

                addNavigationButton(resp, "Open Flight Status Tracker", baseContext + "/flight-status?flightNumber=" + encodedFlightNum + "&flightDate=" + targetDate);
                addNavigationButton(resp, "Search Flights", baseContext + "/search-flights");
                return resp;
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "[AI-CHAT] Error querying flight status: " + e.getMessage());
        }

        String encodedFlightNum = "";
        try {
            encodedFlightNum = java.net.URLEncoder.encode(flightNum, java.nio.charset.StandardCharsets.UTF_8);
        } catch (Exception ignored) {}

        resp.reply = String.format("I checked scheduled operations for flight **%s** on **%s**, but no active schedule was found in our system.\n\n" +
                "Live flight status is not currently available for this flight. You can check scheduled flights on our [Flight Status](%s) page or search for available routes.",
                flightNum, targetDate.format(dateFmt), baseContext + "/flight-status?flightNumber=" + encodedFlightNum);

        addNavigationButton(resp, "Open Flight Status Tracker", baseContext + "/flight-status?flightNumber=" + encodedFlightNum);
        addNavigationButton(resp, "Search Available Routes", baseContext + "/search-flights");
        return resp;
    }

    private ChatResponse handleRouteStatusLookup(String text, AiConversationState state, String baseContext) {
        AiConversationState tempState = new AiConversationState();
        extractAirportsFromText(text, tempState);

        LocalDate today = LocalDate.now(APP_ZONE);
        AiDateParser.DateParseResult dateRes = AiDateParser.parseDates(text, today);
        LocalDate targetDate = (dateRes.departureDate != null && !dateRes.isPastDate) ? dateRes.departureDate : today;

        if (tempState.getOriginCode() != null && tempState.getDestCode() != null) {
            DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd MMM yyyy");
            try {
                List<FlightSchedule> schedules = flightSearchService.searchFlights(tempState.getOriginCode(), tempState.getDestCode(), targetDate, 1, "Economy");
                if (schedules != null && !schedules.isEmpty()) {
                    ChatResponse resp = new ChatResponse();
                    resp.success = true;
                    resp.state = state;

                    StringBuilder sb = new StringBuilder();
                    sb.append(String.format("✈️ **Scheduled Flights: %s → %s** on **%s**:\n\n",
                            tempState.getOriginCity(), tempState.getDestCity(), targetDate.format(dateFmt)));

                    int limit = Math.min(schedules.size(), 4);
                    for (int i = 0; i < limit; i++) {
                        FlightSchedule fs = schedules.get(i);
                        Flight f = fs.getFlight();
                        String fNum = (f != null && f.getFlightNumber() != null) ? f.getFlightNumber() : "Flight";
                        String airline = (f != null && f.getAirline() != null) ? f.getAirline().getAirlineName() : "SkyTech";
                        String dep = (f != null && f.getDepartureTime() != null) ? f.getDepartureTime().toString().substring(0, 5) : "--:--";
                        String arr = (f != null && f.getArrivalTime() != null) ? f.getArrivalTime().toString().substring(0, 5) : "--:--";
                        String status = (fs.getStatus() != null && !fs.getStatus().trim().isEmpty()) ? fs.getStatus().toUpperCase() : "SCHEDULED";

                        sb.append(String.format("• **%s** (%s): %s → %s | Status: `%s`\n",
                                fNum, airline, dep, arr, status));
                    }
                    sb.append("\n*Published schedule information.*");
                    resp.reply = sb.toString();

                    addNavigationButton(resp, "Open Flight Status Tracker", baseContext + "/flight-status");
                    addNavigationButton(resp, "Search Flights", baseContext + "/search-flights?source=" + tempState.getOriginCode() + "&destination=" + tempState.getDestCode() + "&departureDate=" + targetDate);
                    return resp;
                }
            } catch (Exception ignored) {}
        }
        return null;
    }

    private boolean isBudgetFilterQuery(String lower) {
        return (lower.contains("under") || lower.contains("below") || lower.contains("less than")
                || lower.contains("budget") || lower.contains("max") || lower.contains("maximum"))
                && (lower.contains("5000") || lower.contains("₹") || lower.contains("inr") || lower.matches(".*\\b\\d{4,5}\\b.*"));
    }

    private BigDecimal extractBudgetAmount(String text) {
        Matcher m = Pattern.compile("(?:under|below|less than|within|max|budget)?\\s*(?:₹|rs\\.?|inr)?\\s*([0-9]{1,2},?[0-9]{3})\\b", Pattern.CASE_INSENSITIVE).matcher(text);
        if (m.find()) {
            String num = m.group(1).replace(",", "");
            try {
                return new BigDecimal(num);
            } catch (Exception ignored) {}
        }
        return null;
    }

    private ChatResponse handleBudgetFilter(AiConversationState state, BigDecimal maxBudget, String baseContext) {
        ChatResponse resp = new ChatResponse();
        resp.success = true;
        resp.state = state;

        List<FlightCard> original = state.getLastFlights();
        List<FlightCard> filtered = original.stream()
                .filter(fc -> fc.fare != null && fc.fare.compareTo(maxBudget) <= 0)
                .collect(Collectors.toList());

        if (filtered.isEmpty()) {
            resp.reply = String.format("I checked the available flights for **%s → %s** on **%s**, but none are priced under **₹%,.0f**.\n\n" +
                    "The lowest available fare is **%s**.",
                    state.getOriginCity(), state.getDestCity(),
                    state.getDepartureDate().format(DateTimeFormatter.ofPattern("dd MMM yyyy")),
                    maxBudget, original.get(0).formattedFare);
            resp.flights = original;
        } else {
            resp.reply = String.format("✈️ Found **%d flight(s)** under **₹%,.0f** from **%s** to **%s** on **%s**:",
                    filtered.size(), maxBudget, state.getOriginCity(), state.getDestCity(),
                    state.getDepartureDate().format(DateTimeFormatter.ofPattern("dd MMM yyyy")));
            resp.flights = filtered;
        }

        String searchUrl = constructSearchUrl(state, baseContext);
        addNavigationButton(resp, "View All Flights & Book", searchUrl);
        return resp;
    }

    private boolean isDestinationChangeQuery(String lower) {
        return lower.startsWith("change destination to ") || lower.startsWith("change my destination to ")
                || lower.startsWith("to ") || lower.contains("destination to ") || lower.startsWith("change to ");
    }

    private String extractNewDestination(String text) {
        return text.replaceAll("(?i)^(?:change\\s+(?:my\\s+)?destination\\s+to|change\\s+to|fly\\s+to|destination\\s+to|to)\\s+", "").trim();
    }

    private boolean isDateChangeQuery(String lower) {
        return lower.contains("move the date") || lower.contains("move date") || lower.contains("change date")
                || lower.contains("change travel date") || lower.contains("fly on") || lower.startsWith("date to ");
    }

    private boolean isSortByDepartureQuery(String lower) {
        return lower.contains("departure time") || lower.contains("sort by departure") || lower.contains("earliest flight") || lower.contains("sort by time");
    }

    private ChatResponse handleSortByDeparture(AiConversationState state, String baseContext) {
        ChatResponse resp = new ChatResponse();
        resp.success = true;
        resp.state = state;
        List<FlightCard> sorted = new ArrayList<>(state.getLastFlights());
        sorted.sort(Comparator.comparing(fc -> fc.departureTime != null ? fc.departureTime : ""));
        resp.flights = sorted;
        resp.reply = String.format("✈️ Flights from **%s** to **%s** on **%s** sorted by departure time:",
                state.getOriginCity(), state.getDestCity(),
                state.getDepartureDate() != null ? state.getDepartureDate().format(DateTimeFormatter.ofPattern("dd MMM yyyy")) : "");
        String searchUrl = constructSearchUrl(state, baseContext);
        addNavigationButton(resp, "View All Flights & Book", searchUrl);
        return resp;
    }

    private boolean isCheapestThreeQuery(String lower) {
        return lower.contains("cheapest three") || lower.contains("cheapest 3") || lower.contains("top 3") || lower.contains("three options") || lower.contains("3 options");
    }

    private ChatResponse handleCheapestThree(AiConversationState state, String baseContext) {
        ChatResponse resp = new ChatResponse();
        resp.success = true;
        resp.state = state;
        List<FlightCard> sorted = new ArrayList<>(state.getLastFlights());
        sorted.sort(Comparator.comparing(fc -> fc.fare != null ? fc.fare : BigDecimal.ZERO));
        int limit = Math.min(sorted.size(), 3);
        List<FlightCard> top3 = sorted.subList(0, limit);
        resp.flights = top3;
        resp.reply = String.format("✈️ Here are the **cheapest 3 flight options** from **%s** to **%s**:",
                state.getOriginCity(), state.getDestCity());
        String searchUrl = constructSearchUrl(state, baseContext);
        addNavigationButton(resp, "View All Flights & Book", searchUrl);
        return resp;
    }

    private boolean isDirectFlightQuery(String lower) {
        return lower.contains("direct flight") || lower.contains("direct flights") || lower.contains("non-stop") || lower.contains("nonstop");
    }

    private ChatResponse handleDirectFlights(AiConversationState state, String baseContext) {
        ChatResponse resp = new ChatResponse();
        resp.success = true;
        resp.state = state;
        List<FlightCard> direct = state.getLastFlights().stream()
                .filter(fc -> fc.duration == null || !fc.duration.toLowerCase().contains("stop"))
                .collect(Collectors.toList());
        if (direct.isEmpty()) {
            resp.reply = String.format("All scheduled flights between **%s** and **%s** have connecting stops. Here are the available options:",
                    state.getOriginCity(), state.getDestCity());
            resp.flights = state.getLastFlights();
        } else {
            resp.reply = String.format("✈️ Found **%d direct flight option(s)** from **%s** to **%s**:",
                    direct.size(), state.getOriginCity(), state.getDestCity());
            resp.flights = direct;
        }
        String searchUrl = constructSearchUrl(state, baseContext);
        addNavigationButton(resp, "View All Flights & Book", searchUrl);
        return resp;
    }

    private boolean isPassengerChangeQuery(String lower) {
        return (lower.contains("passenger") || lower.contains("passengers") || lower.contains("adults") || lower.contains("seats"))
                && (lower.contains("change") || lower.contains("set") || lower.contains("two") || lower.contains("three") || lower.matches(".*\\b\\d+\\b.*"));
    }

    private ChatResponse handlePassengerChange(String text, AiConversationState state, String baseContext) {
        Matcher m = Pattern.compile("(?i)\\b(\\d+|one|two|three|four|five|six)\\s*(?:passengers?|adults?|seats?)?\\b").matcher(text);
        int pax = 1;
        if (m.find()) {
            String val = m.group(1).toLowerCase(Locale.ENGLISH);
            switch (val) {
                case "one": pax = 1; break;
                case "two": pax = 2; break;
                case "three": pax = 3; break;
                case "four": pax = 4; break;
                case "five": pax = 5; break;
                case "six": pax = 6; break;
                default:
                    try { pax = Integer.parseInt(val); } catch (Exception ignored) {}
            }
        }
        state.setPassengers(pax);
        return executeFlightSearch(state, baseContext, false);
    }

    private boolean isReturnFlightQuery(String lower) {
        return lower.contains("return flight") || lower.contains("fly back") || lower.contains("now find a return") || lower.contains("booking return");
    }

    private ChatResponse handleReturnFlight(AiConversationState state, String baseContext) {
        ChatResponse resp = new ChatResponse();
        resp.success = true;
        resp.state = state;

        String prevOriginCode = state.getOriginCode();
        String prevOriginCity = state.getOriginCity();
        String prevOriginName = state.getOriginAirportName();

        state.setOrigin(state.getDestCode(), state.getDestCity(), state.getDestAirportName());
        state.setDestination(prevOriginCode, prevOriginCity, prevOriginName);

        if (state.getReturnDate() != null) {
            state.setDepartureDate(state.getReturnDate());
            state.setReturnDate(null);
            return executeFlightSearch(state, baseContext, true);
        } else {
            state.setDepartureDate(null);
            state.setAwaitingField("date");
            resp.reply = String.format("✈️ Let's find your return flight from **%s** back to **%s**! When would you like to return?",
                    state.getOriginCity(), state.getDestCity());
            return resp;
        }
    }

    /**
     * Slot-Filling Engine: Extracts parameters, updates state, and performs search when all required slots are present.
     */
    private boolean handleSlotFilling(String text, AiConversationState state, ChatResponse resp, String baseContext) {
        String lower = text.toLowerCase(Locale.ENGLISH);

        // Check Conversational Control actions
        if (lower.equals("choose departure") || lower.equals("departure")) {
            state.setAwaitingField("origin");
            resp.success = true;
            resp.reply = "Which city or airport will you be flying **from**? (e.g. *Jaipur*, *Delhi*, *Mumbai*, *BLR*)";
            return true;
        }
        if (lower.equals("choose destination") || lower.equals("destination")) {
            state.setAwaitingField("destination");
            resp.success = true;
            resp.reply = "Where would you like to travel? (e.g. *Mumbai*, *Goa*, *Bengaluru*, *BOM*)";
            return true;
        }
        if (lower.equals("select travel date") || lower.equals("select date") || lower.equals("travel date")) {
            state.setAwaitingField("date");
            resp.success = true;
            resp.reply = "When would you like to travel? (e.g. *tomorrow*, *next Friday*, or *25 October 2026*)";
            return true;
        }
        if (lower.equals("one way") || lower.equals("one-way")) {
            state.setTripType("one-way");
            state.setReturnDate(null);
            if (state.isReadyForSearch()) {
                ChatResponse searchResp = executeFlightSearch(state, baseContext, state.isCheapestRequested());
                resp.success = searchResp.success;
                resp.reply = searchResp.reply;
                resp.flights = searchResp.flights;
                resp.actionButtons = searchResp.actionButtons;
                return true;
            }
            resp.success = true;
            if (state.getOriginCode() == null && state.getDestCode() == null) {
                state.setAwaitingField("origin");
                resp.reply = "One-way flight selected. Where would you like to fly from and to?";
            } else if (state.getOriginCode() == null) {
                state.setAwaitingField("origin");
                resp.reply = "Which city or airport will you be flying **from**?";
            } else if (state.getDestCode() == null) {
                state.setAwaitingField("destination");
                resp.reply = String.format("Flying from **%s** — where would you like to travel?", state.getOriginCity());
            } else if (state.getDepartureDate() == null) {
                state.setAwaitingField("date");
                resp.reply = String.format("When would you like to travel from **%s** to **%s**?", state.getOriginCity(), state.getDestCity());
            }
            return true;
        }
        if (lower.equals("round trip") || lower.equals("round-trip")) {
            state.setTripType("round-trip");
            resp.success = true;
            if (state.getOriginCode() != null && state.getDestCode() != null && state.getDepartureDate() != null && state.getReturnDate() != null) {
                ChatResponse searchResp = executeFlightSearch(state, baseContext, state.isCheapestRequested());
                resp.success = searchResp.success;
                resp.reply = searchResp.reply;
                resp.flights = searchResp.flights;
                resp.actionButtons = searchResp.actionButtons;
                return true;
            } else if (state.getOriginCode() != null && state.getDestCode() != null && state.getDepartureDate() != null) {
                state.setAwaitingField("return_date");
                resp.reply = String.format("Round-trip travel selected for **%s → %s** departing **%s**.\n\nWhen would you like to return?",
                        state.getOriginCity(), state.getDestCity(), state.getDepartureDate());
                return true;
            }
            state.setAwaitingField("date");
            resp.reply = "Great, round-trip travel selected! ✈️ When would you like to depart and return?";
            return true;
        }

        // Date extraction first
        LocalDate today = LocalDate.now(APP_ZONE);
        AiDateParser.DateParseResult dateResult = AiDateParser.parseDates(text, today);
        boolean hasDate = (dateResult.departureDate != null || dateResult.returnDate != null);

        // Passenger count extraction (e.g. "for 2 adults", "3 passengers", "2 adults", "two adults", "2")
        Matcher paxMatcher = Pattern.compile("(?i)\\b(\\d+|one|two|three|four|five|six|seven|eight|nine)\\s*(?:adults?|passengers?|seats?|people|pax)?\\b").matcher(text);
        boolean hasPax = false;
        if (paxMatcher.find() && (lower.contains("passenger") || lower.contains("adult") || lower.contains("seat") || "passengers".equals(state.getAwaitingField()) || text.trim().matches("^\\d+$"))) {
            String val = paxMatcher.group(1).toLowerCase(Locale.ENGLISH);
            int count = 1;
            switch (val) {
                case "one": count = 1; break;
                case "two": count = 2; break;
                case "three": count = 3; break;
                case "four": count = 4; break;
                case "five": count = 5; break;
                case "six": count = 6; break;
                default:
                    try { count = Integer.parseInt(val); } catch (Exception ignored) {}
            }
            state.setPassengers(count);
            hasPax = true;
        }

        // Check if message mentions flights, travel, airports, dates, or answers a pending prompt
        boolean hasFlightKeywords = lower.contains("flight") || lower.contains("flights") || lower.contains("fly")
                || lower.contains("fare") || lower.contains("ticket") || lower.contains("cheapest") || lower.contains("cheap")
                || lower.contains("from ") || lower.contains("to ") || lower.contains("round trip") || lower.contains("one way");

        boolean hasAwaitingField = state.getAwaitingField() != null;

        if (!hasFlightKeywords && !hasAwaitingField && !hasDate && !hasPax) {
            return false;
        }

        // Travel Class extraction
        if (lower.contains("business")) {
            state.setTravelClass("Business");
        } else if (lower.contains("first class")) {
            state.setTravelClass("First");
        } else if (lower.contains("premium economy")) {
            state.setTravelClass("Premium Economy");
        }

        if (lower.contains("round trip") || lower.contains("roundtrip") || lower.contains("return")) {
            state.setTripType("round-trip");
        } else if (lower.contains("one way") || lower.contains("oneway") || lower.contains("single trip")) {
            state.setTripType("one-way");
        }

        // Apply parsed dates
        if (dateResult.departureDate != null) {
            if (dateResult.isPastDate) {
                resp.success = true;
                resp.reply = "Travel dates in the past are not valid. Please select today (" + today + ") or a future travel date.";
                return true;
            }
            if ("return_date".equals(state.getAwaitingField()) ||
                ("round-trip".equalsIgnoreCase(state.getTripType()) && state.getDepartureDate() != null && dateResult.returnDate == null)) {
                // User was asked for return date, or is supplying return date
                if (dateResult.departureDate.isBefore(state.getDepartureDate())) {
                    resp.success = true;
                    resp.reply = "Return date cannot be earlier than your departure date (" + state.getDepartureDate() + "). Please enter a valid return date.";
                    return true;
                }
                state.setReturnDate(dateResult.departureDate);
                state.setTripType("round-trip");
                state.setAwaitingField(null);
            } else {
                state.setDepartureDate(dateResult.departureDate);
            }
        }
        if (dateResult.returnDate != null) {
            if (dateResult.isReturnBeforeDeparture) {
                resp.success = true;
                resp.reply = "Return date cannot be earlier than your departure date. Please enter a valid return date.";
                return true;
            }
            state.setReturnDate(dateResult.returnDate);
            state.setTripType("round-trip");
            state.setAwaitingField(null);
        }

        // Airport / City extraction with Fuzzy Match confirmation
        FuzzyPromptResult fuzzy = extractAirportsFromText(text, state);
        if (fuzzy != null) {
            resp.success = true;
            resp.reply = String.format("Did you mean %s?", fuzzy.suggestedDisplayName);
            addActionButton(resp, fuzzy.suggestedDisplayName, fuzzy.suggestedDisplayName);
            addActionButton(resp, "Enter another city", "Choose " + fuzzy.slotType);
            state.setAwaitingField(fuzzy.slotType);
            return true;
        }

        // Check for identical departure and destination
        if (state.getOriginCode() != null && state.getDestCode() != null
                && state.getOriginCode().equalsIgnoreCase(state.getDestCode())) {
            resp.success = true;
            resp.reply = "Departure and arrival cities cannot be the same. Please choose a different destination.";
            state.setDestination(null, null, null);
            state.setAwaitingField("destination");
            return true;
        }

        // Check Round Trip requirements
        if ("round-trip".equalsIgnoreCase(state.getTripType()) && state.getOriginCode() != null && state.getDestCode() != null && state.getDepartureDate() != null && state.getReturnDate() == null) {
            state.setAwaitingField("return_date");
            resp.success = true;
            resp.reply = String.format("Got it! **%s → %s**, departing **%s**.\n\nWhen would you like to return?",
                    state.getOriginCity(), state.getDestCity(), state.getDepartureDate().format(DateTimeFormatter.ofPattern("dd MMM yyyy")));
            return true;
        }

        // If all required slots are present -> Execute Search!
        if (state.isReadyForSearch()) {
            state.setAwaitingField(null);
            ChatResponse searchResp = executeFlightSearch(state, baseContext, lower.contains("cheap") || state.isCheapestRequested());
            resp.success = searchResp.success;
            resp.reply = searchResp.reply;
            resp.flights = searchResp.flights;
            resp.actionButtons = searchResp.actionButtons;
            resp.error = searchResp.error;
            return true;
        }

        // Step-by-step missing field prompts
        resp.success = true;
        DateTimeFormatter displayDateFmt = DateTimeFormatter.ofPattern("dd MMM yyyy");
        if (state.getOriginCode() == null && state.getDestCode() == null) {
            state.setAwaitingField("origin");
            resp.reply = "Sure! ✈️ Where would you like to fly from, and where would you like to go?";
            addQuickSearchChips(resp);
        } else if (state.getOriginCode() == null) {
            state.setAwaitingField("origin");
            resp.reply = "Which city or airport will you be flying **from**?";
        } else if (state.getDestCode() == null) {
            state.setAwaitingField("destination");
            resp.reply = String.format("Flying from **%s** — where would you like to travel?", state.getOriginCity());
        } else if (state.getDepartureDate() == null) {
            state.setAwaitingField("date");
            resp.reply = String.format("When would you like to travel from **%s** to **%s**?", state.getOriginCity(), state.getDestCity());
        }

        return true;
    }

    private static class FuzzyPromptResult {
        String slotType; // "origin" or "destination"
        String suggestedDisplayName; // "Jaipur (JAI)"
        String originalQuery;
    }

    private FuzzyPromptResult extractAirportsFromText(String text, AiConversationState state) {
        String lower = text.toLowerCase(Locale.ENGLISH);

        // Pattern A: "from [origin] to [destination]"
        Pattern fromToPattern = Pattern.compile("(?i)(?:from\\s+)([a-zA-Z\\s-]+?)(?:\\s+to\\s+)([a-zA-Z\\s-]+?)(?:\\s+(?:on|for|tomorrow|today|returning|cheapest|at|next|under|class)|$)");
        Matcher ftm = fromToPattern.matcher(text);
        if (ftm.find()) {
            AirportResolutionService.ResolutionResult origRes = airportResolver.resolve(ftm.group(1));
            AirportResolutionService.ResolutionResult destRes = airportResolver.resolve(ftm.group(2));
            if (origRes.isFuzzyMatch && origRes.suggestedAirport != null) {
                FuzzyPromptResult f = new FuzzyPromptResult();
                f.slotType = "origin";
                f.suggestedDisplayName = origRes.getSuggestedDisplayName();
                f.originalQuery = ftm.group(1);
                if (destRes.resolved) {
                    state.setDestination(destRes.getCode(), destRes.getCity(), destRes.airport.getAirportName());
                }
                return f;
            }
            if (destRes.isFuzzyMatch && destRes.suggestedAirport != null) {
                FuzzyPromptResult f = new FuzzyPromptResult();
                f.slotType = "destination";
                f.suggestedDisplayName = destRes.getSuggestedDisplayName();
                f.originalQuery = ftm.group(2);
                if (origRes.resolved) {
                    state.setOrigin(origRes.getCode(), origRes.getCity(), origRes.airport.getAirportName());
                }
                return f;
            }
            if (origRes.resolved) {
                state.setOrigin(origRes.getCode(), origRes.getCity(), origRes.airport.getAirportName());
            }
            if (destRes.resolved) {
                state.setDestination(destRes.getCode(), destRes.getCity(), destRes.airport.getAirportName());
            }
            return null;
        }

        // Pattern B: "[origin] to [destination]"
        Pattern toPattern = Pattern.compile("(?i)^([a-zA-Z\\s-]+?)\\s+to\\s+([a-zA-Z\\s-]+?)(?:\\s+(?:on|for|tomorrow|today|returning|cheapest|at|next)|$)");
        Matcher tm = toPattern.matcher(text);
        if (tm.find()) {
            AirportResolutionService.ResolutionResult origRes = airportResolver.resolve(tm.group(1));
            AirportResolutionService.ResolutionResult destRes = airportResolver.resolve(tm.group(2));
            if (origRes.isFuzzyMatch && origRes.suggestedAirport != null) {
                FuzzyPromptResult f = new FuzzyPromptResult();
                f.slotType = "origin";
                f.suggestedDisplayName = origRes.getSuggestedDisplayName();
                f.originalQuery = tm.group(1);
                if (destRes.resolved) {
                    state.setDestination(destRes.getCode(), destRes.getCity(), destRes.airport.getAirportName());
                }
                return f;
            }
            if (destRes.isFuzzyMatch && destRes.suggestedAirport != null) {
                FuzzyPromptResult f = new FuzzyPromptResult();
                f.slotType = "destination";
                f.suggestedDisplayName = destRes.getSuggestedDisplayName();
                f.originalQuery = tm.group(2);
                if (origRes.resolved) {
                    state.setOrigin(origRes.getCode(), origRes.getCity(), origRes.airport.getAirportName());
                }
                return f;
            }
            if (origRes.resolved) {
                state.setOrigin(origRes.getCode(), origRes.getCity(), origRes.airport.getAirportName());
            }
            if (destRes.resolved) {
                state.setDestination(destRes.getCode(), destRes.getCity(), destRes.airport.getAirportName());
            }
            return null;
        }

        // Pattern C: "from [origin]"
        Matcher fromMatcher = Pattern.compile("(?i)(?:from\\s+)([a-zA-Z\\s-]+?)(?:\\s+(?:on|for|tomorrow|today|cheapest|next)|$)").matcher(text);
        if (fromMatcher.find()) {
            AirportResolutionService.ResolutionResult origRes = airportResolver.resolve(fromMatcher.group(1));
            if (origRes.isFuzzyMatch && origRes.suggestedAirport != null) {
                FuzzyPromptResult f = new FuzzyPromptResult();
                f.slotType = "origin";
                f.suggestedDisplayName = origRes.getSuggestedDisplayName();
                f.originalQuery = fromMatcher.group(1);
                return f;
            }
            if (origRes.resolved) {
                state.setOrigin(origRes.getCode(), origRes.getCity(), origRes.airport.getAirportName());
            }
        }

        // Pattern D: "to [destination]"
        Matcher toOnlyMatcher = Pattern.compile("(?i)(?:to\\s+)([a-zA-Z\\s-]+?)(?:\\s+(?:on|for|tomorrow|today|cheapest|next)|$)").matcher(text);
        if (toOnlyMatcher.find()) {
            AirportResolutionService.ResolutionResult destRes = airportResolver.resolve(toOnlyMatcher.group(1));
            if (destRes.isFuzzyMatch && destRes.suggestedAirport != null) {
                FuzzyPromptResult f = new FuzzyPromptResult();
                f.slotType = "destination";
                f.suggestedDisplayName = destRes.getSuggestedDisplayName();
                f.originalQuery = toOnlyMatcher.group(1);
                return f;
            }
            if (destRes.resolved) {
                state.setDestination(destRes.getCode(), destRes.getCity(), destRes.airport.getAirportName());
            }
        }

        // Pattern E: Single city when awaiting field
        if ("origin".equals(state.getAwaitingField()) && state.getOriginCode() == null) {
            AirportResolutionService.ResolutionResult res = airportResolver.resolve(text);
            if (res.isFuzzyMatch && res.suggestedAirport != null) {
                FuzzyPromptResult f = new FuzzyPromptResult();
                f.slotType = "origin";
                f.suggestedDisplayName = res.getSuggestedDisplayName();
                f.originalQuery = text;
                return f;
            }
            if (res.resolved) {
                state.setOrigin(res.getCode(), res.getCity(), res.airport.getAirportName());
            }
        } else if ("destination".equals(state.getAwaitingField()) && state.getDestCode() == null) {
            AirportResolutionService.ResolutionResult res = airportResolver.resolve(text);
            if (res.isFuzzyMatch && res.suggestedAirport != null) {
                FuzzyPromptResult f = new FuzzyPromptResult();
                f.slotType = "destination";
                f.suggestedDisplayName = res.getSuggestedDisplayName();
                f.originalQuery = text;
                return f;
            }
            if (res.resolved) {
                state.setDestination(res.getCode(), res.getCity(), res.airport.getAirportName());
            }
        }
        return null;
    }

    /**
     * Executes the actual flight search via the backend FlightSearchService.
     */
    private ChatResponse executeFlightSearch(AiConversationState state, String baseContext, boolean cheapestRequested) {
        ChatResponse resp = new ChatResponse();
        resp.success = true;
        resp.state = state;

        String origin = state.getOriginCode();
        String dest = state.getDestCode();
        LocalDate date = state.getDepartureDate();
        int passengers = state.getPassengers();
        String travelClass = state.getTravelClass();
        DateTimeFormatter displayDateFmt = DateTimeFormatter.ofPattern("dd MMM yyyy");

        try {
            LOGGER.info(String.format("[AI-CHAT] Executing real flight search: %s -> %s on %s (%s, %d pax)",
                    origin, dest, date, travelClass, passengers));

            List<FlightSchedule> schedules = flightSearchService.searchFlights(origin, dest, date, passengers, travelClass);

            String searchUrl = constructSearchUrl(state, baseContext);

            if (schedules == null || schedules.isEmpty()) {
                resp.reply = "No flights were returned for this search. Try different dates or airports.";
                addNavigationButton(resp, "Open Flight Search", searchUrl);
                return resp;
            }

            // Filter out schedules without a usable comparable fare
            List<FlightSchedule> validFares = schedules.stream()
                    .filter(s -> s.getBasePrice() != null && s.getBasePrice().compareTo(BigDecimal.ZERO) > 0)
                    .collect(Collectors.toList());

            if (validFares.isEmpty()) {
                resp.reply = "No flights were returned for this search. Try different dates or airports.";
                addNavigationButton(resp, "Open Flight Search", searchUrl);
                return resp;
            }

            // Sort by base price ascending (cheapest first)
            validFares.sort(Comparator.comparing(FlightSchedule::getBasePrice));

            FlightSchedule cheapest = validFares.get(0);

            StringBuilder replyBuilder = new StringBuilder();
            String cheapestAirline = (cheapest.getFlight() != null && cheapest.getFlight().getAirline() != null)
                    ? cheapest.getFlight().getAirline().getAirlineName() : "SkyTech Partner";
            String cheapestFlightNum = (cheapest.getFlight() != null && cheapest.getFlight().getFlightNumber() != null)
                    ? cheapest.getFlight().getFlightNumber() : "Flight";

            if (cheapestRequested) {
                replyBuilder.append(String.format("Lowest fare among the returned results: **%s**, **%s**, **₹%,.0f** (INR per passenger, base fare).\n\n",
                        cheapestAirline, cheapestFlightNum, cheapest.getBasePrice()));
                replyBuilder.append("Available options sorted by total fare (taxes & fees calculated at checkout):");
            } else {
                replyBuilder.append(String.format("Found **%d results** returned for **%s → %s** on **%s**.\n\n",
                        validFares.size(), origin, dest, date.format(displayDateFmt)));
                replyBuilder.append(String.format("Lowest fare among the returned results: **%s**, **%s**, **₹%,.0f** (INR per passenger).\n\n",
                        cheapestAirline, cheapestFlightNum, cheapest.getBasePrice()));
                replyBuilder.append("Here are the top available departures (taxes & fees calculated at checkout):");
            }

            // Convert up to top 4 flights into FlightCard DTOs
            int limit = Math.min(validFares.size(), 4);
            List<FlightCard> cards = new ArrayList<>();
            for (int i = 0; i < limit; i++) {
                FlightSchedule fs = validFares.get(i);
                FlightCard card = new FlightCard();
                card.scheduleId = fs.getScheduleId();
                card.flightDate = date.toString();
                card.origin = origin;
                card.originCity = state.getOriginCity();
                card.destination = dest;
                card.destinationCity = state.getDestCity();
                card.fare = fs.getBasePrice();
                card.formattedFare = String.format("₹%,.0f", fs.getBasePrice());
                card.availableSeats = fs.getAvailableSeats();

                Flight flight = fs.getFlight();
                String flightNum = "";
                if (flight != null) {
                    card.flightNumber = flight.getFlightNumber();
                    flightNum = (flight.getFlightNumber() != null) ? flight.getFlightNumber() : "";
                    card.airline = (flight.getAirline() != null) ? flight.getAirline().getAirlineName() : "SkyTech";
                    card.departureTime = (flight.getDepartureTime() != null) ? flight.getDepartureTime().toString().substring(0, 5) : "--:--";
                    card.arrivalTime = (flight.getArrivalTime() != null) ? flight.getArrivalTime().toString().substring(0, 5) : "--:--";
                    card.duration = flight.getDurationMinutes() > 0 ? (flight.getDurationMinutes() / 60 + "h " + flight.getDurationMinutes() % 60 + "m") : "Non-stop";
                }

                String encodedFlightNum = "";
                try {
                    encodedFlightNum = java.net.URLEncoder.encode(flightNum, java.nio.charset.StandardCharsets.UTF_8);
                } catch (Exception ignored) {}

                // Dynamic relative URL to existing booking workflow
                card.bookUrl = baseContext + "/book-flight"
                        + "?scheduleId=" + fs.getScheduleId()
                        + "&id=" + fs.getScheduleId()
                        + "&flightNumber=" + encodedFlightNum
                        + "&origin=" + origin
                        + "&source=" + origin
                        + "&destination=" + dest
                        + "&dest=" + dest
                        + "&departureDate=" + date
                        + "&travelClass=" + travelClass
                        + "&passengers=" + passengers;

                cards.add(card);
            }

            resp.flights = cards;
            state.setLastFlights(cards);
            state.setLastSearchDate(date);

            resp.reply = replyBuilder.toString();
            addNavigationButton(resp, "View All Flights & Book", searchUrl);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[AI-CHAT] Error searching flights: " + e.getMessage(), e);
            resp.reply = "We couldn't retrieve live flight results right now. You can try again or open the SkyTech flight-search page.";
            addActionButton(resp, "Retry Search", "retry");
            addNavigationButton(resp, "Open Flight Search", constructSearchUrl(state, baseContext));
        }

        return resp;
    }

    private String constructSearchUrl(AiConversationState state, String baseContext) {
        return baseContext + "/search-flights"
                + "?source=" + state.getOriginCode()
                + "&origin=" + state.getOriginCode()
                + "&destination=" + state.getDestCode()
                + "&dest=" + state.getDestCode()
                + "&departureDate=" + state.getDepartureDate()
                + "&tripType=" + state.getTripType()
                + "&adults=" + state.getPassengers()
                + "&passengers=" + state.getPassengers()
                + "&travelClass=" + state.getTravelClass();
    }

    private void addQuickSearchChips(ChatResponse resp) {
        addActionButton(resp, "Choose Departure", "Choose Departure");
        addActionButton(resp, "Choose Destination", "Choose Destination");
        addActionButton(resp, "Select Travel Date", "Select Travel Date");
        addActionButton(resp, "One Way", "One way");
        addActionButton(resp, "Round Trip", "Round trip");
    }

    // ==========================================
    // Backward-Compatible Parameter Extraction for Existing Unit Tests
    // ==========================================

    public static class FlightSearchParams {
        public boolean isSearchIntent = false;
        public String originCode;
        public String originCity;
        public String destCode;
        public String destCity;
        public LocalDate departureDate;
        public int passengers = 1;
        public String travelClass = "Economy";
        public boolean cheapestRequested = false;
        public String missingInfoPrompt = null;
    }

    public FlightSearchParams extractFlightSearchParams(String text) {
        AiConversationState tempState = new AiConversationState();
        ChatResponse tempResp = new ChatResponse();
        handleSlotFilling(text, tempState, tempResp, "");

        FlightSearchParams params = new FlightSearchParams();
        params.originCode = tempState.getOriginCode();
        params.originCity = tempState.getOriginCity();
        params.destCode = tempState.getDestCode();
        params.destCity = tempState.getDestCity();
        params.departureDate = tempState.getDepartureDate();
        params.passengers = tempState.getPassengers();
        params.travelClass = tempState.getTravelClass();
        params.isSearchIntent = (params.originCode != null || params.destCode != null || text.toLowerCase().contains("flight"));
        params.cheapestRequested = text.toLowerCase().contains("cheap");
        params.missingInfoPrompt = tempResp.reply;

        return params;
    }

    // ==========================================
    // PNR & Booking Inquiries
    // ==========================================

    private String extractPnr(String text) {
        Matcher m = Pattern.compile("(?i)\\b(?:pnr|booking|reference)\\s*[:#-]?\\s*([A-Z0-9]{6})\\b").matcher(text);
        if (m.find()) {
            return m.group(1).toUpperCase();
        }
        Matcher m2 = Pattern.compile("^[A-Z0-9]{6}$").matcher(text.trim());
        if (m2.find()) {
            return m2.group(0).toUpperCase();
        }
        return null;
    }

    private boolean isMyBookingsInquiry(String text) {
        String lower = text.toLowerCase();
        return lower.contains("my booking") || lower.contains("my bookings")
                || lower.contains("my ticket") || lower.contains("my tickets")
                || lower.contains("my trip") || lower.contains("my trips")
                || lower.contains("where is my booking") || lower.contains("view booking")
                || lower.contains("view my booking") || lower.contains("show my booking");
    }

    private ChatResponse handlePnrInquiry(String pnr, User currentUser, String baseContext) {
        ChatResponse resp = new ChatResponse();
        resp.success = true;

        try {
            Booking booking = bookingDao.getBookingByReferenceOrPnr(pnr);
            if (booking == null) {
                resp.reply = String.format("I searched our database, but no reservation was found matching PNR **%s**.\n\n" +
                        "Please verify the 6-character code printed on your booking confirmation or check your email.", pnr);
                addNavigationButton(resp, "Search on Manage Booking", baseContext + "/manage-booking");
                return resp;
            }

            boolean isOwner = (currentUser != null && currentUser.getUserId() == booking.getUserId());

            if (isOwner) {
                resp.reply = String.format("🎫 **Booking Details for PNR %s**\n\n" +
                        "• **Status:** `%s`\n" +
                        "• **Flight:** %s (%s → %s)\n" +
                        "• **Travel Date:** %s\n" +
                        "• **Seat(s):** %s\n" +
                        "• **Total Amount:** %s %s\n\n" +
                        "You can manage, print tickets, or select seats below:",
                        booking.getPnr(),
                        booking.getStatus(),
                        booking.getFlightNumber(),
                        booking.getOriginCode(),
                        booking.getDestinationCode(),
                        (booking.getDepartureDate() != null ? booking.getDepartureDate().toString() : "Confirmed Schedule"),
                        (booking.getSeatNumbers() != null ? booking.getSeatNumbers() : "Assigned at Check-in"),
                        (booking.getCurrency() != null ? booking.getCurrency() : "INR"),
                        (booking.getTotalAmount() != null ? booking.getTotalAmount().toString() : "Paid"));

                addNavigationButton(resp, "Manage This Booking", baseContext + "/manage-booking?pnr=" + pnr);
                addNavigationButton(resp, "Download e-Ticket", baseContext + "/ticket?pnr=" + pnr);
            } else {
                resp.reply = String.format("Reservation **%s** is currently **%s** for flight **%s** (%s → %s).\n\n" +
                        "🔒 For passenger privacy and security, full ticket downloads and cancellations require authentication. " +
                        "Please sign in or enter your contact details on the Manage Booking page.",
                        booking.getPnr(), booking.getStatus(), booking.getFlightNumber(),
                        booking.getOriginCode(), booking.getDestinationCode());

                if (currentUser == null) {
                    addNavigationButton(resp, "Sign In to View Full Ticket", baseContext + "/login");
                }
                addNavigationButton(resp, "Verify on Manage Booking", baseContext + "/manage-booking?pnr=" + pnr);
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[AI-CHAT] Failed looking up PNR: " + pnr, e);
            resp.reply = "I had trouble retrieving details for that PNR. Please try using our [Manage Booking](" + baseContext + "/manage-booking) page directly.";
        }

        return resp;
    }

    private ChatResponse handleMyBookingsInquiry(User currentUser, String baseContext) {
        ChatResponse resp = new ChatResponse();
        resp.success = true;

        if (currentUser == null) {
            resp.reply = "Please sign in to view your personal bookings, e-tickets, and travel itineraries.";
            addNavigationButton(resp, "Sign In to Account", baseContext + "/login");
            addNavigationButton(resp, "Search Flights", baseContext + "/search-flights");
            return resp;
        }

        try {
            List<Booking> userBookings = bookingDao.getBookingsByUserId(currentUser.getUserId());
            if (userBookings == null || userBookings.isEmpty()) {
                resp.reply = "You don't have any bookings yet.\n\n" +
                        "Would you like to search for available flights across our network?";
                addNavigationButton(resp, "Search Flights", baseContext + "/search-flights");
                return resp;
            }

            int total = userBookings.size();
            long confirmed = 0;
            long pending = 0;
            long cancelledRefunded = 0;

            for (Booking b : userBookings) {
                if (b.isConfirmed()) {
                    confirmed++;
                } else if (b.isPending()) {
                    pending++;
                } else if (b.isCancelled()) {
                    cancelledRefunded++;
                }
            }

            StringBuilder sb = new StringBuilder();
            sb.append("My Bookings\n");
            sb.append(String.format("Total bookings: %d\n", total));
            sb.append(String.format("Confirmed: %d\n", confirmed));
            sb.append(String.format("Pending payment: %d\n", pending));
            sb.append(String.format("Cancelled/refunded: %d\n\n", cancelledRefunded));

            sb.append("Here are your recent flight reservations:\n\n");

            int count = 0;
            for (Booking b : userBookings) {
                if (count++ >= 5) break;

                String pnr = (b.getPnr() != null && !b.getPnr().isEmpty()) ? b.getPnr() : b.getBookingReference();
                String flight = (b.getFlightNumber() != null && !b.getFlightNumber().isEmpty()) ? b.getFlightNumber() : "Flight";
                String route = String.format("%s → %s", b.getOriginCode(), b.getDestinationCode());
                String date = (b.getDepartureDate() != null) ? b.getDepartureDate().toString() : "Scheduled";
                String bookingStatus = (b.getStatus() != null) ? b.getStatus() : "CONFIRMED";
                String totalFare = (b.getTotalAmount() != null) ? String.format("₹%,.0f", b.getTotalAmount()) : "Paid";

                sb.append(String.format("• **PNR:** `%s` | %s (%s) on %s\n", pnr, flight, route, date));
                sb.append(String.format("  Status: `%s` | Fare: **%s**\n", bookingStatus, totalFare));
            }

            resp.reply = sb.toString();

            // Provide View All Bookings (opens existing My Trips page)
            addNavigationButton(resp, "View All Bookings", baseContext + "/my-trips");

            // Contextual actions based on recent booking statuses
            boolean hasPending = userBookings.stream().anyMatch(Booking::isPending);
            boolean hasConfirmed = userBookings.stream().anyMatch(Booking::isConfirmed);

            if (hasConfirmed) {
                Booking latestConfirmed = userBookings.stream().filter(Booking::isConfirmed).findFirst().orElse(null);
                if (latestConfirmed != null) {
                    addNavigationButton(resp, "Download Ticket (PDF)", baseContext + "/ticket/download?id=" + latestConfirmed.getId());
                }
            }
            if (hasPending) {
                Booking latestPending = userBookings.stream().filter(Booking::isPending).findFirst().orElse(null);
                if (latestPending != null) {
                    addNavigationButton(resp, "Complete Payment", baseContext + "/booking/checkout?bookingId=" + latestPending.getId());
                }
            }

            addNavigationButton(resp, "Manage Bookings", baseContext + "/manage-booking");

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[AI-CHAT] Error retrieving user bookings: " + e.getMessage(), e);
            resp.reply = "I encountered an issue fetching your bookings. Please check your [My Trips](" + baseContext + "/my-trips) page directly.";
            addNavigationButton(resp, "View All Bookings", baseContext + "/my-trips");
        }

        return resp;
    }

    // ==========================================
    // Gemini 2.5 Flash Integration (General FAQ / Fallback)
    // ==========================================

    private ChatResponse handleGeminiChat(String userMessage, List<ChatMessage> history, User currentUser, String baseContext) {
        ChatResponse resp = new ChatResponse();
        resp.success = true;

        if (!AppConfig.isGeminiConfigured()) {
            LOGGER.log(Level.INFO, "[AI-CHAT] Gemini API is not configured. Serving verified local knowledge.");
            resp.reply = getFallbackKnowledgeResponse(userMessage, baseContext);
            attachContextualButtons(resp, userMessage, baseContext);
            return resp;
        }

        String apiKey = AppConfig.getGeminiApiKey();
        String model = AppConfig.getGeminiModel();
        String endpoint = "https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent?key=" + apiKey;

        try {
            String systemInstruction = buildSystemPrompt(currentUser, baseContext);

            ObjectNode root = OBJECT_MAPPER.createObjectNode();
            ObjectNode sysInstNode = root.putObject("systemInstruction");
            ArrayNode sysParts = sysInstNode.putArray("parts");
            sysParts.addObject().put("text", systemInstruction);

            ArrayNode contentsArray = root.putArray("contents");

            if (history != null && !history.isEmpty()) {
                int start = Math.max(0, history.size() - 6);
                for (int i = start; i < history.size(); i++) {
                    ChatMessage msg = history.get(i);
                    if (msg.getText() != null && !msg.getText().trim().isEmpty()) {
                        String role = "user".equalsIgnoreCase(msg.getRole()) ? "user" : "model";
                        ObjectNode contentNode = contentsArray.addObject();
                        contentNode.put("role", role);
                        ArrayNode parts = contentNode.putArray("parts");
                        parts.addObject().put("text", msg.getText().trim());
                    }
                }
            }

            ObjectNode currentMsgNode = contentsArray.addObject();
            currentMsgNode.put("role", "user");
            ArrayNode currentParts = currentMsgNode.putArray("parts");
            currentParts.addObject().put("text", userMessage);

            ObjectNode genConfig = root.putObject("generationConfig");
            genConfig.put("temperature", 0.4);
            genConfig.put("maxOutputTokens", 1024);

            String requestBody = OBJECT_MAPPER.writeValueAsString(root);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .header("Content-Type", "application/json")
                    .timeout(API_TIMEOUT)
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();

            HttpResponse<String> httpResponse = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (httpResponse.statusCode() == 200) {
                JsonNode resRoot = OBJECT_MAPPER.readTree(httpResponse.body());
                JsonNode candidates = resRoot.path("candidates");
                if (candidates.isArray() && candidates.size() > 0) {
                    JsonNode textNode = candidates.get(0).path("content").path("parts").get(0).path("text");
                    if (!textNode.isMissingNode()) {
                        resp.reply = textNode.asText().trim();
                        attachContextualButtons(resp, userMessage, baseContext);
                        return resp;
                    }
                }
            }

            // Fallback if rate limited (429) or other API issue
            resp.reply = getFallbackKnowledgeResponse(userMessage, baseContext);
            attachContextualButtons(resp, userMessage, baseContext);

        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "[AI-CHAT] Gemini communication fallback: " + e.getMessage());
            resp.reply = getFallbackKnowledgeResponse(userMessage, baseContext);
            attachContextualButtons(resp, userMessage, baseContext);
        }

        return resp;
    }

    private String buildSystemPrompt(User user, String baseContext) {
        StringBuilder sb = new StringBuilder();
        sb.append("You are SkyTech AI Flight Assistant, the official, intelligent virtual travel companion of SkyTech Airline Reservation System.\n");
        sb.append("Style: Welcoming, concise, professional, clear, and aviation-accurate. Keep responses brief (2-4 paragraphs max).\n");
        sb.append("Core Knowledge about SkyTech:\n");
        sb.append("1. Flight Search: Available at ").append(baseContext).append("/search-flights. Features one-way, round-trip, multi-city with live fares and seat selection.\n");
        sb.append("2. Manage Booking: Available at ").append(baseContext).append("/manage-booking. Allows checking PNR, seat reassignment, and cancellation.\n");
        sb.append("3. Baggage Allowance: Domestic Economy allows 7kg cabin baggage (1 bag + laptop bag) and 15kg checked baggage. Excess baggage can be purchased.\n");
        sb.append("4. Web Check-in: Opens 48 hours and closes 60 minutes before scheduled flight departure.\n");
        sb.append("5. Payments: Securely integrated via Razorpay gateway supporting credit/debit cards, UPI, and netbanking in test mode.\n");
        sb.append("6. Test / Evaluation Accounts: Admin (admin@airline.com / Admin@12345), Passenger (passenger@airline.com / Passenger@12345).\n");
        sb.append("7. Customer Support: Accessible via the footer or by emailing support@airline.com.\n");
        sb.append("Rules:\n");
        sb.append("- NEVER invent false flight schedules, false pricing, or fake airline policies.\n");
        sb.append("- Never duplicate welcome messages during an active flight search conversation.\n");
        sb.append("- Format replies using readable Markdown (bullet points, bold highlights, short paragraphs).\n");

        if (user != null) {
            sb.append("\nAuthenticated Traveler Context: Signed in as ").append(user.getFirstName()).append(" (Email: ").append(user.getEmail()).append(", Role: ").append(user.getRole()).append(").\n");
        } else {
            sb.append("\nTraveler Context: Guest / Not signed in.\n");
        }

        return sb.toString();
    }

    private void attachContextualButtons(ChatResponse resp, String query, String baseContext) {
        String lower = query.toLowerCase();
        if (lower.contains("status") || lower.contains("track")) {
            addNavigationButton(resp, "Flight Status", baseContext + "/flight-status");
        } else if (lower.contains("book") || lower.contains("flight") || lower.contains("search")) {
            addNavigationButton(resp, "Search Flights", baseContext + "/search-flights");
        } else if (lower.contains("ticket") || lower.contains("pnr") || lower.contains("cancel")) {
            addNavigationButton(resp, "Manage Booking", baseContext + "/manage-booking");
        } else if (lower.contains("support") || lower.contains("help") || lower.contains("contact")) {
            addNavigationButton(resp, "Travel Information", baseContext + "/travel-information");
        }
    }

    private String getFallbackKnowledgeResponse(String query, String baseContext) {
        String lower = query.toLowerCase();
        if (lower.contains("baggage")) {
            return "🧳 **SkyTech Baggage Allowance:**\n\n" +
                    "• **Cabin Baggage:** 1 piece up to 7 kg + 1 small personal item (laptop bag/purse).\n" +
                    "• **Check-in Baggage:** 15 kg per passenger for domestic Economy class.\n" +
                    "• Extra baggage can be added during booking or at airport check-in counters.";
        } else if (lower.contains("check-in") || lower.contains("checkin")) {
            return "🛫 **SkyTech Web Check-in:**\n\n" +
                    "• Web check-in opens **48 hours** before departure and closes **60 minutes** prior.\n" +
                    "• Have your **6-character PNR** and Last Name ready to select seats and generate boarding passes.";
        } else if (lower.contains("cancel") || lower.contains("refund")) {
            return "🔄 **Cancellations & Refunds:**\n\n" +
                    "• You can request booking cancellations via the [Manage Booking](" + baseContext + "/manage-booking) portal.\n" +
                    "• Refund amounts are calculated based on fare type and airline cancellation policies.";
        } else if (lower.contains("hello") || lower.contains("hi") || lower.contains("hey")) {
            return "Hello! I'm SkyTech AI Assistant ✈️\n\n" +
                    "Where would you like to travel from, where would you like to go, and when would you like to fly?\n\n" +
                    "You can type your complete travel request in one message.";
        } else {
            return "I am SkyTech AI Flight Assistant. I can help you search flights, track booking status by PNR, compare fares, or answer travel questions.\n\n" +
                    "Where would you like to fly from, and where would you like to go?";
        }
    }

    private void addNavigationButton(ChatResponse resp, String label, String url) {
        Map<String, String> btn = new HashMap<>();
        btn.put("label", label);
        btn.put("url", url);
        btn.put("action", "navigate");
        resp.actionButtons.add(btn);
    }

    private void addActionButton(ChatResponse resp, String label, String queryText) {
        Map<String, String> btn = new HashMap<>();
        btn.put("label", label);
        btn.put("text", queryText);
        btn.put("action", "query");
        resp.actionButtons.add(btn);
    }
}
