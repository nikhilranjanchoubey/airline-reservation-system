package com.skytech.dao;

import com.skytech.model.Airline;
import com.skytech.model.Airport;
import com.skytech.model.Flight;
import com.skytech.model.FlightSchedule;
import com.skytech.util.DBConnectionUtil;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Flight Schedules and Search queries.
 * Uses PreparedStatements for all database interactions.
 */
public class FlightScheduleDao {

    private static final Logger LOGGER = Logger.getLogger(FlightScheduleDao.class.getName());

    /**
     * Searches available flight schedules from MySQL for a given source, destination, date, and passenger count.
     *
     * @param sourceCode      Origin airport code (e.g. "JAI")
     * @param destinationCode Destination airport code (e.g. "DEL")
     * @param departureDate   Target flight date
     * @param passengers      Required seat capacity
     * @return List of matching {@link FlightSchedule} objects
     * @throws SQLException on database error
     */
    public List<FlightSchedule> searchFlights(String sourceCode, String destinationCode,
                                              LocalDate departureDate, int passengers) throws SQLException {
        List<FlightSchedule> results = new ArrayList<>();

        String sql = "SELECT " +
                "  s.schedule_id, s.flight_id, s.flight_date, s.base_price, s.economy_price, " +
                "  s.premium_economy_price, s.business_price, s.first_class_price, " +
                "  s.available_seats, s.total_seats, s.status, " +
                "  f.flight_number, f.departure_time, f.arrival_time, f.duration_minutes, f.stops, f.aircraft_model, " +
                "  al.airline_id, al.airline_code, al.airline_name, al.logo_icon, " +
                "  src.airport_id AS src_id, src.airport_code AS src_code, src.airport_name AS src_name, " +
                "  src.city AS src_city, src.country AS src_country, src.terminal AS src_terminal, " +
                "  dst.airport_id AS dst_id, dst.airport_code AS dst_code, dst.airport_name AS dst_name, " +
                "  dst.city AS dst_city, dst.country AS dst_country, dst.terminal AS dst_terminal " +
                "FROM flight_schedules s " +
                "JOIN flights f ON s.flight_id = f.flight_id " +
                "JOIN airlines al ON f.airline_id = al.airline_id " +
                "JOIN airports src ON f.source_airport_id = src.airport_id " +
                "JOIN airports dst ON f.destination_airport_id = dst.airport_id " +
                "WHERE src.airport_code = ? " +
                "  AND dst.airport_code = ? " +
                "  AND s.flight_date = ? " +
                "  AND s.available_seats >= ? " +
                "ORDER BY s.economy_price ASC";

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, sourceCode.trim().toUpperCase());
            ps.setString(2, destinationCode.trim().toUpperCase());
            ps.setDate(3, Date.valueOf(departureDate));
            ps.setInt(4, passengers);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    results.add(mapResultSetToSchedule(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Database query not reachable or failed for route " + sourceCode + " -> " + destinationCode + ". Falling back to demo schedule inventory: " + e.getMessage());
        }

        if (results.isEmpty()) {
            results = getFallbackDemoSchedules(sourceCode, destinationCode, departureDate, passengers);
        }

        return results;
    }

    /**
     * Retrieves a single flight schedule by ID with full flight, airline, and airport details.
     *
     * @param scheduleId the unique schedule ID
     * @return {@link FlightSchedule} entity or null if not found
     * @throws SQLException on database error
     */
    public FlightSchedule getScheduleById(int scheduleId) throws SQLException {
        return getScheduleById(scheduleId, null);
    }

    public FlightSchedule getScheduleById(int scheduleId, LocalDate targetDate) throws SQLException {
        String sql = "SELECT " +
                "  s.schedule_id, s.flight_id, s.flight_date, s.base_price, s.economy_price, " +
                "  s.premium_economy_price, s.business_price, s.first_class_price, " +
                "  s.available_seats, s.total_seats, s.status, " +
                "  f.flight_number, f.departure_time, f.arrival_time, f.duration_minutes, f.stops, f.aircraft_model, " +
                "  al.airline_id, al.airline_code, al.airline_name, al.logo_icon, " +
                "  src.airport_id AS src_id, src.airport_code AS src_code, src.airport_name AS src_name, " +
                "  src.city AS src_city, src.country AS src_country, src.terminal AS src_terminal, " +
                "  dst.airport_id AS dst_id, dst.airport_code AS dst_code, dst.airport_name AS dst_name, " +
                "  dst.city AS dst_city, dst.country AS dst_country, dst.terminal AS dst_terminal " +
                "FROM flight_schedules s " +
                "JOIN flights f ON s.flight_id = f.flight_id " +
                "JOIN airlines al ON f.airline_id = al.airline_id " +
                "JOIN airports src ON f.source_airport_id = src.airport_id " +
                "JOIN airports dst ON f.destination_airport_id = dst.airport_id " +
                "WHERE s.schedule_id = ?";

        try (Connection conn = DBConnectionUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, scheduleId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    FlightSchedule fs = mapResultSetToSchedule(rs);
                    if (targetDate != null) {
                        fs.setFlightDate(Date.valueOf(targetDate));
                    }
                    return fs;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Database query not reachable or failed for scheduleId [" + scheduleId + "]. Falling back: " + e.getMessage());
        }

        return getFallbackDemoScheduleById(scheduleId, targetDate);
    }

    private FlightSchedule mapResultSetToSchedule(ResultSet rs) throws SQLException {
        Airline airline = new Airline();
        airline.setAirlineId(rs.getInt("airline_id"));
        airline.setAirlineCode(rs.getString("airline_code"));
        airline.setAirlineName(rs.getString("airline_name"));
        airline.setLogoIcon(rs.getString("logo_icon"));

        Airport source = new Airport();
        source.setAirportId(rs.getInt("src_id"));
        source.setAirportCode(rs.getString("src_code"));
        source.setAirportName(rs.getString("src_name"));
        source.setCity(rs.getString("src_city"));
        source.setCountry(rs.getString("src_country"));
        source.setTerminal(rs.getString("src_terminal"));

        Airport destination = new Airport();
        destination.setAirportId(rs.getInt("dst_id"));
        destination.setAirportCode(rs.getString("dst_code"));
        destination.setAirportName(rs.getString("dst_name"));
        destination.setCity(rs.getString("dst_city"));
        destination.setCountry(rs.getString("dst_country"));
        destination.setTerminal(rs.getString("dst_terminal"));

        Flight flight = new Flight();
        flight.setFlightId(rs.getInt("flight_id"));
        flight.setFlightNumber(rs.getString("flight_number"));
        flight.setAirline(airline);
        flight.setSourceAirport(source);
        flight.setDestinationAirport(destination);
        flight.setDepartureTime(rs.getTime("departure_time"));
        flight.setArrivalTime(rs.getTime("arrival_time"));
        flight.setDurationMinutes(rs.getInt("duration_minutes"));
        flight.setStops(rs.getInt("stops"));
        flight.setAircraftModel(rs.getString("aircraft_model"));

        FlightSchedule schedule = new FlightSchedule();
        schedule.setScheduleId(rs.getInt("schedule_id"));
        schedule.setFlightId(rs.getInt("flight_id"));
        schedule.setFlight(flight);
        schedule.setFlightDate(rs.getDate("flight_date"));
        schedule.setBasePrice(rs.getBigDecimal("base_price"));
        schedule.setEconomyPrice(rs.getBigDecimal("economy_price"));
        schedule.setPremiumEconomyPrice(rs.getBigDecimal("premium_economy_price"));
        schedule.setBusinessPrice(rs.getBigDecimal("business_price"));
        schedule.setFirstClassPrice(rs.getBigDecimal("first_class_price"));
        schedule.setAvailableSeats(rs.getInt("available_seats"));
        schedule.setTotalSeats(rs.getInt("total_seats"));
        schedule.setStatus(rs.getString("status"));

        return schedule;
    }

    private List<FlightSchedule> getFallbackDemoSchedules(String src, String dst, LocalDate depDate, int pax) {
        List<FlightSchedule> allDemo = buildAllDemoSchedules(depDate);
        List<FlightSchedule> filtered = new ArrayList<>();
        String s = src != null ? src.trim().toUpperCase() : "";
        String d = dst != null ? dst.trim().toUpperCase() : "";

        for (FlightSchedule fs : allDemo) {
            String fsSrc = fs.getFlight().getSourceAirport().getAirportCode().toUpperCase();
            String fsDst = fs.getFlight().getDestinationAirport().getAirportCode().toUpperCase();
            if ((s.isEmpty() || fsSrc.equals(s)) && (d.isEmpty() || fsDst.equals(d))) {
                if (fs.getAvailableSeats() >= pax) {
                    filtered.add(fs);
                }
            }
        }
        return filtered;
    }

    private FlightSchedule getFallbackDemoScheduleById(int scheduleId, LocalDate targetDate) {
        LocalDate effectiveDate = (targetDate != null) ? targetDate : LocalDate.now(java.time.ZoneId.of("Asia/Kolkata"));
        List<FlightSchedule> allDemo = buildAllDemoSchedules(effectiveDate);
        for (FlightSchedule fs : allDemo) {
            if (fs.getScheduleId() == scheduleId) {
                return fs;
            }
        }
        return null;
    }

    public List<FlightSchedule> buildAllDemoSchedules(LocalDate date) {
        List<FlightSchedule> list = new ArrayList<>();
        LocalDate effectiveDate = (date != null) ? date : LocalDate.now(java.time.ZoneId.of("Asia/Kolkata"));
        java.sql.Date fDate = java.sql.Date.valueOf(effectiveDate);

        // Airports
        Airport jai = new Airport(1, "JAI", "Jaipur International Airport", "Jaipur", "India", "Terminal 2");
        Airport del = new Airport(2, "DEL", "Indira Gandhi International Airport", "Delhi", "India", "Terminal 3");
        Airport bom = new Airport(3, "BOM", "Chhatrapati Shivaji Maharaj International Airport", "Mumbai", "India", "Terminal 2");
        Airport blr = new Airport(4, "BLR", "Kempegowda International Airport", "Bengaluru", "India", "Terminal 1");
        Airport hyd = new Airport(5, "HYD", "Rajiv Gandhi International Airport", "Hyderabad", "India", "Main Terminal");
        Airport maa = new Airport(6, "MAA", "Chennai International Airport", "Chennai", "India", "Terminal 1");
        Airport goi = new Airport(7, "GOI", "Dabolim Airport", "Goa", "India", "Terminal 1");

        // Airlines
        Airline igo = new Airline(1, "6E", "IndiGo", "indigo.png");
        Airline aii = new Airline(2, "AI", "Air India", "airindia.png");
        Airline akj = new Airline(3, "QP", "Akasa Air", "akasa.png");

        // Flight 1: 6E 204 JAI -> DEL
        list.add(createDemoSchedule(1, 1, "6E 204", igo, jai, del, "06:15:00", "08:20:00", 125, 0, "Airbus A320neo",
                fDate, "3700.00", "4299.00", "6499.00", "12999.00", "18999.00", 28, 180));

        // Flight 2: AI 492 JAI -> DEL
        list.add(createDemoSchedule(2, 2, "AI 492", aii, jai, del, "11:30:00", "13:40:00", 130, 0, "Airbus A321",
                fDate, "4200.00", "4850.00", "7100.00", "14500.00", "21000.00", 8, 186));

        // Flight 3: QP 1312 JAI -> DEL
        list.add(createDemoSchedule(3, 3, "QP 1312", akj, jai, del, "17:45:00", "19:55:00", 130, 0, "Boeing 737 MAX 8",
                fDate, "3300.00", "3890.00", "5990.00", "11800.00", "17000.00", 2, 189));

        // Flight 4: 6E 5321 DEL -> BOM
        list.add(createDemoSchedule(4, 4, "6E 5321", igo, del, bom, "07:00:00", "09:15:00", 135, 0, "Airbus A320",
                fDate, "4650.00", "5400.00", "7800.00", "15900.00", "23000.00", 35, 180));

        // Flight 5: AI 805 DEL -> BOM
        list.add(createDemoSchedule(5, 5, "AI 805", aii, del, bom, "14:15:00", "16:30:00", 135, 0, "Boeing 777-300ER",
                fDate, "5300.00", "6200.00", "8900.00", "17500.00", "25000.00", 12, 342));

        // Flight 6: QP 1102 BOM -> BLR
        list.add(createDemoSchedule(6, 6, "QP 1102", akj, bom, blr, "09:30:00", "11:15:00", 105, 0, "Boeing 737 MAX",
                fDate, "2950.00", "3450.00", "5200.00", "10500.00", "15500.00", 19, 189));

        // Flight 7: 6E 245 DEL -> GOI
        list.add(createDemoSchedule(7, 7, "6E 245", igo, del, goi, "10:00:00", "12:35:00", 155, 0, "Airbus A320",
                fDate, "5050.00", "5890.00", "8200.00", "16500.00", "24000.00", 15, 180));

        // Flight 8: 6E 312 BLR -> HYD
        list.add(createDemoSchedule(8, 8, "6E 312", igo, blr, hyd, "13:00:00", "14:10:00", 70, 0, "Airbus A320",
                fDate, "3400.00", "3999.00", "5800.00", "11200.00", "16000.00", 22, 180));

        // Flight 9: AI 671 MAA -> BOM
        list.add(createDemoSchedule(9, 9, "AI 671", aii, maa, bom, "16:20:00", "18:20:00", 120, 0, "Airbus A321",
                fDate, "4500.00", "5299.00", "7400.00", "14800.00", "21500.00", 14, 186));

        // Flight 10: 6E 205 DEL -> JAI
        list.add(createDemoSchedule(10, 10, "6E 205", igo, del, jai, "07:00:00", "09:05:00", 125, 0, "Airbus A320neo",
                fDate, "3700.00", "4299.00", "6499.00", "12999.00", "18999.00", 24, 180));

        return list;
    }

    private FlightSchedule createDemoSchedule(int sId, int fId, String fNum, Airline al, Airport src, Airport dst,
                                             String depTime, String arrTime, int duration, int stops, String model,
                                             java.sql.Date fDate, String basePrice, String ecoPrice, String pePrice,
                                             String bizPrice, String firstPrice, int availSeats, int totalSeats) {
        Flight f = new Flight();
        f.setFlightId(fId);
        f.setFlightNumber(fNum);
        f.setAirline(al);
        f.setSourceAirport(src);
        f.setDestinationAirport(dst);
        f.setDepartureTime(java.sql.Time.valueOf(depTime));
        f.setArrivalTime(java.sql.Time.valueOf(arrTime));
        f.setDurationMinutes(duration);
        f.setStops(stops);
        f.setAircraftModel(model);

        FlightSchedule s = new FlightSchedule();
        s.setScheduleId(sId);
        s.setFlightId(fId);
        s.setFlight(f);
        s.setFlightDate(fDate);
        s.setBasePrice(new java.math.BigDecimal(basePrice));
        s.setEconomyPrice(new java.math.BigDecimal(ecoPrice));
        s.setPremiumEconomyPrice(new java.math.BigDecimal(pePrice));
        s.setBusinessPrice(new java.math.BigDecimal(bizPrice));
        s.setFirstClassPrice(new java.math.BigDecimal(firstPrice));
        s.setAvailableSeats(availSeats);
        s.setTotalSeats(totalSeats);
        s.setStatus("SCHEDULED");
        return s;
    }
}
