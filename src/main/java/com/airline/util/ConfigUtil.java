package com.airline.util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Utility for accessing application properties and environment variable overrides.
 */
public class ConfigUtil {

    private static final Logger LOGGER = Logger.getLogger(ConfigUtil.class.getName());
    private static final Properties PROPERTIES = new Properties();

    static {
        loadProperties();
    }

    private ConfigUtil() {
    }

    private static synchronized void loadProperties() {
        try (InputStream input = ConfigUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input != null) {
                PROPERTIES.load(input);
            } else {
                LOGGER.log(Level.WARNING, "db.properties not found on classpath.");
            }
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Failed to load db.properties: " + e.getMessage(), e);
        }
    }

    /**
     * Gets a configuration property by key.
     * Order of precedence:
     * 1. System Environment Variable (e.g. GOOGLE_CLIENT_ID for google.client.id)
     * 2. System Property (-Dgoogle.client.id)
     * 3. db.properties entry
     * 4. Default fallback value
     */
    public static String getProperty(String key, String defaultValue) {
        String envKey = key.toUpperCase().replace('.', '_');
        String envValue = System.getenv(envKey);
        if (envValue != null && !envValue.isBlank()) {
            return envValue.trim();
        }

        String sysProp = System.getProperty(key);
        if (sysProp != null && !sysProp.isBlank()) {
            return sysProp.trim();
        }

        String propVal = PROPERTIES.getProperty(key);
        if (propVal != null && !propVal.isBlank()) {
            return propVal.trim();
        }

        return defaultValue;
    }

    /**
     * Gets a configuration property by key or returns null if not configured.
     */
    public static String getProperty(String key) {
        return getProperty(key, null);
    }

    /**
     * Convenience method to retrieve the configured Google Client ID.
     */
    public static String getGoogleClientId() {
        return getProperty("google.client.id", "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com");
    }
}
