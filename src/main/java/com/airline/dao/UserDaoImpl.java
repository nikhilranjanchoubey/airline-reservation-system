package com.airline.dao;

import com.airline.exception.DataAccessException;
import com.airline.model.Role;
import com.airline.model.User;
import com.airline.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * JDBC implementation of the UserDao interface.
 */
public class UserDaoImpl implements UserDao {

    private static final Logger LOGGER = Logger.getLogger(UserDaoImpl.class.getName());

    private static final String SQL_INSERT_USER =
            "INSERT INTO users (email, google_id, password_hash, salt, first_name, last_name, phone, passport_number, date_of_birth, role, status) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String SQL_FIND_BY_EMAIL =
            "SELECT user_id, email, google_id, password_hash, salt, first_name, last_name, phone, passport_number, date_of_birth, profile_photo, role, status, created_at, updated_at " +
            "FROM users WHERE email = ?";

    private static final String SQL_FIND_BY_GOOGLE_ID =
            "SELECT user_id, email, google_id, password_hash, salt, first_name, last_name, phone, passport_number, date_of_birth, profile_photo, role, status, created_at, updated_at " +
            "FROM users WHERE google_id = ?";

    private static final String SQL_LINK_GOOGLE_ID =
            "UPDATE users SET google_id = ? WHERE user_id = ?";

    private static final String SQL_FIND_BY_ID =
            "SELECT user_id, email, google_id, password_hash, salt, first_name, last_name, phone, passport_number, date_of_birth, profile_photo, role, status, created_at, updated_at " +
            "FROM users WHERE user_id = ?";

    private static final String SQL_EXISTS_BY_EMAIL =
            "SELECT 1 FROM users WHERE email = ? LIMIT 1";

    private static final String SQL_UPDATE_PROFILE =
            "UPDATE users SET first_name = ?, last_name = ?, phone = ?, passport_number = ?, date_of_birth = ? " +
            "WHERE user_id = ?";

    private static final String SQL_UPDATE_PROFILE_PHOTO =
            "UPDATE users SET profile_photo = ? WHERE user_id = ?";

    private static final String SQL_UPDATE_PASSWORD =
            "UPDATE users SET password_hash = ?, salt = ? WHERE user_id = ?";

    private static final String SQL_FIND_ALL =
            "SELECT user_id, email, google_id, password_hash, salt, first_name, last_name, phone, passport_number, date_of_birth, profile_photo, role, status, created_at, updated_at " +
            "FROM users ORDER BY created_at DESC";

    private static final String SQL_UPDATE_STATUS =
            "UPDATE users SET status = ? WHERE user_id = ?";

    private static final String SQL_COUNT_USERS =
            "SELECT COUNT(*) FROM users";

    @Override
    public boolean createUser(User user) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT_USER, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getEmail());
            ps.setString(2, user.getGoogleId());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getSalt());
            ps.setString(5, user.getFirstName());
            ps.setString(6, user.getLastName());
            ps.setString(7, user.getPhone());
            ps.setString(8, user.getPassportNumber());

            if (user.getDateOfBirth() != null) {
                ps.setDate(9, Date.valueOf(user.getDateOfBirth()));
            } else {
                ps.setNull(9, Types.DATE);
            }

            ps.setString(10, user.getRole() != null ? user.getRole().name() : Role.PASSENGER.name());
            ps.setString(11, user.getStatus() != null ? user.getStatus() : "ACTIVE");

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        user.setUserId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating user: " + user.getEmail(), e);
        }
        return false;
    }

    @Override
    public User findByEmail(String email) {
        if (email == null) return null;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_BY_EMAIL)) {

            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error finding user by email [" + email + "]: " + e.getMessage(), e);
            throw new DataAccessException("Database connectivity error while fetching user by email", e);
        }
        return null;
    }

    @Override
    public User findByGoogleId(String googleId) {
        if (googleId == null || googleId.isBlank()) return null;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_BY_GOOGLE_ID)) {

            ps.setString(1, googleId.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by googleId: " + googleId, e);
        }
        return null;
    }

    @Override
    public boolean linkGoogleId(int userId, String googleId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_LINK_GOOGLE_ID)) {

            ps.setString(1, googleId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error linking googleId for user ID: " + userId, e);
        }
        return false;
    }

    @Override
    public User findById(int userId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_BY_ID)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error finding user by ID [" + userId + "]: " + e.getMessage(), e);
            throw new DataAccessException("Database connectivity error while fetching user by ID", e);
        }
        return null;
    }

    @Override
    public boolean existsByEmail(String email) {
        if (email == null) return false;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_EXISTS_BY_EMAIL)) {

            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error checking email existence [" + email + "]: " + e.getMessage(), e);
            throw new DataAccessException("Database connectivity error while checking email existence", e);
        }
    }

    @Override
    public boolean updateProfile(User user) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_UPDATE_PROFILE)) {

            ps.setString(1, user.getFirstName());
            ps.setString(2, user.getLastName());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getPassportNumber());

            if (user.getDateOfBirth() != null) {
                ps.setDate(5, Date.valueOf(user.getDateOfBirth()));
            } else {
                ps.setNull(5, Types.DATE);
            }

            ps.setInt(6, user.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating profile for user ID: " + user.getUserId(), e);
        }
        return false;
    }

    @Override
    public boolean updateProfilePhoto(int userId, String photoPath) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_UPDATE_PROFILE_PHOTO)) {

            if (photoPath != null && !photoPath.isBlank()) {
                ps.setString(1, photoPath.trim());
            } else {
                ps.setNull(1, Types.VARCHAR);
            }
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating profile photo for user ID: " + userId, e);
        }
        return false;
    }

    @Override
    public boolean updatePassword(int userId, String newPasswordHash, String newSalt) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_UPDATE_PASSWORD)) {

            ps.setString(1, newPasswordHash);
            ps.setString(2, newSalt);
            ps.setInt(3, userId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating password for user ID: " + userId, e);
        }
        return false;
    }

    @Override
    public List<User> findAllUsers() {
        List<User> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_ALL);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRowToUser(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error fetching all users: " + e.getMessage(), e);
            throw new DataAccessException("Database connectivity error while fetching all users", e);
        }
        return list;
    }

    @Override
    public boolean updateStatus(int userId, String status) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_UPDATE_STATUS)) {

            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating status for user ID: " + userId, e);
        }
        return false;
    }

    @Override
    public int countTotalUsers() {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_COUNT_USERS);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error counting users: " + e.getMessage(), e);
            throw new DataAccessException("Database connectivity error while counting users", e);
        }
        return 0;
    }

    private User mapRowToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setEmail(rs.getString("email"));
        user.setGoogleId(rs.getString("google_id"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setSalt(rs.getString("salt"));
        user.setFirstName(rs.getString("first_name"));
        user.setLastName(rs.getString("last_name"));
        user.setPhone(rs.getString("phone"));
        user.setPassportNumber(rs.getString("passport_number"));

        Date dob = rs.getDate("date_of_birth");
        if (dob != null) {
            user.setDateOfBirth(dob.toLocalDate());
        }

        try {
            user.setProfilePhoto(rs.getString("profile_photo"));
        } catch (SQLException ignored) {
            // Field might be omitted in custom queries
        }

        user.setRole(Role.fromString(rs.getString("role")));
        user.setStatus(rs.getString("status"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            user.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            user.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return user;
    }
}
