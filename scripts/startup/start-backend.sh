#!/bin/bash

# UniCloud Backend Startup Script
# This script starts the Spring Boot backend locally

echo "Starting UniCloud Backend..."
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

echo "Building and starting Spring Boot backend..."
echo "   URL: http://localhost:8080"
echo "   Health: http://localhost:8080/actuator/health"
echo "   API: http://localhost:8080/api/users"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Start Spring Boot backend
cd "$(dirname "$0")"
mvn spring-boot:run -pl unicloud-backend
