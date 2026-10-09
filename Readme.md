# ✈️ SkyTech - Airline Reservation & Passenger Management System

[![Java 21](https://img.shields.io/badge/Java-21%20LTS-007396?logo=openjdk&logoColor=white)](https://www.oracle.com/java/)
[![Jakarta EE 10](https://img.shields.io/badge/Jakarta%20EE-10%20(Servlet%206.0)-E03C11?logo=eclipseide&logoColor=white)](https://jakarta.ee/)
[![MySQL](https://img.shields.io/badge/MySQL-8.3%2B-4479A1?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Tomcat](https://img.shields.io/badge/Apache%20Tomcat-10.1%2B-F8DC75?logo=apachetomcat&logoColor=black)](https://tomcat.apache.org/)
[![Bootstrap 5.3](https://img.shields.io/badge/Bootstrap-5.3-7952B3?logo=bootstrap&logoColor=white)](https://getbootstrap.com/)
[![License](https://img.shields.io/badge/License-Proprietary-blue.svg)]()

---

## 📌 Executive Overview

**SkyTech** is an enterprise-grade airline reservation and passenger management web application engineered for commercial airlines. Built on modern **Java 21** and the **Jakarta EE 10** platform, SkyTech delivers high-throughput flight discovery, interactive aircraft cabin seat selection, secure credential handling, and administrative user governance through a responsive, glassmorphic aviation interface.

---

## 🎨 Theme & Visual Design

SkyTech is crafted with a bespoke **Sky & Cobalt Blue** color palette, frosted glass cards (*glassmorphism*), smooth gradients, and aviation photography:
- **Hero Flight Section:** High-resolution dynamic commercial jet flying through sky and clouds, flight search bar (*From, To, Departure, Return*), and instant service tiles (*Flight Status, Check-In, Baggage Info, Airport Map*).
- **Live Inventory & Fares:** Search filters by price range, multi-airline carriers, and non-stop flight routes.
- **Aircraft Seat Map Selector:** Cabin fuselage visualization with clickable rows (A-F seats) displaying available, selected, and occupied seats.
- **Digital Boarding Pass:** QR ticket preview with airport codes (`NYC` → `LHR`), flight number (`SK322`), gate assignment, seat badges, and flight alerts.
- **Airport Hospitality Services:** VIP Lounges, Executive Car Rentals, Resort Hotels, and Tarmac Concierge.

---

## 🛠️ Technology Stack & Justification

| Technology | Role | Why This Technology Was Chosen |
| :--- | :--- | :--- |
| **Java 21 (LTS)** | Backend Core Language | Long-Term Support release offering record-breaking JVM performance, modern pattern matching, strong memory safety, and virtual-thread scalability. |
| **Jakarta Servlet 6.0** | HTTP Web Request Handling | Standard enterprise Java web specification with the modern `jakarta.*` namespace. Provides non-blocking I/O support, robust session lifecycle management, and filter chains. |
| **Jakarta JSP 3.1 & JSTL 3.0** | Server-Side Presentation | Clean separation of business logic from presentation. Tag libraries eliminate scriptlets, preventing XSS and enforcing clean MVC architecture. |
| **MySQL 8.3 & Connector/J** | Relational Database & Driver | High-performance ACID-compliant relational persistence, indexed email lookups, and support for concurrent passenger booking transactions. |
| **Apache Tomcat 10.1.x** | Application Server Container | Native support for Jakarta EE 10 deployment descriptors (`web.xml` v6.0) and Servlet 6.0 specifications. |
| **Vanilla CSS + Bootstrap 5.3** | UI & Glassmorphism Design | Zero heavy JavaScript framework dependencies. Lightning-fast page load times, full responsiveness, Google Fonts (*Plus Jakarta Sans*), and smooth micro-animations. |
| **SHA-256 + Cryptographic Salt** | Security & Password Hashing | Every password is salted with a unique random hex string and hashed using SHA-256, completely mitigating rainbow table and precomputation attacks. |
| **Role-Based Access Control (RBAC)** | Authorization | Dedicated `AuthenticationFilter` and `AdminAuthorizationFilter` guard protected endpoints (`/profile`, `/admin/*`) at the servlet container level. |

---

## 📂 Project Architecture & Directory Structure

```plaintext
Airline-Reservation-System/
├── pom.xml                                # Maven build descriptor (Java 21, Jakarta EE 10, MySQL)
├── .gitignore                             # Clean VCS ignore rules (excludes target/, IDE files)
├── Readme.md                              # Comprehensive system documentation & roadmap
├── sql/
│   └── schema.sql                         # Database schema & pre-seeded test accounts
└── src/
    ├── main/
    │   ├── java/com/airline/
    │   │   ├── controller/                # Servlet HTTP Controllers (@WebServlet)
    │   │   │   ├── AdminDashboardServlet.java
    │   │   │   ├── LoginServlet.java
    │   │   │   ├── LogoutServlet.java
    │   │   │   ├── ProfileServlet.java
    │   │   │   └── RegisterServlet.java
    │   │   ├── dao/                       # Data Access Layer (JDBC queries)
    │   │   │   ├── UserDao.java
    │   │   │   └── UserDaoImpl.java
    │   │   ├── filter/                    # Security & Authorization Filters (@WebFilter)
    │   │   │   ├── AdminAuthorizationFilter.java
    │   │   │   └── AuthenticationFilter.java
    │   │   ├── model/                     # Domain Entities
    │   │   │   ├── Role.java
    │   │   │   └── User.java
    │   │   ├── service/                   # Business Logic & Validation
    │   │   │   ├── ServiceResult.java
    │   │   │   └── UserService.java
    │   │   └── util/                      # Utilities & Singleton Connection
    │   │       ├── DBConnection.java
    │   │       ├── PasswordUtil.java
    │   │       └── ValidationUtil.java
    │   ├── resources/
    │   │   └── db.properties              # MySQL JDBC connection parameters
    │   └── webapp/
    │       ├── index.jsp                  # SkyTech landing page (Hero, Flights, Seat Selector, Boarding Pass)
    │       ├── css/
    │       │   └── custom.css             # SkyTech glassmorphic stylesheet & design tokens
    │       ├── js/
    │       │   └── auth-validation.js     # Client-side form & password strength validation
    │       ├── images/                    # Aviation & service photography assets
    │       │   ├── plane-hero.jpg
    │       │   ├── service-lounge.jpg
    │       │   ├── service-car.jpg
    │       │   ├── service-hotel.jpg
    │       │   └── service-vip.jpg
    │       └── WEB-INF/
    │           ├── web.xml                # Jakarta EE 10 deployment descriptor
    │           └── views/
    │               ├── admin/dashboard.jsp
    │               ├── auth/login.jsp
    │               ├── auth/register.jsp
    │               ├── common/header.jsp
    │               ├── common/navbar.jsp
    │               ├── common/footer.jsp
    │               ├── errors/403.jsp
    │               ├── errors/404.jsp
    │               └── profile/profile.jsp
    └── test/java/com/airline/util/        # JUnit 5 & Mockito test suites
        ├── PasswordUtilTest.java
        └── ValidationUtilTest.java
```

---

## 🗄️ Database Configuration & Pre-seeded Accounts

### 1. Connection File: `src/main/resources/db.properties`
```properties
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/airline_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8
db.username=root
db.password=root
```

### 2. Pre-seeded Demo Credentials (`sql/schema.sql`)
| Account Type | Email | Password | Role | Permissions |
| :--- | :--- | :--- | :--- | :--- |
| **Administrator** | `admin@airline.com` | `Admin@12345` | `ADMIN` | Full access to Admin Dashboard, user metrics, suspension & activation |
| **Passenger** | `passenger@airline.com` | `Passenger@12345` | `PASSENGER` | Profile management, password reset, seat booking, boarding pass |

---

## 🚀 Step-by-Step Local Execution Guide (Windows PowerShell)

### Step 1: Initialize Database & Verify Connectivity
Verify MySQL is active on port 3306:
```powershell
Test-NetConnection -ComputerName localhost -Port 3306
```

Apply the schema and seed accounts:
```powershell
Get-Content .\sql\schema.sql | mysql -u root -p
```

Verify seeded records:
```powershell
mysql -u root -p -e "USE airline_db; SELECT user_id, email, first_name, last_name, role, status FROM users;"
```

### Step 2: Build the WAR Package with Maven
```powershell
mvn clean package
```
*Creates `target\airline-reservation-system.war` using Java 21.*

### Step 3: Deploy to Apache Tomcat 10.1
Set your Tomcat home environment variable:
```powershell
$env:CATALINA_HOME = "C:\apache-tomcat-10.1.x"   # Adjust to your local Tomcat path
```

Deploy the WAR package to Tomcat's `webapps` folder:
```powershell
Copy-Item .\target\airline-reservation-system.war -Destination "$env:CATALINA_HOME\webapps\" -Force
```

Start Tomcat:
```powershell
& "$env:CATALINA_HOME\bin\startup.bat"
```

*(To stop Tomcat when finished: `& "$env:CATALINA_HOME\bin\shutdown.bat"`)*

### Step 4: Access in the Browser
```powershell
# SkyTech Homepage (Flight Search, Seat Map, Boarding Pass, Services)
Start-Process "http://localhost:8080/airline-reservation-system/"

# Passenger & Admin Sign In
Start-Process "http://localhost:8080/airline-reservation-system/login"

# Passenger Account Registration
Start-Process "http://localhost:8080/airline-reservation-system/register"
```

---

## 📋 Detailed Project Task Breakdown & Roadmap

### ✅ Completed Milestones (Phase 1)
- [x] **Project Foundation:** Jakarta EE 10 + Java 21 build configuration in Maven.
- [x] **Database Architecture:** MySQL 8 `airline_db` schema, salted hashing, connection pool singleton.
- [x] **Authentication Engine:**
  - [x] Registration controller with regex validation for names, phone, email, password strength.
  - [x] Login controller with session establishment and role-based routing.
  - [x] Logout servlet with session invalidation.
- [x] **Security Filters:**
  - [x] `AuthenticationFilter` guarding passenger profiles and administrative endpoints.
  - [x] `AdminAuthorizationFilter` restricting `/admin/*` solely to `ADMIN` role.
- [x] **Profile & Admin Modules:**
  - [x] Personal details editing and secure password changing.
  - [x] Administrator Dashboard with KPI cards and account suspension/activation controls.
- [x] **SkyTech Visual Overhaul:**
  - [x] Bespoke aviation design system (Plus Jakarta Sans, Sky Blue palette, glassmorphic cards).
  - [x] High-resolution airliner flying in sky hero banner.
  - [x] Flight search bar with date pickers and live pricing filters.
  - [x] Interactive cabin seat selection map with real-time fare tally.
  - [x] Digital boarding pass with QR code and flight notifications.
  - [x] Airport hospitality services gallery (Lounges, Car Rentals, Hotels, VIP).
  - [x] Custom error handling (404 Not Found & 403 Forbidden views).

### ⏳ Upcoming Milestones (Roadmap)
- [ ] **Phase 2: Dynamic Flight Schedule Engine:**
  - [ ] Add `flights`, `airports`, and `routes` tables in MySQL.
  - [ ] Implement search servlet querying flights by origin, destination, date, and available seats.
- [ ] **Phase 3: Real-Time Seat Reservation & Booking Transactions:**
  - [ ] Add `bookings`, `tickets`, and `passengers` tables.
  - [ ] Implement atomic JDBC transaction locking selected seats during checkout.
- [ ] **Phase 4: Payment Gateway & Boarding Pass PDF Generation:**
  - [ ] Integrate Stripe / PayPal mock payment gateway.
  - [ ] Generate downloadable PDF boarding pass with iText / PDFBox.
- [ ] **Phase 5: Automated Email & Flight Status Notifications:**
  - [ ] Send booking confirmation and flight delay emails via Jakarta Mail.
