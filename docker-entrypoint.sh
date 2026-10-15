#!/bin/sh
set -e

# Render provides the $PORT environment variable (default to 8080 if not set)
HTTP_PORT="${PORT:-8080}"
echo "Configuring Apache Tomcat to listen on HTTP port ${HTTP_PORT}..."

# Replace port="8080" in Tomcat's server.xml with the dynamic $PORT
if [ -f "/usr/local/tomcat/conf/server.xml" ]; then
    sed -i "s/port=\"8080\"/port=\"${HTTP_PORT}\"/g" /usr/local/tomcat/conf/server.xml
fi

# Determine if local MariaDB/MySQL server should be started
# Starts local daemon if DB_URL is empty, or contains localhost or 127.0.0.1
if [ -z "$DB_URL" ] || echo "$DB_URL" | grep -q "localhost" || echo "$DB_URL" | grep -q "127.0.0.1"; then
    echo "Starting local MariaDB daemon for database persistence..."
    mkdir -p /var/run/mysqld /var/lib/mysql
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

    if [ ! -d "/var/lib/mysql/mysql" ]; then
        echo "Initializing MariaDB system tables..."
        mysql_install_db --user=mysql --datadir=/var/lib/mysql >/dev/null 2>&1 || true
    fi

    # Start MariaDB daemon in background with low memory settings
    mysqld_safe --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 --innodb-buffer-pool-size=16M --key-buffer-size=16M >/dev/null 2>&1 &

    echo "Waiting for MySQL socket..."
    for i in $(seq 1 30); do
        if mysqladmin ping --silent 2>/dev/null; then
            echo "MariaDB is up and accepting connections!"
            break
        fi
        sleep 1
    done

    APP_USER="${DB_USERNAME:-skytech_app}"
    APP_PASS="${DB_PASSWORD:-SkyTech@Prod2026!}"

    # Configure dedicated SkyTech application user with privileges only on skytech_db
    echo "Provisioning dedicated application database user '${APP_USER}'..."
    SQL_PROVISION="CREATE DATABASE IF NOT EXISTS skytech_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${APP_USER}'@'localhost' IDENTIFIED BY '${APP_PASS}';
ALTER USER '${APP_USER}'@'localhost' IDENTIFIED BY '${APP_PASS}';
CREATE USER IF NOT EXISTS '${APP_USER}'@'127.0.0.1' IDENTIFIED BY '${APP_PASS}';
ALTER USER '${APP_USER}'@'127.0.0.1' IDENTIFIED BY '${APP_PASS}';
CREATE USER IF NOT EXISTS '${APP_USER}'@'%' IDENTIFIED BY '${APP_PASS}';
ALTER USER '${APP_USER}'@'%' IDENTIFIED BY '${APP_PASS}';
GRANT ALL PRIVILEGES ON skytech_db.* TO '${APP_USER}'@'localhost';
GRANT ALL PRIVILEGES ON skytech_db.* TO '${APP_USER}'@'127.0.0.1';
GRANT ALL PRIVILEGES ON skytech_db.* TO '${APP_USER}'@'%';
CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED BY '${APP_PASS}';
ALTER USER 'root'@'127.0.0.1' IDENTIFIED BY '${APP_PASS}';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${APP_PASS}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;"

    mysql -u root -e "$SQL_PROVISION" 2>/dev/null || \
    mysql -u root -p"${APP_PASS}" -e "$SQL_PROVISION" 2>/dev/null || true

    # Run schema.sql if present
    if [ -f "/app/database/schema.sql" ]; then
        echo "Applying SkyTech database schema and initial seed data..."
        mysql -u "${APP_USER}" -p"${APP_PASS}" skytech_db < /app/database/schema.sql || \
        mysql -u root -p"${APP_PASS}" skytech_db < /app/database/schema.sql || \
        mysql -u root skytech_db < /app/database/schema.sql || true
        echo "SkyTech database schema applied."
    fi

    # Run any migration scripts if present
    for migration in /app/database/migration_*.sql; do
        if [ -f "$migration" ]; then
            echo "Applying migration $(basename "$migration")..."
            mysql -u "${APP_USER}" -p"${APP_PASS}" skytech_db < "$migration" 2>/dev/null || \
            mysql -u root -p"${APP_PASS}" skytech_db < "$migration" 2>/dev/null || true
        fi
    done

    # Verify all 15 required tables are present before proceeding
    REQUIRED_TABLES="users airports airlines flights flight_schedules aircraft aircraft_seats flight_seat_inventory flight_searches bookings passengers payments tickets cancellations admin_audit_logs"
    echo "Verifying all required database tables..."
    MISSING_TABLES=""
    for tbl in $REQUIRED_TABLES; do
        if ! mysql -u "${APP_USER}" -p"${APP_PASS}" skytech_db -e "SELECT 1 FROM \`$tbl\` LIMIT 1;" >/dev/null 2>&1; then
            MISSING_TABLES="$MISSING_TABLES $tbl"
        fi
    done

    if [ -n "$MISSING_TABLES" ]; then
        echo "WARNING: Missing required database tables detected:$MISSING_TABLES"
        echo "Attempting schema recovery..."
        mysql -u root -p"${APP_PASS}" skytech_db < /app/database/schema.sql || true
        STILL_MISSING=""
        for tbl in $REQUIRED_TABLES; do
            if ! mysql -u "${APP_USER}" -p"${APP_PASS}" skytech_db -e "SELECT 1 FROM \`$tbl\` LIMIT 1;" >/dev/null 2>&1; then
                STILL_MISSING="$STILL_MISSING $tbl"
            fi
        done
        if [ -n "$STILL_MISSING" ]; then
            echo "FATAL: Database verification failed. Unresolved missing tables:$STILL_MISSING"
        else
            echo "Database recovery successful: All 15 required tables verified."
        fi
    else
        echo "Database verification successful: All 15 required tables verified."
    fi

    # Ensure demo accounts have restored profile names
    mysql -u "${APP_USER}" -p"${APP_PASS}" skytech_db -e "UPDATE users SET first_name='Ramesh', last_name='Kumar', phone='+91 999 777 8888', passport_number='P99887766' WHERE email='passenger@airline.com' AND (first_name='John' OR first_name='');" >/dev/null 2>&1 || true
    mysql -u "${APP_USER}" -p"${APP_PASS}" skytech_db -e "UPDATE users SET first_name='Team', last_name='SkyTech' WHERE email='admin@airline.com' AND first_name='System';" >/dev/null 2>&1 || true
else
    echo "External database configured: connecting to remote MySQL host."
fi

echo "Starting SkyTech Airline Reservation System on port ${HTTP_PORT}..."
exec "$@"
