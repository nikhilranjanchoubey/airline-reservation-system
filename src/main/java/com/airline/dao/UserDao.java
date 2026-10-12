package com.airline.dao;

import com.airline.model.User;
import java.util.List;

/**
 * Data Access Object interface for User entities.
 */
public interface UserDao {

    /**
     * Inserts a new user record into the database.
     *
     * @param user The user object to insert
     * @return true if insertion was successful, false otherwise
     */
    boolean createUser(User user);

    /**
     * Finds a user by their unique email address.
     *
     * @param email The user's email
     * @return User object if found, null otherwise
     */
    User findByEmail(String email);

    /**
     * Finds a user by their unique Google subject ID (sub).
     *
     * @param googleId The Google subject ID
     * @return User object if found, null otherwise
     */
    User findByGoogleId(String googleId);

    /**
     * Links a Google subject ID to an existing user account.
     *
     * @param userId   The user's ID
     * @param googleId The Google subject ID
     * @return true if linking succeeded, false otherwise
     */
    boolean linkGoogleId(int userId, String googleId);

    /**
     * Finds a user by their primary key user_id.
     *
     * @param userId The user's ID
     * @return User object if found, null otherwise
     */
    User findById(int userId);

    /**
     * Checks if a user already exists with the given email.
     *
     * @param email The email to check
     * @return true if exists, false otherwise
     */
    boolean existsByEmail(String email);

    /**
     * Updates editable profile fields (first_name, last_name, phone, passport_number, date_of_birth).
     *
     * @param user The user with updated details
     * @return true if update succeeded, false otherwise
     */
    boolean updateProfile(User user);

    /**
     * Updates the profile photo path/reference for a user.
     *
     * @param userId    The user's ID
     * @param photoPath The path to the uploaded photo, or null to remove
     * @return true if update succeeded, false otherwise
     */
    boolean updateProfilePhoto(int userId, String photoPath);

    /**
     * Updates the password hash and salt for a user.
     *
     * @param userId          The user's ID
     * @param newPasswordHash The new PBKDF2 password hash
     * @param newSalt         The new cryptographic salt
     * @return true if update succeeded, false otherwise
     */
    boolean updatePassword(int userId, String newPasswordHash, String newSalt);

    /**
     * Retrieves all users (for Admin User Management).
     *
     * @return List of all users
     */
    List<User> findAllUsers();

    /**
     * Updates user account status (ACTIVE or SUSPENDED).
     *
     * @param userId The user's ID
     * @param status The new status
     * @return true if update succeeded, false otherwise
     */
    boolean updateStatus(int userId, String status);

    /**
     * Returns the total count of registered users.
     *
     * @return total count
     */
    int countTotalUsers();
}
