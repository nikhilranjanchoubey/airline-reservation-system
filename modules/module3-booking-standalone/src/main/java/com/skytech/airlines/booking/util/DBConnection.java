package com.skytech.airlines.booking.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Centralized JDBC connection utility with secure fallback configuration.
 */
public final class DBConnection {

    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());
    private static final String CONFIG_FILE = "application.properties";

    private static String dbDriver = "com.mysql.cj.jdbc.Driver";
    private static String dbUrl = "jdbc:mysql://localhost:3306/skytech_airlines_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";
    private static String dbUser = "root";
    private static String dbPassword = "";

    static {
        loadConfiguration();
        initializeDriver();
    }

    private DBConnection() {}

    private static void loadConfiguration() {
        Properties props = new Properties();
        try (InputStream in = DBConnection.class.getClassLoader().getResourceAsStream(CONFIG_FILE)) {
            if (in != null) {
                props.load(in);
                dbDriver = props.getProperty("db.driver", dbDriver).trim();
                dbUrl = props.getProperty("db.url", dbUrl).trim();
                dbUser = props.getProperty("db.user", dbUser).trim();
                dbPassword = props.getProperty("db.password", dbPassword).trim();
            }
        } catch (IOException e) {
            LOGGER.log(Level.FINE, "Notice reading " + CONFIG_FILE, e);
        }

        try (InputStream inDb = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (inDb != null) {
                Properties dbProps = new Properties();
                dbProps.load(inDb);
                if (dbProps.containsKey("db.driver")) dbDriver = dbProps.getProperty("db.driver").trim();
                if (dbProps.containsKey("db.url")) dbUrl = dbProps.getProperty("db.url").trim();
                if (dbProps.containsKey("db.user")) dbUser = dbProps.getProperty("db.user").trim();
                if (dbProps.containsKey("db.password")) dbPassword = dbProps.getProperty("db.password").trim();
            }
        } catch (IOException e) {
            LOGGER.log(Level.FINE, "Notice reading db.properties", e);
        }

        String envUrl = System.getenv("SKYTECH_DB_URL");
        if (envUrl != null && !envUrl.isBlank()) dbUrl = envUrl.trim();

        String envUser = System.getenv("SKYTECH_DB_USER");
        if (envUser != null && !envUser.isBlank()) dbUser = envUser.trim();

        String envPass = System.getenv("SKYTECH_DB_PASSWORD");
        if (envPass != null) dbPassword = envPass.trim();
    }

    private static void initializeDriver() {
        try {
            Class.forName(dbDriver);
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.WARNING, "MySQL Driver not found on classpath: " + dbDriver, e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(dbUrl, dbUser, dbPassword);
    }
}
