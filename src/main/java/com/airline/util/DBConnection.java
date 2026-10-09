package com.airline.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Singleton database connection manager.
 * Reads connection settings from db.properties and provides connections.
 */
public class DBConnection {

    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());
    private static final Properties PROPERTIES = new Properties();

    private static String driver;
    private static String url;
    private static String username;
    private static String password;
    private static boolean initialized = false;

    static {
        loadProperties();
    }

    private DBConnection() {
    }

    private static synchronized void loadProperties() {
        if (initialized) {
            return;
        }

        try (InputStream input = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input == null) {
                LOGGER.log(Level.WARNING, "db.properties not found in classpath. Falling back to default settings.");
                driver = "com.mysql.cj.jdbc.Driver";
                url = "jdbc:mysql://localhost:3306/airline_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
                username = "root";
                password = "root";
            } else {
                PROPERTIES.load(input);
                driver = PROPERTIES.getProperty("db.driver", "com.mysql.cj.jdbc.Driver");
                url = PROPERTIES.getProperty("db.url", "jdbc:mysql://localhost:3306/airline_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC");
                username = PROPERTIES.getProperty("db.username", "root");
                password = PROPERTIES.getProperty("db.password", "root");
            }

            Class.forName(driver);
            initialized = true;
            LOGGER.info("JDBC Driver loaded successfully: " + driver);
        } catch (IOException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Failed to load database configuration or JDBC driver: " + e.getMessage(), e);
            throw new RuntimeException("Database initialization failure", e);
        }
    }

    /**
     * Obtains a new JDBC Connection from DriverManager.
     *
     * @return active java.sql.Connection
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        if (!initialized) {
            loadProperties();
        }
        return DriverManager.getConnection(url, username, password);
    }

    /**
     * Allows setting custom connection parameters (useful for unit/integration tests).
     */
    public static synchronized void configure(String customDriver, String customUrl, String customUser, String customPass) {
        driver = customDriver;
        url = customUrl;
        username = customUser;
        password = customPass;
        try {
            Class.forName(driver);
            initialized = true;
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Failed to load driver: " + driver, e);
        }
    }
}
