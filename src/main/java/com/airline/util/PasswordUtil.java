package com.airline.util;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;

/**
 * Utility for secure password hashing and verification using PBKDF2 with HMAC-SHA512.
 * Adheres to OWASP cryptographic storage standards.
 */
public final class PasswordUtil {

    private static final String ALGORITHM = "PBKDF2WithHmacSHA512";
    private static final int ITERATIONS = 65536;
    private static final int KEY_LENGTH = 256; // bits
    private static final int SALT_BYTES = 16;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private PasswordUtil() {
        // Utility class
    }

    /**
     * Generates a cryptographically secure random salt encoded as a hex string.
     */
    public static String generateSalt() {
        byte[] salt = new byte[SALT_BYTES];
        SECURE_RANDOM.nextBytes(salt);
        return bytesToHex(salt);
    }

    /**
     * Hashes the raw password using PBKDF2WithHmacSHA512 with the provided hex salt.
     *
     * @param password Raw plaintext password
     * @param saltHex  Hex-encoded salt string
     * @return Hex-encoded password hash
     */
    public static String hashPassword(String password, String saltHex) {
        if (password == null || saltHex == null) {
            throw new IllegalArgumentException("Password and salt must not be null");
        }
        byte[] salt = hexToBytes(saltHex);
        try {
            KeySpec spec = new PBEKeySpec(password.toCharArray(), salt, ITERATIONS, KEY_LENGTH);
            SecretKeyFactory factory = SecretKeyFactory.getInstance(ALGORITHM);
            byte[] hash = factory.generateSecret(spec).getEncoded();
            return bytesToHex(hash);
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new RuntimeException("Error occurred while hashing password: " + e.getMessage(), e);
        }
    }

    /**
     * Verifies whether the provided raw password matches the expected hash.
     * Uses constant-time equality check to prevent timing attacks.
     *
     * @param rawPassword     Plaintext password from user input
     * @param saltHex         Stored salt
     * @param expectedHashHex Stored password hash
     * @return true if matches, false otherwise
     */
    public static boolean verifyPassword(String rawPassword, String saltHex, String expectedHashHex) {
        if (rawPassword == null || saltHex == null || expectedHashHex == null) {
            return false;
        }
        String calculatedHash = hashPassword(rawPassword, saltHex);
        return MessageDigest.isEqual(hexToBytes(calculatedHash), hexToBytes(expectedHashHex));
    }

    /**
     * Converts a byte array into a lowercase hex string.
     */
    public static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    /**
     * Converts a hex string into a byte array.
     */
    public static byte[] hexToBytes(String hex) {
        if (hex == null || hex.length() % 2 != 0) {
            throw new IllegalArgumentException("Invalid hex string");
        }
        int len = hex.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(hex.charAt(i), 16) << 4)
                    + Character.digit(hex.charAt(i + 1), 16));
        }
        return data;
    }
}
