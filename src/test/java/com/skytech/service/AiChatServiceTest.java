package com.skytech.service;

import com.airline.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.*;

class AiChatServiceTest {

    private AiChatService aiChatService;

    @BeforeEach
    void setUp() {
        aiChatService = new AiChatService();
    }

    @Test
    @DisplayName("Test flight intent extraction from natural language query")
    void testExtractFlightSearchParams() {
        AiChatService.FlightSearchParams params = aiChatService.extractFlightSearchParams("Find the cheapest flight from Jaipur to Delhi tomorrow");
        assertNotNull(params);
        assertTrue(params.isSearchIntent);
        assertEquals("JAI", params.originCode);
        assertEquals("DEL", params.destCode);
        assertEquals(LocalDate.now(ZoneId.of("Asia/Kolkata")).plusDays(1), params.departureDate);
        assertTrue(params.cheapestRequested);
    }

    @Test
    @DisplayName("Test flight intent extraction with cities")
    void testExtractFlightSearchParamsCities() {
        AiChatService.FlightSearchParams params = aiChatService.extractFlightSearchParams("Find flights from Mumbai to Bangalore today");
        assertNotNull(params);
        assertTrue(params.isSearchIntent);
        assertEquals("BOM", params.originCode);
        assertEquals("BLR", params.destCode);
        assertEquals(LocalDate.now(ZoneId.of("Asia/Kolkata")), params.departureDate);
    }

    @Test
    @DisplayName("Test flight search query with missing destination produces helpful clarification")
    void testMissingDestinationGeneratesClarification() {
        AiChatService.ChatResponse response = aiChatService.processChat("Find me flights from Jaipur", new ArrayList<>(), null, "/airline-reservation-system");
        assertNotNull(response);
        assertTrue(response.success);
        assertNotNull(response.reply);
        assertTrue(response.reply.toLowerCase().contains("destination") || response.reply.toLowerCase().contains("where") || response.reply.toLowerCase().contains("to"));
    }

    @Test
    @DisplayName("Test baggage allowance FAQ gives verified accurate response")
    void testBaggageAllowanceFaq() {
        AiChatService.ChatResponse response = aiChatService.processChat("What is the baggage allowance?", new ArrayList<>(), null, "/airline-reservation-system");
        assertNotNull(response);
        assertTrue(response.success);
        assertNotNull(response.reply);
        String replyLower = response.reply.toLowerCase();
        assertTrue(replyLower.contains("baggage") || replyLower.contains("cabin") || replyLower.contains("kg") || replyLower.contains("check-in"));
    }

    @Test
    @DisplayName("Test booking check without authentication informs user to sign in or provides manage booking link")
    void testBookingLookupRequiresAuthentication() {
        AiChatService.ChatResponse response = aiChatService.processChat("Where can I find my booking?", new ArrayList<>(), null, "/airline-reservation-system");
        assertNotNull(response);
        assertTrue(response.success);
        assertNotNull(response.reply);
        String replyLower = response.reply.toLowerCase();
        assertTrue(replyLower.contains("sign in") || replyLower.contains("login") || replyLower.contains("manage booking") || replyLower.contains("pnr") || replyLower.contains("trips"));
    }

    @Test
    @DisplayName("Test empty or blank message produces friendly validation response")
    void testBlankMessage() {
        AiChatService.ChatResponse response = aiChatService.processChat("   ", new ArrayList<>(), null, "/airline-reservation-system");
        assertNotNull(response);
        assertFalse(response.success);
        assertNotNull(response.error);
    }

    @Test
    @DisplayName("Test rate limiting functionality")
    void testRateLimiter() {
        String testClientId = "test-client-ip-123";
        for (int i = 0; i < 25; i++) {
            assertFalse(aiChatService.isRateLimited(testClientId));
        }
        // 26th request within a minute should be rate limited
        assertTrue(aiChatService.isRateLimited(testClientId));
    }

    @Test
    @DisplayName("Test flight search result generates Book Flight URL pointing directly to /book-flight")
    void testFlightSearchResultGeneratesBookFlightUrlPointingToPassengerDetails() {
        AiChatService.ChatResponse response = aiChatService.processChat(
                "Find the cheapest flight from Jaipur to Delhi tomorrow",
                new ArrayList<>(),
                null,
                "/airline-reservation-system"
        );
        assertNotNull(response);
        assertTrue(response.success);
        if (response.flights != null && !response.flights.isEmpty()) {
            AiChatService.FlightCard card = response.flights.get(0);
            assertNotNull(card.bookUrl, "FlightCard bookUrl must not be null");
            assertTrue(card.bookUrl.contains("/book-flight"), "Book URL must point directly to /book-flight, not /search-flights");
            assertTrue(card.bookUrl.contains("scheduleId="), "Book URL must contain scheduleId");
            assertTrue(card.bookUrl.contains("departureDate="), "Book URL must contain departureDate");
            assertTrue(card.bookUrl.contains("travelClass="), "Book URL must contain travelClass");
            assertTrue(card.bookUrl.contains("passengers="), "Book URL must contain passengers");
        }
    }

    @Test
    @DisplayName("Test processAction 'cheapest' sets intent and prompts for travel details")
    void testProcessActionCheapestPrompt() {
        AiConversationState state = new AiConversationState();
        AiChatService.ChatResponse response = aiChatService.processAction("cheapest", null, "/airline-reservation-system", state);
        assertNotNull(response);
        assertTrue(response.success);
        assertTrue(response.reply.contains("lowest available fares"));
        assertEquals("CHEAPEST", state.getActiveIntent());
        assertTrue(state.isCheapestRequested());
    }

    @Test
    @DisplayName("Test processAction 'search' sets intent and prompts for travel details")
    void testProcessActionSearchPrompt() {
        AiConversationState state = new AiConversationState();
        AiChatService.ChatResponse response = aiChatService.processAction("search", null, "/airline-reservation-system", state);
        assertNotNull(response);
        assertTrue(response.success);
        assertTrue(response.reply.contains("Where would you like to fly?"));
        assertEquals("SEARCH", state.getActiveIntent());
    }

    @Test
    @DisplayName("Test processAction 'booking' presents manage booking options and button")
    void testProcessActionBookingPrompt() {
        AiConversationState state = new AiConversationState();
        AiChatService.ChatResponse response = aiChatService.processAction("booking", null, "/airline-reservation-system", state);
        assertNotNull(response);
        assertTrue(response.success);
        assertTrue(response.reply.contains("Need help with an existing booking?"));
        assertEquals("BOOKING", state.getActiveIntent());
        assertNotNull(response.actionButtons);
        assertTrue(response.actionButtons.stream().anyMatch(btn -> "Open My Bookings".equals(btn.get("label")) && btn.get("url").contains("/manage-booking")));
    }

    @Test
    @DisplayName("Test processAction 'status' prompts for airline and flight number")
    void testProcessActionStatusPrompt() {
        AiConversationState state = new AiConversationState();
        AiChatService.ChatResponse response = aiChatService.processAction("status", null, "/airline-reservation-system", state);
        assertNotNull(response);
        assertTrue(response.success);
        assertTrue(response.reply.contains("Check your flight status"));
        assertTrue(response.reply.contains("6E 204"));
        assertEquals("STATUS", state.getActiveIntent());
    }

    @Test
    @DisplayName("Test conversation state persistence across turns without re-asking collected slots")
    void testConversationStatePersistenceAcrossTurns() {
        AiConversationState state = new AiConversationState();
        state.setActiveIntent("CHEAPEST");
        state.setCheapestRequested(true);
        state.setOrigin("JAI", "Jaipur", "Jaipur International Airport");
        state.setDestination("BOM", "Mumbai", "Chhatrapati Shivaji Maharaj International Airport");
        state.setDepartureDate(LocalDate.now(ZoneId.of("Asia/Kolkata")).plusDays(2));

        // When user supplies missing passenger count
        AiChatService.ChatResponse response = aiChatService.processChat(
                "2 passengers",
                new ArrayList<>(),
                null,
                "/airline-reservation-system",
                state
        );

        assertNotNull(response);
        assertTrue(response.success);
        assertEquals(2, state.getPassengers());
        // Origin and destination should not be lost
        assertEquals("JAI", state.getOriginCode());
        assertEquals("BOM", state.getDestCode());
        // Search should execute
        assertNotNull(response.flights);
        assertFalse(response.flights.isEmpty());
    }

    @Test
    @DisplayName("Test cheapest flights search sorts results ascending by fare")
    void testCheapestFlightSearchSortsAscending() {
        AiConversationState state = new AiConversationState();
        AiChatService.ChatResponse response = aiChatService.processChat(
                "Find cheapest flights from Jaipur to Delhi tomorrow",
                new ArrayList<>(),
                null,
                "/airline-reservation-system",
                state
        );

        assertNotNull(response);
        assertTrue(response.success);
        if (response.flights != null && response.flights.size() > 1) {
            for (int i = 0; i < response.flights.size() - 1; i++) {
                assertTrue(response.flights.get(i).fare.compareTo(response.flights.get(i + 1).fare) <= 0,
                        "Flights should be sorted ascending by fare: " + response.flights.get(i).fare + " <= " + response.flights.get(i + 1).fare);
            }
        }
    }

    @Test
    @DisplayName("Test flight status lookup for unknown flight honestly reports live status unavailability")
    void testFlightStatusUnknownFlight() {
        AiConversationState state = new AiConversationState();
        state.setActiveIntent("STATUS");
        AiChatService.ChatResponse response = aiChatService.processChat(
                "Flight status for ZZ 9999",
                new ArrayList<>(),
                null,
                "/airline-reservation-system",
                state
        );

        String replyLower = response.reply.toLowerCase();
        assertTrue(replyLower.contains("live flight status is not currently available")
                || replyLower.contains("not found")
                || replyLower.contains("scheduled flights"));
    }

    @Test
    @DisplayName("Test required conversation: Find flights from Bengaluru to Jaipur on 20 October 2026")
    void testBengaluruToJaipurSpecificDate() {
        AiConversationState state = new AiConversationState();
        AiChatService.ChatResponse response = aiChatService.processChat(
                "Find flights from Bengaluru to Jaipur on 20 October 2026",
                new ArrayList<>(),
                null,
                "/airline-reservation-system",
                state
        );

        assertNotNull(response);
        assertTrue(response.success);
        assertEquals("BLR", state.getOriginCode());
        assertEquals("JAI", state.getDestCode());
        assertEquals(LocalDate.of(2026, 10, 20), state.getDepartureDate());
        assertNull(state.getAwaitingField());
        assertNotNull(response.reply);
        assertTrue(response.reply.contains("Bengaluru") || response.reply.contains("BLR"));
    }

    @Test
    @DisplayName("Test fuzzy airport matching: Flights from Jaqipur to Delhi tomorrow")
    void testFuzzyAirportMatchJaqipur() {
        AiConversationState state = new AiConversationState();
        AiChatService.ChatResponse response = aiChatService.processChat(
                "Flights from Jaqipur to Delhi tomorrow",
                new ArrayList<>(),
                null,
                "/airline-reservation-system",
                state
        );

        assertNotNull(response);
        assertTrue(response.success);
        // Chatbot must ask: "Did you mean Jaipur (JAI)?"
        assertTrue(response.reply.contains("Did you mean Jaipur (JAI)?"));
        assertNotNull(response.actionButtons);
        assertTrue(response.actionButtons.stream().anyMatch(btn -> "Jaipur (JAI)".equals(btn.get("label"))));
        assertTrue(response.actionButtons.stream().anyMatch(btn -> "Enter another city".equals(btn.get("label"))));
    }

    @Test
    @DisplayName("Test round trip from Jaipur to Mumbai on 20 October, returning 25 October")
    void testRoundTripJaipurToMumbai() {
        AiConversationState state = new AiConversationState();
        AiChatService.ChatResponse response = aiChatService.processChat(
                "Round trip from Jaipur to Mumbai on 20 October, returning 25 October",
                new ArrayList<>(),
                null,
                "/airline-reservation-system",
                state
        );

        assertNotNull(response);
        assertTrue(response.success);
        assertEquals("JAI", state.getOriginCode());
        assertEquals("BOM", state.getDestCode());
        assertEquals(LocalDate.of(2026, 10, 20), state.getDepartureDate());
        assertEquals(LocalDate.of(2026, 10, 25), state.getReturnDate());
        assertEquals("round-trip", state.getTripType());
    }

    @Test
    @DisplayName("Test quick actions: Contact Support and Find Flights")
    void testContactSupportAndFindFlightsActions() {
        AiConversationState state = new AiConversationState();
        AiChatService.ChatResponse supportResp = aiChatService.processAction("support", null, "/airline-reservation-system", state);
        assertNotNull(supportResp);
        assertTrue(supportResp.success);
        assertTrue(supportResp.reply.contains("support@skytech.com"));
        assertTrue(supportResp.reply.contains("+91 1800-SKY-TECH"));
        assertTrue(supportResp.actionButtons.stream().anyMatch(btn -> "Travel Information".equals(btn.get("label"))));

        AiChatService.ChatResponse searchResp = aiChatService.processAction("find_flights", null, "/airline-reservation-system", state);
        assertNotNull(searchResp);
        assertTrue(searchResp.success);
        assertTrue(searchResp.reply.contains("Where would you like to fly?"));
    }

    @Test
    @DisplayName("Test clicking One Way and Round Trip does not produce an error")
    void testOneWayAndRoundTripActions() {
        AiConversationState state = new AiConversationState();
        AiChatService.ChatResponse oneWayResp = aiChatService.processChat("One way", new ArrayList<>(), null, "/airline-reservation-system", state);
        assertNotNull(oneWayResp);
        assertTrue(oneWayResp.success);
        assertEquals("one-way", state.getTripType());

        AiChatService.ChatResponse roundTripResp = aiChatService.processChat("Round trip", new ArrayList<>(), null, "/airline-reservation-system", state);
        assertNotNull(roundTripResp);
        assertTrue(roundTripResp.success);
        assertEquals("round-trip", state.getTripType());
    }
}

