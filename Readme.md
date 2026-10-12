# ✈️ SkyTech - Airline Reservation & Passenger Management System

[![Java 21](https://img.shields.io/badge/Java-21%20LTS-007396?logo=openjdk&logoColor=white)](https://www.oracle.com/java/)
[![Jakarta EE 10](https://img.shields.io/badge/Jakarta%20EE-10%20(Servlet%206.0)-E03C11?logo=eclipseide&logoColor=white)](https://jakarta.ee/)
[![MySQL](https://img.shields.io/badge/MySQL-8.3%2B-4479A1?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Tomcat](https://img.shields.io/badge/Apache%20Tomcat-10.1%2B-F8DC75?logo=apachetomcat&logoColor=black)](https://tomcat.apache.org/)
[![Bootstrap 5.3](https://img.shields.io/badge/Bootstrap-5.3-7952B3?logo=bootstrap&logoColor=white)](https://getbootstrap.com/)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)]()

---

## 📌 Project Overview & Team Credits

**Project:** SkyTech — Airline Reservation & Passenger Management System  
**Branch:** `integration/skytech` (Unified Integration of Module 1 & Module 2)  
**Mentor:** Er. Ram Babu Buri  
**Department:** Department of Computer Science and Engineering (CSE)  
**Project Period:** 6 July 2026 – 6 October 2026  
**Technology Stack:** Java 21 LTS, Jakarta EE 10 (Servlet 6.0, JSP 3.1, JSTL 3.0), JDBC, MySQL 8.3+, Maven, Apache Tomcat 10.1+, Bootstrap 5.3, HTML5, CSS3, JavaScript.

### Integrated Development Modules

| Module | Scope & Responsibilities | Lead Developer | Package Namespace |
|---|---|---|---|
| **Module 1: Authentication & User Management** | User registration, login, logout, profile management, password hashing (SHA-256 with salt), admin authorization filter, Google Sign-In (GIS). | **Mohammed Sahil** | `com.airline.*` |
| **Module 2: Flight Search & Availability** | Airport search & autocomplete, one-way/round-trip/multi-city search, route filters, sorting, live ReefAPI integration, catalog fallbacks, aircraft seat map selection. | **Nikhil Ranjan Choubey** | `com.skytech.*` |

---

## 🏗️ System Architecture

SkyTech follows a clean, enterprise-grade Model–View–Controller (MVC) architecture. Both modules run seamlessly within a single unified Java web application:

```
+-----------------------------------------------------------------------------------+
|                                 CLIENT TIER                                       |
|  Bootstrap 5.3 UI • Glassmorphism Theme • Autocomplete • Seat Map • Google GIS   |
+-----------------------------------------------------------------------------------+
                                       │ HTTP / HTTPS
                                       ▼
+-----------------------------------------------------------------------------------+
|                        JAKARTA SERVLET 6.0 (TOMCAT 10.1)                          |
|                                                                                   |
|  [Filters]                                                                        |
|    - CharacterEncodingFilter (UTF-8)                                              |
|    - AuthenticationFilter (/profile, /user/*)                                     |
|    - AdminAuthorizationFilter (/admin/*)                                          |
|                                                                                   |
|  [Module 1 Controllers - com.airline.controller]                                  |
|    - LoginServlet (/login)               - LogoutServlet (/logout)                |
|    - RegisterServlet (/register)         - ProfileServlet (/profile)              |
|    - GoogleAuthServlet (/auth/google)    - AdminDashboardServlet (/admin/dashboard)|
|    - AboutServlet (/about)                                                        |
|                                                                                   |
|  [Module 2 Controllers - com.skytech.controller]                                  |
|    - HomeController (/home)              - FlightSearchController (/search-flights)|
|    - FlightResultsController (/flight-results)                                    |
|    - FlightDetailsController (/flight-details)                                    |
|    - SeatSelectionController (/seat-selection)                                    |
|    - AirportSearchApiController (/api/airports)                                   |
|    - FlightStatusController (/flight-status)                                      |
|    - ManageBookingController (/manage-booking)                                    |
|    - TravelInfoController (/travel-information)                                   |
|    - ProjectController (/project)                                                 |
+-----------------------------------------------------------------------------------+
                 │                                                │
                 ▼                                                ▼
+------------------------------------+          +-----------------------------------+
|          SERVICE / DAO LAYER       |          |      EXTERNAL PROVIDERS           |
|  - UserService, UserDao            |          |  - ReefAPI Client (Live Flights)  |
|  - FlightSearchService, SeatDao    |          |  - Google Identity Token Verifier |
|  - AirportDao, FlightScheduleDao   |          +-----------------------------------+
|  - SearchHistoryDao, AppConfig     |
+------------------------------------+
                 │ JDBC (MySQL Connector/J)
                 ▼
+-----------------------------------------------------------------------------------+
|                         DATABASE TIER: MySQL (skytech_db)                         |
|  users, roles, airports, airlines, flights, flight_schedules, aircraft,           |
|  aircraft_seats, flight_seat_inventory, flight_searches                           |
+-----------------------------------------------------------------------------------+
```

![SkyTech System Architecture](docs/images/skytech-system-architecture.png)

---

## 🗄️ Unified Database Schema (`skytech_db`)

The unified database script is located at [database/schema.sql](database/schema.sql).

![SkyTech Database ER Diagram](docs/images/skytech-database-er.png)

### Key Database Tables

1. **`users`**: User identity, hashed passwords, salts, profile details, Google OAuth ID, and role (`PASSENGER`, `ADMIN`).
2. **`airports`**: IATA airport master data (DEL, BOM, BLR, GOI, HYD, MAA, CCU, JAI, etc.).
3. **`airlines`**: Airline codes, names, fleets (IndiGo, Air India, Vistara, SpiceJet, Akasa Air).
4. **`flights`**: Master flight numbers, source/destination airports, duration, terminal info.
5. **`flight_schedules`**: Real-time schedules, departure/arrival timestamps, pricing by cabin class, dynamic seat availability.
6. **`aircraft`**: Fleet aircraft models (Airbus A320neo, Boeing 737-800).
7. **`aircraft_seats`**: Physical seating layouts (rows, column letters, seat types, extra legroom fees).
8. **`flight_seat_inventory`**: Per-flight dynamic seat reservation states (`AVAILABLE`, `OCCUPIED`, `BLOCKED`).
9. **`flight_searches`**: Search audit log with optional user attribution linking to `users(user_id)`.

---

## 🚀 Key Implemented Features

### Module 1: Authentication & User Management
- **Passenger Registration & Login:** Full server-side validation, password length/complexity checks, email uniqueness enforcement.
- **Cryptographic Security:** Salted SHA-256 password hashing via `PasswordUtil`.
- **Google Sign-In:** Google Identity Services (GIS) integration; backend verification using Google API Client library.
- **Session Management:** Secure cookie sessions with 30-minute inactivity timeouts.
- **Access Control:** `AuthenticationFilter` protects `/profile`; `AdminAuthorizationFilter` ensures only `ADMIN` roles access `/admin/*`.
- **Admin Console:** Passenger metrics, status management, and audit inspection.

### Module 2: Flight Search & Availability
- **Search Engine:** Support for One-Way, Round-Trip, and Multi-City itineraries.
- **Airport Autocomplete:** Fast REST endpoint `/api/airports` providing IATA codes, city names, and airport titles.
- **Airport Swapping & Date Sync:** Quick swap between origin and destination with automatic validation.
- **Flight Filtering & Sorting:** Filter by airline, stops (non-stop vs 1+ stops), departure time window, and cabin class. Sort by lowest price, shortest duration, or earliest departure.
- **Interactive Seat Map:** Aircraft layout visualization for Airbus A320neo / Boeing 737-800, displaying seat categories (`WINDOW`, `AISLE`, `MIDDLE`, `EXTRA_LEGROOM`, `EXIT_ROW`) and seat pricing calculation.
- **Dual Data Strategy:** Live ReefAPI integration for dynamic flight schedules with transparent offline fallback to MySQL database catalog.

---

## 🌐 Application URL Route Map

| URL Route | Method | Description | Access Level |
|---|---|---|---|
| `/` or `/home` | GET | SkyTech Homepage & Flight Search Engine | Public |
| `/search-flights` | GET | Flight search submission and query execution | Public |
| `/flight-results` | GET | Flight search results with filters and sorting | Public |
| `/flight-details` | GET | Flight segment specifications, baggage, and fare rules | Public |
| `/seat-selection` | GET | Interactive aircraft cabin seat map selection | Public |
| `/api/airports` | GET | Airport search autocomplete JSON API | Public |
| `/flight-status` | GET | Real-time flight schedule status tracker | Public |
| `/manage-booking` | GET | Retrieve reservation and passenger itinerary | Public |
| `/travel-information` | GET | Passenger guidelines, baggage, documentation, FAQs | Public |
| `/login` | GET, POST | User authentication & sign in | Public / Guests |
| `/register` | GET, POST | User registration & account creation | Public / Guests |
| `/auth/google` | POST | Google Identity Services OAuth callback | Public / Guests |
| `/logout` | GET, POST | User logout and session invalidation | Authenticated |
| `/profile` | GET, POST | Passenger profile view & edit | Authenticated Passengers |
| `/admin/dashboard` | GET | Administrative console & user metrics | Admin Only |
| `/about` | GET | Project team, developer credits & academic mentor details | Public |
| `/project` | GET | Project architecture documentation & diagrams | Public |

---

## ⚙️ Environment Configuration

SkyTech uses a secure 3-tier configuration hierarchy managed by `AppConfig`:
1. **System Environment Variables**
2. **Project Root `.env` file** (excluded from Git via `.gitignore`)
3. **Classpath properties:** `src/main/resources/db.properties`

### 1. Database & Secrets Setup (`.env`)
Create a `.env` file in the project root based on [.env.example](.env.example):

```properties
# Database Configuration
DB_URL=jdbc:mysql://localhost:3306/skytech_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata&characterEncoding=UTF-8
DB_USERNAME=root
DB_PASSWORD=your_mysql_password
DB_DRIVER=com.mysql.cj.jdbc.Driver

# External Flight Provider (Optional)
REEF_API_KEY=your_reef_api_key_if_available
REEF_API_URL=https://api.reefapi.com

# Google Identity Services Client ID (Optional)
GOOGLE_CLIENT_ID=your_google_oauth_client_id.apps.googleusercontent.com
```

### 2. Database Initialization
Run the unified schema script in MySQL 8.x:
```bash
mysql -u root -p < database/schema.sql
```

Default demonstration accounts seeded:
- **Administrator:** `admin@airline.com` / `Admin@12345`
- **Passenger:** `passenger@airline.com` / `Passenger@12345`

---

## 🛠️ Build and Testing Instructions

### Prerequisites
- **JDK 21** or later (`java -version`)
- **Apache Maven 3.9+** (`mvn -v`)
- **MySQL Server 8.0+**
- **Apache Tomcat 10.1+** (for Jakarta EE 10 / Servlet 6.0 deployment)

### Running Unit Tests
```bash
mvn clean test
```

### Building WAR Artifact
```bash
mvn clean package
```
Generates deployable WAR: `target/airline-reservation-system.war`.

### Deploying to Apache Tomcat 10.1
1. Copy `target/airline-reservation-system.war` to Tomcat's `webapps/` folder:
   - **Linux / macOS:** `cp target/airline-reservation-system.war $CATALINA_HOME/webapps/`
   - **Windows:** `copy target\airline-reservation-system.war %CATALINA_HOME%\webapps\`
2. Start Tomcat (`startup.bat` / `startup.sh`).
3. Access in browser: `http://localhost:8080/airline-reservation-system/`.

---

## 📸 Application Screenshots

| Homepage & Flight Search Engine | Flight Results & Filter Panel |
|:---:|:---:|
| ![Homepage](docs/images/skytech-flight-search-home.png) | ![Flight Results](docs/images/skytech-flight-results.png) |
| *SkyTech Landing Page with Hero and Search Engine* | *Flight Results with Real-time Filters and Pricing* |

---

## 🔒 Security Practices
- **Never commit `.env` or sensitive credentials.** All credentials remain in `.gitignore`.
- **All SQL interactions utilize parameterized `PreparedStatement`** to prevent SQL injection.
- **Password security:** Passwords stored as cryptographically salted SHA-256 hashes.
- **Session Protection:** HttpOnly cookies prevent client-side XSS session theft.

---

## 👥 Academic & Project Team
- **Module 1 (Authentication):** Mohammed Sahil
- **Module 2 (Flight Search):** Nikhil Ranjan Choubey
- **Faculty Mentor:** Er. Ram Babu Buri
- **Department:** Computer Science and Engineering (CSE)
