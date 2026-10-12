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
    private static final Map<String, String> DOTENV_FALLBACK_MAP = new java.util.concurrent.ConcurrentHashMap<>();
    private static final Properties CLASSPATH_PROPERTIES = new Properties();
    private static final Map<String, String> CONFIG_SOURCES = new java.util.concurrent.ConcurrentHashMap<>();

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

        // 2. Fallback manual search for .env across common project/container locations
        loadDotenvManuallyIfEmpty();

        // 3. Load classpath properties (db.properties, api.properties)
        loadClasspathProperties("db.properties");
        loadClasspathProperties("api.properties");

        // 4. Log safe diagnostics (never exposing secrets)
        logSafeDiagnostics();
    }

    private static synchronized void loadDotenvManuallyIfEmpty() {
        String catalinaBase = System.getProperty("catalina.base");
        String catalinaHome = System.getProperty("catalina.home");
        String userDir = System.getProperty("user.dir");

        String[] possiblePaths = {
            "c:\\Users\\choub\\OneDrive\\Documents\\GitHub\\airline-reservation-system\\.env",
            catalinaBase != null ? catalinaBase + File.separator + ".env" : null,
            catalinaBase != null ? catalinaBase + File.separator + "bin" + File.separator + ".env" : null,
            catalinaBase != null ? catalinaBase + File.separator + "webapps" + File.separator + "airline-reservation-system" + File.separator + ".env" : null,
            catalinaBase != null ? catalinaBase + File.separator + "webapps" + File.separator + "airline-reservation-system" + File.separator + "WEB-INF" + File.separator + ".env" : null,
            catalinaHome != null ? catalinaHome + File.separator + ".env" : null,
            userDir != null ? userDir + File.separator + ".env" : null,
            "/etc/secrets/.env",
            ".env",
            "../.env",
            "../../.env"
        };

        for (String path : possiblePaths) {
            if (path == null) continue;
            File f = new File(path);
            if (f.exists() && f.isFile() && f.canRead()) {
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(new FileInputStream(f), StandardCharsets.UTF_8))) {
                    String line;
                    int keysLoaded = 0;
                    while ((line = reader.readLine()) != null) {
                        line = line.trim();
                        if (line.isEmpty() || line.startsWith("#")) continue;
                        int eq = line.indexOf('=');
                        if (eq > 0) {
                            String k = line.substring(0, eq).trim();
                            String v = cleanValue(line.substring(eq + 1).trim());
                            if (!k.isEmpty() && v != null && !v.isEmpty()) {
                                if (!DOTENV_FALLBACK_MAP.containsKey(k)) {
                                    DOTENV_FALLBACK_MAP.put(k, v);
                                    CONFIG_SOURCES.put(k, "Local file (" + f.getAbsolutePath() + ")");
                                    keysLoaded++;
                                }
                            }
                        }
                    }
                    if (keysLoaded > 0) {
                        LOGGER.info("Loaded " + keysLoaded + " configuration keys from: " + f.getAbsolutePath());
                    }
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
            CONFIG_SOURCES.put(key, "System environment variable (System.getenv)");
            return cleanValue(envVal);
        }

        // 2. Dotenv library
        if (dotenvInstance != null) {
            try {
                String val = dotenvInstance.get(key);
                if (val != null && !val.trim().isEmpty()) {
                    CONFIG_SOURCES.put(key, "Dotenv library (.env)");
                    return cleanValue(val);
                }
            } catch (Exception ignored) {
            }
        }

        // 3. Fallback .env map (if key missing, retry scan once)
        String fallbackVal = DOTENV_FALLBACK_MAP.get(key);
        if (fallbackVal == null && (key.startsWith("RAZORPAY") || key.startsWith("DB_") || key.startsWith("REEF"))) {
            loadDotenvManuallyIfEmpty();
            fallbackVal = DOTENV_FALLBACK_MAP.get(key);
        }
        if (fallbackVal != null && !fallbackVal.trim().isEmpty()) {
            return cleanValue(fallbackVal);
        }

        // 4. Classpath properties
        String propVal = CLASSPATH_PROPERTIES.getProperty(key);
        if (propVal != null && !propVal.trim().isEmpty()) {
            CONFIG_SOURCES.put(key, "Classpath properties file");
            return cleanValue(propVal);
        }

        return defaultValue;
    }

    private static String cleanValue(String val) {
        if (val == null) return null;
        val = val.trim();
        if ((val.startsWith("\"") && val.endsWith("\"")) || (val.startsWith("'") && val.endsWith("'"))) {
            if (val.length() >= 2) {
                val = val.substring(1, val.length() - 1).trim();
            }
        }
        return val;
    }

    public static String get(String key) {
        return get(key, null);
    }

    // ReefAPI accessors

    /**
     * Obtains the configured ReefAPI Key (from REEF_API_KEY or reef.api.key).
     * Fails cleanly if missing without exposing secret data.
     */
    public static String getReefApiKey() {
        String key = get("REEF_API_KEY", get("reef.api.key", null));
        if (key == null || key.trim().isEmpty()) {
            throw new IllegalStateException("ReefAPI configuration is missing. Please configure REEF_API_KEY in .env or environment.");
        }
        return key.trim();
    }

    /**
     * Returns true if ReefAPI Key is configured.
     */
    public static boolean isReefApiConfigured() {
        String key = get("REEF_API_KEY", get("reef.api.key", null));
        return key != null && !key.trim().isEmpty();
    }

    /**
     * Obtains the ReefAPI Base URL (default: https://api.reefapi.com).
     */
    public static String getReefApiBaseUrl() {
        return get("REEF_API_URL", "https://api.reefapi.com");
    }

    // Legacy accessors (deprecated)

    @Deprecated
    public static String getRapidApiKey() {
        return get("RAPIDAPI_KEY", "");
    }

    @Deprecated
    public static boolean isRapidApiConfigured() {
        String key = get("RAPIDAPI_KEY");
        return key != null && !key.trim().isEmpty();
    }

    @Deprecated
    public static String getRapidApiHost() {
        return get("RAPIDAPI_HOST", "aerodatabox.p.rapidapi.com");
    }

    // Database accessors

    public static String getDbUrl() {
        return get("DB_URL", get("db.url",
                "jdbc:mysql://localhost:3306/skytech_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata&characterEncoding=UTF-8"));
    }

    public static String getDbUsername() {
        return get("DB_USERNAME", get("db.user", "skytech_app"));
    }

    public static String getDbPassword() {
        return get("DB_PASSWORD", get("db.password", "SkyTech@Prod2026!"));
    }

    public static String getDbDriver() {
        return get("DB_DRIVER", get("db.driver", "com.mysql.cj.jdbc.Driver"));
    }

    // Razorpay payment integration accessors (Secure server-side handling)

    /**
     * Public Key ID safe for client-side Razorpay Checkout initialization.
     */
    public static String getRazorpayKeyId() {
        return get("RAZORPAY_KEY_ID", null);
    }

    /**
     * Private Key Secret strictly kept on server side for signature verification.
     */
    public static String getRazorpayKeySecret() {
        return get("RAZORPAY_KEY_SECRET", null);
    }

    /**
     * Indicates whether valid Razorpay credentials have been supplied.
     */
    public static boolean isRazorpayConfigured() {
        String key = getRazorpayKeyId();
        String secret = getRazorpayKeySecret();
        return key != null && !key.trim().isEmpty() && secret != null && !secret.trim().isEmpty();
    }

    /**
     * Reports which configuration source provided the given key.
     */
    public static String getConfigurationSource(String key) {
        if (key == null) return "Unknown";
        String src = CONFIG_SOURCES.get(key);
        return src != null ? src : "Not found in any source";
    }

    /**
     * Safe diagnostics: Logs whether credentials are present and their sources without exposing secret values.
     */
    public static void logSafeDiagnostics() {
        boolean keyIdPresent = getRazorpayKeyId() != null && !getRazorpayKeyId().trim().isEmpty();
        boolean keySecretPresent = getRazorpayKeySecret() != null && !getRazorpayKeySecret().trim().isEmpty();
        String keyIdSource = getConfigurationSource("RAZORPAY_KEY_ID");
        String keySecretSource = getConfigurationSource("RAZORPAY_KEY_SECRET");

        LOGGER.info("[APP-CONFIG DIAGNOSTICS] Razorpay Key ID Present: " + keyIdPresent + " (Source: " + keyIdSource + ")");
        LOGGER.info("[APP-CONFIG DIAGNOSTICS] Razorpay Key Secret Present: " + keySecretPresent + " (Source: " + keySecretSource + ")");
        LOGGER.info("[APP-CONFIG DIAGNOSTICS] Razorpay Fully Configured: " + isRazorpayConfigured());
    }
}

