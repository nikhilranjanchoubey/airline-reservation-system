@echo off
setlocal enabledelayedexpansion

title SkyTech - Stop Local Server
color 0C

echo ===============================================================================
echo                SKYTECH - AIRLINE RESERVATION SYSTEM SHUTDOWN
echo ===============================================================================
echo.

cd /d "%~dp0"

set "TOMCAT_HOME=%USERPROFILE%\apache-tomcat-10.1.36"

if not exist "!TOMCAT_HOME!\bin\catalina.bat" (
    if defined CATALINA_HOME (
        set "TOMCAT_HOME=%CATALINA_HOME%"
    )
)

if exist "!TOMCAT_HOME!\bin\shutdown.bat" (
    echo [1/2] Invoking Tomcat graceful shutdown via shutdown.bat...
    call "!TOMCAT_HOME!\bin\shutdown.bat" >nul 2>&1
    timeout /t 2 >nul 2>&1
)

echo [2/2] Checking port 8080 status...
netstat -ano | findstr /R /C:":8080 .*LISTENING" >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo        Port 8080 is still occupied.
    echo        Terminating Tomcat process on port 8080 safely...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr /R /C:":8080 .*LISTENING"') do (
        set PID=%%a
        if not "!PID!"=="0" (
            taskkill /PID !PID! /F >nul 2>&1
        )
    )
    echo        Tomcat process terminated.
) else (
    echo        Tomcat has stopped cleanly.
)

echo.
echo ===============================================================================
echo [SUCCESS] SkyTech local server has been shut down.
echo ===============================================================================
echo.
pause
