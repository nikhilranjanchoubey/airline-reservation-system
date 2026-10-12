package com.skytech.airlines.booking.integration;

import com.skytech.airlines.booking.dao.BookingDAO;
import com.skytech.airlines.booking.model.Booking;
import com.skytech.airlines.booking.model.BookingStatus;
import com.skytech.airlines.booking.model.PaymentStatus;

public class BookingExportServiceImpl implements IBookingExportService {
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    public Booking getBookingByPnr(String pnr) {
        return bookingDAO.findByPnr(pnr);
    }

    @Override
    public boolean cancelBookingByPnr(String pnr, String reason) {
        Booking booking = bookingDAO.findByPnr(pnr);
        if (booking == null) return false;
        booking.setBookingStatus(BookingStatus.CANCELLED);
        if (booking.getPayment() != null) {
            booking.getPayment().setPaymentStatus(PaymentStatus.REFUNDED);
        }
        if (booking.getSeatAllocations() != null) {
            for (var sa : booking.getSeatAllocations()) {
                sa.setAllocationStatus("RELEASED");
            }
        }
        return bookingDAO.updateBookingStatus(booking.getBookingId(), BookingStatus.CANCELLED);
    }
}
