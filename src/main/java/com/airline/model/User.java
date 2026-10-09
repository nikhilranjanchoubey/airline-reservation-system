package com.airline.model;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Entity representing a user (Passenger or Admin) in the system.
 */
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private int userId;
    private String email;
    private String passwordHash;
    private String salt;
    private String firstName;
    private String lastName;
    private String phone;
    private String passportNumber;
    private LocalDate dateOfBirth;
    private Role role = Role.PASSENGER;
    private String status = "ACTIVE";
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public User() {
    }

    public User(String email, String passwordHash, String salt, String firstName, 
                String lastName, String phone, String passportNumber, LocalDate dateOfBirth, Role role) {
        this.email = email;
        this.passwordHash = passwordHash;
        this.salt = salt;
        this.firstName = firstName;
        this.lastName = lastName;
        this.phone = phone;
        this.passportNumber = passportNumber;
        this.dateOfBirth = dateOfBirth;
        this.role = role != null ? role : Role.PASSENGER;
        this.status = "ACTIVE";
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getSalt() {
        return salt;
    }

    public void setSalt(String salt) {
        this.salt = salt;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getFullName() {
        if (firstName == null && lastName == null) return "";
        if (firstName == null) return lastName;
        if (lastName == null) return firstName;
        return firstName.trim() + " " + lastName.trim();
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getPassportNumber() {
        return passportNumber;
    }

    public void setPassportNumber(String passportNumber) {
        this.passportNumber = passportNumber;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public boolean isAdmin() {
        return Role.ADMIN.equals(this.role);
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", email='" + email + '\'' +
                ", firstName='" + firstName + '\'' +
                ", lastName='" + lastName + '\'' +
                ", phone='" + phone + '\'' +
                ", role=" + role +
                ", status='" + status + '\'' +
                '}';
    }
}
