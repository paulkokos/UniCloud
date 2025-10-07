#!/bin/bash

# UniCloud Backend Stop Script
# This script stops the Spring Boot backend

echo "Stopping UniCloud Backend..."

# Stop Spring Boot process
if pgrep -f "spring-boot:run" > /dev/null; then
    pkill -f "spring-boot:run"
    echo "Backend stopped"
else
    echo "Backend is not running"
fi

# Optionally stop Docker services
read -p "Stop Docker services (PostgreSQL, Redis)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Stopping Docker services..."
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml down
    echo "Docker services stopped"
fi

echo "Done"
