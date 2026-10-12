package com.skytech.integration.amadeus;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Configuration holder for external Amadeus Flight APIs.
 * Loads settings safely from api.properties or environment variables.
 */
public final class AmadeusConfig {

    private static final Logger LOGGER = Logger.getLogger(AmadeusConfig.class.getName());
    private static final Properties PROPERTIES = new Properties();

    private static boolean enabled = false;
    private static String clientId = "";
    private static String clientSecret = "";
    private static String environment = "test";

    static {
        loadConfiguration();
    }

    private AmadeusConfig() {
    }

    public static void loadConfiguration() {
        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
        InputStream input = classLoader.getResourceAsStream("api.properties");

        if (input == null) {
            input = classLoader.getResourceAsStream("api.properties.example");
        }

        if (input != null) {
            try {
                PROPERTIES.load(input);
            } catch (IOException e) {
                LOGGER.log(Level.WARNING, "Failed to load api.properties", e);
            } finally {
                try {
                    input.close();
                } catch (IOException ignored) {
                }
            }
        }

        // Support environment variables override as well
        String envEnabled = System.getenv("AMADEUS_ENABLED");
        String envClientId = System.getenv("AMADEUS_CLIENT_ID");
        String envClientSecret = System.getenv("AMADEUS_CLIENT_SECRET");
        String envEnvironment = System.getenv("AMADEUS_ENVIRONMENT");

        enabled = envEnabled != null ? Boolean.parseBoolean(envEnabled)
                : Boolean.parseBoolean(PROPERTIES.getProperty("amadeus.enabled", "false"));

        clientId = envClientId != null ? envClientId
                : PROPERTIES.getProperty("amadeus.client.id", "");

        clientSecret = envClientSecret != null ? envClientSecret
                : PROPERTIES.getProperty("amadeus.client.secret", "");

        environment = envEnvironment != null ? envEnvironment
                : PROPERTIES.getProperty("amadeus.environment", "test");
    }

    public static boolean isEnabled() {
        return enabled && clientId != null && !clientId.trim().isEmpty()
                && clientSecret != null && !clientSecret.trim().isEmpty()
                && !"YOUR_AMADEUS_CLIENT_ID".equals(clientId);
    }

    public static String getClientId() {
        return clientId;
    }

    public static String getClientSecret() {
        return clientSecret;
    }

    public static String getEnvironment() {
        return environment;
    }

    public static String getBaseUrl() {
        if ("production".equalsIgnoreCase(environment)) {
            return "https://api.amadeus.com";
        }
        return "https://test.api.amadeus.com";
    }
}
