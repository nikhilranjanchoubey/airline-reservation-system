package com.airline.init;

import com.airline.model.Role;
import com.airline.util.PasswordUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DatabaseInitializerTest {

    @Mock
    private Connection connection;

    @Mock
    private PreparedStatement selectPs;

    @Mock
    private PreparedStatement insertPs;

    @Mock
    private PreparedStatement updatePs;

    @Mock
    private ResultSet adminRs;

    @Mock
    private ResultSet passengerRs;

    @Test
    void testProvisionDemoAccountsWhenMissing() throws SQLException {
        when(connection.prepareStatement(startsWith("SELECT user_id"))).thenReturn(selectPs);
        when(connection.prepareStatement(startsWith("INSERT INTO users"))).thenReturn(insertPs);

        // Neither admin nor passenger exist
        when(selectPs.executeQuery()).thenReturn(adminRs, passengerRs);
        when(adminRs.next()).thenReturn(false);
        when(passengerRs.next()).thenReturn(false);

        DatabaseInitializer.provisionOrVerifyDemoAccounts(connection);

        // Verify insert statements executed twice (once for Admin, once for Passenger)
        verify(insertPs, times(2)).executeUpdate();
    }

    @Test
    void testVerifyDemoAccountsWhenAlreadyValid() throws SQLException {
        when(connection.prepareStatement(startsWith("SELECT user_id"))).thenReturn(selectPs);

        // Admin exists and has valid hash
        String adminSalt = DatabaseInitializer.DEMO_ADMIN_SALT;
        String adminHash = PasswordUtil.hashPassword(DatabaseInitializer.DEMO_ADMIN_PASS, adminSalt);

        // Passenger exists and has valid hash
        String passSalt = DatabaseInitializer.DEMO_PASSENGER_SALT;
        String passHash = PasswordUtil.hashPassword(DatabaseInitializer.DEMO_PASSENGER_PASS, passSalt);

        when(selectPs.executeQuery()).thenReturn(adminRs, passengerRs);

        when(adminRs.next()).thenReturn(true);
        when(adminRs.getInt("user_id")).thenReturn(1);
        when(adminRs.getString("password_hash")).thenReturn(adminHash);
        when(adminRs.getString("salt")).thenReturn(adminSalt);
        when(adminRs.getString("role")).thenReturn("ADMIN");
        when(adminRs.getString("status")).thenReturn("ACTIVE");

        when(passengerRs.next()).thenReturn(true);
        when(passengerRs.getInt("user_id")).thenReturn(2);
        when(passengerRs.getString("password_hash")).thenReturn(passHash);
        when(passengerRs.getString("salt")).thenReturn(passSalt);
        when(passengerRs.getString("role")).thenReturn("PASSENGER");
        when(passengerRs.getString("status")).thenReturn("ACTIVE");

        DatabaseInitializer.provisionOrVerifyDemoAccounts(connection);

        // Neither insert nor update should be called because accounts are already valid
        verify(connection, never()).prepareStatement(startsWith("INSERT INTO users"));
        verify(connection, never()).prepareStatement(startsWith("UPDATE users"));
    }

    @Test
    void testRepairDemoAccountWhenPasswordBroken() throws SQLException {
        when(connection.prepareStatement(startsWith("SELECT user_id"))).thenReturn(selectPs);
        when(connection.prepareStatement(startsWith("UPDATE users"))).thenReturn(updatePs);

        // Admin exists but has wrong/broken hash
        when(selectPs.executeQuery()).thenReturn(adminRs, passengerRs);

        when(adminRs.next()).thenReturn(true);
        when(adminRs.getInt("user_id")).thenReturn(1);
        when(adminRs.getString("password_hash")).thenReturn("obsolete_incompatible_hash");
        when(adminRs.getString("salt")).thenReturn(DatabaseInitializer.DEMO_ADMIN_SALT);
        when(adminRs.getString("role")).thenReturn("ADMIN");
        when(adminRs.getString("status")).thenReturn("ACTIVE");

        // Passenger already valid
        String passSalt = DatabaseInitializer.DEMO_PASSENGER_SALT;
        String passHash = PasswordUtil.hashPassword(DatabaseInitializer.DEMO_PASSENGER_PASS, passSalt);
        when(passengerRs.next()).thenReturn(true);
        when(passengerRs.getInt("user_id")).thenReturn(2);
        when(passengerRs.getString("password_hash")).thenReturn(passHash);
        when(passengerRs.getString("salt")).thenReturn(passSalt);
        when(passengerRs.getString("role")).thenReturn("PASSENGER");
        when(passengerRs.getString("status")).thenReturn("ACTIVE");

        DatabaseInitializer.provisionOrVerifyDemoAccounts(connection);

        // Update statement must be called once for Admin to repair credentials
        verify(updatePs, times(1)).executeUpdate();
    }
}
