<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.skyport.model.Booking" %>
<%@ page import="java.math.BigDecimal" %>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>SkyPort | Electronic Ticket</title>

    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            --primary: #1769c2;
            --dark-blue: #103968;
            --light-blue: #eaf3ff;
            --background: #f4f7fb;
            --white: #ffffff;
            --text: #263238;
            --muted: #718096;
            --border: #e2eaf4;
            --green: #15803d;
            --red: #b91c1c;
        }

        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background: var(--background);
            color: var(--text);
            min-height: 100vh;
        }

        /* Navigation */

        .navbar {
            background: var(--dark-blue);
            color: white;
            padding: 18px 7%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
        }

        .logo {
            font-size: 25px;
            font-weight: 800;
            letter-spacing: 0.5px;
            color: white;
            text-decoration: none;
        }

        .nav-label {
            font-size: 12px;
            color: #d7e7ff;
            text-align: right;
            letter-spacing: 0.5px;
        }

        /* Main page */

        .page {
            width: 92%;
            max-width: 950px;
            margin: 40px auto;
        }

        .ticket {
            background: white;
            border-radius: 18px;
            overflow: hidden;
            box-shadow: 0 12px 40px rgba(15, 50, 90, 0.12);
        }

        .ticket-header {
            background: linear-gradient(120deg, #0b3b70, #176fc0);
            color: white;
            padding: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
        }

        .ticket-header h1 {
            font-size: 27px;
            margin-bottom: 8px;
        }

        .ticket-header p {
            color: #dceaff;
            font-size: 14px;
            line-height: 1.6;
        }

        .ticket-label {
            border: 1px solid rgba(255, 255, 255, 0.5);
            padding: 10px 13px;
            border-radius: 8px;
            font-size: 11px;
            font-weight: bold;
            white-space: nowrap;
        }

        .ticket-body {
            padding: 30px;
        }

        /* PNR and status */

        .booking-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 18px;
            flex-wrap: wrap;
            margin-bottom: 28px;
        }

        .small-label {
            font-size: 12px;
            color: var(--muted);
            margin-bottom: 7px;
        }

        .pnr {
            font-size: 27px;
            font-weight: 800;
            letter-spacing: 3px;
            color: var(--dark-blue);
            overflow-wrap: anywhere;
        }

        .status {
            display: inline-block;
            padding: 9px 15px;
            border-radius: 30px;
            font-size: 12px;
            font-weight: 800;
        }

        .confirmed {
            background: #dcfce7;
            color: var(--green);
        }

        .cancelled {
            background: #fee2e2;
            color: var(--red);
        }

        .other-status {
            background: #fef3c7;
            color: #92400e;
        }

        /* Flight route */

        .section-title {
            font-size: 16px;
            font-weight: 800;
            margin: 25px 0 15px;
            padding-bottom: 12px;
            border-bottom: 1px solid var(--border);
            color: var(--dark-blue);
        }

        .route {
            background: #f4f8fe;
            border: 1px solid #e1eaf7;
            border-radius: 12px;
            padding: 24px;
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr);
            align-items: center;
            gap: 20px;
        }

        .city {
            font-size: 24px;
            font-weight: 800;
            margin-top: 7px;
            overflow-wrap: anywhere;
            color: var(--dark-blue);
        }

        .airplane {
            font-size: 27px;
            color: var(--primary);
        }

        .right {
            text-align: right;
        }

        /* Booking details */

        .details-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 15px;
        }

        .detail {
            background: #f2f6fd;
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 17px;
            min-width: 0;
        }

        .detail-label {
            color: var(--muted);
            font-size: 12px;
            margin-bottom: 9px;
        }

        .detail-value {
            color: var(--dark-blue);
            font-size: 16px;
            font-weight: 750;
            overflow-wrap: anywhere;
        }

        /* Fare */

        .fare {
            margin-top: 22px;
            background: var(--dark-blue);
            color: white;
            border-radius: 10px;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
        }

        .fare-label {
            font-size: 13px;
        }

        .fare-amount {
            font-size: 25px;
            font-weight: 800;
            overflow-wrap: anywhere;
        }

        /* Messages */

        .notice {
            margin-top: 20px;
            background: #effcf4;
            border: 1px solid #bbf7d0;
            color: #166534;
            padding: 17px;
            border-radius: 10px;
            font-size: 13px;
            line-height: 1.8;
        }

        .notice-error {
            background: #fff1f2;
            border-color: #fecdd3;
            color: #9f1239;
        }

        .notice-warning {
            background: #fffbeb;
            border-color: #fde68a;
            color: #92400e;
        }

        /* Buttons */

        .actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 25px;
            align-items: center;
        }

        .btn {
            border: none;
            border-radius: 8px;
            padding: 13px 18px;
            font-size: 14px;
            font-weight: 750;
            text-decoration: none;
            text-align: center;
            cursor: pointer;
            transition: 0.2s;
            display: inline-block;
            font-family: inherit;
        }

        .btn:hover {
            transform: translateY(-2px);
            opacity: 0.92;
        }

        .btn-home {
            background: var(--dark-blue);
            color: white;
        }

        .btn-print {
            background: var(--primary);
            color: white;
        }

        .btn-cancel {
            background: #dc3545;
            color: white;
        }

        .btn-disabled {
            background: #e5e7eb;
            color: #6b7280;
            cursor: not-allowed;
        }

        .ticket-footer {
            border-top: 1px dashed #cad7e8;
            padding: 22px;
            text-align: center;
            color: #78879b;
            font-size: 11px;
            line-height: 1.8;
        }

        /* Error page */

        .error-box {
            background: white;
            padding: 40px 30px;
            border-radius: 15px;
            box-shadow: 0 8px 30px rgba(15, 50, 90, 0.08);
            text-align: center;
        }

        .error-icon {
            font-size: 48px;
            margin-bottom: 15px;
        }

        .error-box h2 {
            margin-bottom: 15px;
            color: var(--dark-blue);
        }

        .error-box p {
            margin-bottom: 20px;
            color: #64748b;
            line-height: 1.8;
        }

        .error-message {
            background: #fff1f2;
            color: #9f1239;
            border: 1px solid #fecdd3;
            padding: 12px;
            border-radius: 8px;
            margin: 15px 0 22px;
            overflow-wrap: anywhere;
        }

        /* Responsive */

        @media (max-width: 600px) {
            .navbar {
                padding: 16px 5%;
            }

            .logo {
                font-size: 21px;
            }

            .nav-label {
                font-size: 10px;
            }

            .page {
                width: 95%;
                margin: 20px auto;
            }

            .ticket-header,
            .ticket-body {
                padding: 20px;
            }

            .ticket-header {
                align-items: flex-start;
                flex-direction: column;
            }

            .ticket-header h1 {
                font-size: 23px;
            }

            .ticket-label {
                white-space: normal;
            }

            .details-grid {
                grid-template-columns: 1fr;
            }

            .city {
                font-size: 18px;
            }

            .route {
                padding: 16px;
                gap: 10px;
            }

            .airplane {
                font-size: 21px;
            }

            .fare-amount {
                font-size: 20px;
            }

            .btn {
                width: 100%;
            }

            .actions form {
                width: 100%;
            }
        }

        /* Print */

        @media print {
            body {
                background: white;
                color: black;
            }

            .navbar,
            .actions {
                display: none !important;
            }

            .page {
                width: 100%;
                max-width: none;
                margin: 0;
            }

            .ticket {
                box-shadow: none;
                border: 1px solid #ddd;
            }

            .ticket-header,
            .fare {
                print-color-adjust: exact;
                -webkit-print-color-adjust: exact;
            }
        }
    </style>
</head>

<body>

<header class="navbar">

    <a class="logo"
       href="<%= request.getContextPath() %>/index.html">
        ✈ SkyPort
    </a>

    <div class="nav-label">
        YOUR JOURNEY, OUR PRIORITY
    </div>

</header>

<main class="page">

<%
    Booking booking = (Booking) request.getAttribute("booking");

    String error = (String) request.getAttribute("error");

    String pnr = (String) request.getAttribute("searchedPNR");

    if (pnr == null) {
        pnr = request.getParameter("pnr");
    }

    if (pnr == null) {
        pnr = "";
    }

    String status = null;
    boolean isConfirmed = false;
    boolean isCancelled = false;

    if (booking != null) {
        status = booking.getBookingStatus();

        isConfirmed = status != null
                && "CONFIRMED".equalsIgnoreCase(status);

        isCancelled = status != null
                && "CANCELLED".equalsIgnoreCase(status);
    }
%>

<% if (booking != null) { %>

    <!-- Ticket -->

    <div class="ticket">

        <div class="ticket-header">

            <div>
                <h1>Electronic Ticket</h1>

                <p>
                    Your SkyPort booking information
                </p>
            </div>

            <div class="ticket-label">
                E-TICKET / BOOKING RECORD
            </div>

        </div>

        <div class="ticket-body">

            <!-- PNR and status -->

            <div class="booking-top">

                <div>
                    <div class="small-label">
                        PNR / BOOKING REFERENCE
                    </div>

                    <div class="pnr">
                        <%= booking.getPnr() == null
                                ? "N/A" : booking.getPnr() %>
                    </div>
                </div>

                <div>
                    <div class="small-label">
                        BOOKING STATUS
                    </div>

                    <span class="status <%= isConfirmed
                            ? "confirmed"
                            : (isCancelled ? "cancelled" : "other-status") %>">

                        <%= status == null ? "UNKNOWN" : status %>

                    </span>
                </div>

            </div>

            <!-- Route -->

            <div class="section-title">
                ✈ Flight Information
            </div>

            <div class="route">

                <div>

                    <div class="small-label">
                        FROM
                    </div>

                    <div class="city">
                        <%= booking.getSource() == null
                                ? "N/A" : booking.getSource() %>
                    </div>

                    <div class="small-label">
                        Departure city
                    </div>

                </div>

                <div class="airplane">
                    ✈
                </div>

                <div class="right">

                    <div class="small-label">
                        TO
                    </div>

                    <div class="city">
                        <%= booking.getDestination() == null
                                ? "N/A" : booking.getDestination() %>
                    </div>

                    <div class="small-label">
                        Arrival city
                    </div>

                </div>

            </div>

            <!-- Passenger details -->

            <div class="section-title">
                Passenger and Booking Details
            </div>

            <div class="details-grid">

                <div class="detail">

                    <div class="detail-label">
                        Passenger Name
                    </div>

                    <div class="detail-value">
                        <%= booking.getPassengerName() == null
                                ? "N/A" : booking.getPassengerName() %>
                    </div>

                </div>

                <div class="detail">

                    <div class="detail-label">
                        Flight Number
                    </div>

                    <div class="detail-value">
                        <%= booking.getFlightNumber() == null
                                ? "N/A" : booking.getFlightNumber() %>
                    </div>

                </div>

                <div class="detail">

                    <div class="detail-label">
                        Departure Date
                    </div>

                    <div class="detail-value">
                        <%= booking.getDepartureDate() == null
                                ? "N/A" : booking.getDepartureDate() %>
                    </div>

                </div>

                <div class="detail">

                    <div class="detail-label">
                        Departure Time
                    </div>

                    <div class="detail-value">
                        <%= booking.getDepartureTime() == null
                                ? "N/A" : booking.getDepartureTime() %>
                    </div>

                </div>

                <div class="detail">

                    <div class="detail-label">
                        Booking Reference
                    </div>

                    <div class="detail-value">
                        <%= booking.getPnr() == null
                                ? "N/A" : booking.getPnr() %>
                    </div>

                </div>

                <div class="detail">

                    <div class="detail-label">
                        Ticket Status
                    </div>

                    <div class="detail-value">
                        <%= status == null ? "UNKNOWN" : status %>
                    </div>

                </div>

            </div>

            <!-- Fare -->

            <div class="fare">

                <div class="fare-label">
                    TOTAL TICKET FARE
                </div>

                <div class="fare-amount">
                    ₹ <%= booking.getTotalAmount() == null
                            ? "0.00" : booking.getTotalAmount() %>
                </div>

            </div>

            <!-- Status message -->

            <% if (isConfirmed) { %>

                <div class="notice">

                    <strong>✓ Booking Confirmed</strong>
                    <br>

                    Your booking is confirmed in the SkyPort application.
                    Keep this e-ticket for your reference.

                    <br><br>

                    <strong>Note:</strong>
                    This is an application-generated ticket record,
                    not an airline-issued boarding pass.

                </div>

            <% } else if (isCancelled) { %>

                <div class="notice notice-error">

                    <strong>Booking Cancelled</strong>
                    <br>

                    This reservation has been cancelled.
                    The ticket cannot be cancelled again.

                </div>

            <% } else { %>

                <div class="notice notice-warning">

                    <strong>Booking Status: <%= status == null
                            ? "UNKNOWN" : status %></strong>
                    <br>

                    Please contact the administrator to confirm
                    the status of this booking.

                </div>

            <% } %>

            <!-- Actions -->

            <div class="actions">

                <a class="btn btn-home"
                   href="<%= request.getContextPath() %>/index.html">

                    ← Back to Home

                </a>

                <button type="button"
                        class="btn btn-print"
                        onclick="window.print()">

                    Print / Download E-Ticket

                </button>

                <% if (isConfirmed) { %>

                    <form
                        action="<%= request.getContextPath() %>/cancel-booking"
                        method="post"
                        onsubmit="return confirm('Are you sure you want to cancel this ticket?');">

                        <input
                            type="hidden"
                            name="pnr"
                            value="<%= booking.getPnr() == null
                                    ? "" : booking.getPnr() %>">

                        <button type="submit"
                                class="btn btn-cancel">

                            Cancel Ticket

                        </button>

                    </form>

                <% } else if (isCancelled) { %>

                    <button type="button"
                            class="btn btn-disabled"
                            disabled>

                        Ticket Cancelled

                    </button>

                <% } %>

            </div>

        </div>

        <div class="ticket-footer">

            SKYPORT — ELECTRONIC TICKET
            <br>

            Please verify your booking details before travel.
            <br>

            This document is generated by the SkyPort student project.

        </div>

    </div>

<% } else { %>

    <!-- Booking not found or search error -->

    <div class="error-box">

        <div class="error-icon">
            ✈️
        </div>

        <h2>Booking Details Unavailable</h2>

        <p>
            We couldn't display your booking details.
            Please verify your PNR and try again.
        </p>

        <% if (error != null && !error.trim().isEmpty()) { %>

            <div class="error-message">
                <%= error %>
            </div>

        <% } %>

        <a href="<%= request.getContextPath() %>/index.html#pnr-search"
           class="btn btn-home">

            Search Booking Again

        </a>

    </div>

<% } %>

</main>

</body>
</html>