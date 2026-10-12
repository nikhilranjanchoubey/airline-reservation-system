<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.skyport.util.DBConnection" %>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>SkyPort | Booking History</title>

<style>
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #f0f4fb;
    color: #172b4d;
}

.navbar {
    background: #073b75;
    color: white;
    padding: 22px 6%;
    font-size: 25px;
    font-weight: bold;
}

.container {
    max-width: 1200px;
    margin: 35px auto;
    padding: 25px;
    background: white;
    border-radius: 14px;
    box-shadow: 0 5px 20px rgba(0,0,0,0.08);
}

h1 {
    color: #073b75;
    margin-bottom: 8px;
}

.subtitle {
    color: #64748b;
    margin-bottom: 25px;
}

.table-wrapper {
    width: 100%;
    overflow-x: auto;
}

table {
    width: 100%;
    border-collapse: collapse;
    min-width: 950px;
}

th {
    background: #073b75;
    color: white;
    padding: 14px 12px;
    text-align: left;
    white-space: nowrap;
}

td {
    padding: 13px 12px;
    border-bottom: 1px solid #e2e8f0;
    white-space: nowrap;
}

tbody tr:hover {
    background: #f1f6ff;
}

.status {
    display: inline-block;
    padding: 6px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: bold;
}

.confirmed {
    background: #dcfce7;
    color: #166534;
}

.cancelled {
    background: #fee2e2;
    color: #b91c1c;
}

.other {
    background: #fef3c7;
    color: #92400e;
}

.button {
    display: inline-block;
    margin-top: 25px;
    padding: 12px 22px;
    background: #073b75;
    color: white;
    text-decoration: none;
    border-radius: 7px;
    font-weight: bold;
}

.button:hover {
    background: #1769aa;
}

.message {
    padding: 18px;
    background: #fff7ed;
    color: #9a3412;
    border-radius: 8px;
    margin-top: 20px;
}

@media (max-width: 600px) {
    .container {
        margin: 15px;
        padding: 15px;
    }
}
</style>
</head>

<body>

<div class="navbar">
    SKYPORT ✈
</div>

<div class="container">

    <h1>My Booking History</h1>

    <p class="subtitle">
        View all bookings and check their current status.
    </p>

    <%
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet rs = null;

        boolean hasBookings = false;

        try {
            connection = DBConnection.getConnection();

            String sql =
                "SELECT booking_id, pnr, passenger_name, flight_number, " +
                "source, destination, departure_date, departure_time, " +
                "total_amount, booking_status " +
                "FROM bookings ORDER BY booking_id DESC";

            statement = connection.prepareStatement(sql);
            rs = statement.executeQuery();
    %>

    <div class="table-wrapper">

        <table>
            <thead>
                <tr>
                    <th>PNR</th>
                    <th>Passenger</th>
                    <th>Flight</th>
                    <th>From</th>
                    <th>To</th>
                    <th>Departure Date</th>
                    <th>Departure Time</th>
                    <th>Fare</th>
                    <th>Status</th>
                </tr>
            </thead>

            <tbody>

            <%
                while (rs.next()) {
                    hasBookings = true;

                    String status = rs.getString("booking_status");

                    String statusClass = "other";

                    if ("CONFIRMED".equalsIgnoreCase(status)) {
                        statusClass = "confirmed";
                    } else if ("CANCELLED".equalsIgnoreCase(status)) {
                        statusClass = "cancelled";
                    }
            %>

                <tr>
                    <td><strong><%= rs.getString("pnr") %></strong></td>

                    <td><%= rs.getString("passenger_name") %></td>

                    <td><%= rs.getString("flight_number") %></td>

                    <td><%= rs.getString("source") %></td>

                    <td><%= rs.getString("destination") %></td>

                    <td><%= rs.getDate("departure_date") %></td>

                    <td><%= rs.getTime("departure_time") %></td>

                    <td>
                        &#8377; <%= rs.getBigDecimal("total_amount") %>
                    </td>

                    <td>
                        <span class="status <%= statusClass %>">
                            <%= status %>
                        </span>
                    </td>
                </tr>

            <%
                }

                if (!hasBookings) {
            %>

                <tr>
                    <td colspan="9">No bookings found.</td>
                </tr>

            <%
                }
            %>

            </tbody>
        </table>

    </div>

    <%
        } catch (SQLException e) {
            application.log("Unable to load booking history", e);
    %>

        <div class="message">
            Unable to load booking history.
            Please check the database connection and table structure.
        </div>

    <%
        } finally {
            try {
                if (rs != null) rs.close();
            } catch (SQLException e) {
                application.log("Error closing result set", e);
            }

            try {
                if (statement != null) statement.close();
            } catch (SQLException e) {
                application.log("Error closing statement", e);
            }

            try {
                if (connection != null) connection.close();
            } catch (SQLException e) {
                application.log("Error closing connection", e);
            }
        }
    %>

    <a href="index.html" class="button">← Back to Home</a>

</div>

</body>
</html>