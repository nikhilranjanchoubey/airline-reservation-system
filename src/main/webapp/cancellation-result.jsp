<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>SkyPort - Cancellation Result</title>

<style>
    * {
        box-sizing: border-box;
    }

    body {
        margin: 0;
        padding: 30px 15px;
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        background: #f0f5fc;
        font-family: Arial, sans-serif;
        color: #103b70;
    }

    .card {
        width: 100%;
        max-width: 750px;
        padding: 45px 35px;
        background: white;
        border-radius: 18px;
        text-align: center;
        box-shadow: 0 10px 35px rgba(0, 0, 0, 0.08);
    }

    .logo {
        font-size: 36px;
        font-weight: bold;
        margin-bottom: 25px;
        color: #0b3d78;
    }

    h1 {
        font-size: 28px;
        margin-bottom: 25px;
    }

    .message {
        padding: 20px;
        margin: 25px 0;
        border-radius: 10px;
        background: #eaf2ff;
        font-size: 18px;
        line-height: 1.6;
        overflow-wrap: anywhere;
    }

    .pnr {
        margin: 25px 0;
        font-size: 18px;
    }

    .button {
        display: inline-block;
        padding: 14px 28px;
        margin-top: 15px;
        background: #0b3d78;
        color: white;
        text-decoration: none;
        border-radius: 7px;
        font-size: 17px;
    }

    .button:hover {
        background: #082d59;
    }

    @media (max-width: 480px) {
        .card {
            padding: 30px 18px;
        }

        h1 {
            font-size: 23px;
        }
    }
</style>
</head>

<body>

<div class="card">

    <div class="logo">SkyPort ✈</div>

    <h1>Ticket Cancellation Result</h1>

    <div class="message">
        <%= request.getAttribute("message") != null
            ? request.getAttribute("message")
            : "No cancellation result is available. Please search for your booking again." %>
    </div>

    <%
        String pnr = (String) request.getAttribute("pnr");

        if (pnr != null && !pnr.trim().isEmpty()) {
    %>

        <div class="pnr">
            PNR Number: <strong><%= pnr %></strong>
        </div>

    <%
        }
    %>

    <a class="button" href="index.html">Back to Home</a>

</div>

</body>
</html>