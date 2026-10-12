# SKYTECH Airlines — Architecture & Design Specification

## 1. Architectural Pattern: Model-View-Controller (MVC)

Module 3 strictly adheres to classic Enterprise Java MVC architecture:
- **Model**: Java POJO classes representing entities (`Booking`, `Passenger`, `SeatAllocation`, `Payment`, `FareBreakdown`) located in `com.skytech.airlines.booking.model`.
- **View**: JavaServer Pages (JSP) using Bootstrap 5 and dedicated design tokens (`assets/css/booking.css`). JSP files contain **zero SQL queries and zero business logic**.
- **Controller**: Java Servlets (`javax.servlet.http.HttpServlet`) handling HTTP requests, input parameter validation, error routing, and dispatching.
- **Service Layer**: Business rules, transactional boundaries, authoritative fare calculation, and Razorpay HMAC-SHA256 crypto.
- **Data Access Layer (DAO)**: Pure JDBC operations using `PreparedStatement` and connection lifecycle management.

## 2. State Machine: Booking & Payment Lifecycle

```
[User Selects Flight]
          │
          ▼
[Enter Passenger Details] ──(Validates Demographics & Contact)──> [Valid Roster]
          │
          ▼
[Seat Map Interactive Selection] ──(Checks 180 Cabin Seats & Locks)──> [Seats Selected]
          │
          ▼
[Booking Review] ──(Authoritative Server Fare Calculation)──> [Pending Booking Created]
          │                                                  │
          ▼                                                  ▼
   [Payment Page] <───────────────────────────── (Booking: PENDING, Seats: HELD)
          │                                       (15-Minute Expiry Window)
          ▼
   [Razorpay Standard Checkout]
          │
    ┌─────┴────────────────┐
    ▼                      ▼
[Payment Cancelled]    [Payment Captured]
(Return to Retry)          │
                           ▼
               [Backend Signature Check]
               (HMAC-SHA256 Verification)
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
      [Invalid / Tampered]       [Signature Verified]
      (Reject Transaction)               │
                                         ▼
                               [Atomic DB Transition]
                               • Booking: CONFIRMED
                               • Seats: ALLOCATED
                               • Payment: SUCCESS
                               • Unique PNR Issued
                                         │
                                         ▼
                           [Booking Confirmation Page]
                           (Display E-ticket & PNR)
```

## 3. Financial Exactness Policy
- No floating-point types (`float` or `double`) are used for currency calculations.
- All monetary operations use `java.math.BigDecimal` with `RoundingMode.HALF_UP`.
- Database columns are defined as `DECIMAL(10, 2)`.
- Razorpay minor units (paise) are calculated as:
  `amount.multiply(new BigDecimal(100)).setScale(0, RoundingMode.HALF_UP).longValue()`
