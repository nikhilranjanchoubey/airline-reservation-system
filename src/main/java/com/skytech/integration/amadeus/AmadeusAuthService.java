package com.skytech.integration.amadeus;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Handles OAuth2 client credentials authentication with Amadeus API.
 * Safely caches tokens to prevent unnecessary authorization round-trips.
 */
public class AmadeusAuthService {

    private static final Logger LOGGER = Logger.getLogger(AmadeusAuthService.class.getName());

    private String cachedToken;
    private long tokenExpiryEpochMs;

    public synchronized String getAccessToken() throws Exception {
        long now = System.currentTimeMillis();
        // If token exists and has at least 60 seconds of validity remaining, reuse it
        if (cachedToken != null && now < (tokenExpiryEpochMs - 60000)) {
            return cachedToken;
        }

        String clientId = AmadeusConfig.getClientId();
        String clientSecret = AmadeusConfig.getClientSecret();

        if (clientId == null || clientId.trim().isEmpty() || clientSecret == null || clientSecret.trim().isEmpty()) {
            throw new IllegalStateException("Amadeus API credentials are not configured.");
        }

        String tokenUrl = AmadeusConfig.getBaseUrl() + "/v1/security/oauth2/token";
        String postParams = "grant_type=client_credentials" +
                "&client_id=" + URLEncoder.encode(clientId, StandardCharsets.UTF_8) +
                "&client_secret=" + URLEncoder.encode(clientSecret, StandardCharsets.UTF_8);

        URL url = new URL(tokenUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setConnectTimeout(8000);
        conn.setReadTimeout(8000);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(postParams.getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();
        if (status != 200) {
            String errorMsg = "Amadeus OAuth error: HTTP " + status;
            LOGGER.log(Level.WARNING, errorMsg);
            throw new RuntimeException(errorMsg);
        }

        StringBuilder response = new StringBuilder();
        try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = in.readLine()) != null) {
                response.append(line);
            }
        }

        JsonObject json = JsonParser.parseString(response.toString()).getAsJsonObject();
        this.cachedToken = json.get("access_token").getAsString();
        long expiresInSec = json.has("expires_in") ? json.get("expires_in").getAsLong() : 1799;
        this.tokenExpiryEpochMs = System.currentTimeMillis() + (expiresInSec * 1000);

        LOGGER.info("Successfully refreshed Amadeus OAuth access token.");
        return this.cachedToken;
    }
}
