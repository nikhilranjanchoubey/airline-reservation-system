package com.skytech.airlines.booking.config;

import com.skytech.airlines.booking.util.DBConnection;
import java.sql.Connection;
import java.sql.SQLException;

public class DatabaseConfig {
    public static Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }
}
