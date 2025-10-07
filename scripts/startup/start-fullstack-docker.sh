#!/bin/bash

# UniCloud Full Stack Startup Script (All Docker)
# This script starts backend in Docker + desktop locally

echo "Starting UniCloud Full Stack (Docker Backend + Local Desktop)..."
echo ""

# Stop local backend if running
if pgrep -f "spring-boot:run" > /dev/null; then
    echo "Stopping local backend..."
    pkill -f "spring-boot:run"
    sleep 2
fi

# Start Docker services (backend, postgres, redis)
echo "Starting Docker services..."
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

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

# Show Docker logs
echo "Backend logs:"
docker logs unicloud-backend --tail 10
echo ""

# Start desktop application
echo "Starting Desktop Application..."
echo ""
mvn javafx:run -pl unicloud-desktop

# Optionally stop Docker services
echo ""
read -p "Stop Docker services? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml down
    echo "Docker services stopped"
fi
