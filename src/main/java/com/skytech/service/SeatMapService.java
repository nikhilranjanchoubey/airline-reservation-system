package com.skytech.service;

import com.skytech.dao.SeatDao;
import com.skytech.model.Seat;

import java.util.List;

/**
 * Service managing seat map queries, seat types, and pricing.
 */
public class SeatMapService {

    private final SeatDao seatDao;

    public SeatMapService() {
        this.seatDao = new SeatDao();
    }

    public SeatMapService(SeatDao seatDao) {
        this.seatDao = seatDao;
    }

    /**
     * Retrieves all cabin seats with availability for a given flight schedule.
     */
    public List<Seat> getSeatMapForSchedule(int scheduleId) {
        return seatDao.getSeatsForSchedule(scheduleId);
    }

    /**
     * Retrieves cabin seats priced according to carrier ancillary rules.
     */
    public List<Seat> getSeatMapForSchedule(int scheduleId, String airlineCode) {
        return seatDao.getSeatsForSchedule(scheduleId, airlineCode);
    }
}
