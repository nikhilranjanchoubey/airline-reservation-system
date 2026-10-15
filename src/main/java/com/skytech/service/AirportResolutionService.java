package com.skytech.service;

import com.skytech.dao.AirportDao;
import com.skytech.model.Airport;

import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service to resolve natural language city names, airport names, aliases,
 * and 3-letter IATA airport codes into validated Airport entities.
 */
public class AirportResolutionService {

    private static final Logger LOGGER = Logger.getLogger(AirportResolutionService.class.getName());

    private final AirportDao airportDao;

    // Cache of static global and major domestic hubs to support broad natural language searches
    private static final Map<String, Airport> GLOBAL_AIRPORT_REGISTRY = new LinkedHashMap<>();

    static {
        // Indian Major Airports
        register("JAI", "Jaipur", "Jaipur International Airport", "India", "Terminal 2");
        register("DEL", "Delhi", "Indira Gandhi International Airport", "India", "Terminal 3");
        register("BOM", "Mumbai", "Chhatrapati Shivaji Maharaj International Airport", "India", "Terminal 2");
        register("BLR", "Bengaluru", "Kempegowda International Airport", "India", "Terminal 1");
        register("HYD", "Hyderabad", "Rajiv Gandhi International Airport", "India", "Main Terminal");
        register("CCU", "Kolkata", "Netaji Subhash Chandra Bose International Airport", "India", "Terminal 2");
        register("MAA", "Chennai", "Chennai International Airport", "India", "Terminal 1");
        register("AMD", "Ahmedabad", "Sardar Vallabhbhai Patel International Airport", "India", "Terminal 1");
        register("PNQ", "Pune", "Pune Airport", "India", "Main Terminal");
        register("GOI", "Goa", "Dabolim Airport", "India", "Terminal 1");
        register("COK", "Kochi", "Cochin International Airport", "India", "Terminal 3");
        register("TRV", "Thiruvananthapuram", "Trivandrum International Airport", "India", "Terminal 1");
        register("GAU", "Guwahati", "Lokpriya Gopinath Bordoloi International Airport", "India", "Terminal 1");
        register("ATQ", "Amritsar", "Sri Guru Ram Dass Jee International Airport", "India", "Main Terminal");
        register("LKO", "Lucknow", "Chaudhary Charan Singh International Airport", "India", "Terminal 2");
        register("IXC", "Chandigarh", "Shaheed Bhagat Singh International Airport", "India", "Main Terminal");
        register("PAT", "Patna", "Jay Prakash Narayan Airport", "India", "Terminal 1");
        register("BBI", "Bhubaneswar", "Biju Patnaik International Airport", "India", "Terminal 1");
        register("SXR", "Srinagar", "Sheikh ul-Alam International Airport", "India", "Main Terminal");
        register("IXB", "Bagdogra", "Bagdogra Airport", "India", "Main Terminal");
        register("IDR", "Indore", "Devi Ahilya Bai Holkar Airport", "India", "Main Terminal");
        register("NAG", "Nagpur", "Dr. Babasaheb Ambedkar International Airport", "India", "Terminal 1");
        register("IXZ", "Port Blair", "Veer Savarkar International Airport", "India", "Main Terminal");

        // Major International Hubs commonly queried
        register("DXB", "Dubai", "Dubai International Airport", "United Arab Emirates", "Terminal 3");
        register("LHR", "London", "Heathrow Airport", "United Kingdom", "Terminal 2");
        register("LGW", "London", "Gatwick Airport", "United Kingdom", "South Terminal");
        register("SIN", "Singapore", "Singapore Changi Airport", "Singapore", "Terminal 3");
        register("BKK", "Bangkok", "Suvarnabhumi Airport", "Thailand", "Main Terminal");
        register("KUL", "Kuala Lumpur", "Kuala Lumpur International Airport", "Malaysia", "KLIA");
        register("DOH", "Doha", "Hamad International Airport", "Qatar", "Main Terminal");
        register("AUH", "Abu Dhabi", "Zayed International Airport", "United Arab Emirates", "Terminal A");
        register("JFK", "New York", "John F. Kennedy International Airport", "United States", "Terminal 4");
        register("EWR", "New York", "Newark Liberty International Airport", "United States", "Terminal C");
        register("CDG", "Paris", "Charles de Gaulle Airport", "France", "Terminal 2E");
        register("FRA", "Frankfurt", "Frankfurt Airport", "Germany", "Terminal 1");
        register("AMS", "Amsterdam", "Amsterdam Airport Schiphol", "Netherlands", "Main Terminal");
        register("NRT", "Tokyo", "Narita International Airport", "Japan", "Terminal 1");
        register("HND", "Tokyo", "Haneda Airport", "Japan", "Terminal 3");
        register("SYD", "Sydney", "Sydney Kingsford Smith Airport", "Australia", "Terminal 1");
        register("MEL", "Melbourne", "Melbourne Airport", "Australia", "Terminal 2");
        register("YYZ", "Toronto", "Toronto Pearson International Airport", "Canada", "Terminal 1");
        register("YVR", "Vancouver", "Vancouver International Airport", "Canada", "Main Terminal");
        register("SFO", "San Francisco", "San Francisco International Airport", "United States", "International Terminal");
        register("ORD", "Chicago", "O'Hare International Airport", "United States", "Terminal 5");
        register("LAX", "Los Angeles", "Los Angeles International Airport", "United States", "Tom Bradley Terminal");
    }

    private static void register(String code, String city, String name, String country, String terminal) {
        Airport a = new Airport();
        a.setAirportCode(code);
        a.setCity(city);
        a.setAirportName(name);
        a.setCountry(country);
        a.setTerminal(terminal);
        GLOBAL_AIRPORT_REGISTRY.put(code, a);
    }

    public AirportResolutionService() {
        this(new AirportDao());
    }

    public AirportResolutionService(AirportDao airportDao) {
        this.airportDao = airportDao;
    }

    public static class ResolutionResult {
        public boolean resolved;
        public Airport airport;
        public boolean isAmbiguous;
        public boolean isFuzzyMatch;
        public Airport suggestedAirport;
        public List<Airport> candidates = new ArrayList<>();
        public String query;

        public String getCode() {
            return airport != null ? airport.getAirportCode() : (suggestedAirport != null ? suggestedAirport.getAirportCode() : null);
        }

        public String getCity() {
            return airport != null ? airport.getCity() : (suggestedAirport != null ? suggestedAirport.getCity() : null);
        }

        public String getDisplayName() {
            if (airport != null) return airport.getCity() + " (" + airport.getAirportCode() + ")";
            if (suggestedAirport != null) return suggestedAirport.getCity() + " (" + suggestedAirport.getAirportCode() + ")";
            return query;
        }

        public String getSuggestedDisplayName() {
            if (suggestedAirport == null) return null;
            return suggestedAirport.getCity() + " (" + suggestedAirport.getAirportCode() + ")";
        }
    }

    /**
     * Resolves an airport query (city name, alias, airport name, or 3-letter IATA code).
     */
    public ResolutionResult resolve(String rawQuery) {
        ResolutionResult result = new ResolutionResult();
        if (rawQuery == null || rawQuery.trim().isEmpty()) {
            result.resolved = false;
            return result;
        }

        String query = cleanQuery(rawQuery);
        result.query = query;

        if (query.isEmpty()) {
            result.resolved = false;
            return result;
        }

        // 1. Direct 3-letter IATA Code match
        if (query.matches("^[A-Z]{3}$")) {
            Airport match = findByIataCode(query);
            if (match != null) {
                result.resolved = true;
                result.airport = match;
                return result;
            }
        }

        // 2. Canonical city name & alias normalization
        String normalized = normalizeCityAlias(query);

        // 3. Search local database airports first
        List<Airport> dbAirports = getDatabaseAirports();
        for (Airport a : dbAirports) {
            if (isDirectMatch(a, normalized)) {
                result.resolved = true;
                result.airport = a;
                return result;
            }
        }

        // 4. Search global airport registry
        List<Airport> globalMatches = new ArrayList<>();
        for (Airport a : GLOBAL_AIRPORT_REGISTRY.values()) {
            if (isDirectMatch(a, normalized)) {
                globalMatches.add(a);
            }
        }

        if (!globalMatches.isEmpty()) {
            result.resolved = true;
            result.airport = globalMatches.get(0); // Primary airport for city
            if (globalMatches.size() > 1) {
                result.isAmbiguous = true;
                result.candidates = globalMatches;
            }
            return result;
        }

        // 5. Partial / Contains search
        for (Airport a : dbAirports) {
            if (isPartialMatch(a, normalized)) {
                result.resolved = true;
                result.airport = a;
                return result;
            }
        }

        for (Airport a : GLOBAL_AIRPORT_REGISTRY.values()) {
            if (isPartialMatch(a, normalized)) {
                result.resolved = true;
                result.airport = a;
                return result;
            }
        }

        // 6. Fuzzy Spellcheck Matching (e.g. "Jaqipur" -> "Jaipur", "Bengalore" -> "Bengaluru")
        Airport closest = findClosestFuzzyMatch(normalized, dbAirports);
        if (closest != null) {
            result.resolved = false;
            result.isFuzzyMatch = true;
            result.suggestedAirport = closest;
            return result;
        }

        // Could not resolve
        result.resolved = false;
        return result;
    }

    /**
     * Finds the closest airport city match using Levenshtein distance.
     */
    private Airport findClosestFuzzyMatch(String query, List<Airport> airports) {
        if (query == null || query.length() < 3) return null;
        String q = query.toLowerCase(Locale.ENGLISH);

        Airport bestAirport = null;
        int bestDistance = Integer.MAX_VALUE;

        // Check database airports
        for (Airport a : airports) {
            if (a.getCity() == null) continue;
            String c = a.getCity().toLowerCase(Locale.ENGLISH);
            int dist = computeLevenshteinDistance(q, c);
            if (dist < bestDistance) {
                bestDistance = dist;
                bestAirport = a;
            }
        }

        // Check global registry airports
        for (Airport a : GLOBAL_AIRPORT_REGISTRY.values()) {
            if (a.getCity() == null) continue;
            String c = a.getCity().toLowerCase(Locale.ENGLISH);
            int dist = computeLevenshteinDistance(q, c);
            if (dist < bestDistance) {
                bestDistance = dist;
                bestAirport = a;
            }
        }

        // Acceptable threshold: max 2 edits for length >= 5, max 1 edit for length 3-4
        int maxAllowed = (q.length() >= 5) ? 2 : 1;
        if (bestDistance <= maxAllowed && bestAirport != null) {
            return bestAirport;
        }

        return null;
    }

    private int computeLevenshteinDistance(String s1, String s2) {
        int[] costs = new int[s2.length() + 1];
        for (int j = 0; j < costs.length; j++) costs[j] = j;
        for (int i = 1; i <= s1.length(); i++) {
            costs[0] = i;
            int nw = i - 1;
            for (int j = 1; j <= s2.length(); j++) {
                int cj = Math.min(1 + Math.min(costs[j], costs[j - 1]),
                        s1.charAt(i - 1) == s2.charAt(j - 1) ? nw : nw + 1);
                nw = costs[j];
                costs[j] = cj;
            }
        }
        return costs[s2.length()];
    }

    private String cleanQuery(String raw) {
        String clean = raw.trim();
        // Remove common surrounding words
        clean = clean.replaceAll("(?i)\\b(from|to|airport|city|international|domestic|airports|flights?|in|at)\\b", "").trim();
        clean = clean.replaceAll("[^a-zA-Z\\s-]", "").trim();
        return clean.toUpperCase(Locale.ENGLISH);
    }

    private String normalizeCityAlias(String cleanQuery) {
        String lower = cleanQuery.toLowerCase(Locale.ENGLISH);
        if (lower.equals("bangalore") || lower.contains("bangalore")) return "bengaluru";
        if (lower.equals("bombay") || lower.contains("bombay")) return "mumbai";
        if (lower.equals("calcutta") || lower.contains("calcutta")) return "kolkata";
        if (lower.equals("madras") || lower.contains("madras")) return "chennai";
        if (lower.equals("cochin") || lower.contains("cochin")) return "kochi";
        if (lower.equals("trivandrum") || lower.contains("trivandrum")) return "thiruvananthapuram";
        if (lower.equals("new delhi") || lower.equals("delhi ncr")) return "delhi";
        if (lower.equals("nyc") || lower.equals("new york city")) return "new york";
        return lower;
    }

    private boolean isDirectMatch(Airport a, String normalized) {
        if (a == null) return false;
        String city = (a.getCity() != null ? a.getCity().toLowerCase(Locale.ENGLISH) : "");
        String code = (a.getAirportCode() != null ? a.getAirportCode().toLowerCase(Locale.ENGLISH) : "");
        return city.equals(normalized) || code.equals(normalized);
    }

    private boolean isPartialMatch(Airport a, String normalized) {
        if (a == null) return false;
        String city = (a.getCity() != null ? a.getCity().toLowerCase(Locale.ENGLISH) : "");
        String name = (a.getAirportName() != null ? a.getAirportName().toLowerCase(Locale.ENGLISH) : "");
        String code = (a.getAirportCode() != null ? a.getAirportCode().toLowerCase(Locale.ENGLISH) : "");

        return (normalized.length() >= 3 && (city.contains(normalized) || normalized.contains(city) || name.contains(normalized) || code.contains(normalized)));
    }

    private Airport findByIataCode(String code) {
        Airport a = airportDao.getAirportByCode(code);
        if (a != null) return a;
        return GLOBAL_AIRPORT_REGISTRY.get(code.toUpperCase(Locale.ENGLISH));
    }

    private List<Airport> getDatabaseAirports() {
        try {
            List<Airport> list = airportDao.getAllAirports();
            if (list != null && !list.isEmpty()) {
                return list;
            }
        } catch (Exception e) {
            LOGGER.log(Level.FINE, "Failed fetching database airports in AirportResolutionService: " + e.getMessage());
        }
        return new ArrayList<>(GLOBAL_AIRPORT_REGISTRY.values());
    }
}
