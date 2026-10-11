package com.skytech.integration.amadeus;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.skytech.dao.AirportDao;
import com.skytech.model.Airline;
import com.skytech.model.Airport;
import com.skytech.model.Flight;
import com.skytech.model.FlightSchedule;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Date;
import java.sql.Time;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Executes real-time flight searches via Amadeus Flight Offers Search API (v2).
 */
public class AmadeusFlightService {

    private static final Logger LOGGER = Logger.getLogger(AmadeusFlightService.class.getName());

    private final AmadeusAuthService authService;
    private final AirportDao airportDao;

    public AmadeusFlightService() {
        this.authService = new AmadeusAuthService();
        this.airportDao = new AirportDao();
    }

    public AmadeusFlightService(AmadeusAuthService authService, AirportDao airportDao) {
        this.authService = authService;
        this.airportDao = airportDao;
    }

    /**
     * Queries Amadeus Flight Offers Search v2 API.
     */
    public List<FlightSchedule> searchFlightOffers(String origin, String destination, LocalDate departureDate,
                                                   int adults, String travelClass) throws Exception {
        List<FlightSchedule> schedules = new ArrayList<>();
        String token = authService.getAccessToken();

        String amadeusTravelClass = mapCabinClass(travelClass);

        String endpoint = AmadeusConfig.getBaseUrl() + "/v2/shopping/flight-offers?" +
                "originLocationCode=" + URLEncoder.encode(origin.toUpperCase(), StandardCharsets.UTF_8) +
                "&destinationLocationCode=" + URLEncoder.encode(destination.toUpperCase(), StandardCharsets.UTF_8) +
                "&departureDate=" + departureDate.toString() +
                "&adults=" + adults +
                "&travelClass=" + amadeusTravelClass +
                "&currencyCode=INR" +
                "&max=10";

        URL url = new URL(endpoint);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(9000);
        conn.setReadTimeout(9000);
        conn.setRequestProperty("Authorization", "Bearer " + token);
        conn.setRequestProperty("Accept", "application/json");

        int status = conn.getResponseCode();
        if (status != 200) {
            LOGGER.log(Level.WARNING, "Amadeus flight-offers responded with HTTP status " + status);
            return schedules;
        }

        StringBuilder response = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
        }

        JsonObject root = JsonParser.parseString(response.toString()).getAsJsonObject();
        if (!root.has("data") || !root.get("data").isJsonArray()) {
            return schedules;
        }

        JsonArray data = root.getAsJsonArray("data");
        int index = 1;
        for (JsonElement elem : data) {
            try {
                FlightSchedule schedule = parseFlightOffer(elem.getAsJsonObject(), index++, departureDate);
                if (schedule != null) {
                    schedules.add(schedule);
                }
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Error parsing individual Amadeus flight offer: " + e.getMessage());
            }
        }

        return schedules;
    }

    private FlightSchedule parseFlightOffer(JsonObject offer, int offerId, LocalDate requestedDate) {
        if (!offer.has("itineraries") || offer.getAsJsonArray("itineraries").size() == 0) {
            return null;
        }

        JsonObject itinerary = offer.getAsJsonArray("itineraries").get(0).getAsJsonObject();
        JsonArray segments = itinerary.getAsJsonArray("segments");
        if (segments.size() == 0) return null;

        JsonObject firstSegment = segments.get(0).getAsJsonObject();
        JsonObject lastSegment = segments.get(segments.size() - 1).getAsJsonObject();

        String carrierCode = firstSegment.get("carrierCode").getAsString();
        String flightNumber = carrierCode + "-" + firstSegment.get("number").getAsString();

        JsonObject depObj = firstSegment.getAsJsonObject("departure");
        JsonObject arrObj = lastSegment.getAsJsonObject("arrival");

        String depIata = depObj.get("iataCode").getAsString();
        String arrIata = arrObj.get("iataCode").getAsString();

        String depTimeStr = depObj.get("at").getAsString(); // e.g. 2026-10-15T06:15:00
        String arrTimeStr = arrObj.get("at").getAsString();

        LocalDateTime depLdt = LocalDateTime.parse(depTimeStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
        LocalDateTime arrLdt = LocalDateTime.parse(arrTimeStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME);

        int durationMins = (int) Duration.between(depLdt, arrLdt).toMinutes();
        if (durationMins <= 0) durationMins = 120;

        int stops = segments.size() - 1;

        // Pricing
        JsonObject priceObj = offer.getAsJsonObject("price");
        BigDecimal totalFare = new BigDecimal(priceObj.get("total").getAsString());
        BigDecimal baseFare = priceObj.has("base") ? new BigDecimal(priceObj.get("base").getAsString()) : totalFare;

        int numberOfBookableSeats = offer.has("numberOfBookableSeats") 
                ? offer.get("numberOfBookableSeats").getAsInt() : 9;

        // Construct Airline
        Airline airline = new Airline(1, carrierCode, resolveCarrierName(carrierCode), "bi-airplane-fill");

        // Construct Airports
        Airport src = airportDao.getAirportByCode(depIata);
        if (src == null) src = new Airport(1, depIata, depIata + " Airport", depIata, "India", "Terminal 1");

        Airport dst = airportDao.getAirportByCode(arrIata);
        if (dst == null) dst = new Airport(2, arrIata, arrIata + " Airport", arrIata, "India", "Terminal 2");

        // Construct Flight
        Flight flight = new Flight();
        flight.setFlightId(offerId);
        flight.setFlightNumber(flightNumber);
        flight.setAirline(airline);
        flight.setSourceAirport(src);
        flight.setDestinationAirport(dst);
        flight.setDepartureTime(Time.valueOf(depLdt.toLocalTime()));
        flight.setArrivalTime(Time.valueOf(arrLdt.toLocalTime()));
        flight.setDurationMinutes(durationMins);
        flight.setStops(stops);
        flight.setAircraftModel("Commercial Jet");

        // Construct Schedule
        FlightSchedule schedule = new FlightSchedule();
        schedule.setScheduleId(offerId);
        schedule.setFlightId(offerId);
        schedule.setFlight(flight);
        schedule.setFlightDate(Date.valueOf(depLdt.toLocalDate()));
        schedule.setBasePrice(baseFare);
        schedule.setEconomyPrice(totalFare);
        schedule.setPremiumEconomyPrice(totalFare.multiply(BigDecimal.valueOf(1.3)).setScale(2, java.math.RoundingMode.HALF_UP));
        schedule.setBusinessPrice(totalFare.multiply(BigDecimal.valueOf(2.0)).setScale(2, java.math.RoundingMode.HALF_UP));
        schedule.setFirstClassPrice(totalFare.multiply(BigDecimal.valueOf(3.2)).setScale(2, java.math.RoundingMode.HALF_UP));
        schedule.setAvailableSeats(numberOfBookableSeats);
        schedule.setTotalSeats(180);
        schedule.setStatus("CONFIRMED");

        return schedule;
    }

    private String mapCabinClass(String travelClass) {
        if (travelClass == null) return "ECONOMY";
        switch (travelClass.trim().toUpperCase()) {
            case "BUSINESS": return "BUSINESS";
            case "FIRST CLASS": return "FIRST";
            case "PREMIUM ECONOMY": return "PREMIUM_ECONOMY";
            default: return "ECONOMY";
        }
    }

    private String resolveCarrierName(String code) {
        switch (code.toUpperCase()) {
            case "6E": return "IndiGo";
            case "AI": return "Air India";
            case "SG": return "SpiceJet";
            case "UK": return "Vistara";
            case "QP": return "Akasa Air";
            default: return code + " Airlines";
        }
    }
}
