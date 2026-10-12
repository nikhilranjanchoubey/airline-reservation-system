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
    mysqld_safe --user=mysql --datadir=/var/lib/mysql --innodb-buffer-pool-size=16M --key-buffer-size=16M >/dev/null 2>&1 &

    echo "Waiting for MySQL socket..."
    for i in $(seq 1 30); do
        if mysqladmin ping --silent 2>/dev/null; then
            echo "MariaDB is up and accepting connections!"
            break
        fi
        sleep 1
    done

    # Run schema.sql if database does not exist
    if [ -f "/app/database/schema.sql" ]; then
        echo "Applying SkyTech database schema and initial seed data..."
        mysql -u root -e "CREATE DATABASE IF NOT EXISTS skytech_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || true
        mysql -u root skytech_db < /app/database/schema.sql 2>/dev/null || true
        echo "SkyTech database schema applied successfully."
    fi
else
    echo "External database configured: connecting to remote MySQL host."
fi

echo "Starting SkyTech Airline Reservation System on port ${HTTP_PORT}..."
exec "$@"
