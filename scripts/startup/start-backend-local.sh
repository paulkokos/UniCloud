#!/bin/bash

# UniCloud Backend Startup Script (Local PostgreSQL)
# This script starts the Spring Boot backend using local PostgreSQL on port 5432

echo "Starting UniCloud Backend (Local PostgreSQL)..."
echo ""

# Check if local PostgreSQL is running
if ! pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
    echo "Local PostgreSQL is not running!"
    echo "Starting PostgreSQL service..."
    sudo systemctl start postgresql
    sleep 2

    if ! pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        echo "Failed to start PostgreSQL"
        exit 1
    fi
fi

echo "Local PostgreSQL is running on port 5432"
echo ""

# Setup database if needed
echo "Setting up database..."

# Check if dev_user exists
if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='dev_user'" | grep -q 1; then
    echo "Creating dev_user role..."
    sudo -u postgres psql -c "CREATE USER dev_user WITH PASSWORD 'dev_password';"
fi

# Check if unicloud_dev database exists
if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw unicloud_dev; then
    echo "Creating unicloud_dev database..."
    sudo -u postgres psql -c "CREATE DATABASE unicloud_dev OWNER dev_user;"
fi

# Create schema
echo "Creating unicloud schema..."
PGPASSWORD=dev_password psql -h localhost -p 5432 -U dev_user -d unicloud_dev -c "CREATE SCHEMA IF NOT EXISTS unicloud;" 2>/dev/null

echo "Database setup complete"
echo ""

# Create temporary application-local.properties
cat > /tmp/application-local.properties << 'EOF'
# Local PostgreSQL Configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/unicloud_dev
spring.datasource.username=dev_user
spring.datasource.password=dev_password
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA/Hibernate Configuration
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.default_schema=unicloud

# Logging
logging.level.root=INFO
logging.level.com.unicloud=DEBUG
logging.level.org.springframework.security=DEBUG
EOF

# Check if port 8080 is already in use
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "Port 8080 is already in use!"
    echo "Stopping any existing backend..."
    pkill -f "spring-boot:run" || true
    sleep 2
fi

echo "Building and starting Spring Boot backend with LOCAL PostgreSQL..."
echo "   Database: localhost:5432/unicloud_dev"
echo "   URL: http://localhost:8080"
echo "   Health: http://localhost:8080/actuator/health"
echo "   API: http://localhost:8080/api/users"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Start Spring Boot backend with local profile
cd "$(dirname "$0")"
mvn spring-boot:run -pl unicloud-backend -Dspring-boot.run.arguments="--spring.config.additional-location=file:/tmp/application-local.properties"
