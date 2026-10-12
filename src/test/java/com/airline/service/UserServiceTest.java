package com.airline.service;

import com.airline.dao.UserDao;
import com.airline.model.Role;
import com.airline.model.User;
import com.airline.util.PasswordUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserDao userDao;

    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService(userDao);
    }

    private User createSampleUser(String email) {
        User user = new User();
        user.setUserId(1);
        user.setEmail(email);
        user.setFirstName("Jane");
        user.setLastName("Doe");
        user.setPhone("9876543210");
        user.setPassportNumber("A1234567");
        user.setDateOfBirth(LocalDate.of(1995, 5, 20));
        user.setRole(Role.PASSENGER);
        user.setStatus("ACTIVE");
        String salt = PasswordUtil.generateSalt();
        user.setSalt(salt);
        user.setPasswordHash(PasswordUtil.hashPassword("Secure@1234", salt));
        return user;
    }

    @Test
    void testRegisterSuccess() {
        User newUser = new User();
        newUser.setFirstName("John");
        newUser.setLastName("Doe");
        newUser.setEmail("john.doe@test.com");
        newUser.setPhone("9876543210");
        newUser.setPassportNumber("P12345678");
        newUser.setDateOfBirth(LocalDate.of(1992, 1, 15));

        when(userDao.existsByEmail("john.doe@test.com")).thenReturn(false);
        when(userDao.createUser(any(User.class))).thenReturn(true);

        ServiceResult<User> result = userService.register(newUser, "Secure@Pass1", "Secure@Pass1");

        assertTrue(result.isSuccess());
        assertNotNull(newUser.getSalt());
        assertNotNull(newUser.getPasswordHash());
        assertEquals("ACTIVE", newUser.getStatus());
        assertEquals(Role.PASSENGER, newUser.getRole());
        verify(userDao).createUser(newUser);
    }

    @Test
    void testRegisterNullUser() {
        ServiceResult<User> result = userService.register(null, "Pass@123", "Pass@123");
        assertFalse(result.isSuccess());
        assertEquals("Registration data is required.", result.getMessage());
    }

    @Test
    void testRegisterInvalidEmail() {
        User user = new User();
        user.setFirstName("John");
        user.setLastName("Doe");
        user.setEmail("not-an-email");
        user.setPhone("9876543210");

        ServiceResult<User> result = userService.register(user, "Secure@Pass1", "Secure@Pass1");
        assertFalse(result.isSuccess());
        assertTrue(result.getMessage().contains("email"));
    }

    @Test
    void testRegisterInvalidName() {
        User user = new User();
        user.setFirstName("J"); // too short
        user.setLastName("Doe");
        user.setEmail("john@test.com");
        user.setPhone("9876543210");

        ServiceResult<User> result = userService.register(user, "Secure@Pass1", "Secure@Pass1");
        assertFalse(result.isSuccess());
        assertTrue(result.getMessage().contains("First name"));
    }

    @Test
    void testRegisterInvalidPhone() {
        User user = new User();
        user.setFirstName("John");
        user.setLastName("Doe");
        user.setEmail("john@test.com");
        user.setPhone("123"); // too short

        ServiceResult<User> result = userService.register(user, "Secure@Pass1", "Secure@Pass1");
        assertFalse(result.isSuccess());
        assertTrue(result.getMessage().contains("Phone number"));
    }

    @Test
    void testRegisterPasswordMismatch() {
        User user = new User();
        user.setFirstName("John");
        user.setLastName("Doe");
        user.setEmail("john@test.com");
        user.setPhone("9876543210");

        ServiceResult<User> result = userService.register(user, "Secure@Pass1", "Different@Pass1");
        assertFalse(result.isSuccess());
        assertEquals("Passwords do not match.", result.getMessage());
    }

    @Test
    void testRegisterWeakPassword() {
        User user = new User();
        user.setFirstName("John");
        user.setLastName("Doe");
        user.setEmail("john@test.com");
        user.setPhone("9876543210");

        ServiceResult<User> result = userService.register(user, "weak", "weak");
        assertFalse(result.isSuccess());
        assertTrue(result.getMessage().contains("Password must be at least 8 characters long"));
    }

    @Test
    void testRegisterDuplicateEmail() {
        User user = new User();
        user.setFirstName("John");
        user.setLastName("Doe");
        user.setEmail("exists@test.com");
        user.setPhone("9876543210");

        when(userDao.existsByEmail("exists@test.com")).thenReturn(true);

        ServiceResult<User> result = userService.register(user, "Secure@Pass1", "Secure@Pass1");
        assertFalse(result.isSuccess());
        assertEquals("An account with this email address already exists.", result.getMessage());
    }

    @Test
    void testRegisterDatabaseFailure() {
        User user = new User();
        user.setFirstName("John");
        user.setLastName("Doe");
        user.setEmail("new@test.com");
        user.setPhone("9876543210");

        when(userDao.existsByEmail("new@test.com")).thenReturn(false);
        when(userDao.createUser(any(User.class))).thenReturn(false);

        ServiceResult<User> result = userService.register(user, "Secure@Pass1", "Secure@Pass1");
        assertFalse(result.isSuccess());
        assertTrue(result.getMessage().contains("database error"));
    }

    @Test
    void testLoginSuccess() {
        User sample = createSampleUser("jane@test.com");
        when(userDao.findByEmail("jane@test.com")).thenReturn(sample);

        ServiceResult<User> result = userService.login("jane@test.com", "Secure@1234");
        assertTrue(result.isSuccess());
        assertNotNull(result.getData());
        assertEquals("jane@test.com", result.getData().getEmail());
    }

    @Test
    void testLoginAdminSuccess() {
        User admin = new User();
        admin.setUserId(99);
        admin.setEmail("admin@airline.com");
        admin.setRole(Role.ADMIN);
        admin.setStatus("ACTIVE");
        String salt = PasswordUtil.generateSalt();
        admin.setSalt(salt);
        admin.setPasswordHash(PasswordUtil.hashPassword("Admin@12345", salt));

        when(userDao.findByEmail("admin@airline.com")).thenReturn(admin);

        ServiceResult<User> result = userService.login("admin@airline.com", "Admin@12345");
        assertTrue(result.isSuccess());
        assertNotNull(result.getData());
        assertEquals(Role.ADMIN, result.getData().getRole());
        assertTrue(result.getData().isAdmin());
    }

    @Test
    void testLoginPassengerSuccess() {
        User passenger = new User();
        passenger.setUserId(100);
        passenger.setEmail("passenger@airline.com");
        passenger.setRole(Role.PASSENGER);
        passenger.setStatus("ACTIVE");
        String salt = PasswordUtil.generateSalt();
        passenger.setSalt(salt);
        passenger.setPasswordHash(PasswordUtil.hashPassword("Passenger@12345", salt));

        when(userDao.findByEmail("passenger@airline.com")).thenReturn(passenger);

        ServiceResult<User> result = userService.login("passenger@airline.com", "Passenger@12345");
        assertTrue(result.isSuccess());
        assertNotNull(result.getData());
        assertEquals(Role.PASSENGER, result.getData().getRole());
        assertFalse(result.getData().isAdmin());
    }

    @Test
    void testLoginEmailNormalization() {
        User sample = createSampleUser("jane@test.com");
        when(userDao.findByEmail("jane@test.com")).thenReturn(sample);

        ServiceResult<User> result = userService.login("  JANE@TEST.COM  ", "Secure@1234");
        assertTrue(result.isSuccess());
        verify(userDao).findByEmail("jane@test.com");
    }

    @Test
    void testLoginDatabaseConnectivityFailure() {
        when(userDao.findByEmail("admin@airline.com"))
                .thenThrow(new com.airline.exception.DataAccessException("Connection refused"));

        ServiceResult<User> result = userService.login("admin@airline.com", "Admin@12345");
        assertFalse(result.isSuccess());
        assertTrue(result.getMessage().contains("Database connection failed") || result.getMessage().contains("temporarily unavailable"));
    }

    @Test
    void testLoginUnknownEmail() {
        when(userDao.findByEmail("unknown@test.com")).thenReturn(null);

        ServiceResult<User> result = userService.login("unknown@test.com", "AnyPassword");
        assertFalse(result.isSuccess());
        assertEquals("Invalid email or password.", result.getMessage());
    }

    @Test
    void testLoginInvalidPassword() {
        User sample = createSampleUser("jane@test.com");
        when(userDao.findByEmail("jane@test.com")).thenReturn(sample);

        ServiceResult<User> result = userService.login("jane@test.com", "WrongPassword!99");
        assertFalse(result.isSuccess());
        assertEquals("Invalid email or password.", result.getMessage());
    }

    @Test
    void testLoginSuspendedAccount() {
        User sample = createSampleUser("suspended@test.com");
        sample.setStatus("SUSPENDED");
        when(userDao.findByEmail("suspended@test.com")).thenReturn(sample);

        ServiceResult<User> result = userService.login("suspended@test.com", "Secure@1234");
        assertFalse(result.isSuccess());
        assertTrue(result.getMessage().contains("suspended"));
    }

    @Test
    void testLoginEmptyCredentials() {
        ServiceResult<User> result = userService.login("", "");
        assertFalse(result.isSuccess());
        assertEquals("Email and password are required.", result.getMessage());
    }

    @Test
    void testUpdateProfileSuccess() {
        User existing = createSampleUser("update@test.com");
        when(userDao.findById(1)).thenReturn(existing);
        when(userDao.updateProfile(any(User.class))).thenReturn(true);

        ServiceResult<User> result = userService.updateProfile(1, "Alice", "Smith", "9123456789", "B9876543", LocalDate.of(1990, 8, 12));
        assertTrue(result.isSuccess());
        assertEquals("Alice", result.getData().getFirstName());
        assertEquals("Smith", result.getData().getLastName());
        assertEquals("9123456789", result.getData().getPhone());
    }

    @Test
    void testUpdateProfileNotFound() {
        when(userDao.findById(99)).thenReturn(null);

        ServiceResult<User> result = userService.updateProfile(99, "Alice", "Smith", "9123456789", "B9876543", LocalDate.of(1990, 8, 12));
        assertFalse(result.isSuccess());
        assertEquals("User not found.", result.getMessage());
    }

    @Test
    void testUpdateProfileDatabaseFailure() {
        User existing = createSampleUser("update@test.com");
        when(userDao.findById(1)).thenReturn(existing);
        when(userDao.updateProfile(any(User.class))).thenReturn(false);

        ServiceResult<User> result = userService.updateProfile(1, "Alice", "Smith", "9123456789", "B9876543", LocalDate.of(1990, 8, 12));
        assertFalse(result.isSuccess());
        assertEquals("Failed to update profile in database.", result.getMessage());
    }

    @Test
    void testChangePasswordSuccess() {
        User existing = createSampleUser("pw@test.com");
        when(userDao.findById(1)).thenReturn(existing);
        when(userDao.updatePassword(eq(1), anyString(), anyString())).thenReturn(true);

        ServiceResult<Void> result = userService.changePassword(1, "Secure@1234", "BrandNew@9876", "BrandNew@9876");
        assertTrue(result.isSuccess());
        assertEquals("Password changed successfully.", result.getMessage());
    }

    @Test
    void testChangePasswordWrongCurrent() {
        User existing = createSampleUser("pw@test.com");
        when(userDao.findById(1)).thenReturn(existing);

        ServiceResult<Void> result = userService.changePassword(1, "WrongCurrentPass1!", "BrandNew@9876", "BrandNew@9876");
        assertFalse(result.isSuccess());
        assertEquals("Current password is incorrect.", result.getMessage());
    }

    @Test
    void testChangePasswordMismatchNew() {
        User existing = createSampleUser("pw@test.com");
        when(userDao.findById(1)).thenReturn(existing);

        ServiceResult<Void> result = userService.changePassword(1, "Secure@1234", "BrandNew@9876", "Different@1234");
        assertFalse(result.isSuccess());
        assertEquals("New passwords do not match.", result.getMessage());
    }

    @Test
    void testChangePasswordWeakNew() {
        User existing = createSampleUser("pw@test.com");
        when(userDao.findById(1)).thenReturn(existing);

        ServiceResult<Void> result = userService.changePassword(1, "Secure@1234", "weak", "weak");
        assertFalse(result.isSuccess());
        assertTrue(result.getMessage().contains("New password must be at least 8 characters long"));
    }

    @Test
    void testToggleUserStatusActiveToSuspended() {
        User user = createSampleUser("toggle@test.com");
        user.setStatus("ACTIVE");
        when(userDao.findById(1)).thenReturn(user);
        when(userDao.updateStatus(1, "SUSPENDED")).thenReturn(true);

        boolean toggled = userService.toggleUserStatus(1);
        assertTrue(toggled);
        verify(userDao).updateStatus(1, "SUSPENDED");
    }

    @Test
    void testToggleUserStatusSuspendedToActive() {
        User user = createSampleUser("toggle@test.com");
        user.setStatus("SUSPENDED");
        when(userDao.findById(1)).thenReturn(user);
        when(userDao.updateStatus(1, "ACTIVE")).thenReturn(true);

        boolean toggled = userService.toggleUserStatus(1);
        assertTrue(toggled);
        verify(userDao).updateStatus(1, "ACTIVE");
    }

    @Test
    void testGetAllUsers() {
        List<User> userList = Arrays.asList(createSampleUser("u1@test.com"), createSampleUser("u2@test.com"));
        when(userDao.findAllUsers()).thenReturn(userList);

        List<User> result = userService.getAllUsers();
        assertEquals(2, result.size());
    }
}
