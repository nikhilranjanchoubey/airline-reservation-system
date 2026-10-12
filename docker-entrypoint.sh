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
    mysql -u root <<EOF || true
CREATE DATABASE IF NOT EXISTS skytech_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

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
FLUSH PRIVILEGES;
EOF

    # Run schema.sql if present
    if [ -f "/app/database/schema.sql" ]; then
        echo "Applying SkyTech database schema and initial seed data..."
        mysql -u "${APP_USER}" -p"${APP_PASS}" skytech_db < /app/database/schema.sql 2>/dev/null || \
        mysql -u root -p"${APP_PASS}" skytech_db < /app/database/schema.sql 2>/dev/null || \
        mysql -u root skytech_db < /app/database/schema.sql 2>/dev/null || true
        echo "SkyTech database schema applied successfully."
    fi
else
    echo "External database configured: connecting to remote MySQL host."
fi

echo "Starting SkyTech Airline Reservation System on port ${HTTP_PORT}..."
exec "$@"
