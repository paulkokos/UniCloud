#!/bin/bash

# UniCloud Full Stack Startup Script
# This script starts both backend and desktop application

echo "Starting UniCloud Full Stack (Backend + Desktop)..."
echo ""

# Get project root directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

# Check if Docker PostgreSQL is running
if ! docker ps | grep -q unicloud-postgres; then
    echo "Starting Docker PostgreSQL..."
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d postgres redis
    echo "Waiting for PostgreSQL to be ready..."
    sleep 5
fi

echo "Database ready"
echo ""

# Start backend in background
echo "Starting Backend API..."
mvn spring-boot:run -pl unicloud-backend > /tmp/unicloud-backend.log 2>&1 &
BACKEND_PID=$!

# Wait for backend to be ready
echo "Waiting for backend to start..."
for i in {1..30}; do
    if curl -s http://localhost:8080/actuator/health >/dev/null 2>&1; then
        echo "Backend is ready at http://localhost:8080"
        break
    fi
    sleep 1
    echo -n "."
done
echo ""

# Start desktop application
echo "Starting Desktop Application..."
echo ""
mvn javafx:run -pl unicloud-desktop

# Cleanup on exit
echo ""
echo "Shutting down backend..."
kill $BACKEND_PID 2>/dev/null
echo "Done"
