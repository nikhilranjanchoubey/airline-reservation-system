package com.skytech.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Shared JDBC Database Connection Utility for SkyTech.
 * Manages database driver loading, connection pooling baseline, and resource cleanup.
 */
public final class DBConnectionUtil {

    private static final Logger LOGGER = Logger.getLogger(DBConnectionUtil.class.getName());
    private static final Properties PROPERTIES = new Properties();
    private static boolean driverLoaded = false;

    static {
        loadConfiguration();
    }

    private DBConnectionUtil() {
        // Utility class - prevent instantiation
    }

    /**
     * Loads database configuration properties from classpath.
     * Looks for 'db.properties' first; falls back to 'db.properties.example' with a warning if not present.
     */
    private static void loadConfiguration() {
        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
        InputStream input = classLoader.getResourceAsStream("db.properties");

        if (input == null) {
            LOGGER.log(Level.WARNING,
                    "db.properties not found in classpath. Attempting to fall back to db.properties.example. " +
                    "Please copy src/main/resources/db.properties.example to db.properties for local setup.");
            input = classLoader.getResourceAsStream("db.properties.example");
        }

        if (input != null) {
            try {
                PROPERTIES.load(input);
            } catch (IOException e) {
                LOGGER.log(Level.SEVERE, "Failed to load database properties configuration", e);
            } finally {
                try {
                    input.close();
                } catch (IOException ignored) {
                }
            }
        } else {
            LOGGER.log(Level.SEVERE, "Neither db.properties nor db.properties.example could be found in classpath.");
        }

        // Register JDBC driver
        String driver = AppConfig.getDbDriver();
        try {
            Class.forName(driver);
            driverLoaded = true;
            LOGGER.info("MySQL JDBC Driver registered successfully: " + driver);
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL JDBC Driver not found in classpath: " + driver, e);
        }
    }

    /**
     * Obtains a new database connection using loaded credentials.
     *
     * @return active {@link Connection} instance
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        if (!driverLoaded) {
            loadConfiguration();
        }

        String url = AppConfig.getDbUrl();
        String user = AppConfig.getDbUsername();
        String password = AppConfig.getDbPassword();

        return DriverManager.getConnection(url, user, password);
    }

    /**
     * Safely closes a database connection.
     *
     * @param connection the connection to close
     */
    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing database connection", e);
            }
        }
    }

    /**
     * Safely closes statement and result set resources.
     *
     * @param statement the statement to close
     * @param resultSet the result set to close
     */
    public static void closeResources(Statement statement, ResultSet resultSet) {
        if (resultSet != null) {
            try {
                resultSet.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing ResultSet", e);
            }
        }
        if (statement != null) {
            try {
                statement.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing Statement", e);
            }
        }
    }

    /**
     * Safely closes connection, statement, and result set resources.
     *
     * @param connection the connection to close
     * @param statement the statement to close
     * @param resultSet the result set to close
     */
    public static void closeAll(Connection connection, Statement statement, ResultSet resultSet) {
        closeResources(statement, resultSet);
        closeConnection(connection);
    }
}
