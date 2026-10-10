package com.airline.service;

import com.airline.dao.UserDao;
import com.airline.dao.UserDaoImpl;
import com.airline.model.Role;
import com.airline.model.User;
import com.airline.util.PasswordUtil;
import com.airline.util.ValidationUtil;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service class orchestrating business logic for Authentication & User Management.
 */
public class UserService {

    private final UserDao userDao;

    public UserService() {
        this.userDao = new UserDaoImpl();
    }

    public UserService(UserDao userDao) {
        this.userDao = userDao;
    }

    /**
     * Registers a new passenger.
     */
    public ServiceResult<User> register(User user, String rawPassword, String confirmPassword) {
        if (user == null) {
            return ServiceResult.fail("Registration data is required.");
        }

        // Validate names
        if (!ValidationUtil.isValidName(user.getFirstName())) {
            return ServiceResult.fail("First name must be between 2 and 50 alphabetic characters.");
        }
        if (!ValidationUtil.isValidName(user.getLastName())) {
            return ServiceResult.fail("Last name must be between 2 and 50 alphabetic characters.");
        }

        // Validate email
        if (!ValidationUtil.isValidEmail(user.getEmail())) {
            return ServiceResult.fail("Please provide a valid email address.");
        }

        // Validate phone
        if (!ValidationUtil.isValidPhone(user.getPhone())) {
            return ServiceResult.fail("Phone number must contain between 7 and 15 digits.");
        }

        // Validate passport if present
        if (!ValidationUtil.isValidPassport(user.getPassportNumber())) {
            return ServiceResult.fail("Passport number must be 6 to 20 alphanumeric characters.");
        }

        // Validate Date of Birth
        if (user.getDateOfBirth() != null && !ValidationUtil.isValidDateOfBirth(user.getDateOfBirth())) {
            return ServiceResult.fail("Please provide a valid past date of birth (must be a realistic passenger age).");
        }

        // Validate password
        if (rawPassword == null || !rawPassword.equals(confirmPassword)) {
            return ServiceResult.fail("Passwords do not match.");
        }
        if (!ValidationUtil.isValidPassword(rawPassword)) {
            return ServiceResult.fail("Password must be at least 8 characters long, contain uppercase, lowercase, a number, and a special character.");
        }

        // Check if email already in use
        if (userDao.existsByEmail(user.getEmail())) {
            return ServiceResult.fail("An account with this email address already exists.");
        }

        // Secure password hashing
        String salt = PasswordUtil.generateSalt();
        String passwordHash = PasswordUtil.hashPassword(rawPassword, salt);

        user.setSalt(salt);
        user.setPasswordHash(passwordHash);
        if (user.getRole() == null) {
            user.setRole(Role.PASSENGER);
        }
        user.setStatus("ACTIVE");

        boolean created = userDao.createUser(user);
        if (created) {
            return ServiceResult.ok("Registration successful! You may now log in.", user);
        } else {
            return ServiceResult.fail("Failed to create account due to a database error. Please try again later.");
        }
    }

    /**
     * Authenticates a user with email and password.
     */
    public ServiceResult<User> login(String email, String rawPassword) {
        if (email == null || email.trim().isEmpty() || rawPassword == null || rawPassword.isEmpty()) {
            return ServiceResult.fail("Email and password are required.");
        }

        User user = userDao.findByEmail(email.trim().toLowerCase());
        if (user == null) {
            return ServiceResult.fail("Invalid email or password.");
        }

        if ("SUSPENDED".equalsIgnoreCase(user.getStatus())) {
            return ServiceResult.fail("Your account has been suspended. Please contact support.");
        }

        boolean passwordMatch = PasswordUtil.verifyPassword(rawPassword, user.getSalt(), user.getPasswordHash());
        if (!passwordMatch) {
            return ServiceResult.fail("Invalid email or password.");
        }

        return ServiceResult.ok("Login successful.", user);
    }

    /**
     * Updates profile personal details.
     */
    public ServiceResult<User> updateProfile(int userId, String firstName, String lastName, 
                                             String phone, String passportNumber, LocalDate dob) {
        User user = userDao.findById(userId);
        if (user == null) {
            return ServiceResult.fail("User not found.");
        }

        if (!ValidationUtil.isValidName(firstName)) {
            return ServiceResult.fail("First name must be between 2 and 50 alphabetic characters.");
        }
        if (!ValidationUtil.isValidName(lastName)) {
            return ServiceResult.fail("Last name must be between 2 and 50 alphabetic characters.");
        }
        if (!ValidationUtil.isValidPhone(phone)) {
            return ServiceResult.fail("Phone number must contain between 7 and 15 digits.");
        }
        if (!ValidationUtil.isValidPassport(passportNumber)) {
            return ServiceResult.fail("Passport number must be 6 to 20 alphanumeric characters.");
        }
        if (dob != null && !ValidationUtil.isValidDateOfBirth(dob)) {
            return ServiceResult.fail("Please provide a valid date of birth.");
        }

        user.setFirstName(firstName.trim());
        user.setLastName(lastName.trim());
        user.setPhone(phone.trim());
        user.setPassportNumber(passportNumber != null ? passportNumber.trim() : null);
        user.setDateOfBirth(dob);

        boolean updated = userDao.updateProfile(user);
        if (updated) {
            return ServiceResult.ok("Profile updated successfully.", user);
        } else {
            return ServiceResult.fail("Failed to update profile in database.");
        }
    }

    /**
     * Changes user's password.
     */
    public ServiceResult<Void> changePassword(int userId, String currentPassword, 
                                              String newPassword, String confirmPassword) {
        User user = userDao.findById(userId);
        if (user == null) {
            return ServiceResult.fail("User not found.");
        }

        if (currentPassword == null || !PasswordUtil.verifyPassword(currentPassword, user.getSalt(), user.getPasswordHash())) {
            return ServiceResult.fail("Current password is incorrect.");
        }

        if (newPassword == null || !newPassword.equals(confirmPassword)) {
            return ServiceResult.fail("New passwords do not match.");
        }

        if (!ValidationUtil.isValidPassword(newPassword)) {
            return ServiceResult.fail("New password must be at least 8 characters long, contain uppercase, lowercase, a number, and a special character.");
        }

        String newSalt = PasswordUtil.generateSalt();
        String newHash = PasswordUtil.hashPassword(newPassword, newSalt);

        boolean updated = userDao.updatePassword(userId, newHash, newSalt);
        if (updated) {
            return ServiceResult.ok("Password changed successfully.", null);
        } else {
            return ServiceResult.fail("Failed to update password in database.");
        }
    }

    /**
     * Retrieves all users for admin management.
     */
    public List<User> getAllUsers() {
        return userDao.findAllUsers();
    }

    /**
     * Toggles user status between ACTIVE and SUSPENDED.
     */
    public boolean toggleUserStatus(int userId) {
        User user = userDao.findById(userId);
        if (user == null) {
            return false;
        }
        String newStatus = "ACTIVE".equalsIgnoreCase(user.getStatus()) ? "SUSPENDED" : "ACTIVE";
        return userDao.updateStatus(userId, newStatus);
    }

    /**
     * Retrieves user by ID.
     */
    public User getUserById(int userId) {
        return userDao.findById(userId);
    }

    /**
     * Verifies a Google ID token and authenticates or registers the user.
     *
     * @param idTokenString    The JWT ID token sent from Google Identity Services
     * @param expectedClientId The configured Google Client ID
     * @return ServiceResult containing authenticated User or failure message
     */
    public ServiceResult<User> processGoogleLogin(String idTokenString, String expectedClientId) {
        if (idTokenString == null || idTokenString.isBlank()) {
            return ServiceResult.fail("Google ID token is required.");
        }
        if (expectedClientId == null || expectedClientId.isBlank()) {
            return ServiceResult.fail("Google Client ID is not configured on server.");
        }

        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), new GsonFactory())
                    .setAudience(Collections.singletonList(expectedClientId))
                    .setIssuers(Arrays.asList("https://accounts.google.com", "accounts.google.com"))
                    .build();

            GoogleIdToken idToken = verifier.verify(idTokenString);
            if (idToken == null) {
                return ServiceResult.fail("Invalid or expired Google authentication token.");
            }

            GoogleIdToken.Payload payload = idToken.getPayload();
            String googleId = payload.getSubject();
            String email = payload.getEmail();
            Boolean emailVerified = payload.getEmailVerified();

            if (googleId == null || googleId.isBlank()) {
                return ServiceResult.fail("Invalid Google token: subject identifier missing.");
            }
            if (email == null || email.isBlank()) {
                return ServiceResult.fail("Invalid Google token: email missing.");
            }
            if (emailVerified != null && !emailVerified) {
                return ServiceResult.fail("Google email address is not verified.");
            }

            String cleanEmail = email.trim().toLowerCase();

            // 1. Check if user already exists with this googleId
            User user = userDao.findByGoogleId(googleId);
            if (user != null) {
                if ("SUSPENDED".equalsIgnoreCase(user.getStatus())) {
                    return ServiceResult.fail("Your account has been suspended. Please contact support.");
                }
                return ServiceResult.ok("Google sign-in successful.", user);
            }

            // 2. Check if user exists by email address (Safe Account Linking Policy)
            User existingUser = userDao.findByEmail(cleanEmail);
            if (existingUser != null) {
                if ("SUSPENDED".equalsIgnoreCase(existingUser.getStatus())) {
                    return ServiceResult.fail("Your account has been suspended. Please contact support.");
                }
                if (existingUser.getGoogleId() != null && !existingUser.getGoogleId().equals(googleId)) {
                    return ServiceResult.fail("An account with this email is already linked to another Google account.");
                }

                // Safely link Google ID to existing verified account
                boolean linked = userDao.linkGoogleId(existingUser.getUserId(), googleId);
                if (linked) {
                    existingUser.setGoogleId(googleId);
                    return ServiceResult.ok("Google account linked successfully.", existingUser);
                } else {
                    return ServiceResult.fail("Failed to link Google account in database.");
                }
            }

            // 3. New User Registration via Google (Strictly PASSENGER role)
            String name = (String) payload.get("name");
            String givenName = (String) payload.get("given_name");
            String familyName = (String) payload.get("family_name");

            String firstName = (givenName != null && !givenName.isBlank()) ? givenName.trim() : "Passenger";
            String lastName = (familyName != null && !familyName.isBlank()) ? familyName.trim() : "User";

            if ((givenName == null || givenName.isBlank()) && name != null && !name.isBlank()) {
                String[] parts = name.trim().split("\\s+", 2);
                firstName = parts[0];
                if (parts.length > 1) {
                    lastName = parts[1];
                }
            }

            User newUser = new User();
            newUser.setEmail(cleanEmail);
            newUser.setGoogleId(googleId);
            newUser.setFirstName(firstName);
            newUser.setLastName(lastName);
            newUser.setPhone(null);
            newUser.setPassportNumber(null);
            newUser.setDateOfBirth(null);
            newUser.setPasswordHash(null);
            newUser.setSalt(null);
            newUser.setRole(Role.PASSENGER); // Always PASSENGER for new Google registrations
            newUser.setStatus("ACTIVE");

            boolean created = userDao.createUser(newUser);
            if (created) {
                return ServiceResult.ok("Passenger account created via Google Sign-In.", newUser);
            } else {
                return ServiceResult.fail("Failed to create user account from Google Sign-In.");
            }

        } catch (Exception e) {
            Logger.getLogger(UserService.class.getName()).log(Level.SEVERE, "Error verifying Google token", e);
            return ServiceResult.fail("Google authentication failed: " + e.getMessage());
        }
    }
}
