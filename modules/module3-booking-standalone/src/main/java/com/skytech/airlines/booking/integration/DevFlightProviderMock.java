package com.skytech.airlines.booking.integration;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class DevFlightProviderMock implements IFlightProvider {

    private final List<FlightSummary> flights = new ArrayList<>();

    public DevFlightProviderMock() {
        LocalDateTime baseTime = LocalDateTime.now().withMinute(0).withSecond(0).withNano(0);

        flights.add(new FlightSummary(
                101L, "SK-701", "Airbus A320neo", "DEL", "New Delhi (DEL)", "BOM", "Mumbai (BOM)",
                baseTime.plusDays(3).withHour(6).withMinute(30), baseTime.plusDays(3).withHour(8).withMinute(45),
                135, new BigDecimal("4500.00"), 180, 142, "Capt. Rajesh Sharma",
                710, "Silver Tier", "1.0x Base Miles &bull; Complimentary Beverage"
        ));

        flights.add(new FlightSummary(
                102L, "SK-304", "Boeing 737-800", "BLR", "Bengaluru (BLR)", "DEL", "New Delhi (DEL)",
                baseTime.plusDays(3).withHour(9).withMinute(15), baseTime.plusDays(3).withHour(12).withMinute(0),
                165, new BigDecimal("5200.00"), 180, 86, "Capt. Ananya Roy",
                1060, "Gold Privilege", "1.25x Bonus Miles &bull; Priority Check-in"
        ));

        flights.add(new FlightSummary(
                103L, "SK-902", "Boeing 787-9 Dreamliner", "BOM", "Mumbai (BOM)", "DXB", "Dubai Intl (DXB)",
                baseTime.plusDays(4).withHour(16).withMinute(45), baseTime.plusDays(4).withHour(20).withMinute(15),
                210, new BigDecimal("12500.00"), 240, 118, "Capt. Vikramaditya Rathore",
                1200, "Platinum Elite", "1.5x Bonus Miles &bull; Dubai Lounge Access"
        ));

        flights.add(new FlightSummary(
                104L, "SK-415", "Airbus A320neo", "BOM", "Mumbai (BOM)", "GOI", "Goa Dabolim (GOI)",
                baseTime.plusDays(3).withHour(11).withMinute(20), baseTime.plusDays(3).withHour(12).withMinute(35),
                75, new BigDecimal("3200.00"), 180, 64, "Capt. Sameer Kulkarni",
                430, "Silver Tier", "1.0x Base Miles &bull; Quick Baggage Drop"
        ));

        flights.add(new FlightSummary(
                105L, "SK-528", "Airbus A321neo", "DEL", "New Delhi (DEL)", "BLR", "Bengaluru (BLR)",
                baseTime.plusDays(4).withHour(14).withMinute(0), baseTime.plusDays(4).withHour(16).withMinute(50),
                170, new BigDecimal("5400.00"), 220, 175, "Capt. Neha Singhania",
                1060, "Gold Privilege", "1.25x Bonus Miles &bull; Free Standard Seat Selection"
        ));

        flights.add(new FlightSummary(
                106L, "SK-612", "Boeing 737-800", "CCU", "Kolkata (CCU)", "BOM", "Mumbai (BOM)",
                baseTime.plusDays(4).withHour(8).withMinute(10), baseTime.plusDays(4).withHour(11).withMinute(0),
                170, new BigDecimal("4800.00"), 180, 92, "Capt. Sourav Mukherjee",
                1020, "Silver Tier", "1.0x Base Miles &bull; Extra 5kg Baggage"
        ));

        flights.add(new FlightSummary(
                107L, "SK-220", "Airbus A320neo", "HYD", "Hyderabad (HYD)", "DEL", "New Delhi (DEL)",
                baseTime.plusDays(5).withHour(10).withMinute(30), baseTime.plusDays(5).withHour(12).withMinute(45),
                135, new BigDecimal("4650.00"), 180, 128, "Capt. Arjun Varma",
                780, "Gold Privilege", "1.25x Bonus Miles &bull; Express Baggage Delivery"
        ));

        flights.add(new FlightSummary(
                108L, "SK-880", "Boeing 787-9 Dreamliner", "MAA", "Chennai (MAA)", "SIN", "Singapore Changi (SIN)",
                baseTime.plusDays(5).withHour(23).withMinute(15), baseTime.plusDays(6).withHour(5).withMinute(45),
                240, new BigDecimal("14800.00"), 240, 74, "Capt. Meenakshi Sundaram",
                1820, "Platinum Elite", "1.5x Bonus Miles &bull; Changi Lounge &bull; Fast-Track Boarding"
        ));

        flights.add(new FlightSummary(
                109L, "SK-114", "Airbus A350-900", "DEL", "New Delhi (DEL)", "LHR", "London Heathrow (LHR)",
                baseTime.plusDays(6).withHour(2).withMinute(20), baseTime.plusDays(6).withHour(7).withMinute(10),
                560, new BigDecimal("38500.00"), 300, 153, "Capt. Harpreet Singh Brar",
                4180, "Diamond Executive", "2.0x Double Miles &bull; Heathrow VIP Lounge &bull; +15kg Baggage"
        ));

        flights.add(new FlightSummary(
                110L, "SK-332", "Airbus A320neo", "AMD", "Ahmedabad (AMD)", "BOM", "Mumbai (BOM)",
                baseTime.plusDays(3).withHour(18).withMinute(0), baseTime.plusDays(3).withHour(19).withMinute(15),
                75, new BigDecimal("2900.00"), 180, 49, "Capt. Rohan Patel",
                330, "Silver Tier", "1.0x Base Miles &bull; Priority Gate Service"
        ));

        flights.add(new FlightSummary(
                111L, "SK-745", "ATR 72-600", "BLR", "Bengaluru (BLR)", "GOI", "Goa Dabolim (GOI)",
                baseTime.plusDays(4).withHour(7).withMinute(45), baseTime.plusDays(4).withHour(9).withMinute(5),
                80, new BigDecimal("3100.00"), 78, 31, "Capt. Tanvi Hegde",
                360, "Silver Tier", "1.0x Base Miles &bull; Vacation Rewards Multiplier"
        ));

        flights.add(new FlightSummary(
                112L, "SK-950", "Boeing 737 MAX 8", "DEL", "New Delhi (DEL)", "BKK", "Bangkok Suvarnabhumi (BKK)",
                baseTime.plusDays(5).withHour(13).withMinute(50), baseTime.plusDays(5).withHour(19).withMinute(40),
                260, new BigDecimal("11200.00"), 189, 104, "Capt. Devendra Joshi",
                1840, "Platinum Elite", "1.5x Bonus Miles &bull; Suvarnabhumi VIP Fast-Track"
        ));
    }

    @Override
    public FlightSummary getFlightById(Long flightId) {
        if (flightId == null) return null;
        for (FlightSummary f : flights) {
            if (f.getFlightId().equals(flightId)) return f;
        }
        return null;
    }

    @Override
    public boolean hasAvailableSeats(Long flightId, int requiredSeats) {
        FlightSummary f = getFlightById(flightId);
        return f != null && f.getAvailableSeats() >= requiredSeats;
    }

    @Override
    public List<FlightSummary> getSampleFlights() {
        return new ArrayList<>(flights);
    }
}
