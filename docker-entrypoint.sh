#!/bin/sh
set -e

# Render provides the $PORT environment variable (default to 8080 if not set)
HTTP_PORT="${PORT:-8080}"
echo "Configuring Apache Tomcat to listen on HTTP port ${HTTP_PORT}..."

# Replace port="8080" in Tomcat's server.xml with the dynamic $PORT
if [ -f "/usr/local/tomcat/conf/server.xml" ]; then
    sed -i "s/port=\"8080\"/port=\"${HTTP_PORT}\"/g" /usr/local/tomcat/conf/server.xml
fi

echo "Starting SkyTech Airline Reservation System on port ${HTTP_PORT}..."
exec "$@"
