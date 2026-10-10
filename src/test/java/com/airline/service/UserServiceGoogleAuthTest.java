package com.airline.service;

import com.airline.dao.UserDao;
import com.airline.model.Role;
import com.airline.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceGoogleAuthTest {

    @Mock
    private UserDao userDao;

    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService(userDao);
    }

    @Test
    void testProcessGoogleLoginNullIdToken() {
        ServiceResult<User> result = userService.processGoogleLogin(null, "client-id-123");
        assertFalse(result.isSuccess());
        assertEquals("Google ID token is required.", result.getMessage());
    }

    @Test
    void testProcessGoogleLoginBlankIdToken() {
        ServiceResult<User> result = userService.processGoogleLogin("   ", "client-id-123");
        assertFalse(result.isSuccess());
        assertEquals("Google ID token is required.", result.getMessage());
    }

    @Test
    void testProcessGoogleLoginNullClientId() {
        ServiceResult<User> result = userService.processGoogleLogin("dummy-token", null);
        assertFalse(result.isSuccess());
        assertEquals("Google Client ID is not configured on server.", result.getMessage());
    }

    @Test
    void testProcessGoogleLoginInvalidToken() {
        // Passing invalid JWT string will fail token verification
        ServiceResult<User> result = userService.processGoogleLogin("invalid.jwt.token", "client-id-123");
        assertFalse(result.isSuccess());
        assertTrue(result.getMessage().contains("Invalid") || result.getMessage().contains("failed"));
    }
}
