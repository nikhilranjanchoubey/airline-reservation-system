# SKYTECH AIRLINES — Official Flight Reservation System

[![Java](https://img.shields.io/badge/Java-21%20LTS-orange.svg)](https://www.oracle.com/java/)
[![Tomcat](https://img.shields.io/badge/Server-Apache%20Tomcat%209-blue.svg)](https://tomcat.apache.org/)
[![Servlet](https://img.shields.io/badge/Servlet%20API-javax.servlet%204.0.1-green.svg)](https://javaee.github.io/)
[![MySQL](https://img.shields.io/badge/Database-MySQL%208.4%20LTS-informational.svg)](https://www.mysql.com/)
[![Razorpay](https://img.shields.io/badge/Payment-Razorpay%20Standard%20Checkout-blueviolet.svg)](https://razorpay.com/)

An enterprise-grade airline reservation and passenger management system built using **Java**, **Apache Tomcat 9**, **Java Servlets (`javax.servlet`)**, **JSP**, **Bootstrap 5**, **JDBC**, **MySQL**, and **Razorpay Standard Checkout**. Includes full lifecycle booking and instant cancellation with automatic seat release and refund initiation.

Designed to run seamlessly inside **Eclipse IDE on macOS** or via the included embedded launcher.

---

## 1. Project Overview & Multi-Module Architecture

SKYTECH Airlines is structured into five integrated team modules:
1. **Module 1**: Authentication & User Management
2. **Module 2**: Flight Search & Availability
3. **Module 3 (This Module)**: **Booking & Passenger Management**
4. **Module 4**: Ticketing & Cancellation
5. **Module 5**: Admin Dashboard & Flight Management

### Booking & Cancellation Workflow
The application implements an authoritative booking progress pipeline and self-service cancellation:

```
[1. Flight Selected] ──> [2. Passenger Details] ──> [3. Seat Selection] ──> [4. Review Booking] ──> [5. Payment] ──> [6. Confirmation] ──> [7. Self-Service Cancellation & Refund]
```

- **Flight Selected**: Retrieves flight schedules, aircraft type, and base fare through the `FlightProvider` contract.
- **Passenger Details**: Multi-passenger demographic intake (Adult, Child, Infant) with rigorous server-side validation.
- **Seat Selection**: Interactive 180-seat aircraft cabin map (Airbus A320neo, 3-3 configuration) featuring live status, class categorization (Business, Premium Economy, Economy), and surcharge computation.
- **Review Booking**: Authoritative server-side fare calculation (taxes, surcharges, exact decimal precision). Never trusts browser-submitted prices.
- **Payment**: Official Razorpay Standard Checkout modal with a 15-minute temporary seat hold countdown and cryptographic HMAC-SHA256 signature verification.
- **Confirmation**: Atomically confirmed booking, guaranteed unique 6-character PNR, electronic ticket with print view, and instant update to user's booking history.
- **Cancellation & Refund**: One-click flight cancellation with confirmation modal from either the e-ticket or My Bookings dashboard; automatically releases reserved seats back to inventory and marks payment status as `REFUNDED`.

---

## 2. Environment Prerequisites (macOS)

Ensure your macOS development environment has the following installed:

| Tool | Version | Installation via Homebrew / Official |
| :--- | :--- | :--- |
| **Operating System** | macOS Monterey, Ventura, Sonoma, Sequoia | Apple Silicon (M1/M2/M3/M4) or Intel |
| **JDK** | Java 21 LTS | `brew install openjdk@21` |
| **IDE** | Eclipse IDE for Enterprise Java & Web | [Eclipse Downloads](https://www.eclipse.org/downloads/packages/) |
| **Servlet Container**| Apache Tomcat 9.0.x | `brew install tomcat@9` |
| **Database** | MySQL Community Server 8.4 LTS or 8.0+ | `brew install mysql` |
| **Build Tool** | Apache Maven 3.9+ | `brew install maven` |

---

## 3. Step-by-Step Setup Instructions on macOS

### Step 3.1: Install & Start MySQL on macOS
```bash
# Install MySQL via Homebrew
brew install mysql

# Start the MySQL background service
brew services start mysql

# Verify MySQL is running
mysql -u root -p
```

### Step 3.2: Create Database & Execute Schema
Execute the provided SQL script to create the database and seed records:
```bash
cd SKYTECH-Airlines
mysql -u root < database/schema.sql
```
This script creates:
- `skytech_airlines_db`
- Module 3 Owned Tables: `bookings`, `passengers`, `booking_passengers`, `seat_allocations`, `payments`
- Development Mock Tables: `shared_users_dev_mock`, `shared_flights_dev_mock`
- Seed Flights (SK-701 Delhi-Mumbai, SK-304 Bengaluru-Delhi, SK-902 Mumbai-Dubai)

### Step 3.3: Configure Database Connection
Edit `src/main/resources/application.properties` (or set environment variables):
```properties
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/skytech_airlines_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8
db.user=root
db.password=your_mysql_password
```
Alternatively, set environment variables:
```bash
export SKYTECH_DB_URL="jdbc:mysql://localhost:3306/skytech_airlines_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8"
export SKYTECH_DB_USER="root"
export SKYTECH_DB_PASSWORD="your_mysql_password"
```

### Step 3.4: Configure Razorpay Test Mode Credentials
Register for a free Razorpay account at [dashboard.razorpay.com](https://dashboard.razorpay.com/) and navigate to **Settings -> API Keys**.
Copy your Test Key ID and Secret into `application.properties`:
```properties
razorpay.key.id=rzp_test_YourTestKeyIdHere
razorpay.key.secret=YourRazorpaySecretKeyHere
razorpay.webhook.secret=YourWebhookSecretHere
razorpay.currency=INR
```
*Note: The application includes an offline simulation mode so tests and evaluation can proceed smoothly even without internet connectivity.*

---

## 4. How to Run in Eclipse IDE

You can run the project in Eclipse in two ways:

### Option A: Eclipse One-Click Direct Launcher (Fastest, No Tomcat Setup Needed)
1. Open **Eclipse IDE**.
2. Select **File -> Import... -> Existing Maven Projects**.
3. Browse to the folder `SKYTECH-Airlines` and click **Finish**.
4. In Project Explorer, open:
   `src/main/java -> com.skytech.airlines.booking -> RunInEclipse.java`
5. Right-click `RunInEclipse.java` -> **Run As -> Java Application**.
6. Eclipse starts the embedded HTTP server and automatically opens your browser at:
   **`http://localhost:8080/`**
7. To stop the server, click the red **Terminate []** icon in the Eclipse Console toolbar.

### Option B: Deploy to Apache Tomcat 9 in Eclipse
1. In Eclipse, open the **Servers** tab (`Window -> Show View -> Servers`).
2. Click **No servers are available. Click this link to create a new server...**.
3. Expand **Apache -> Tomcat v9.0 Server**, click **Next**.
4. Set the **Tomcat installation directory** to your Tomcat 9 path (e.g. `/opt/homebrew/opt/tomcat@9/libexec`).
5. Set JRE to **Java 21**. Click **Next**.
6. Select `skytech-booking-module`, click **Add >**, and click **Finish**.
7. Right-click the server -> **Start**.
8. Open your browser at:
   **`http://localhost:8080/skytech-booking/`**

---

## 5. How to Build & Test via Command Line

### Compile Main and Test Classes:
```bash
javac -cp "lib/*" -d target/classes $(find src/main/java -name "*.java")
javac -cp "target/classes:target/test-classes:lib/*" -d target/test-classes $(find src/test/java -name "*.java")
```

### Run Comprehensive 81-Test Self-Test Verification Suite:
```bash
java -cp "target/classes:lib/*" com.skytech.airlines.booking.service.Module3SelfTest
```
Expected output:
```
===============================================================================
 SKYTECH AIRLINES - MODULE 3: BOOKING & PASSENGER MANAGEMENT SELF-TEST SUITE
===============================================================================
...
-------------------------------------------------------------------------------
 TEST RESULTS: 81 / 81 TESTS PASSED SUCCESSFULLY (100%)
===============================================================================
```

### Run JUnit 5 Unit Tests:
```bash
java -cp "target/classes:target/test-classes:lib/*" com.skytech.airlines.booking.AllUnitTestsRunner
```
Expected output:
```
===============================================================================
  JUNIT TEST SUMMARY: 13 Passed, 0 Failed
===============================================================================
```

---

## 6. Project Directory Structure

```
SKYTECH-Airlines/
├── pom.xml                                      # Maven WAR POM with Java 21 & Tomcat 9 dependencies
├── README.md                                    # Comprehensive setup & operational guide
├── ECLIPSE_RUN_GUIDE.md                         # Focused guide for Eclipse on macOS
├── .gitignore                                   # Standard git ignore for Java/Eclipse/Mac
├── .env.example                                 # Safe template for credentials
├── SKYTECH-Airlines-Run-In-Eclipse.launch       # Eclipse launcher for standalone app
├── SKYTECH-Airlines-Self-Test.launch           # Eclipse launcher for test suite
├── database/
│   └── schema.sql                               # Complete MySQL DDL & DML seed script
├── docs/
│   ├── architecture.md                          # MVC architecture & state machine documentation
│   ├── integration-contracts.md                 # Team boundary interfaces for Modules 1, 2, 4, 5
│   └── database-notes.md                        # ER diagrams, indexes, and locking strategy
├── lib/                                         # Bundled jar dependencies for offline Eclipse use
├── src/main/resources/
│   ├── application.properties                   # Main configuration
│   └── db.properties                            # Database connection properties
├── src/main/java/com/skytech/airlines/booking/
│   ├── RunInEclipse.java                        # Main application entry point for Eclipse
│   ├── config/                                  # AppConfig, DatabaseConfig
│   ├── model/                                   # Booking, Passenger, Seat, Payment, etc.
│   ├── exception/                               # Custom business exceptions
│   ├── util/                                    # DBConnection, ValidationUtil, FareCalculator, etc.
│   ├── dao/                                     # BookingDAO, PassengerDAO, SeatAllocationDAO, PaymentDAO
│   ├── service/                                 # BookingService, PaymentService, RazorpayService, etc.
│   ├── integration/                             # AdaptiveAuthenticationProvider, DatabaseFlightProvider, etc.
│   ├── controller/                              # Servlets (Passenger, Seat, Review, Payment, Confirmation, etc.)
│   └── server/                                  # StandaloneAppServer (Embedded runner)
├── src/main/webapp/
│   ├── index.jsp                                # Home & Flight Selector
│   ├── WEB-INF/web.xml                          # Tomcat 9 Servlet & Session mappings
│   ├── includes/                                # header.jsp, footer.jsp, stepper.jsp
│   ├── booking/                                 # 6 connected workflow JSPs
│   │   ├── passenger-details.jsp
│   │   ├── seat-selection.jsp
│   │   ├── booking-review.jsp
│   │   ├── payment.jsp
│   │   ├── booking-confirmation.jsp
│   │   └── my-bookings.jsp
│   └── assets/                                  # booking.css, passenger-form.js, seat-selection.js
└── src/test/java/                               # JUnit 5 test classes
```

---

## 7. Security & Business Rules Implemented

1. **Exact Currency Arithmetic**: All money values use exact `BigDecimal` representations (`DECIMAL(10,2)` in SQL). Conversion to Razorpay minor units (paise) uses exact arithmetic without floating-point inaccuracies.
2. **Cryptographic Payment Verification**: HMAC-SHA256 signature calculated on `order_id|payment_id` against the secret key. Tampered, mismatched, or altered payloads are strictly rejected.
3. **15-Minute Seat Hold Policy**: When a pending booking is created, seats are placed in `HELD` status for 900 seconds. If checkout exceeds 15 minutes, the hold expires, preventing stale seat locks.
4. **IDOR & User-Scoped Ownership**: Authenticated users can only view or manage their own bookings (`WHERE user_id = ?`). URL tampering or PNR parameter guessing is blocked.
5. **ACID Duplicate Seat Guard**: A database unique constraint on `(flight_id, seat_number, allocation_status)` prevents race conditions where two users attempt to lock the same seat simultaneously.
6. **XSS & Injection Protection**: JDBC `PreparedStatement` parameterized queries are used for 100% of database operations. Input sanitization prevents script injection in passenger names.

---

## 8. Integration Contracts with Team Modules

Module 3 is fully isolated and connects via clean Java interfaces:

| Module | Integration Interface / Endpoint | Purpose |
| :--- | :--- | :--- |
| **Module 1 (Auth)** | `AuthenticationProvider` | Extracts authenticated user ID, name, email from session |
| **Module 2 (Flights)** | `FlightProvider` | Queries flight schedules, aircraft model, and seat availability |
| **Module 4 (Ticketing)** | `IBookingExportService` & `/api/booking/details?pnr=...` | Exports confirmed bookings for e-ticket issuance and handles cancellations |
| **Module 5 (Admin)** | `BookingDAO.findAllBookings()` | Provides passenger manifest and flight occupancy data for admin reports |

---

## 9. Troubleshooting Common Errors

### Error: `java.lang.ClassNotFoundException: com.mysql.cj.jdbc.Driver`
- **Cause**: MySQL Connector jar not in classpath.
- **Fix**: In Eclipse, ensure `lib/mysql-connector-j-8.3.0.jar` is in your Build Path (Right-click project -> Build Path -> Add Libraries... or Maven Update).

### Error: `Port 8080 already in use`
- **Cause**: Another process or Tomcat instance is occupying port 8080.
- **Fix**: Run `lsof -i :8080` and `kill -9 <PID>`, or change `APP_PORT=8085` in `.env` / `application.properties`.

### Error: `Seat hold expired` during payment test
- **Cause**: The 15-minute booking timer ran out.
- **Fix**: Re-select the flight from the home page to start a fresh 15-minute reservation window.

---

## 10. PBL Demonstration Checklist

- [x] Flight schedule selection from home page
- [x] Multi-passenger entry with age category verification (Adult, Child, Infant)
- [x] Interactive aircraft seat map (180 seats, Business, Legroom, Economy)
- [x] Authoritative server-side fare recalculation
- [x] Pending booking creation with 15-minute seat hold
- [x] Razorpay Standard Checkout invocation with test mode credentials
- [x] Server-side HMAC-SHA256 signature verification
- [x] Unique 6-character PNR generation with collision retry
- [x] Electronic ticket confirmation view with print support
- [x] "My Bookings" user dashboard with IDOR security
- [x] REST JSON export for Module 4 (`/api/booking/details?pnr=SK8M2P`)
- [x] 81 / 81 Self-Test suite passing (100%)
