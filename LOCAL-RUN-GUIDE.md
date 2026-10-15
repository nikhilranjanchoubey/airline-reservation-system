# SkyTech - Local Development Running Guide (Windows)

This guide provides simple, step-by-step instructions for running the **SkyTech Airline Reservation System** locally on Windows.

---

## ⚡ The Fastest Way to Run (One Double-Click)

1. Open the project root folder in File Explorer.
2. **Double-click `START-SKYTECH.bat`**.
3. The script will:
   - Verify Java is installed.
   - Verify MySQL database service status.
   - Package the application WAR using the Maven wrapper (`./mvnw.cmd package -DskipTests`).
   - Deploy to your local Apache Tomcat server (`apache-tomcat-10.1.36`).
   - Start Tomcat (if not already running).
   - **Automatically launch your browser at:**
     ```
     http://localhost:8080/airline-reservation-system/
     ```
4. When finished, double-click **`STOP-SKYTECH.bat`** to gracefully stop Tomcat and free port 8080.

---

## 📋 Prerequisites Verified on Your System

| Component | Status on Your Machine | Notes |
| :--- | :--- | :--- |
| **Java** | JDK 21 / 25 Installed | Required for compiling and running the modern Jakarta EE Servlet/JSP app. |
| **Database** | MySQL80 Windows Service Running | Connected to `skytech_db` on default port `3306`. |
| **Tomcat** | Apache Tomcat 10.1.36 | Located in your user directory: `%USERPROFILE%\apache-tomcat-10.1.36`. |
| **Maven** | Maven Wrapper (`mvnw.cmd`) | Included in the repository; builds without needing global Maven. |

---

## 🌐 Local Application URLs

- **Homepage**: [http://localhost:8080/airline-reservation-system/](http://localhost:8080/airline-reservation-system/)
- **Flight Search**: [http://localhost:8080/airline-reservation-system/search-flights](http://localhost:8080/airline-reservation-system/search-flights)
- **Manage Booking**: [http://localhost:8080/airline-reservation-system/manage-booking](http://localhost:8080/airline-reservation-system/manage-booking)
- **Flight Status**: [http://localhost:8080/airline-reservation-system/flight-status](http://localhost:8080/airline-reservation-system/flight-status)
- **Health Check API**: [http://localhost:8080/airline-reservation-system/api/health](http://localhost:8080/airline-reservation-system/api/health)

---

## 🛠️ Troubleshooting & FAQ

### Port 8080 is already in use
If you get a port conflict, double-click `STOP-SKYTECH.bat` to terminate any hanging Tomcat instances, then re-run `START-SKYTECH.bat`.

### Database Connection Error
Ensure the MySQL Windows service is active:
1. Open PowerShell / Command Prompt as Administrator.
2. Run: `net start MySQL80`
3. Credentials and settings are read safely from your local `.env` file (`DB_URL`, `DB_USERNAME`, `DB_PASSWORD`).

### Environment Variables
Your sensitive keys and configuration are maintained securely in your local `.env` file:
- Never commit `.env` to Git (it is strictly excluded in `.gitignore`).
- The application automatically picks up changes upon rebuild.
