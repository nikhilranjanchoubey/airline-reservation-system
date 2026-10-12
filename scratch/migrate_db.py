import subprocess

def run_sql(sql):
    cmd = [r'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe', '-u', 'root', '-p#Nikhil@2025sql', 'skytech_db', '-e', sql]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print("SQL Error:", res.stderr)
    return res.stdout, res.stderr

def get_columns(table):
    sql = f"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'skytech_db' AND TABLE_NAME = '{table}';"
    stdout, _ = run_sql(sql)
    cols = [line.strip() for line in stdout.splitlines() if line.strip() and line.strip() != 'COLUMN_NAME']
    return cols

def main():
    print("Checking columns...")
    b_cols = get_columns('bookings')
    print("Current bookings columns:", b_cols)
    
    # 1. Update bookings table
    run_sql("ALTER TABLE bookings MODIFY COLUMN status VARCHAR(30) NOT NULL DEFAULT 'PENDING_PAYMENT';")
    if 'schedule_id' not in b_cols:
        run_sql("ALTER TABLE bookings ADD COLUMN schedule_id INT NULL;")
    if 'flight_number' not in b_cols:
        run_sql("ALTER TABLE bookings ADD COLUMN flight_number VARCHAR(20) NULL;")
    if 'travel_class' not in b_cols:
        run_sql("ALTER TABLE bookings ADD COLUMN travel_class VARCHAR(30) DEFAULT 'Economy';")
    if 'seat_numbers' not in b_cols:
        run_sql("ALTER TABLE bookings ADD COLUMN seat_numbers VARCHAR(100) NULL;")
    if 'contact_email' not in b_cols:
        run_sql("ALTER TABLE bookings ADD COLUMN contact_email VARCHAR(100) NULL;")
    if 'contact_phone' not in b_cols:
        run_sql("ALTER TABLE bookings ADD COLUMN contact_phone VARCHAR(20) NULL;")
    if 'pnr' not in b_cols:
        run_sql("ALTER TABLE bookings ADD COLUMN pnr VARCHAR(20) NULL;")
        run_sql("CREATE INDEX idx_bookings_pnr ON bookings(pnr);")

    # 2. Update passengers table
    p_cols = get_columns('passengers')
    print("Current passengers columns:", p_cols)
    if 'seat_number' not in p_cols:
        run_sql("ALTER TABLE passengers ADD COLUMN seat_number VARCHAR(10) NULL;")
    if 'ticket_number' not in p_cols:
        run_sql("ALTER TABLE passengers ADD COLUMN ticket_number VARCHAR(50) NULL;")

    # 3. Update payments table
    pay_cols = get_columns('payments')
    print("Current payments columns:", pay_cols)
    run_sql("ALTER TABLE payments MODIFY COLUMN status VARCHAR(30) NOT NULL DEFAULT 'PENDING';")
    if 'razorpay_order_id' not in pay_cols:
        run_sql("ALTER TABLE payments ADD COLUMN razorpay_order_id VARCHAR(150) NULL;")
    if 'razorpay_payment_id' not in pay_cols:
        run_sql("ALTER TABLE payments ADD COLUMN razorpay_payment_id VARCHAR(150) NULL;")
    if 'razorpay_signature' not in pay_cols:
        run_sql("ALTER TABLE payments ADD COLUMN razorpay_signature VARCHAR(255) NULL;")

    # 4. Create tickets table
    run_sql("""
    CREATE TABLE IF NOT EXISTS tickets (
        ticket_id BIGINT AUTO_INCREMENT PRIMARY KEY,
        booking_id BIGINT NOT NULL,
        passenger_id BIGINT NOT NULL,
        ticket_number VARCHAR(50) NOT NULL UNIQUE,
        pnr VARCHAR(20) NOT NULL,
        flight_number VARCHAR(20) NOT NULL,
        origin_code CHAR(3) NOT NULL,
        destination_code CHAR(3) NOT NULL,
        departure_time DATETIME NOT NULL,
        arrival_time DATETIME NOT NULL,
        seat_number VARCHAR(10) NULL,
        cabin_class VARCHAR(30) DEFAULT 'Economy',
        passenger_name VARCHAR(150) NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED',
        issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT fk_tickets_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
        INDEX idx_tickets_pnr (pnr),
        INDEX idx_tickets_booking (booking_id)
    ) ENGINE=InnoDB;
    """)

    # 5. Create cancellations table
    run_sql("""
    CREATE TABLE IF NOT EXISTS cancellations (
        cancellation_id BIGINT AUTO_INCREMENT PRIMARY KEY,
        booking_id BIGINT NOT NULL,
        pnr VARCHAR(20) NOT NULL,
        cancellation_reason VARCHAR(255) NULL,
        cancellation_fee DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
        refund_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
        refund_status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
        refund_reference VARCHAR(150) NULL,
        cancelled_by_user_id BIGINT NULL,
        cancelled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT fk_cancellations_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
        INDEX idx_cancellations_pnr (pnr)
    ) ENGINE=InnoDB;
    """)

    print("Migration complete. Verifying tables:")
    stdout, _ = run_sql("SHOW TABLES;")
    print(stdout)

if __name__ == '__main__':
    main()
