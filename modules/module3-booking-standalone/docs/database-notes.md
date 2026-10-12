# SKYTECH Airlines — Database Design & Concurrency Strategy

## 1. Entity Relationship Summary

```
[shared_users_dev_mock] 1 ──── 0..* [bookings]
                                      │
                                      ├── 1 ──── 1..* [passengers]
                                      │
                                      ├── 1 ──── 1..* [booking_passengers]
                                      │
[shared_flights_dev_mock] 1 ── 0..* [seat_allocations]
                                      │
                                    [payments] (1 per booking)
```

## 2. Duplicate Seat Prevention & Concurrency Protection
To prevent two passengers from booking or holding the exact same seat on the same flight instance concurrently:
```sql
CONSTRAINT uq_flight_seat_active UNIQUE (flight_id, seat_number, allocation_status)
```
In addition, database transactions use `conn.setAutoCommit(false)` with explicit rollbacks in catch blocks, ensuring that header, passenger, seat, and payment records succeed or fail together atomically.

## 3. Database Indexes for Query Optimization
- `idx_bookings_pnr`: O(1) lookups on 6-character PNR.
- `idx_bookings_user_id`: Fast retrieval for authenticated "My Bookings" view.
- `idx_allocations_flight_seat`: Instant cabin map occupancy queries.
- `idx_payments_razorpay_order`: O(1) order reconciliation on webhook or callback.
