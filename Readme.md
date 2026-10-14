# ✈️ SkyTech — Airline Reservation System

[![Java 21](https://img.shields.io/badge/Java-21%20LTS-007396?logo=openjdk&logoColor=white)](https://www.oracle.com/java/)
[![Jakarta EE 10](https://img.shields.io/badge/Jakarta%20EE-10%20(Servlet%206.0)-E03C11?logo=eclipseide&logoColor=white)](https://jakarta.ee/)
[![MySQL 8.3](https://img.shields.io/badge/MySQL-8.3%2B-4479A1?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Tomcat 10.1](https://img.shields.io/badge/Apache%20Tomcat-10.1%2B-F8DC75?logo=apachetomcat&logoColor=black)](https://tomcat.apache.org/)
[![Bootstrap 5.3](https://img.shields.io/badge/Bootstrap-5.3-7952B3?logo=bootstrap&logoColor=white)](https://getbootstrap.com/)
[![OpenPDF 2.0.3](https://img.shields.io/badge/OpenPDF-2.0.3-red?logo=adobeacrobatreader&logoColor=white)](https://github.com/LibrePDF/OpenPDF)
[![Build Status](https://img.shields.io/badge/Build-71%20Tests%20Passing-brightgreen.svg)]()

---

## 📌 Academic Context & Project Overview
https://skytech-0l59.onrender.com/


**Institution:** Department of Computer Science and Engineering (CSE)  
**Academic Program:** Bachelor of Technology (B.Tech) in Computer Science & Engineering  
**Academic Context:** 5th Semester — Java Project-Based Learning (PBL)  
**Project Title:** SkyTech — Airline Reservation System  
**Mentor:** Er. Ram Babu Buri  
**Project Duration:** 6 July 2026 – 6 October 2026 (10 Weeks)  
**Primary Integration Branch:** `integration/skytech` (Targeting `main`)  
**Technology Stack:** Java 21 LTS, Jakarta EE 10 (Servlet 6.0, JSP 3.1, JSTL 3.0), JDBC (MySQL Connector/J 8.3), MySQL 8.3+, Apache Maven 3.9+, Apache Tomcat 10.1+, Bootstrap 5.3, OpenPDF 2.0.3, HTML5, CSS3, JavaScript.

SkyTech is an enterprise-grade, aviation-themed Airline Reservation System designed to provide passengers with seamless flight discovery, real-time schedule tracking, interactive seat map selection, secure payment processing, and digital e-ticket generation. Concurrently, it delivers operations personnel and system administrators a consolidated management dashboard with real-time fleet analytics, passenger management, seat inventory, and operational audit logging.

---

## 👥 Project Team Members

| # | Name | Enrollment Number | Email |
|---|---|---|---|
| 1 | Mohammed Sahil | 24E1ARCSM30P095 | [mohammedsahil9549@gmail.com](mailto:mohammedsahil9549@gmail.com) |
| 2 | Mukesh Sah | 24E1ARCSM30P097 | [mukeshsah6395@gmail.com](mailto:mukeshsah6395@gmail.com) |
| 3 | Muskan Raj | 24E1ARCSF40P098 | [muskanraj172024@gmail.com](mailto:muskanraj172024@gmail.com) |
| 4 | Nikhil Ranjan Choubey | 24E1ARCSM40P103 | [ranjannikhil476@gmail.com](mailto:ranjannikhil476@gmail.com) |
| 5 | Prashant Chaudhary | 24E1ARCSM10P115 | [chaudharyprashant590@gmail.com](mailto:chaudharyprashant590@gmail.com) |

---

## 🧩 Module Ownership & Git Branch Mapping

The engineering workload is partitioned into five specialized modules mapped to individual feature branches. All modules undergo rigorous pull-request review and integration on the `integration/skytech` branch prior to deployment on `main`.

| Module | Scope & Core Responsibilities | Lead Engineer | Assigned Feature Branch | Package Namespace |
|---|---|---|---|---|
| **Module 1: Authentication & User Management** | User registration, login, logout, password hashing (salted SHA-256), Google Sign-In (GIS OAuth), session lifecycle, avatar uploads, and role-based route security (`AuthenticationFilter`). | **Mohammed Sahil** | `feature/mohammedsahil-auth` *(mapped to `feature/authentication`)* | `com.airline.controller`<br>`com.airline.service`<br>`com.airline.dao` |
| **Module 2: Flight Search & Availability** | Airport search and autocomplete API (`/api/airports`), one-way/round-trip/multi-city search engine, flight filtering (airlines, stops, cabin class), sorting, live ReefAPI integration with offline catalog fallback, and aircraft seat map selection. | **Nikhil Ranjan Choubey** | `feature/nikhilranjanchoubey-flightsearch` *(mapped to `feature/flight-search`)* | `com.skytech.controller`<br>`com.skytech.service`<br>`com.skytech.api`<br>`com.skytech.dao` |
| **Module 3: Booking & Passenger Management** | Booking lifecycle (`PENDING_PAYMENT` to `CONFIRMED`), unique PNR generation, passenger details capture, dynamic seat allocation, passenger booking history ("My Trips"), and reservation status retrieval. | **Mukesh Sah** | `feature/mukeshsah-booking` *(mapped to `feature/booking`)* | `com.skytech.service.BookingService`<br>`com.skytech.dao.BookingDao`<br>`com.skytech.model.Booking` |
| **Module 4: Payment & Ticketing** | Razorpay payment gateway integration, order creation, signature verification, payment transaction auditing, and high-quality vector PDF E-Ticket generation using OpenPDF with Code128 barcodes. | **Muskan Raj** | `feature/muskanraj-ticketing` *(mapped to `feature/ticketing`)* | `com.skytech.service.PaymentService`<br>`com.skytech.service.TicketService`<br>`com.skytech.controller.TicketController` |
| **Module 5: Admin Dashboard & System Management** | Executive operations dashboard with 8 KPI cards, fleet aircraft and seat capacity management (`/admin/aircraft`), flight schedules CRUD, airport/airline registries, cancellations, revenue analytics, and audit logging. | **Prashant Chaudhary** | `feature/prashantchaudhary-admin` *(mapped to `feature/admin`)* | `com.airline.controller.admin.*`<br>`com.skytech.dao.Admin*Dao`<br>`com.airline.dao.AdminAuditDao` |

---

## 🏗️ System Architecture & Layered Design

SkyTech implements a strict Model-View-Controller (MVC) architecture deployed on Apache Tomcat 10.1 (Jakarta EE 10 / Servlet 6.0 specification).

```
+-----------------------------------------------------------------------------------------+
|                                      CLIENT TIER                                        |
|  Bootstrap 5.3 UI • Glassmorphism Aesthetic • Airport Autocomplete • Seat Selection    |
|  Interactive Flight Filters • Razorpay Modal • Google Identity Services (GIS)           |
+-----------------------------------------------------------------------------------------+
                                             │ HTTP / HTTPS
                                             ▼
+-----------------------------------------------------------------------------------------+
|                              JAKARTA EE 10 SERVLET ENGINE                               |
|                                                                                         |
|  [Security & Encoding Filters]                                                          |
|    - CharacterEncodingFilter (UTF-8 Enforced)                                           |
|    - AuthenticationFilter (/profile, /my-bookings, /user/*)                             |
|    - AdminAuthorizationFilter (/admin/*, Role-Based Clearance)                          |
|                                                                                         |
|  [Module 1: Authentication Controllers]                                                 |
|    - LoginServlet (/login)               - LogoutServlet (/logout)                      |
|    - RegisterServlet (/register)         - ProfileServlet (/profile)                    |
|    - GoogleAuthServlet (/auth/google)    - AvatarServlet (/avatar)                      |
|                                                                                         |
|  [Module 2: Flight Search Controllers]                                                  |
|    - HomeController (/)                  - FlightSearchController (/search-flights)     |
|    - FlightResultsController (/flight-results) - FlightDetailsController (/flight-details)|
|    - SeatSelectionController (/seat-selection) - AirportSearchApiController (/api/airports)|
|                                                                                         |
|  [Modules 3 & 4: Booking, Payment & Ticketing Controllers]                              |
|    - CheckoutController (/checkout)      - BookingConfirmationController (/confirmation)|
|    - MyBookingsController (/my-bookings) - TicketController (/ticket/download, /ticket/view)|
|                                                                                         |
|  [Module 5: Admin Management Controllers]                                               |
|    - AdminDashboardServlet (/admin, /admin/dashboard)                                   |
|    - AdminAircraftServlet (/admin/aircraft) - AdminFlightServlet (/admin/flights)       |
|    - AdminBookingServlet (/admin/bookings) - AdminPassengerServlet (/admin/passengers)  |
|    - AdminPaymentServlet (/admin/payments) - AdminAuditServlet (/admin/audit)           |
+-----------------------------------------------------------------------------------------+
                         │                                         │
                         ▼                                         ▼
+--------------------------------------------+    +---------------------------------------+
|             SERVICE & DAO TIER             |    |         EXTERNAL INTEGRATIONS         |
|  - UserService, UserDao                    |    |  - ReefAPI Client (Live Schedules)    |
|  - FlightSearchService, SeatDao            |    |  - Razorpay Gateway (Payments & Webhook)|
|  - BookingService, BookingDao              |    |  - Google Identity OAuth2 Verifier    |
|  - PaymentService, PaymentDao              |    |  - OpenPDF Engine (Vector Barcodes)   |
|  - TicketService (Aviation Boarding Pass)  |    +---------------------------------------+
|  - AdminDashboardDao, AircraftDao          |
|  - AdminAuditDao, AppConfig                |
+--------------------------------------------+
                         │ JDBC (MySQL Connector/J 8.3)
                         ▼
+-----------------------------------------------------------------------------------------+
|                                    PERSISTENT STORAGE                                   |
|                               MySQL 8.3 Database (skytech_db)                           |
|  users, roles, airports, airlines, flights, flight_schedules, aircraft, aircraft_seats, |
|  flight_seat_inventory, bookings, passengers, payments, tickets, admin_audit_logs       |
+-----------------------------------------------------------------------------------------+
```

---

## 🗄️ Database Schema & Relational Structure

The unified relational schema is defined in [database/schema.sql](database/schema.sql) with supplemental migrations [database/migration_profile_photo.sql](database/migration_profile_photo.sql) and [database/migration_admin_audit.sql](database/migration_admin_audit.sql).

### Key Database Entities

1. **`users`**: Passenger and administrator identities, email, cryptographic `password_hash`, `salt`, `role` (`PASSENGER`, `ADMIN`), `status` (`ACTIVE`, `SUSPENDED`), profile photo paths, and optional `google_id`.
2. **`airports`**: Master IATA records (IATA code, airport name, city, country, terminal layout) indexed for rapid autocomplete queries.
3. **`airlines`**: Carrier codes, names, logo assets, and fleet configurations (IndiGo, Air India, Vistara, SpiceJet, Akasa Air).
4. **`flights`**: Master flight routes, origin airport, destination airport, scheduled departure/arrival times, duration minutes, and stops.
5. **`flight_schedules`**: Date-specific flight operations, dynamic seat availability counters, and cabin pricing across Economy, Premium Economy, and Business classes.
6. **`aircraft` & `aircraft_seats`**: Fleet aircraft models (Airbus A320neo, Boeing 737-800) and physical seat grid mappings (row numbers, seat letters, class, extra legroom designations).
7. **`flight_seat_inventory`**: Per-flight dynamic seat reservation states (`AVAILABLE`, `OCCUPIED`, `BLOCKED`).
8. **`bookings`**: Master reservation records, unique booking reference, 6-character PNR, passenger contact details, total amount in INR, and status (`PENDING_PAYMENT`, `CONFIRMED`, `CANCELLED`).
9. **`passengers`**: Passenger manifest details (first name, last name, type, assigned seat number, individual e-ticket number).
10. **`payments`**: Payment gateway records, Razorpay order IDs, payment IDs, signature verification stamps, currency, and amount.
11. **`tickets`**: Electronic boarding pass records linked to bookings and passengers.
12. **`admin_audit_logs`**: Administrative action audit trail (action type, target entity, admin user ID, IP address, timestamp, details).

---

## 📅 10-Week Comprehensive Project Log

### WEEK 1: Project Introduction and Requirements Analysis
- **Objectives:** Establish the core project vision, analyze domain requirements for airline flight reservations, define technology stack boundaries (Java 21, Jakarta EE 10, Tomcat 10.1, MySQL), and formulate team member roles.
- **Activities:** Conducted collaborative domain analysis on commercial airline booking platforms (IndiGo, Air India, Emirates). Evaluated booking workflows, ticket distribution rules, dynamic seat matrices, and administrative operational needs.
- **Technical Implementation:** Formulated the high-level system boundary document. Selected Jakarta Servlet 6.0, JSP 3.1, Maven multi-module dependency structure, and MySQL relational storage. Established the Git repository workflow with five feature branches and a shared integration branch.
- **Responsible Team Members:** All team members (Mohammed Sahil, Mukesh Sah, Muskan Raj, Nikhil Ranjan Choubey, Prashant Chaudhary) under faculty guidance from Er. Ram Babu Buri.
- **Challenges & Solutions:** *Challenge:* Resolving whether to use an ORM (Hibernate) versus native JDBC. *Solution:* Selected pure JDBC with parameterized `PreparedStatement` to satisfy course PBL constraints, maximize raw query execution speed, and eliminate heavy ORM overhead.
- **Testing & Validation:** Review of requirements document against academic evaluation rubrics.
- **Deliverables:** Approved Problem Statement, Project Scope Document, and initial Git repository layout.
- **Outcome & Next Steps:** Clear architectural vision established; proceeded to formal Software Requirements Specification (SRS).

---

### WEEK 2: Software Requirements and System Planning
- **Objectives:** Produce a comprehensive Software Requirements Specification (SRS), model functional and non-functional requirements, and establish use case models.
- **Activities:** Formulated detailed use case scenarios for guest travelers, registered passengers, and airline administrators. Outlined performance benchmarks (sub-500ms search latency) and security requirements (salted password hashing, SQL injection prevention).
- **Technical Implementation:** Drafted use-case actors and functional specifications across user registration, multi-criteria flight search, real-time seat inventory reservation, Razorpay online checkout, and back-office fleet management.
- **Responsible Team Members:** Mohammed Sahil (Auth specs), Nikhil Ranjan Choubey (Search & Seat specs), Mukesh Sah (Booking lifecycle specs), Muskan Raj (Payment & Ticketing specs), Prashant Chaudhary (Admin & Audit specs).
- **Challenges & Solutions:** *Challenge:* Handling concurrent seat bookings for the same flight inventory. *Solution:* Designed optimistic locking and transactional state transitions in MySQL (`AVAILABLE` -> `BLOCKED` -> `OCCUPIED`).
- **Testing & Validation:** Walkthrough inspection of use cases and state transition diagrams.
- **Deliverables:** Formal Software Requirements Specification (SRS) and Use Case Matrix.
- **Outcome & Next Steps:** Solid requirement foundation completed; transitioned to architecture and UML structural design.

---

### WEEK 3: Architecture and UML Design
- **Objectives:** Design the high-level MVC architecture, component interactions, class diagrams, sequence diagrams, and database entity relationships (ER).
- **Activities:** Created UML class models representing domain entities (`User`, `Flight`, `FlightSchedule`, `Aircraft`, `Seat`, `Booking`, `Passenger`, `Payment`, `Ticket`). Modeled authentication and flight search sequence flows.
- **Technical Implementation:** Formalized the three-tier architecture: Client Tier (Bootstrap 5.3 + JSP), Controller/Service Tier (Jakarta Servlets + Services + DAOs), and Persistence Tier (MySQL). Established standard DTOs and singleton connection pooling models.
- **Responsible Team Members:** All team members; architectural coordination led by Nikhil Ranjan Choubey.
- **Challenges & Solutions:** *Challenge:* Structuring the package hierarchy across two collaborative project modules. *Solution:* Established distinct yet complementary package namespaces (`com.airline.*` for authentication/user management and `com.skytech.*` for flight operations, booking, ticketing, and search).
- **Testing & Validation:** Verification of UML diagrams against OO principles (SOLID) and Jakarta EE conventions.
- **Deliverables:** UML Class Diagram, Component Architecture Diagram, Sequence Diagrams, and Entity-Relationship (ER) Diagram.
- **Outcome & Next Steps:** System design finalized; commenced database schema modeling and frontend interface prototyping.

---

### WEEK 4: Database Design and User Interface
- **Objectives:** Design and normalize the MySQL database schema (`skytech_db`) to Third Normal Form (3NF), build UI wireframes, and formulate the SkyTech aviation design system.
- **Activities:** Created SQL DDL scripts with primary/foreign key constraints, indexes, and sample carrier records (DEL, BOM, BLR, CCU, HYD). Developed high-fidelity wireframes using modern aviation styling.
- **Technical Implementation:** Authored `database/schema.sql`. Created `custom.css` featuring the official SkyTech palette: Midnight Navy (`#071A35`), Deep Aviation Blue (`#0B2D52`), Electric Sky Blue (`#168BFF`), Cloud White (`#F4F8FC`), and Slate Text (`#172B45`). Implemented reusable Bootstrap components and responsive layouts.
- **Responsible Team Members:** Mukesh Sah & Prashant Chaudhary (Database DDL & Constraints), Mohammed Sahil & Nikhil Ranjan Choubey (Frontend Design System & Wireframes).
- **Challenges & Solutions:** *Challenge:* Supporting both one-way flights and complex multi-passenger reservations without schema duplication. *Solution:* Normalized passenger details into a separate `passengers` table linked via foreign key to `bookings(id)`.
- **Testing & Validation:** Executed SQL script in MySQL 8.3; validated referential integrity with test inserts; verified cross-browser CSS responsiveness.
- **Deliverables:** Normalized `database/schema.sql`, master stylesheet `custom.css`, and UI wireframe templates.
- **Outcome & Next Steps:** Schema and design system deployed; initiated core Java backend implementation.

---

### WEEK 5: Project Structure and Core Implementation
- **Objectives:** Establish the Maven project build configuration (`pom.xml`), set up Tomcat 10.1 runtime descriptors (`web.xml`), and build shared core infrastructure utilities.
- **Activities:** Configured Maven dependencies for Jakarta Servlet 6.0, JSTL 3.0, MySQL Connector/J 8.3, OpenPDF 2.0.3, JUnit 5, and Mockito. Implemented database connection management and cryptographic utilities.
- **Technical Implementation:**
  - Implemented `DBConnectionUtil` with multi-tier configuration reading from `.env`, system environment variables, and classpath `db.properties`.
  - Implemented `PasswordUtil` providing cryptographically secure 16-byte random salts and SHA-256 hashing.
  - Implemented `ValidationUtil` providing server-side regex validation for emails, phone numbers, and names.
  - Implemented `AuthenticationFilter` and `AdminAuthorizationFilter`.
- **Responsible Team Members:** Mohammed Sahil (Auth security & filters), Nikhil Ranjan Choubey (Maven build & `DBConnectionUtil`), Muskan Raj (Dependencies & config).
- **Challenges & Solutions:** *Challenge:* Avoiding hardcoded database credentials in source control. *Solution:* Built `AppConfig` with Dotenv support to safely load credentials from a git-ignored `.env` file with sensible catalog fallbacks.
- **Testing & Validation:** Created unit tests in `PasswordUtilTest` and `ValidationUtilTest`; verified that passwords generate unique salted hashes and validate reliably.
- **Deliverables:** Functional Maven project structure, `DBConnectionUtil`, `PasswordUtil`, and security filter configurations.
- **Outcome & Next Steps:** Foundational platform established; commenced specialized Module 2 and Module 1 development.

---

### WEEK 6: Flight Search and Availability (Special Focus: Nikhil Ranjan Choubey)
- **Objectives:** Deliver a high-performance, dynamic flight search engine supporting One-Way, Round-Trip, and Multi-City travel, instant airport autocomplete, live schedule queries, comprehensive flight filtering, and interactive aircraft seat selection.
- **Activities:** Implemented `FlightSearchController`, `FlightSearchService`, `AirportSearchApiController`, and `SeatSelectionController`. Integrated external flight schedule data provider (ReefAPI) with an automated fallback to the local MySQL catalog. Developed an interactive visual aircraft cabin seat map.
- **Technical Implementation:**
  - **Airport Autocomplete REST API (`/api/airports`):** Delivers rapid JSON responses matching airport IATA codes, cities, and airport names using SQL indexed prefix queries.
  - **Search Engine Workflow (`FlightSearchService`):** Parses origin, destination, departure dates, passenger count (Adults, Children, Infants), and cabin classes (`Economy`, `Premium Economy`, `Business`).
  - **Dynamic Filtering & Sorting:** Allows client-side and server-side filtering by airline (IndiGo, Air India, Vistara), stop count (Non-stop, 1+ stops), departure time window (Morning, Afternoon, Evening), and sorting (Lowest Price, Shortest Duration, Earliest Departure).
  - **Interactive Seat Map (`SeatSelectionController`):** Dynamically renders fuselage layouts for Airbus A320neo and Boeing 737-800, displaying seat categories (`WINDOW`, `AISLE`, `MIDDLE`, `EXTRA_LEGROOM`) with real-time seat price calculation.
  - **Dual-Data Architecture:** Implemented `ReefApiClient` for live flight queries with transparent offline failover to MySQL `flight_schedules`.
- **Responsible Team Member:** **Nikhil Ranjan Choubey** (Lead Developer — Module 2).
- **Challenges & Solutions:** *Challenge:* External API key expirations or network latency slowing down flight search results. *Solution:* Engineered a graceful fallback mechanism in `FlightSearchService` that queries the local verified database schedule whenever the external API is unreachable or returns an error.
- **Testing & Validation:** Developed `FlightSearchServiceTest` (7 tests passing) and `ReefApiIntegrationTest` (3 tests passing). Verified autocomplete responsiveness (<50ms) and seat map rendering.
- **Deliverables:** Complete flight search interface, REST API endpoints, seat selection engine, and service test suite.
- **Outcome & Next Steps:** Flight discovery fully operational; proceeded to booking creation and payment processing.

---

### WEEK 7: Booking, Passenger Management, and Payments
- **Objectives:** Implement the passenger booking lifecycle, unique PNR assignment, passenger manifest capture, dynamic seat reservation, and Razorpay payment gateway integration.
- **Activities:** Built `BookingService`, `BookingDao`, `PaymentService`, `PaymentDao`, and checkout views. Formulated transactional booking state management from checkout to confirmed status.
- **Technical Implementation:**
  - **Booking Creation:** `BookingService` creates reservations with a unique 6-character alphanumeric PNR (e.g., `SK7890`) and booking reference (`SKYT-XXXXXX`).
  - **Passenger Manifest Capture:** Binds individual passenger names, age categories, seat numbers, and individual ticket numbers.
  - **Payment Integration (`PaymentService`):** Integrates with the official Razorpay Orders API. Initiates transactions in INR (paise conversion), renders the secure Razorpay Checkout modal, and validates cryptographic SHA-256 HMAC payment signatures (`razorpay_order_id|razorpay_payment_id`) upon completion.
  - **Status Transitions:** Bookings transition from `PENDING_PAYMENT` to `CONFIRMED` upon signature verification, with automated rollback handling upon payment cancellation.
- **Responsible Team Members:** Mukesh Sah (Booking & Passenger Management), Muskan Raj (Payment Gateway & Transactions).
- **Challenges & Solutions:** *Challenge:* Preventing duplicate order creation upon browser reload on checkout. *Solution:* Implemented idempotent order checks in `PaymentService.initiateOrder()` that re-use existing active pending Razorpay orders.
- **Testing & Validation:** Created `BookingServiceTest` (3 tests passing) and `PaymentServiceTest` (6 tests passing). Verified payment signature verification and failed-payment rollback logic.
- **Deliverables:** End-to-end checkout workflow, Razorpay integration, booking confirmation view, and "My Trips" dashboard.
- **Outcome & Next Steps:** Reservation and payment processing completed; progressed to back-office administration and ticketing.

---

### WEEK 8: Admin Dashboard and System Management
- **Objectives:** Construct an operations executive dashboard providing real-time fleet analytics, flight schedule management, airport/airline management, passenger registry, and audit logging.
- **Activities:** Built `AdminDashboardServlet`, `AdminAircraftServlet`, `AdminFlightServlet`, `AdminPassengerServlet`, `AdminAuditDao`, and corresponding JSP administration templates.
- **Technical Implementation:**
  - **Executive Analytics Dashboard (`/admin/dashboard`):** Real-time aggregation of 8 primary KPIs: Total Bookings, Active Flights, Fleet Seat Capacity, Verified Revenue (INR), Active Passengers, Pending Bookings, Cancellations, and Seat Utilization Rate.
  - **Fleet & Aircraft Management (`/admin/aircraft`):** Displays fleet KPI metrics (Total Aircraft, Seat Capacity, Cabin Rows), aircraft fleet table, and an interactive cabin seat configuration preview.
  - **Administrative Operations Queues:** Displays upcoming departures, recent reservations, real-time payment log, and pending approvals.
  - **Security & Audit Trail (`AdminAuditDao`):** Logs administrative updates (passenger status toggles, schedule additions) with admin ID, action type, IP address, and timestamp.
  - **Admin Identity Section:** Polished persistent sidebar displaying the administrator avatar, title, and email.
- **Responsible Team Member:** **Prashant Chaudhary** (Lead Developer — Module 5).
- **Challenges & Solutions:** *Challenge:* Preventing administrators from accidentally suspending their own administrative account. *Solution:* Added strict self-modification checks in `AdminPassengerServlet` preventing an administrator from toggling their own account status.
- **Testing & Validation:** Created `AdminDashboardServletTest` verifying KPI calculation and forwarding; verified role enforcement with `AdminAuthorizationFilter`.
- **Deliverables:** Administrative dashboard, fleet aircraft manager, passenger administration tools, and audit log viewer.
- **Outcome & Next Steps:** Back-office system operational; initiated complete multi-module integration and bug fixing.

---

### WEEK 9: Integration, Testing, and Bug Fixes
- **Objectives:** Integrate all five individual modules on the shared `integration/skytech` branch, eliminate routing and layout anomalies, resolve cross-module session bugs, and execute a comprehensive automated regression suite.
- **Activities:** Conducted full system integration walkthroughs. Resolved dropdown clipping on the homepage, fixed admin profile 404 routing, updated admin sidebar identity formatting, and executed automated tests.
- **Technical Implementation:**
  - Standardized navbar z-index and dropdown layering (`z-index: 1060`) preventing curved hero section clipping.
  - Registered missing servlet mappings in `web.xml` for `ProfileServlet`, `AdminProfileServlet`, `AdminAircraftServlet`, and `AdminDashboardServlet`.
  - Built comprehensive unit and integration tests across all modules.
  - Enforced consistent UTF-8 character encoding and HTTP security headers across all views.
- **Responsible Team Members:** All team members; integration lead by Nikhil Ranjan Choubey and Mohammed Sahil.
- **Challenges & Solutions:** *Challenge:* Discrepancies between legacy servlet test constructors and refactored DAOs. *Solution:* Refactored `AdminDashboardServletTest` with Mockito to match current `AdminDashboardDao` contracts, achieving a 100% build pass rate.
- **Testing & Validation:** Executed `mvn test`: **71 tests executed, 0 failures, 0 errors, 0 skipped**. Verified cross-module cookie session sharing and role separation.
- **Deliverables:** Fully integrated codebase on `integration/skytech`, resolved defect log, and automated test regression suite.
- **Outcome & Next Steps:** Clean system integration verified; commenced final evaluation deliverables and high-quality e-ticketing.

---

### WEEK 10: Final Evaluation, Polish and Deliverables
- **Objectives:** Implement a premium OpenPDF-generated airline boarding pass e-ticket, perform full repository audit and safe cleanup, standardize user-facing branding to "SkyTech", verify Tomcat runtime deployment, and prepare final academic evaluation deliverables.
- **Activities:** Re-engineered `TicketService` with OpenPDF 2.0.3, generated sharp vector Code128 barcodes, purged disposable test scripts, standardized branding across all views, and documented the 10-week development log in this master README.
- **Technical Implementation:**
  - **Premium PDF E-Ticket Engine (`TicketService`):** Generates clean, print-friendly electronic tickets featuring deep navy and aviation blue styling, flight itinerary route cards, passenger seat assignment tables, GST fare breakdowns, native OpenPDF `Barcode128` vector barcodes, and travel guidance notices.
  - **Ticket Download Security (`TicketController`):** Restricts ticket downloads (`/ticket/download`, `/ticket/view`) to confirmed bookings belonging strictly to the authenticated passenger (or administrators), returning HTTP 403 Forbidden on unauthorized attempts.
  - **Branding Standardization:** Eliminated all inconsistent branding variations (*"SkyTech Airlines"*, *"SkyTech Airline"*), standardizing visible UI, titles, and dialogs strictly to **SkyTech**.
  - **Final Cleanup:** Purged ephemeral scratch scripts while preserving all Java, JSP, SQL, configuration, and Git history assets.
- **Responsible Team Members:** All team members (Mohammed Sahil, Mukesh Sah, Muskan Raj, Nikhil Ranjan Choubey, Prashant Chaudhary).
- **Challenges & Solutions:** *Challenge:* Generating sharp barcodes without external web services or raster blur. *Solution:* Utilized OpenPDF's built-in `Barcode128` class to write vector-quality barcode paths directly into the `PdfContentByte` layer.
- **Testing & Validation:** Verified with `TicketServiceTest` (4 unit tests), browser subagent live inspection of Tomcat web pages, and full `mvn test` execution.
- **Deliverables:** Final deployable WAR artifact, master `README.md` with 10-week log, verified schema, and clean repository.
- **Outcome & Next Steps:** System fully verified, tested, and ready for academic project presentation and evaluation.

---

## 🌐 Application URL Route Map

| URL Route | HTTP Method | Description | Access Clearance |
|---|---|---|---|
| `/` or `/home` | GET | SkyTech Homepage & Flight Search Engine | Public |
| `/search-flights` | GET | Flight search submission and query execution | Public |
| `/flight-results` | GET | Flight search results with real-time filters and sorting | Public |
| `/flight-details` | GET | Flight segment specifications, baggage, and fare rules | Public |
| `/seat-selection` | GET | Interactive aircraft cabin seat map selection | Public |
| `/api/airports` | GET | Airport search autocomplete JSON REST API | Public |
| `/flight-status` | GET | Real-time flight schedule tracker | Public |
| `/manage-booking` | GET | Retrieve reservation itinerary by PNR | Public |
| `/travel-information` | GET | Passenger guidelines, baggage allowances, and FAQs | Public |
| `/login` | GET, POST | Passenger and administrator sign-in | Public / Guests |
| `/register` | GET, POST | Passenger registration and account creation | Public / Guests |
| `/auth/google` | POST | Google Identity Services (GIS) OAuth2 callback | Public / Guests |
| `/logout` | GET, POST | Session invalidation and secure logout | Authenticated |
| `/profile` | GET, POST | Passenger account profile viewing and updates | Authenticated Passenger |
| `/avatar` | GET | Passenger profile photo retrieval endpoint | Authenticated Passenger |
| `/checkout` | GET, POST | Secure booking checkout with Razorpay gateway | Authenticated Passenger |
| `/confirmation` | GET | Booking confirmation and itinerary receipt | Authenticated Passenger |
| `/my-bookings` | GET | Passenger booking history ("My Trips") | Authenticated Passenger |
| `/ticket/download` | GET | Download electronic PDF flight ticket (Attachment) | Authenticated Owner / Admin |
| `/ticket/view` | GET | In-browser preview of electronic PDF flight ticket | Authenticated Owner / Admin |
| `/admin` or `/admin/dashboard` | GET | Executive operations dashboard & KPI metrics | Admin Only |
| `/admin/aircraft` | GET, POST | Fleet aircraft & seat capacity management | Admin Only |
| `/admin/flights` | GET, POST | Flight routes and schedules management | Admin Only |
| `/admin/passengers` | GET, POST | Passenger registry & account status toggles | Admin Only |
| `/admin/bookings` | GET, POST | Master booking registry and status administration | Admin Only |
| `/admin/payments` | GET | Payment transaction audit records | Admin Only |
| `/admin/audit` | GET | Administrative system action audit logs | Admin Only |
| `/about` | GET | Project team, developer credits & academic mentor details | Public |

---

## ⚙️ Environment Setup & Run Guide

### 1. Prerequisites
- **Java Development Kit (JDK):** Version 21 LTS (`java -version`)
- **Build Tool:** Apache Maven 3.9+ (`mvn -v`)
- **Database:** MySQL Server 8.0+ (`mysql --version`)
- **Servlet Container:** Apache Tomcat 10.1+ (Jakarta EE 10 / Servlet 6.0 compatible)

### 2. Database Initialization
Log into MySQL and execute the unified schema script:
```bash
mysql -u root -p < database/schema.sql
```
*(Optional migrations for profile avatar photos and audit logging can be applied via `database/migration_profile_photo.sql` and `database/migration_admin_audit.sql`.)*

Default seeded accounts for demonstration:
- **System Administrator:** `admin@airline.com` / `Admin@12345`
- **Standard Passenger:** `passenger@airline.com` / `Passenger@12345`

### 3. Environment Configuration (`.env`)
Create a `.env` file in the project root directory based on the provided [.env.example](.env.example):

```properties
# MySQL Database Connection
DB_URL=jdbc:mysql://localhost:3306/skytech_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata&characterEncoding=UTF-8
DB_USERNAME=root
DB_PASSWORD=your_mysql_password
DB_DRIVER=com.mysql.cj.jdbc.Driver

# External Flight Provider (Optional live schedules)
REEF_API_KEY=your_reef_api_key_if_available
REEF_API_URL=https://api.reefapi.com

# Razorpay Payment Gateway
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret

# Google Identity Services (GIS)
GOOGLE_CLIENT_ID=your_google_oauth_client_id.apps.googleusercontent.com
```

### 4. Running Automated Tests
Execute the full automated test suite using Maven:
```bash
mvn clean test
```
*Expected Result: 71 tests executed, 0 failures, 0 errors, 0 skipped.*

### 5. Building Deployable WAR
Package the application into an enterprise WAR bundle:
```bash
mvn clean package
```
Generates deployable WAR artifact at: `target/airline-reservation-system.war`.

### 6. Deployment to Apache Tomcat 10.1
1. Copy `target/airline-reservation-system.war` into `%CATALINA_HOME%\webapps\` (Windows) or `$CATALINA_HOME/webapps/` (Linux/macOS).
2. Start the Tomcat server (`bin/startup.bat` or `bin/startup.sh`).
3. Open a browser and navigate to:
   ```
   http://localhost:8080/airline-reservation-system/
   ```

---

## 🔒 Security Architecture & Best Practices

- **Zero Plaintext Passwords:** Passwords are salted with 16 cryptographically random bytes and hashed using SHA-256 before persistence.
- **SQL Injection Prevention:** All SQL queries across all DAOs use parameterized `PreparedStatement` interfaces.
- **Role-Based Authorization:** `AuthenticationFilter` and `AdminAuthorizationFilter` guard passenger and administrator sectors, returning HTTP 403 or redirecting unauthenticated requests.
- **Session Security:** Session IDs are regenerated upon successful authentication; session cookies are managed with `HttpOnly` flags to prevent cross-site scripting (XSS) interception.
- **Download Guard:** Ticket download requests (`/ticket/download`) verify booking ownership against the session user ID, preventing unauthorized passenger access.
- **Credential Protection:** All database passwords, Razorpay API secrets, and OAuth keys are kept out of source control using `.gitignore` and `.env` separation.

---

## 📄 License & Academic Attribution

This project is submitted in partial fulfillment of the requirements for the **B.Tech Computer Science and Engineering — Java Project-Based Learning (PBL)** curriculum (5th Semester).

© 2026 **SkyTech Project Team**. Developed under the mentorship of **Er. Ram Babu Buri**, Department of Computer Science and Engineering.
