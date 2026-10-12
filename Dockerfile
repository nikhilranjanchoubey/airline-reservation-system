# Multi-stage production build for SkyTech — Airline Reservation System
# Stage 1: Build application WAR with Maven and Eclipse Temurin JDK 21
FROM maven:3.9.9-eclipse-temurin-21 AS builder
WORKDIR /app

# Copy dependency configuration and source files
COPY pom.xml .
COPY src ./src
COPY database ./database

# Compile and package production WAR artifact
RUN mvn clean package -DskipTests

# Stage 2: Production runtime with Apache Tomcat 10.1 & JDK 21
FROM tomcat:10.1-jdk21-temurin

# Install MariaDB server and client for self-contained production database
ENV DEBIAN_FRONTEND=noninteractive
RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d && \
    apt-get update && \
    apt-get install -y --no-install-recommends mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Clean out default Tomcat sample applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy packaged WAR as both ROOT.war (for root domain access) and airline-reservation-system.war (for context path access)
COPY --from=builder /app/target/airline-reservation-system.war /usr/local/tomcat/webapps/ROOT.war
COPY --from=builder /app/target/airline-reservation-system.war /usr/local/tomcat/webapps/airline-reservation-system.war

# Copy database schema for container initialization
COPY database /app/database

# Copy and set execution permissions for the dynamic port entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Expose Render default port and Tomcat default port
EXPOSE 8080 10000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
