package com.skytech.airlines.booking.model;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.Period;

/**
 * Traveler entity representing passenger demographics and identification.
 */
public class Passenger implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long passengerId;
    private Long bookingId;
    private String firstName;
    private String lastName;
    private LocalDate dateOfBirth;
    private String gender;
    private PassengerType passengerType = PassengerType.ADULT;
    private String passportOrId;
    private String nationality = "Indian";
    private String seatNumber;

    public Passenger() {}

    public Passenger(String firstName, String lastName, LocalDate dateOfBirth, 
                     String gender, PassengerType passengerType, String passportOrId, String nationality) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.dateOfBirth = dateOfBirth;
        this.gender = gender;
        this.passengerType = passengerType != null ? passengerType : PassengerType.ADULT;
        this.passportOrId = passportOrId;
        this.nationality = (nationality != null && !nationality.trim().isEmpty()) ? nationality : "Indian";
    }

    public int getAge() {
        if (dateOfBirth == null) return 0;
        return Period.between(dateOfBirth, LocalDate.now()).getYears();
    }

    public String getFullName() {
        return ((firstName != null ? firstName : "") + " " + (lastName != null ? lastName : "")).trim();
    }

    // Getters and Setters
    public Long getPassengerId() { return passengerId; }
    public void setPassengerId(Long passengerId) { this.passengerId = passengerId; }

    public Long getBookingId() { return bookingId; }
    public void setBookingId(Long bookingId) { this.bookingId = bookingId; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public PassengerType getPassengerType() { return passengerType; }
    public void setPassengerType(PassengerType passengerType) { this.passengerType = passengerType; }

    public String getPassportOrId() { return passportOrId; }
    public void setPassportOrId(String passportOrId) { this.passportOrId = passportOrId; }

    public String getNationality() { return nationality; }
    public void setNationality(String nationality) { this.nationality = nationality; }

    public String getSeatNumber() { return seatNumber; }
    public void setSeatNumber(String seatNumber) { this.seatNumber = seatNumber; }

    @Override
    public String toString() {
        return "Passenger{" +
                "name='" + getFullName() + "\'" +
                ", type=" + passengerType +
                ", seat=" + seatNumber +
                '}';
    }
}
