package com.airline.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class PasswordUtilTest {

    @Test
    void testGenerateSaltNotNullOrEmpty() {
        String salt1 = PasswordUtil.generateSalt();
        String salt2 = PasswordUtil.generateSalt();

        assertNotNull(salt1);
        assertEquals(32, salt1.length()); // 16 bytes in hex = 32 chars
        assertNotEquals(salt1, salt2);
    }

    @Test
    void testHashAndVerifySuccess() {
        String password = "SecurePassword@123";
        String salt = PasswordUtil.generateSalt();
        String hash = PasswordUtil.hashPassword(password, salt);

        assertNotNull(hash);
        assertEquals(64, hash.length()); // 256 bits = 32 bytes = 64 hex chars

        assertTrue(PasswordUtil.verifyPassword(password, salt, hash));
        assertFalse(PasswordUtil.verifyPassword("WrongPassword", salt, hash));
        assertFalse(PasswordUtil.verifyPassword(password, "00000000000000000000000000000000", hash));
    }

    @Test
    void testPrintSeedHashes() {
        String saltAdmin = "a1b2c3d4e5f60718293a4b5c6d7e8f90";
        String hashAdmin = PasswordUtil.hashPassword("Admin@12345", saltAdmin);
        System.out.println("SEED_ADMIN_SALT=" + saltAdmin);
        System.out.println("SEED_ADMIN_HASH=" + hashAdmin);

        String saltPassenger = "f1e2d3c4b5a69788796a5b4c3d2e1f00";
        String hashPassenger = PasswordUtil.hashPassword("Passenger@12345", saltPassenger);
        System.out.println("SEED_PASSENGER_SALT=" + saltPassenger);
        System.out.println("SEED_PASSENGER_HASH=" + hashPassenger);

        assertTrue(PasswordUtil.verifyPassword("Admin@12345", saltAdmin, hashAdmin));
        assertTrue(PasswordUtil.verifyPassword("Passenger@12345", saltPassenger, hashPassenger));
    }
}
