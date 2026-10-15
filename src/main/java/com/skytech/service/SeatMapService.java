package com.skytech.service;

import com.skytech.dao.SeatDao;
import com.skytech.model.CabinLayout;
import com.skytech.model.CabinRow;
import com.skytech.model.Seat;
import com.skytech.model.SeatCategory;

import java.math.BigDecimal;
import java.util.*;

/**
 * Service managing aircraft cabin layout construction, seat map queries,
 * seat types, pricing, and smart contiguous seat allocation.
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

    /**
     * Constructs a full, structured aircraft cabin layout matching the aircraft model,
     * travel class, and carrier configuration.
     *
     * @param scheduleId flight schedule identifier
     * @param airlineCode IATA airline code (e.g. 6E, AI, QP)
     * @param travelClass Economy, Business, First, Premium Economy
     * @param aircraftModel aircraft model name (e.g. Airbus A320neo, Boeing 737-800, Boeing 777)
     * @param airlineName carrier name
     * @return {@link CabinLayout} object
     */
    public CabinLayout getCabinLayout(int scheduleId, String airlineCode, String travelClass, String aircraftModel, String airlineName) {
        CabinLayout layout = new CabinLayout();
        String model = (aircraftModel != null && !aircraftModel.trim().isEmpty()) ? aircraftModel.trim() : "Airbus A320neo";
        String carrierCode = (airlineCode != null && !airlineCode.trim().isEmpty()) ? airlineCode.trim().toUpperCase() : "6E";
        String cls = (travelClass != null && !travelClass.trim().isEmpty()) ? travelClass.trim() : "Economy";

        layout.setAircraftModel(model);
        layout.setAirlineCode(carrierCode);
        layout.setAirlineName(airlineName != null ? airlineName : "SkyTech Airline");
        layout.setTravelClass(cls);

        boolean isBusinessClass = cls.equalsIgnoreCase("Business") || cls.equalsIgnoreCase("First");
        String modelLower = model.toLowerCase(Locale.ENGLISH);
        boolean isWidebody = modelLower.contains("777") || modelLower.contains("787") || modelLower.contains("a350") || modelLower.contains("dreamliner");
        boolean isRegional = modelLower.contains("atr") || modelLower.contains("q400") || modelLower.contains("bombardier") || modelLower.contains("embraer");

        int totalRows;
        List<String> leftCols = new ArrayList<>();
        List<String> centerCols = new ArrayList<>();
        List<String> rightCols = new ArrayList<>();
        List<Integer> exitRows = new ArrayList<>();
        int wingStart;
        int wingEnd;

        if (isBusinessClass) {
            // Dedicated Business Class cabin: 2-2 layout (A, C | D, F)
            totalRows = 8;
            leftCols.addAll(Arrays.asList("A", "C"));
            rightCols.addAll(Arrays.asList("D", "F"));
            exitRows.add(5);
            wingStart = 4;
            wingEnd = 8;
            layout.setTwinAisle(false);
            layout.setSeatsPerRow(4);
        } else if (isWidebody) {
            // Twin-Aisle Widebody layout: 3-3-3 (A, B, C | D, E, F | G, H, J)
            totalRows = 28;
            leftCols.addAll(Arrays.asList("A", "B", "C"));
            centerCols.addAll(Arrays.asList("D", "E", "F"));
            rightCols.addAll(Arrays.asList("G", "H", "J"));
            exitRows.addAll(Arrays.asList(11, 22));
            wingStart = 10;
            wingEnd = 20;
            layout.setTwinAisle(true);
            layout.setSeatsPerRow(9);
        } else if (isRegional) {
            // Regional turboprop / jet: 2-2 layout (A, C | D, F)
            totalRows = 18;
            leftCols.addAll(Arrays.asList("A", "C"));
            rightCols.addAll(Arrays.asList("D", "F"));
            exitRows.add(9);
            wingStart = 7;
            wingEnd = 13;
            layout.setTwinAisle(false);
            layout.setSeatsPerRow(4);
        } else {
            // Standard Narrowbody: Airbus A320 / Boeing 737 / A321 (3-3 layout: A, B, C | D, E, F)
            totalRows = modelLower.contains("a321") ? 30 : 26;
            leftCols.addAll(Arrays.asList("A", "B", "C"));
            rightCols.addAll(Arrays.asList("D", "E", "F"));
            exitRows.addAll(Arrays.asList(12, 13));
            wingStart = 10;
            wingEnd = 18;
            layout.setTwinAisle(false);
            layout.setSeatsPerRow(6);
        }

        layout.setTotalRows(totalRows);
        layout.setLeftColumns(leftCols);
        layout.setCenterColumns(centerCols);
        layout.setRightColumns(rightCols);
        layout.setExitRows(exitRows);
        layout.setWingStartRow(wingStart);
        layout.setWingEndRow(wingEnd);

        // Fetch seat inventory from DAO
        List<Seat> rawSeats = seatDao.getSeatsForSchedule(scheduleId, carrierCode);
        Map<String, Seat> seatMap = new HashMap<>();
        for (Seat s : rawSeats) {
            if (s.getSeatNumber() != null) {
                seatMap.put(s.getSeatNumber().toUpperCase(), s);
            }
        }

        int totalSeats = 0;
        int availableSeats = 0;
        List<CabinRow> cabinRows = new ArrayList<>();

        for (int row = 1; row <= totalRows; row++) {
            boolean isExit = exitRows.contains(row);
            boolean isWing = (row >= wingStart && row <= wingEnd);
            CabinRow cRow = new CabinRow(row, isExit, isWing);

            // Set section title at key boundaries
            if (row == 1) {
                cRow.setSectionTitle(isBusinessClass ? "Business Class Cabin" : "Front Cabin (Rows 1–3)");
            } else if (!isBusinessClass && row == 4) {
                cRow.setSectionTitle("Preferred Forward Rows (Rows 4–8)");
            } else if (!isBusinessClass && row == 9) {
                cRow.setSectionTitle("Main Cabin (Rows 9–" + totalRows + ")");
            } else if (!isBusinessClass && row == 12 && exitRows.contains(12)) {
                cRow.setSectionTitle("Emergency Exit Rows (Extra Legroom)");
            }

            // Populate Left Seats
            List<Seat> leftList = new ArrayList<>();
            for (String col : leftCols) {
                Seat s = getOrCreateSeat(seatMap, row, col, carrierCode, isExit, isBusinessClass);
                leftList.add(s);
                totalSeats++;
                if (s.isAvailable()) availableSeats++;
            }
            cRow.setLeftSeats(leftList);

            // Populate Center Seats (Widebody)
            if (layout.isTwinAisle()) {
                List<Seat> centerList = new ArrayList<>();
                for (String col : centerCols) {
                    Seat s = getOrCreateSeat(seatMap, row, col, carrierCode, isExit, isBusinessClass);
                    centerList.add(s);
                    totalSeats++;
                    if (s.isAvailable()) availableSeats++;
                }
                cRow.setCenterSeats(centerList);
            }

            // Populate Right Seats
            List<Seat> rightList = new ArrayList<>();
            for (String col : rightCols) {
                Seat s = getOrCreateSeat(seatMap, row, col, carrierCode, isExit, isBusinessClass);
                rightList.add(s);
                totalSeats++;
                if (s.isAvailable()) availableSeats++;
            }
            cRow.setRightSeats(rightList);

            cabinRows.add(cRow);
        }

        layout.setRows(cabinRows);
        layout.setTotalSeatCount(totalSeats);
        layout.setAvailableSeatCount(availableSeats);

        return layout;
    }

    private Seat getOrCreateSeat(Map<String, Seat> seatMap, int row, String col, String carrierCode, boolean isExitRow, boolean isBusinessClass) {
        String seatNum = row + col;
        Seat existing = seatMap.get(seatNum);
        if (existing != null) {
            return existing;
        }

        // Generate dynamic seat with accurate carrier ancillary pricing
        SeatPricingConfig.SeatPricingInfo pricing = SeatPricingConfig.resolveSeatPricing(carrierCode, row, col);
        String status = "AVAILABLE";

        // Realistic baseline occupancy pattern for demo schedules
        if ((row == 1 && "A".equals(col)) || (row == 2 && "B".equals(col)) || (row == 3 && "C".equals(col)) ||
            (row == 5 && "D".equals(col)) || (row == 6 && "E".equals(col)) || (row == 8 && "F".equals(col)) ||
            (row == 12 && "A".equals(col)) || (row == 12 && "B".equals(col)) || (row == 15 && "C".equals(col)) ||
            (row == 18 && "D".equals(col)) || (row == 20 && "E".equals(col))) {
            status = "OCCUPIED";
        } else if ((row == 1 && "F".equals(col)) || (row == 13 && "A".equals(col))) {
            status = "BLOCKED";
        }

        String seatType = isExitRow ? "EXIT_ROW" : (row == 1 ? "EXTRA_LEGROOM" : pricing.getCategory().name());
        BigDecimal fee = pricing.getPrice();
        String label = isExitRow ? "Exit Row Legroom" : pricing.getCategoryLabel();

        return new Seat(
                row * 10 + col.charAt(0),
                seatNum,
                row,
                col,
                seatType,
                fee,
                status,
                label
        );
    }

    /**
     * Smart contiguous seat allocation algorithm:
     * Finds adjacent available seats in the same row and cluster for multiple passengers.
     *
     * @param layout cabin layout
     * @param count number of passengers requiring seats
     * @return list of adjacent seat numbers, or empty list if no contiguous block exists
     */
    public List<String> findAdjacentSeats(CabinLayout layout, int count) {
        if (layout == null || count <= 0) return Collections.emptyList();
        if (count == 1) {
            // Find first available seat
            for (CabinRow r : layout.getRows()) {
                for (Seat s : r.getLeftSeats()) {
                    if (s.isAvailable()) return Collections.singletonList(s.getSeatNumber());
                }
                for (Seat s : r.getRightSeats()) {
                    if (s.isAvailable()) return Collections.singletonList(s.getSeatNumber());
                }
            }
            return Collections.emptyList();
        }

        for (CabinRow r : layout.getRows()) {
            // Check left group
            List<String> match = findConsecutiveAvailable(r.getLeftSeats(), count);
            if (!match.isEmpty()) return match;

            // Check center group (widebody)
            if (r.hasCenterSeats()) {
                match = findConsecutiveAvailable(r.getCenterSeats(), count);
                if (!match.isEmpty()) return match;
            }

            // Check right group
            match = findConsecutiveAvailable(r.getRightSeats(), count);
            if (!match.isEmpty()) return match;
        }

        return Collections.emptyList();
    }

    private List<String> findConsecutiveAvailable(List<Seat> group, int count) {
        if (group == null || group.size() < count) return Collections.emptyList();
        for (int i = 0; i <= group.size() - count; i++) {
            boolean allAvail = true;
            List<String> seats = new ArrayList<>();
            for (int j = 0; j < count; j++) {
                Seat s = group.get(i + j);
                if (!s.isAvailable()) {
                    allAvail = false;
                    break;
                }
                seats.add(s.getSeatNumber());
            }
            if (allAvail) {
                return seats;
            }
        }
        return Collections.emptyList();
    }

    /**
     * Server-side validation of a selected seat against the cabin layout.
     */
    public boolean validateSeat(int scheduleId, String seatNumber) {
        return seatDao.isSeatAvailable(scheduleId, seatNumber);
    }
}

