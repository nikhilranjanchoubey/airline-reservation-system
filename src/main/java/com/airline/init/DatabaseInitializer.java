package com.airline.init;

import com.airline.model.Role;
import com.airline.util.DBConnection;
import com.airline.util.PasswordUtil;
import com.skytech.util.AppConfig;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Application startup lifecycle listener that verifies database connectivity,
 * creates essential database tables if missing, and idempotently provisions
 * or repairs the official SkyTech demo accounts (Admin and Passenger).
 */
@WebListener
public class DatabaseInitializer implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(DatabaseInitializer.class.getName());

    public static final String[] REQUIRED_TABLES = {
        "users", "airports", "airlines", "flights", "flight_schedules",
        "aircraft", "aircraft_seats", "flight_seat_inventory", "flight_searches",
        "bookings", "passengers", "payments", "tickets", "cancellations", "admin_audit_logs"
    };

    public static final String DEMO_ADMIN_EMAIL = "admin@airline.com";
    public static final String DEMO_ADMIN_PASS = "Admin@12345";
    public static final String DEMO_ADMIN_SALT = "a1b2c3d4e5f60718293a4b5c6d7e8f90";

    public static final String DEMO_PASSENGER_EMAIL = "passenger@airline.com";
    public static final String DEMO_PASSENGER_PASS = "Passenger@12345";
    public static final String DEMO_PASSENGER_SALT = "f1e2d3c4b5a69788796a5b4c3d2e1f00";

    private static final String SQL_CREATE_USERS_TABLE =
            "CREATE TABLE IF NOT EXISTS users (" +
            "    user_id INT AUTO_INCREMENT PRIMARY KEY," +
            "    email VARCHAR(100) NOT NULL UNIQUE," +
            "    google_id VARCHAR(255) NULL UNIQUE," +
            "    password_hash VARCHAR(256) NULL," +
            "    salt VARCHAR(64) NULL," +
            "    first_name VARCHAR(50) NOT NULL," +
            "    last_name VARCHAR(50) NOT NULL," +
            "    phone VARCHAR(20) NULL," +
            "    passport_number VARCHAR(30) NULL," +
            "    date_of_birth DATE NULL," +
            "    profile_photo VARCHAR(255) NULL," +
            "    role ENUM('PASSENGER', 'ADMIN') NOT NULL DEFAULT 'PASSENGER'," +
            "    status ENUM('ACTIVE', 'SUSPENDED') NOT NULL DEFAULT 'ACTIVE'," +
            "    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
            "    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP," +
            "    INDEX idx_user_email (email)," +
            "    INDEX idx_user_google_id (google_id)," +
            "    INDEX idx_user_role (role)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("[DB-INIT] Initializing SkyTech database and demo accounts...");
        initializeDatabaseSafely();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOGGER.info("[DB-INIT] SkyTech context shut down.");
    }

    /**
     * Attempts safe and idempotent initialization of database tables and demo accounts.
     *
     * @return true if database connection succeeded and accounts verified, false otherwise
     */
    public static synchronized boolean initializeDatabaseSafely() {
        // Attempt to create database if server reachable but database missing
        ensureDatabaseCatalogExists();

        try (Connection conn = DBConnection.getConnection()) {
            LOGGER.info("[DB-INIT] Database connection established successfully.");

            // 1. Ensure users table exists
            ensureUsersTableExists(conn);

            // 2. Ensure remaining schema master tables exist
            ensureMasterTablesExist(conn);

            // 3. Idempotently provision demo accounts
            provisionOrVerifyDemoAccounts(conn);

            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "[DB-INIT] Database connection not available on startup: " + e.getMessage());
            return false;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[DB-INIT] Unexpected error during database initialization: " + e.getMessage(), e);
            return false;
        }
    }

    private static void ensureDatabaseCatalogExists() {
        String url = AppConfig.getDbUrl();
        if (url == null || !url.contains("/skytech_db")) {
            return;
        }
        try {
            // Check if connecting directly to skytech_db works
            try (Connection testConn = DriverManager.getConnection(url, AppConfig.getDbUsername(), AppConfig.getDbPassword())) {
                return; // Database exists and is accessible
            }
        } catch (SQLException e) {
            String errorMsg = e.getMessage().toLowerCase();
            if (errorMsg.contains("unknown database") || errorMsg.contains("doesn't exist")) {
                LOGGER.info("[DB-INIT] Database skytech_db does not exist yet. Attempting creation...");
                int idx = url.indexOf("/skytech_db");
                String rootUrl = url.substring(0, idx + 1);
                int queryIdx = url.indexOf('?');
                if (queryIdx > 0) {
                    rootUrl += url.substring(queryIdx);
                }
                try (Connection rootConn = DriverManager.getConnection(rootUrl, AppConfig.getDbUsername(), AppConfig.getDbPassword());
                     Statement stmt = rootConn.createStatement()) {
                    stmt.executeUpdate("CREATE DATABASE IF NOT EXISTS skytech_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
                    LOGGER.info("[DB-INIT] Database skytech_db created successfully.");
                } catch (SQLException ex) {
                    LOGGER.log(Level.WARNING, "[DB-INIT] Could not create database catalog via root connection: " + ex.getMessage());
                }
            }
        }
    }

    private static void ensureUsersTableExists(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(SQL_CREATE_USERS_TABLE);
            LOGGER.info("[DB-INIT] Users table verified.");
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "[DB-INIT] Error creating/verifying users table: " + e.getMessage());
        }
    }

    private static void ensureMasterTablesExist(Connection conn) {
        List<String> missingTables = getMissingTables(conn);
        if (!missingTables.isEmpty()) {
            LOGGER.warning("[DB-INIT] Required database tables missing: " + missingTables + ". Loading full schema from resources...");
            executeSchemaScript(conn);

            List<String> remainingMissing = getMissingTables(conn);
            if (!remainingMissing.isEmpty()) {
                LOGGER.severe("[DB-INIT] FATAL: Database tables still missing after schema initialization: " + remainingMissing);
            } else {
                LOGGER.info("[DB-INIT] All 15 required database tables verified successfully.");
            }
        } else {
            LOGGER.info("[DB-INIT] All 15 required database tables verified.");
        }
    }

    public static List<String> getMissingTables(Connection conn) {
        List<String> missing = new ArrayList<>();
        for (String table : REQUIRED_TABLES) {
            String checkSql = "SELECT 1 FROM `" + table + "` LIMIT 1";
            try (Statement stmt = conn.createStatement()) {
                stmt.execute(checkSql);
            } catch (SQLException e) {
                missing.add(table);
            }
        }
        return missing;
    }

    private static void executeSchemaScript(Connection conn) {
        InputStream in = DatabaseInitializer.class.getClassLoader().getResourceAsStream("database/schema.sql");
        if (in == null) {
            LOGGER.log(Level.WARNING, "[DB-INIT] schema.sql resource not found in classpath.");
            return;
        }

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
             Statement stmt = conn.createStatement()) {

            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                String trimmed = line.trim();
                if (trimmed.isEmpty() || trimmed.startsWith("--") || trimmed.startsWith("/*")) {
                    continue;
                }
                sb.append(line).append("\n");
                if (trimmed.endsWith(";")) {
                    String sql = sb.toString().trim();
                    if (sql.endsWith(";")) {
                        sql = sql.substring(0, sql.length() - 1).trim();
                    }
                    if (!sql.isEmpty() && !sql.toUpperCase().startsWith("CREATE DATABASE") && !sql.toUpperCase().startsWith("USE ")) {
                        try {
                            stmt.execute(sql);
                        } catch (SQLException e) {
                            LOGGER.log(Level.FINE, "[DB-INIT] Schema execution note for statement: " + e.getMessage());
                        }
                    }
                    sb.setLength(0);
                }
            }
            LOGGER.info("[DB-INIT] Completed schema script execution.");
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "[DB-INIT] Failed executing schema script: " + e.getMessage(), e);
        }
    }

    /**
     * Idempotently creates or repairs the advertised demo accounts.
     */
    public static void provisionOrVerifyDemoAccounts(Connection conn) {
        provisionOrVerifyAccount(conn, DEMO_ADMIN_EMAIL, DEMO_ADMIN_PASS, DEMO_ADMIN_SALT,
                "Team", "SkyTech", "+91 9876543210", "ADM99988877", LocalDate.of(1985, 1, 1), Role.ADMIN);

        provisionOrVerifyAccount(conn, DEMO_PASSENGER_EMAIL, DEMO_PASSENGER_PASS, DEMO_PASSENGER_SALT,
                "Ramesh", "Kumar", "+91 999 777 8888", "P99887766", LocalDate.of(1993, 8, 20), Role.PASSENGER);
    }

    private static void provisionOrVerifyAccount(Connection conn, String email, String rawPassword, String defaultSalt,
                                                 String firstName, String lastName, String phone, String passportNumber,
                                                 LocalDate dob, Role role) {
        String cleanEmail = email.trim().toLowerCase();
        String selectSql = "SELECT user_id, password_hash, salt, role, status, first_name, last_name FROM users WHERE email = ?";
        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setString(1, cleanEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int userId = rs.getInt("user_id");
                    String existingHash = rs.getString("password_hash");
                    String existingSalt = rs.getString("salt");
                    String existingRole = rs.getString("role");
                    String existingStatus = rs.getString("status");
                    String existingFirstName = rs.getString("first_name");
                    String existingLastName = rs.getString("last_name");

                    // If account has default placeholder "John Doe", safely update to restored profile "Ramesh Kumar"
                    boolean nameNeedsUpdate = ("John".equalsIgnoreCase(existingFirstName) && "Doe".equalsIgnoreCase(existingLastName))
                            || (firstName != null && !firstName.equalsIgnoreCase(existingFirstName) && "passenger@airline.com".equalsIgnoreCase(cleanEmail));

                    if (nameNeedsUpdate) {
                        String updateNameSql = "UPDATE users SET first_name = ?, last_name = ?, phone = COALESCE(phone, ?), passport_number = COALESCE(passport_number, ?) WHERE user_id = ?";
                        try (PreparedStatement updateNamePs = conn.prepareStatement(updateNameSql)) {
                            updateNamePs.setString(1, firstName);
                            updateNamePs.setString(2, lastName);
                            updateNamePs.setString(3, phone);
                            updateNamePs.setString(4, passportNumber);
                            updateNamePs.setInt(5, userId);
                            updateNamePs.executeUpdate();
                            LOGGER.info("[DB-INIT] Corrected user account name to [" + firstName + " " + lastName + "] for [" + cleanEmail + "]");
                        }
                    }

                    boolean passwordValid = (existingHash != null && existingSalt != null)
                            && PasswordUtil.verifyPassword(rawPassword, existingSalt, existingHash);

                    boolean roleValid = role.name().equalsIgnoreCase(existingRole);
                    boolean statusValid = "ACTIVE".equalsIgnoreCase(existingStatus);

                    if (passwordValid && roleValid && statusValid) {
                        LOGGER.info("[DB-INIT] Verified account [" + cleanEmail + "] (Name: " + (nameNeedsUpdate ? firstName + " " + lastName : existingFirstName + " " + existingLastName) + ", Role: " + existingRole + ", Status: " + existingStatus + ")");
                    } else {
                        // Safe repair: refresh hash with expected password and ensure ACTIVE status and intended role
                        String newSalt = (existingSalt != null && !existingSalt.isBlank()) ? existingSalt : defaultSalt;
                        String newHash = PasswordUtil.hashPassword(rawPassword, newSalt);

                        String updateSql = "UPDATE users SET password_hash = ?, salt = ?, role = ?, status = 'ACTIVE' WHERE user_id = ?";
                        try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                            updatePs.setString(1, newHash);
                            updatePs.setString(2, newSalt);
                            updatePs.setString(3, role.name());
                            updatePs.setInt(4, userId);
                            updatePs.executeUpdate();
                            LOGGER.info("[DB-INIT] Safely refreshed demo account credentials for [" + cleanEmail + "]");
                        }
                    }
                } else {
                    // Idempotent insertion
                    String salt = (defaultSalt != null && !defaultSalt.isBlank()) ? defaultSalt : PasswordUtil.generateSalt();
                    String hash = PasswordUtil.hashPassword(rawPassword, salt);

                    String insertSql = "INSERT INTO users (email, password_hash, salt, first_name, last_name, phone, passport_number, date_of_birth, role, status) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE')";
                    try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                        insertPs.setString(1, cleanEmail);
                        insertPs.setString(2, hash);
                        insertPs.setString(3, salt);
                        insertPs.setString(4, firstName);
                        insertPs.setString(5, lastName);
                        insertPs.setString(6, phone);
                        insertPs.setString(7, passportNumber);
                        insertPs.setDate(8, Date.valueOf(dob));
                        insertPs.setString(9, role.name());
                        insertPs.executeUpdate();
                        LOGGER.info("[DB-INIT] Successfully provisioned account [" + cleanEmail + "] (" + firstName + " " + lastName + ") with role " + role);
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "[DB-INIT] Error provisioning demo account [" + cleanEmail + "]: " + e.getMessage(), e);
        }
    }
}
