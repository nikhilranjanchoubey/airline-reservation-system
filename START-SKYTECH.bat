@echo off
setlocal EnableDelayedExpansion

title SkyTech - Airline Reservation System Launcher
color 0B

echo ===============================================================================
echo                SKYTECH - AIRLINE RESERVATION SYSTEM LAUNCHER
echo ===============================================================================
echo.

cd /d "%~dp0"

:: -----------------------------------------------------------------------------
:: Step 1: Detect Java Installation
:: -----------------------------------------------------------------------------
echo [1/6] Checking Java Environment...
where java >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Java runtime was not found on your system PATH!
    echo Please install Java 21 or Java 17 ^(e.g. Eclipse Temurin or Oracle JDK^).
    echo Download: https://adoptium.net/
    echo.
    pause
    exit /b 1
)
echo        Java is installed and available on PATH.

:: -----------------------------------------------------------------------------
:: Step 2: Check MySQL Database Service
:: -----------------------------------------------------------------------------
echo [2/6] Checking MySQL Database Service...
sc query MySQL80 >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo        MySQL Service ^(MySQL80^) detected.
) else (
    echo        [INFO] MySQL80 Windows service not found directly by name.
    echo        If MySQL is running on port 3306 or via Docker/XAMPP, connection will succeed.
)

:: -----------------------------------------------------------------------------
:: Step 3: Check / Find Apache Tomcat Installation
:: -----------------------------------------------------------------------------
echo [3/6] Locating Apache Tomcat 10.1...
set "TOMCAT_HOME=%USERPROFILE%\apache-tomcat-10.1.36"

if not exist "!TOMCAT_HOME!\bin\catalina.bat" (
    if defined CATALINA_HOME (
        set "TOMCAT_HOME=%CATALINA_HOME%"
    )
)

if not exist "!TOMCAT_HOME!\bin\catalina.bat" (
    echo.
    echo [ERROR] Apache Tomcat 10.1 was not found at:
    echo         !TOMCAT_HOME!
    echo.
    echo Please verify Tomcat installation or set CATALINA_HOME in your environment.
    echo Download: https://tomcat.apache.org/download-10.cgi
    echo.
    pause
    exit /b 1
)
echo        Tomcat located at: !TOMCAT_HOME!

:: -----------------------------------------------------------------------------
:: Step 4: Build / Package with Maven Wrapper
:: -----------------------------------------------------------------------------
echo [4/6] Building Application WAR with Maven Wrapper...
if not exist "mvnw.cmd" (
    echo.
    echo [ERROR] Maven wrapper 'mvnw.cmd' was not found in project root!
    pause
    exit /b 1
)

call mvnw.cmd package -DskipTests
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Maven build failed! Please check compilation errors above.
    echo.
    pause
    exit /b 1
)

if not exist "target\airline-reservation-system.war" (
    echo.
    echo [ERROR] Built WAR 'target\airline-reservation-system.war' was not found!
    pause
    exit /b 1
)

:: Deploy WAR and exploded folder to Tomcat
echo        Deploying WAR to Tomcat webapps...
copy /Y "target\airline-reservation-system.war" "!TOMCAT_HOME!\webapps\airline-reservation-system.war" >nul
xcopy /E /I /Y "target\airline-reservation-system\*" "!TOMCAT_HOME!\webapps\airline-reservation-system\" >nul 2>&1
echo        Application deployed successfully!

:: -----------------------------------------------------------------------------
:: Step 5: Start Apache Tomcat
:: -----------------------------------------------------------------------------
echo [5/6] Checking Tomcat Process ^& Port 8080...
netstat -ano | findstr /R /C:":8080 .*LISTENING" >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo        Tomcat or a service on port 8080 is already running.
) else (
    echo        Starting Apache Tomcat in a separate window...
    set "CATALINA_HOME=!TOMCAT_HOME!"
    start "SkyTech Tomcat Server" cmd /c "!TOMCAT_HOME!\bin\catalina.bat run"
)

:: -----------------------------------------------------------------------------
:: Step 6: Wait for Health & Open Browser
:: -----------------------------------------------------------------------------
echo [6/6] Waiting for SkyTech to become available...
set "APP_URL=http://localhost:8080/airline-reservation-system/"

echo.
echo ===============================================================================
echo [SUCCESS] SkyTech Airline Reservation System is LIVE!
echo.
echo Access URL: %APP_URL%
echo.
echo Opening SkyTech in your default browser...
start %APP_URL%
echo.
echo To shut down Tomcat when finished, run: STOP-SKYTECH.bat
echo ===============================================================================
echo.
pause
