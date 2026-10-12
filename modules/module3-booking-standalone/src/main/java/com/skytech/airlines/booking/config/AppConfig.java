package com.skytech.airlines.booking.config;

import java.io.InputStream;
import java.math.BigDecimal;
import java.util.Properties;
import java.util.logging.Logger;

/**
 * Centralized application configuration reader.
 */
public class AppConfig {
    private static final Logger LOGGER = Logger.getLogger(AppConfig.class.getName());
    private static final Properties props = new Properties();

    static {
        loadProperties();
    }

    private static void loadProperties() {
        try (InputStream in = AppConfig.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (in != null) {
                props.load(in);
                LOGGER.info("Successfully loaded application.properties for SKYTECH Booking Module.");
            }
        } catch (Exception e) {
            LOGGER.warning("Could not read application.properties: " + e.getMessage());
        }
    }

    public static String getProperty(String key, String defaultValue) {
        String envVal = System.getenv(key.replace('.', '_').toUpperCase());
        if (envVal != null && !envVal.isBlank()) return envVal;
        return props.getProperty(key, defaultValue);
    }

    public static String getRazorpayKeyId() {
        String env = System.getenv("RAZORPAY_KEY_ID");
        if (env != null && !env.isBlank()) return env.trim();
        return getProperty("razorpay.key.id", "rzp_test_placeholderKey");
    }

    public static String getRazorpayKeySecret() {
        String env = System.getenv("RAZORPAY_KEY_SECRET");
        if (env != null && !env.isBlank()) return env.trim();
        return getProperty("razorpay.key.secret", "placeholderSecret");
    }

    public static String getRazorpayWebhookSecret() {
        String env = System.getenv("RAZORPAY_WEBHOOK_SECRET");
        if (env != null && !env.isBlank()) return env.trim();
        return getProperty("razorpay.webhook.secret", "webhookSecretPlaceholder");
    }

    public static String getCurrency() {
        return getProperty("razorpay.currency", "INR");
    }

    public static long getSeatHoldSeconds() {
        try {
            return Long.parseLong(getProperty("booking.seat.hold.seconds", "900"));
        } catch (NumberFormatException e) {
            return 900L;
        }
    }

    public static BigDecimal getTaxRate() {
        try {
            return new BigDecimal(getProperty("booking.tax.rate", "0.12"));
        } catch (Exception e) {
            return new BigDecimal("0.12");
        }
    }

    public static String getModule1LoginUrl() {
        return getProperty("module1.login.url", "/auth/login");
    }
}
