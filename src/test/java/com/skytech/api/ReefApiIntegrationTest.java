package com.skytech.api;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.skytech.model.FlightSchedule;
import com.skytech.util.AppConfig;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.time.LocalDate;
import java.util.List;

public class ReefApiIntegrationTest {

    private ReefApiClient client;
    private ObjectMapper objectMapper;

    @Before
    public void setUp() {
        AppConfig.initialize();
        client = new ReefApiClient();
        objectMapper = new ObjectMapper();
        ReefApiClient.clearCache();
    }

    /**
     * TEST 1: Confirm that the ReefAPI key is loaded server-side.
     */
    @Test
    public void test1_ReefApiKeyLoaded() {
        Assert.assertTrue("ReefAPI key must be configured in AppConfig", AppConfig.isReefApiConfigured());
        String key = AppConfig.getReefApiKey();
        Assert.assertNotNull("ReefAPI key must not be null", key);
        Assert.assertTrue("ReefAPI key length must be valid (>15 chars)", key.length() > 15);
        Assert.assertFalse("Key should not be placeholder", key.contains("YOUR_REEF_API_KEY"));
    }

    /**
     * TEST 2: Response Parser with genuine ReefAPI JSON structure.
     */
    @Test
    public void test2_ResponseParserAndMapping() throws Exception {
        String sampleJson = "{\n" +
                "  \"ok\": true,\n" +
                "  \"data\": {\n" +
                "    \"flights\": [\n" +
                "      {\n" +
                "        \"id\": \"flight_jai_del_101\",\n" +
                "        \"carrier\": \"6E\",\n" +
                "        \"flight_number\": \"6E 2165\",\n" +
                "        \"departure\": {\n" +
                "          \"airport\": \"JAI\",\n" +
                "          \"time\": \"2026-10-15T09:00:00+05:30\"\n" +
                "        },\n" +
                "        \"arrival\": {\n" +
                "          \"airport\": \"DEL\",\n" +
                "          \"time\": \"2026-10-15T10:15:00+05:30\"\n" +
                "        },\n" +
                "        \"duration\": 75,\n" +
                "        \"stops\": 0,\n" +
                "        \"price\": {\n" +
                "          \"amount\": 5489.0,\n" +
                "          \"currency\": \"INR\"\n" +
                "        },\n" +
                "        \"booking_url\": \"https://www.kiwi.com/deep?affilid=test&booking_token=xyz123\",\n" +
                "        \"segments\": [\n" +
                "          {\n" +
                "            \"carrier\": \"6E\",\n" +
                "            \"flight_number\": \"6E 2165\",\n" +
                "            \"origin\": \"JAI\",\n" +
                "            \"destination\": \"DEL\",\n" +
                "            \"departure_time\": \"2026-10-15T09:00:00+05:30\",\n" +
                "            \"arrival_time\": \"2026-10-15T10:15:00+05:30\",\n" +
                "            \"duration\": 75\n" +
                "          }\n" +
                "        ]\n" +
                "      }\n" +
                "    ]\n" +
                "  },\n" +
                "  \"meta\": {\n" +
                "    \"record_count\": 1,\n" +
                "    \"search_id\": \"srch_test_123\"\n" +
                "  }\n" +
                "}";

        List<FlightSchedule> results = client.parseReefSearchResponse(sampleJson, "JAI", "DEL", LocalDate.parse("2026-10-15"), "Economy");

        Assert.assertEquals(1, results.size());
        FlightSchedule f = results.get(0);
        Assert.assertEquals("6E 2165", f.getFlight().getFlightNumber());
        Assert.assertEquals("IndiGo", f.getFlight().getAirline().getAirlineName());
        Assert.assertEquals("JAI", f.getFlight().getSourceAirport().getAirportCode());
        Assert.assertEquals("DEL", f.getFlight().getDestinationAirport().getAirportCode());
        Assert.assertEquals(5489.0, f.getEconomyPrice().doubleValue(), 0.01);
        Assert.assertEquals("INR", f.getCurrency());
        Assert.assertFalse("Real API prices are not estimated", f.isEstimatedFare());
        Assert.assertEquals("https://www.kiwi.com/deep?affilid=test&booking_token=xyz123", f.getBookingUrl());
        Assert.assertNotNull(f.getSegments());
        Assert.assertEquals(1, f.getSegments().size());
        Assert.assertEquals("JAI", f.getSegments().get(0).getOrigin());
        Assert.assertEquals("DEL", f.getSegments().get(0).getDestination());
    }

    /**
     * TEST 3: Defensive error handling for error envelopes.
     */
    @Test
    public void test3_ErrorEnvelopeHandling() {
        String errorJson = "{\n" +
                "  \"ok\": false,\n" +
                "  \"error\": {\n" +
                "    \"code\": \"AUTH_FAILED\",\n" +
                "    \"message\": \"Invalid or expired API key\"\n" +
                "  }\n" +
                "}";

        try {
            client.parseReefSearchResponse(errorJson, "JAI", "DEL", LocalDate.parse("2026-10-15"), "Economy");
            Assert.fail("Should throw ApiException for ok=false error response");
        } catch (ApiException e) {
            Assert.assertEquals(ApiException.ErrorCategory.AUTHENTICATION, e.getCategory());
            Assert.assertTrue(e.getMessage().contains("Invalid or expired API key"));
        }
    }
}
