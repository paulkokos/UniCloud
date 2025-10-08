#!/bin/bash

# UniCloud Desktop Application Startup Script
# This script starts the JavaFX desktop application

echo "Starting UniCloud Desktop Application..."
echo ""

# Check if backend is running
if ! curl -s http://localhost:8080/actuator/health >/dev/null 2>&1; then
    echo "Backend is not running!"
    echo ""
    read -p "Start backend first? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "Starting backend..."
        ./start-backend.sh &
        BACKEND_PID=$!
        echo "Waiting for backend to start..."
        sleep 10
    else
        echo "Desktop app may not work without backend!"
        echo ""
    fi
fi

echo "Backend is running at http://localhost:8080"
echo ""

echo "Starting JavaFX Desktop Application..."
echo "   Main Class: com.unicloud.desktop.UniCloudDesktopApplication"
echo ""
echo "Close the window to stop the application"
echo ""

# Start JavaFX Desktop Application
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"
mvn javafx:run -pl unicloud-desktop

# Cleanup
if [ ! -z "$BACKEND_PID" ]; then
    echo ""
    read -p "Stop backend? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kill $BACKEND_PID 2>/dev/null
        echo "Backend stopped"
    fi
fi
