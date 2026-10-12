package com.skytech.airlines.booking.integration;

import com.skytech.airlines.booking.model.Booking;

public interface IBookingExportService {
    Booking getBookingByPnr(String pnr);
    boolean cancelBookingByPnr(String pnr, String reason);
}
