package com.skytech.airlines.booking;

import com.skytech.airlines.booking.server.StandaloneAppServer;

import java.awt.Desktop;
import java.net.URI;

/**
 * =============================================================================
 * SKYTECH AIRLINES — Official Flight Reservation System
 * Eclipse IDE "Ready to Run" Application Launcher
 * =============================================================================
 * 
 * HOW TO RUN IN ECLIPSE IDE:
 * 1. Open Eclipse IDE (Eclipse for Enterprise Java and Web Developers).
 * 2. In Project Explorer, navigate to:
 *       src/main/java -> com.skytech.airlines.booking -> RunInEclipse.java
 * 3. Right-Click on 'RunInEclipse.java' -> 'Run As' -> 'Java Application'.
 * 4. The server starts immediately and opens your default browser at http://localhost:8080/
 * 
 * ALTERNATIVE IN ECLIPSE:
 * - Double-click 'SKYTECH-Airlines-Run-In-Eclipse.launch' in the project root.
 * - Or Right-Click project -> 'Run As' -> 'Run on Server' -> 'Apache Tomcat v9.0'.
 * =============================================================================
 */
public class RunInEclipse {

    public static void main(String[] args) {
        System.out.println("===============================================================================");
        System.out.println("  SKYTECH AIRLINES — OFFICIAL FLIGHT RESERVATION SYSTEM                       ");
        System.out.println("  Starting Eclipse IDE Embedded Application Server...                          ");
        System.out.println("===============================================================================");

        try {
            int port = StandaloneAppServer.startServer();
            String appUrl = "http://localhost:" + port + "/";
            String myBookingsUrl = "http://localhost:" + port + "/my-bookings";
            System.out.println("\n [SUCCESS] SKYTECH AIRLINES Application Server is LIVE and listening!");
            System.out.println("-------------------------------------------------------------------------------");
            System.out.println("   Official Flight Booking : " + appUrl);
            System.out.println("   My Bookings Dashboard   : " + myBookingsUrl);
            System.out.println("-------------------------------------------------------------------------------");
            System.out.println(" [ECLIPSE CONSOLE NOTE] Server is running in the background.");
            System.out.println(" To terminate the server in Eclipse, click the red 'Terminate' button []");
            System.out.println(" in the Console view toolbar.\n");

            // Attempt to open the default system web browser automatically
            try {
                if (Desktop.isDesktopSupported() && Desktop.getDesktop().isSupported(Desktop.Action.BROWSE)) {
                    System.out.println(" Launching default browser to: " + appUrl);
                    Desktop.getDesktop().browse(new URI(appUrl));
                } else {
                    System.out.println(" [INFO] Open " + appUrl + " in your web browser.");
                }
            } catch (Exception ex) {
                System.out.println(" [INFO] Open " + appUrl + " in your web browser.");
            }

            // Keep main thread alive for Eclipse console execution
            Thread.currentThread().join();

        } catch (InterruptedException ie) {
            System.out.println("\n Server stopped by user.");
            Thread.currentThread().interrupt();
        } catch (Exception e) {
            System.err.println("\n [ERROR] Failed to start server in Eclipse: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
