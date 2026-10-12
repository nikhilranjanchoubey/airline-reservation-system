<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.skyport.model.Booking" %>

<%!
    // Escape HTML characters to prevent error messages from being
    // interpreted as HTML. No JSTL dependency is required.
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    Booking booking = (Booking) request.getAttribute("booking");
    String error = (String) request.getAttribute("error");
    String searchedPNR = (String) request.getAttribute("searchedPNR");

    if (searchedPNR == null) {
        searchedPNR = "";
    }

    String status = "";

    if (booking != null && booking.getBookingStatus() != null) {
        status = booking.getBookingStatus();
    }

    boolean cancelled = "CANCELLED".equalsIgnoreCase(status);
    boolean confirmed = "CONFIRMED".equalsIgnoreCase(status);

    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>SkyPort | Electronic Ticket</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Manrope:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">

    <style>
        /* =====================================
           SKYPORT DESIGN SYSTEM
        ===================================== */

        :root {
            --sky-navy: #071A35;
            --sky-deep-blue: #0B2D52;
            --sky-blue: #168BFF;
            --sky-cyan: #56CCF2;
            --sky-cloud: #F4F8FC;
            --sky-white: #FFFFFF;
            --sky-success: #18A878;
            --sky-danger: #E5484D;
            --sky-text: #172B45;
            --sky-muted: #64748B;
            --sky-border: #D8E3EF;

            --sky-radius-sm: 8px;
            --sky-radius-md: 14px;
            --sky-radius-lg: 22px;

            --sky-shadow: 0 10px 30px rgba(7, 26, 53, 0.10);
            --sky-transition: 220ms ease;
        }

        /* =====================================
           RESET AND BODY
        ===================================== */

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: "Inter", system-ui, sans-serif;
            background: var(--sky-cloud);
            color: var(--sky-text);
            min-height: 100vh;
            line-height: 1.6;
        }

        button,
        input {
            font: inherit;
        }

        a {
            text-decoration: none;
        }

        :focus-visible {
            outline: 3px solid var(--sky-cyan);
            outline-offset: 3px;
        }

        .sky-heading {
            font-family: "Manrope", "Inter", sans-serif;
            color: var(--sky-navy);
        }

        /* =====================================
           NAVIGATION
        ===================================== */

        .navbar {
            background: var(--sky-navy);
            padding: 20px 0;
        }

        .nav-container {
            width: min(1120px, 92%);
            margin: auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
        }

        .navbar-brand {
            font-family: "Manrope", sans-serif;
            font-size: 25px;
            font-weight: 800;
            color: var(--sky-white);
            letter-spacing: -0.5px;
        }

        .navbar-brand span {
            color: var(--sky-cyan);
        }

        .nav-tagline {
            color: #DCEBFA;
            font-size: 13px;
        }

        /* =====================================
           MAIN CONTAINER
        ===================================== */

        .page-container {
            width: min(1000px, 92%);
            margin: 38px auto;
        }

        .sky-card {
            background: var(--sky-white);
            border: 1px solid var(--sky-border);
            border-radius: var(--sky-radius-md);
            box-shadow: var(--sky-shadow);
        }

        .ticket-card {
            padding: 34px;
        }

        /* =====================================
           TICKET HEADER
        ===================================== */

        .ticket-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            padding-bottom: 24px;
            border-bottom: 2px dashed var(--sky-border);
        }

        .ticket-header h1 {
            font-family: "Manrope", sans-serif;
            font-size: clamp(25px, 4vw, 34px);
            color: var(--sky-navy);
            line-height: 1.3;
        }

        .ticket-subtitle {
            color: var(--sky-muted);
            margin-top: 7px;
            font-size: 15px;
        }

        .ticket-label {
            display: inline-block;
            margin-top: 14px;
            padding: 7px 13px;
            background: #EAF4FF;
            color: var(--sky-deep-blue);
            border-radius: var(--sky-radius-sm);
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1px;
        }

        .ticket-logo {
            font-family: "Manrope", sans-serif;
            font-size: 23px;
            font-weight: 800;
            color: var(--sky-deep-blue);
            white-space: nowrap;
        }

        .ticket-logo span {
            color: var(--sky-blue);
        }

        /* =====================================
           PNR AND BOOKING STATUS
        ===================================== */

        .booking-overview {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            margin: 28px 0 34px;
        }

        .pnr-box {
            background: #EFF6FF;
            border: 1px solid #D6E7FF;
            border-radius: var(--sky-radius-md);
            padding: 16px 22px;
            min-width: 230px;
            max-width: 100%;
        }

        .field-label {
            display: block;
            font-size: 13px;
            color: var(--sky-muted);
            margin-bottom: 5px;
        }

        .pnr-value {
            color: var(--sky-deep-blue);
            font-family: "Manrope", sans-serif;
            font-size: 29px;
            font-weight: 800;
            letter-spacing: 3px;
            overflow-wrap: anywhere;
        }

        .status-wrapper {
            text-align: right;
        }

        .status-badge {
            display: inline-block;
            padding: 8px 17px;
            border-radius: 50px;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.5px;
        }

        .status-confirmed {
            color: #08784E;
            background: #DDF8EB;
        }

        .status-cancelled {
            color: #B4232B;
            background: #FFE3E3;
        }

        .status-other {
            color: var(--sky-deep-blue);
            background: #EAF4FF;
        }

        /* =====================================
           SECTION HEADINGS
        ===================================== */

        .section {
            margin-top: 30px;
        }

        .section-title {
            font-family: "Manrope", sans-serif;
            font-size: 20px;
            font-weight: 800;
            color: var(--sky-navy);
            padding-bottom: 10px;
            margin-bottom: 18px;
            border-bottom: 1px solid var(--sky-border);
        }

        /* =====================================
           FLIGHT ROUTE
        ===================================== */

        .route-section {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr);
            align-items: center;
            gap: 20px;
            padding: 25px;
            background: #F8FAFC;
            border: 1px solid var(--sky-border);
            border-radius: var(--sky-radius-md);
        }

        .route-city:last-child {
            text-align: right;
        }

        .route-city strong {
            display: block;
            font-family: "Manrope", sans-serif;
            font-size: 25px;
            color: var(--sky-deep-blue);
            overflow-wrap: anywhere;
        }

        .route-arrow {
            text-align: center;
            color: var(--sky-blue);
        }

        .plane-icon {
            font-size: 32px;
            display: block;
        }

        .route-line {
            width: 45px;
            height: 2px;
            margin: 7px auto 0;
            background: var(--sky-cyan);
        }

        /* =====================================
           BOOKING DETAILS GRID
        ===================================== */

        .details-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }

        .detail-item {
            padding: 17px 20px;
            background: #F0F6FF;
            border: 1px solid #D9E7FF;
            border-radius: var(--sky-radius-sm);
            min-width: 0;
        }

        .detail-value {
            display: block;
            font-family: "Manrope", sans-serif;
            color: var(--sky-navy);
            font-size: 17px;
            font-weight: 800;
            overflow-wrap: anywhere;
        }

        /* =====================================
           TOTAL FARE
        ===================================== */

        .fare-box {
            margin-top: 28px;
            padding: 20px 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            background: var(--sky-deep-blue);
            color: var(--sky-white);
            border-radius: var(--sky-radius-md);
        }

        .fare-label {
            font-size: 15px;
            font-weight: 600;
        }

        .fare-value {
            font-family: "Manrope", sans-serif;
            font-size: 27px;
            font-weight: 800;
            overflow-wrap: anywhere;
        }

        /* =====================================
           MESSAGES
        ===================================== */

        .message {
            margin-top: 25px;
            padding: 18px 20px;
            border-radius: var(--sky-radius-sm);
            border: 1px solid;
            overflow-wrap: anywhere;
        }

        .message strong {
            display: block;
            margin-bottom: 4px;
        }

        .message p + p {
            margin-top: 15px;
        }

        .message-cancelled,
        .message-error {
            background: #FFF2F2;
            border-color: #FFBFC2;
            color: #B4232B;
        }

        .message-confirmed {
            background: #EAFBF3;
            border-color: #A8E7CA;
            color: #08784E;
        }

        .message-info {
            background: #EFF6FF;
            border-color: #C7DFFF;
            color: var(--sky-deep-blue);
        }

        /* =====================================
           BUTTONS
        ===================================== */

        .action-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 14px;
            margin-top: 28px;
        }

        .sky-primary-button,
        .sky-secondary-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 13px 22px;
            min-height: 48px;
            font-size: 14px;
            font-weight: 800;
            border-radius: var(--sky-radius-sm);
            cursor: pointer;
            transition:
                transform var(--sky-transition),
                box-shadow var(--sky-transition),
                background var(--sky-transition);
        }

        .sky-primary-button {
            background: var(--sky-blue);
            color: var(--sky-white);
            border: 1px solid transparent;
        }

        .sky-primary-button:hover {
            background: var(--sky-deep-blue);
            transform: translateY(-2px);
            box-shadow: var(--sky-shadow);
        }

        .sky-secondary-button {
            background: var(--sky-deep-blue);
            color: var(--sky-white);
            border: 1px solid transparent;
        }

        .sky-secondary-button:hover {
            background: var(--sky-navy);
            transform: translateY(-2px);
            box-shadow: var(--sky-shadow);
        }

        /* =====================================
           FOOTER
        ===================================== */

        .ticket-footer {
            margin-top: 32px;
            padding-top: 20px;
            border-top: 1px dashed var(--sky-border);
            text-align: center;
            color: var(--sky-muted);
            font-size: 12px;
        }

        .ticket-footer strong {
            display: block;
            color: var(--sky-deep-blue);
            letter-spacing: 1px;
            margin-bottom: 6px;
        }

        /* =====================================
           RESPONSIVE DESIGN
        ===================================== */

        @media (max-width: 600px) {
            .page-container {
                width: 94%;
                margin: 20px auto;
            }

            .ticket-card {
                padding: 20px 16px;
            }

            .ticket-header {
                align-items: flex-start;
            }

            .ticket-logo {
                display: none;
            }

            .booking-overview {
                align-items: flex-start;
                flex-direction: column;
            }

            .pnr-box {
                width: 100%;
                min-width: 0;
            }

            .status-wrapper {
                text-align: left;
            }

            .route-section {
                gap: 10px;
                padding: 18px 12px;
            }

            .route-city strong {
                font-size: 19px;
            }

            .plane-icon {
                font-size: 25px;
            }

            .route-line {
                width: 25px;
            }

            .details-grid {
                grid-template-columns: 1fr;
                gap: 12px;
            }

            .detail-item {
                padding: 14px;
            }

            .fare-box {
                padding: 17px;
                flex-wrap: wrap;
            }

            .fare-value {
                font-size: 23px;
            }

            .action-buttons {
                flex-direction: column;
            }

            .sky-primary-button,
            .sky-secondary-button {
                width: 100%;
            }
        }

        /* =====================================
           PRINT / SAVE AS PDF
        ===================================== */

        @media print {
            @page {
                size: A4 portrait;
                margin: 10mm;
            }

            html,
            body {
                background: white !important;
                color: #172B45 !important;
                margin: 0 !important;
                padding: 0 !important;
                font-size: 10pt;
                print-color-adjust: exact;
                -webkit-print-color-adjust: exact;
            }

            .navbar {
                padding: 10px 0;
                background: var(--sky-navy) !important;
                print-color-adjust: exact;
                -webkit-print-color-adjust: exact;
            }

            .nav-container {
                width: 100%;
            }

            .page-container {
                width: 100%;
                max-width: none;
                margin: 12px auto;
            }

            .ticket-card {
                padding: 18px;
                box-shadow: none !important;
                border: 1px solid var(--sky-border);
                border-radius: 0;
            }

            .section {
                margin-top: 18px;
            }

            .section-title {
                margin-bottom: 10px;
                font-size: 15px;
            }

            .booking-overview {
                margin: 16px 0 20px;
            }

            .pnr-box {
                padding: 10px 14px;
            }

            .pnr-value {
                font-size: 23px;
            }

            .route-section {
                padding: 15px;
            }

            .route-city strong {
                font-size: 20px;
            }

            .details-grid {
                gap: 9px;
            }

            .detail-item {
                padding: 10px 12px;
                break-inside: avoid;
                page-break-inside: avoid;
            }

            .detail-value {
                font-size: 13px;
            }

            .fare-box {
                margin-top: 16px;
                padding: 14px 18px;
                break-inside: avoid;
                page-break-inside: avoid;
            }

            .fare-value {
                font-size: 22px;
            }

            .message {
                margin-top: 15px;
                padding: 12px 14px;
                break-inside: avoid;
                page-break-inside: avoid;
            }

            .ticket-footer {
                margin-top: 18px;
                padding-top: 12px;
            }

            .no-print {
                display: none !important;
            }

            .sky-card {
                box-shadow: none !important;
            }
        }
    </style>
</head>

<body>

    <!-- NAVIGATION -->
    <nav class="navbar no-print">
        <div class="nav-container">
            <a class="navbar-brand" href="<%= contextPath %>/index.html">
                SKYPORT <span>✈</span>
            </a>

            <span class="nav-tagline">
                Your journey, made simple.
            </span>
        </div>
    </nav>

    <main class="page-container">
        <div class="sky-card ticket-card">

            <% if (booking == null) { %>

                <!-- NO BOOKING FOUND -->
                <header class="ticket-header">
                    <div>
                        <h1 class="sky-heading">Booking Details</h1>

                        <p class="ticket-subtitle">
                            Find your SkyPort reservation.
                        </p>
                    </div>

                    <div class="ticket-logo">
                        SKYPORT <span>✈</span>
                    </div>
                </header>

                <div class="message message-error">
                    <strong>Booking Not Available</strong>

                    <p>
                        <%= escapeHtml(error != null
                            ? error
                            : "No booking details were found. Please search using a valid PNR number.") %>
                    </p>
                </div>

                <!-- SEARCH FORM -->
                <section class="section no-print">
                    <h2 class="section-title">Find Your Booking</h2>

                    <form action="<%= contextPath %>/search-booking"
                          method="post">

                        <label for="pnr" class="field-label">
                            Enter your PNR number
                        </label>

                        <input
                            type="text"
                            id="pnr"
                            name="pnr"
                            value="<%= escapeHtml(searchedPNR) %>"
                            placeholder="Enter booking reference"
                            maxlength="30"
                            required
                            style="width:100%;padding:13px 15px;border:1px solid var(--sky-border);border-radius:8px;margin-bottom:15px;">

                        <div class="action-buttons">
                            <button type="submit"
                                    class="sky-primary-button">
                                Search Booking
                            </button>

                            <a class="sky-secondary-button"
                               href="<%= contextPath %>/index.html">
                                Back to Home
                            </a>
                        </div>
                    </form>
                </section>

            <% } else { %>

                <!-- TICKET HEADER -->
                <header class="ticket-header">
                    <div>
                        <h1 class="sky-heading">Electronic Ticket</h1>

                        <p class="ticket-subtitle">
                            Your SkyPort booking information
                        </p>

                        <span class="ticket-label">
                            E-TICKET / BOOKING RECORD
                        </span>
                    </div>

                    <div class="ticket-logo">
                        SKYPORT <span>✈</span>
                    </div>
                </header>

                <!-- PNR AND STATUS -->
                <section class="booking-overview">
                    <div class="pnr-box">
                        <span class="field-label">
                            PNR / Booking Reference
                        </span>

                        <div class="pnr-value">
                            <%= escapeHtml(booking.getPnr()) %>
                        </div>
                    </div>

                    <div class="status-wrapper">
                        <span class="field-label">Booking Status</span>

                        <% if (cancelled) { %>
                            <span class="status-badge status-cancelled">
                                CANCELLED
                            </span>
                        <% } else if (confirmed) { %>
                            <span class="status-badge status-confirmed">
                                CONFIRMED
                            </span>
                        <% } else { %>
                            <span class="status-badge status-other">
                                <%= escapeHtml(status.isEmpty()
                                    ? "UNKNOWN" : status) %>
                            </span>
                        <% } %>
                    </div>
                </section>

                <!-- FLIGHT INFORMATION -->
                <section class="section">
                    <h2 class="section-title">Flight Information</h2>

                    <div class="route-section">
                        <div class="route-city">
                            <span class="field-label">FROM</span>

                            <strong>
                                <%= escapeHtml(booking.getSource()) %>
                            </strong>
                        </div>

                        <div class="route-arrow">
                            <span class="plane-icon">✈</span>
                            <div class="route-line"></div>
                        </div>

                        <div class="route-city">
                            <span class="field-label">TO</span>

                            <strong>
                                <%= escapeHtml(booking.getDestination()) %>
                            </strong>
                        </div>
                    </div>
                </section>

                <!-- PASSENGER AND BOOKING DETAILS -->
                <section class="section">
                    <h2 class="section-title">
                        Passenger and Booking Details
                    </h2>

                    <div class="details-grid">
                        <div class="detail-item">
                            <span class="field-label">Passenger Name</span>

                            <span class="detail-value">
                                <%= escapeHtml(booking.getPassengerName()) %>
                            </span>
                        </div>

                        <div class="detail-item">
                            <span class="field-label">Flight Number</span>

                            <span class="detail-value">
                                <%= escapeHtml(booking.getFlightNumber()) %>
                            </span>
                        </div>

                        <div class="detail-item">
                            <span class="field-label">Departure Date</span>

                            <span class="detail-value">
                                <%= booking.getDepartureDate() == null
                                    ? "Not available"
                                    : booking.getDepartureDate() %>
                            </span>
                        </div>

                        <div class="detail-item">
                            <span class="field-label">Departure Time</span>

                            <span class="detail-value">
                                <%= booking.getDepartureTime() == null
                                    ? "Not available"
                                    : booking.getDepartureTime() %>
                            </span>
                        </div>

                        <div class="detail-item">
                            <span class="field-label">Booking Reference</span>

                            <span class="detail-value">
                                <%= escapeHtml(booking.getPnr()) %>
                            </span>
                        </div>

                        <div class="detail-item">
                            <span class="field-label">Ticket Status</span>

                            <span class="detail-value">
                                <%= escapeHtml(status.isEmpty()
                                    ? "UNKNOWN" : status) %>
                            </span>
                        </div>
                    </div>
                </section>

                <!-- TOTAL FARE -->
                <section class="fare-box">
                    <span class="fare-label">Total Ticket Fare</span>

                    <span class="fare-value">
                        &#8377;
                        <%= booking.getTotalAmount() == null
                            ? "0.00"
                            : String.format(
                                java.util.Locale.US,
                                "%.2f",
                                booking.getTotalAmount()) %>
                    </span>
                </section>

                <!-- BOOKING STATUS MESSAGE -->
                <% if (cancelled) { %>

                    <div class="message message-cancelled">
                        <strong>Booking Cancelled</strong>

                        <p>
                            This booking has been cancelled.
                            This document is a cancellation record
                            and must not be used as a valid travel ticket.
                        </p>

                        <p>
                            Refund eligibility and refund amount
                            must be verified separately.
                        </p>
                    </div>

                <% } else if (confirmed) { %>

                    <div class="message message-confirmed">
                        <strong>Booking Confirmed</strong>

                        <p>
                            Your reservation is confirmed.
                            Please verify your flight details before travelling.
                        </p>
                    </div>

                <% } else { %>

                    <div class="message message-info">
                        <strong>Booking Information</strong>

                        <p>
                            Please verify the current status of this booking
                            before making travel arrangements.
                        </p>
                    </div>

                <% } %>

                <!-- ACTION BUTTONS -->
                <div class="action-buttons no-print">
                    <a class="sky-secondary-button"
                       href="<%= contextPath %>/index.html">
                        Back to Home
                    </a>

                    <button type="button"
                            class="sky-primary-button"
                            onclick="window.print()">
                        Print / Download E-Ticket
                    </button>
                </div>

                <!-- FOOTER -->
                <footer class="ticket-footer">
                    <strong>SKYPORT — ELECTRONIC TICKET</strong>

                    <p>
                        Please verify your booking details before travel.
                    </p>

                    <p>
                        This document is generated by the SkyPort
                        student project and is not an official airline-issued
                        ticket or boarding pass.
                    </p>
                </footer>

            <% } %>

        </div>
    </main>

</body>
</html>