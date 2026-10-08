package com.skytech.integration;

import com.skytech.dao.FlightScheduleDao;
import com.skytech.model.FlightSchedule;

import java.time.LocalDate;
import java.util.List;

/**
 * Local MySQL database flight inventory provider.
 */
public class DatabaseFlightProvider implements FlightProvider {

    private final FlightScheduleDao flightScheduleDao;

    public DatabaseFlightProvider() {
        this.flightScheduleDao = new FlightScheduleDao();
    }

    public DatabaseFlightProvider(FlightScheduleDao flightScheduleDao) {
        this.flightScheduleDao = flightScheduleDao;
    }

    @Override
    public List<FlightSchedule> searchFlights(String origin, String destination, LocalDate departureDate,
                                              int passengers, String travelClass) throws Exception {
        return flightScheduleDao.searchFlights(origin, destination, departureDate, passengers);
    }

    @Override
    public FlightSchedule getFlightDetails(int scheduleId) throws Exception {
        return flightScheduleDao.getScheduleById(scheduleId);
    }

    @Override
    public String getProviderName() {
        return "Local Database Inventory";
    }

    @Override
    public boolean isLive() {
        return false;
    }
}
