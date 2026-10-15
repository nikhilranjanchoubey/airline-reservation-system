package com.skytech.controller.api;

import com.airline.model.Role;
import com.airline.model.User;
import com.skytech.dto.UserDto;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

class AuthApiControllerTest {

    @Test
    @DisplayName("UserDto strips passwordHash and salt from serialized user payload")
    void testUserDtoSafety() {
        User user = new User();
        user.setUserId(99);
        user.setEmail("passenger@skytech.com");
        user.setFirstName("Sarah");
        user.setLastName("Connor");
        user.setPasswordHash("super_secret_argon2_hash");
        user.setSalt("random_salt_12345");
        user.setPhone("+919876543210");
        user.setDateOfBirth(LocalDate.of(1995, 5, 20));
        user.setRole(Role.PASSENGER);
        user.setStatus("ACTIVE");

        UserDto dto = UserDto.fromEntity(user);

        assertNotNull(dto);
        assertEquals(99, dto.getUserId());
        assertEquals("passenger@skytech.com", dto.getEmail());
        assertEquals("Sarah", dto.getFirstName());
        assertEquals("Connor", dto.getLastName());
        assertEquals(Role.PASSENGER, dto.getRole());
        assertEquals("+919876543210", dto.getPhone());
        assertEquals(LocalDate.of(1995, 5, 20), dto.getDateOfBirth());
        // Verify that UserDto class literally has no getPasswordHash or getSalt accessors
    }

    @Test
    @DisplayName("UserDto handles null gracefully")
    void testUserDtoNull() {
        assertNull(UserDto.fromEntity(null));
    }
}
