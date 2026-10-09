package com.skytech.util;

import io.github.cdimascio.dotenv.Dotenv;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Centralized application configuration utility for SkyTech.
 * Securely manages credentials with strict priority:
 * 1. System Environment variables (System.getenv)
 * 2. Project root / local .env file
 * 3. Classpath properties (db.properties / api.properties)
 *
 * Never logs or exposes raw secrets in exceptions, UI, or console output.
 */
public final class AppConfig {

    private static final Logger LOGGER = Logger.getLogger(AppConfig.class.getName());

    private static Dotenv dotenvInstance;
    private static final Map<String, String> DOTENV_FALLBACK_MAP = new HashMap<>();
    private static final Properties CLASSPATH_PROPERTIES = new Properties();

    static {
        initialize();
    }

    private AppConfig() {
        // Prevent instantiation
    }

    /**
     * Initializes configuration sources cleanly at startup.
     */
    public static synchronized void initialize() {
        // 1. Attempt loading via dotenv-java
        try {
            dotenvInstance = Dotenv.configure()
                    .ignoreIfMissing()
                    .load();
        } catch (Exception e) {
            LOGGER.log(Level.FINE, "Dotenv-java standard load skipped: " + e.getMessage());
        }

        // 2. Fallback manual search for .env in common project/container locations
        loadDotenvManuallyIfEmpty();

        // 3. Load classpath properties (db.properties, api.properties)
        loadClasspathProperties("db.properties");
        loadClasspathProperties("api.properties");
    }

    private static void loadDotenvManuallyIfEmpty() {
        String[] possiblePaths = {
            ".env",
            "../.env",
            System.getProperty("user.dir") + File.separator + ".env",
            System.getProperty("catalina.base") + File.separator + ".env",
            System.getProperty("catalina.home") + File.separator + ".env"
        };

        for (String path : possiblePaths) {
            if (path == null) continue;
            File f = new File(path);
            if (f.exists() && f.isFile() && f.canRead()) {
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(new FileInputStream(f), StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        line = line.trim();
                        if (line.isEmpty() || line.startsWith("#")) continue;
                        int eq = line.indexOf('=');
                        if (eq > 0) {
                            String k = line.substring(0, eq).trim();
                            String v = line.substring(eq + 1).trim();
                            if ((v.startsWith("\"") && v.endsWith("\"")) || (v.startsWith("'") && v.endsWith("'"))) {
                                v = v.substring(1, v.length() - 1);
                            }
                            if (!k.isEmpty() && !DOTENV_FALLBACK_MAP.containsKey(k)) {
                                DOTENV_FALLBACK_MAP.put(k, v);
                            }
                        }
                    }
                    LOGGER.info("Successfully loaded environment configuration from: " + f.getName());
                    break;
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Could not read .env at path: " + path, e);
                }
            }
        }
    }

    private static void loadClasspathProperties(String filename) {
        ClassLoader cl = Thread.currentThread().getContextClassLoader();
        if (cl == null) {
            cl = AppConfig.class.getClassLoader();
        }
        try (InputStream in = cl.getResourceAsStream(filename)) {
            if (in != null) {
                CLASSPATH_PROPERTIES.load(in);
            }
        } catch (Exception e) {
            LOGGER.log(Level.FINE, "Optional classpath properties not loaded: " + filename);
        }
    }

    /**
     * Resolves a configuration property following the strict priority order.
     */
    public static String get(String key, String defaultValue) {
        if (key == null || key.trim().isEmpty()) {
            return defaultValue;
        }

        // 1. Environment variables
        String envVal = System.getenv(key);
        if (envVal != null && !envVal.trim().isEmpty()) {
            return envVal.trim();
        }

        // 2. Dotenv library
        if (dotenvInstance != null) {
            try {
                String val = dotenvInstance.get(key);
                if (val != null && !val.trim().isEmpty()) {
                    return val.trim();
                }
            } catch (Exception ignored) {
            }
        }

        // 3. Fallback .env map
        String fallbackVal = DOTENV_FALLBACK_MAP.get(key);
        if (fallbackVal != null && !fallbackVal.trim().isEmpty()) {
            return fallbackVal.trim();
        }

        // 4. Classpath properties
        String propVal = CLASSPATH_PROPERTIES.getProperty(key);
        if (propVal != null && !propVal.trim().isEmpty()) {
            return propVal.trim();
        }

        return defaultValue;
    }

    public static String get(String key) {
        return get(key, null);
    }

    // ==========================================
    // RAPIDAPI / AERODATABOX ACCESSORS
    // ==========================================

    /**
     * Obtains the configured RapidAPI Key.
     * Fails clearly if missing without exposing secret data.
     */
    public static String getRapidApiKey() {
        String key = get("RAPIDAPI_KEY");
        if (key == null || key.trim().isEmpty()) {
            throw new IllegalStateException("RapidAPI configuration is missing. Please configure RAPIDAPI_KEY in .env or environment.");
        }
        return key.trim();
    }

    /**
     * Returns true if RapidAPI Key is configured.
     */
    public static boolean isRapidApiConfigured() {
        String key = get("RAPIDAPI_KEY");
        return key != null && !key.trim().isEmpty();
    }

    /**
     * Obtains the RapidAPI Host (default: aerodatabox.p.rapidapi.com).
     */
    public static String getRapidApiHost() {
        return get("RAPIDAPI_HOST", "aerodatabox.p.rapidapi.com");
    }

    // ==========================================
    // DATABASE / MYSQL ACCESSORS
    // ==========================================

    public static String getDbUrl() {
        return get("DB_URL", get("db.url",
                "jdbc:mysql://localhost:3306/skytech_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata&characterEncoding=UTF-8"));
    }

    public static String getDbUsername() {
        return get("DB_USERNAME", get("db.user", "root"));
    }

    public static String getDbPassword() {
        return get("DB_PASSWORD", get("db.password", ""));
    }

    public static String getDbDriver() {
        return get("DB_DRIVER", get("db.driver", "com.mysql.cj.jdbc.Driver"));
    }
}
