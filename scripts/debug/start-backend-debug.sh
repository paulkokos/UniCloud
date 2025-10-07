#!/bin/bash

# UniCloud Backend Startup Script - Debug Mode
# Starts Spring Boot backend with remote debugging enabled on port 5005

echo "Starting UniCloud Backend in DEBUG mode..."
echo ""

# Check if Docker PostgreSQL is running
if ! docker ps | grep -q unicloud-postgres; then
    echo "Docker PostgreSQL is not running!"
    echo "Starting Docker services..."
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d postgres redis
    echo "Waiting for PostgreSQL to be ready..."
    sleep 5
fi

echo "Docker PostgreSQL is running on port 5433"
echo ""

# Check if port 8080 is already in use
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "Port 8080 is already in use!"
    echo "Stopping any existing backend..."
    pkill -f "spring-boot:run" || true
    sleep 2
fi

# Check if debug port 5005 is already in use
if lsof -Pi :5005 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "WARNING: Debug port 5005 is already in use!"
    read -p "Kill existing process on port 5005? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        lsof -ti:5005 | xargs kill -9
        sleep 1
    else
        echo "Exiting..."
        exit 1
    fi
fi

echo "Starting Spring Boot backend with DEBUG enabled..."
echo ""
echo "Application:"
echo "   URL:     http://localhost:8080"
echo "   Health:  http://localhost:8080/actuator/health"
echo "   API:     http://localhost:8080/api/users"
echo ""
echo "Debug:"
echo "   Port:    5005"
echo "   Type:    Remote JVM Debug"
echo "   Suspend: No (application starts immediately)"
echo ""
echo "Connect your IDE debugger to localhost:5005"
echo "Press Ctrl+C to stop"
echo ""

# Start Spring Boot backend with debug enabled
cd "$(dirname "$0")"
mvn spring-boot:run -pl unicloud-backend \
  -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 -Xmx1024m -Xms512m"
