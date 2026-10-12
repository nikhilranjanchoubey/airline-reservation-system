package com.skytech.airlines.booking.integration;

import java.util.List;

public interface FlightProvider {
    FlightSummary getFlightById(Long flightId);
    boolean hasAvailableSeats(Long flightId, int requiredSeats);
    List<FlightSummary> getSampleFlights();
}
