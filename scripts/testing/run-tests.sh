#!/bin/bash

# UniCloud Test Runner Script
# This script runs all tests with coverage reporting

echo "Running UniCloud Test Suite..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
SKIP_INTEGRATION=false
COVERAGE=false
MODULE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-integration)
            SKIP_INTEGRATION=true
            shift
            ;;
        --coverage)
            COVERAGE=true
            shift
            ;;
        --module)
            MODULE="$2"
            shift 2
            ;;
        --help)
            echo "Usage: ./run-tests.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-integration    Skip integration tests (unit tests only)"
            echo "  --coverage           Generate code coverage report"
            echo "  --module <name>      Run tests for specific module (backend/common/desktop)"
            echo "  --help               Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./run-tests.sh                          # Run all tests"
            echo "  ./run-tests.sh --skip-integration       # Run unit tests only"
            echo "  ./run-tests.sh --coverage               # Run with coverage report"
            echo "  ./run-tests.sh --module unicloud-backend # Run backend tests only"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if TestContainers needs Docker
if [ "$SKIP_INTEGRATION" = false ]; then
    echo "Checking Docker for integration tests..."
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}Docker is not running!${NC}"
        echo "Integration tests require Docker for TestContainers."
        echo "Please start Docker or use --skip-integration flag."
        exit 1
    fi
    echo -e "${GREEN}Docker is running${NC}"
    echo ""
fi

# Build Maven test command
MVN_CMD="mvn clean test"

if [ -n "$MODULE" ]; then
    MVN_CMD="$MVN_CMD -pl $MODULE"
    echo "Running tests for module: $MODULE"
else
    echo "Running tests for all modules"
fi

if [ "$SKIP_INTEGRATION" = true ]; then
    MVN_CMD="$MVN_CMD -DexcludedGroups=integration"
    echo -e "${YELLOW}Skipping integration tests${NC}"
fi

if [ "$COVERAGE" = true ]; then
    MVN_CMD="$MVN_CMD jacoco:prepare-agent jacoco:report"
    echo "Code coverage reporting enabled"
fi

echo ""
echo "Command: $MVN_CMD"
echo ""
echo "─────────────────────────────────────────────────────"
echo ""

# Run tests
cd "$(dirname "$0")"
$MVN_CMD

TEST_EXIT_CODE=$?

echo ""
echo "─────────────────────────────────────────────────────"
echo ""

# Show results
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"

    if [ "$COVERAGE" = true ]; then
        echo ""
        echo "Coverage reports generated:"
        find . -name "index.html" -path "*/jacoco/*" | while read report; do
            echo "   file://$PWD/$report"
        done
    fi

    echo ""
    echo "Test summary:"
    mvn surefire-report:report-only 2>/dev/null

else
    echo -e "${RED}Tests failed!${NC}"
    echo ""
    echo "To see detailed failure reports:"
    echo "  cat target/surefire-reports/*.txt"
    echo ""
    exit 1
fi

# Show test counts
echo ""
echo "Test Statistics:"
echo "─────────────────────────────────────────────────────"

# Count test files
UNIT_TESTS=$(find . -name "*Test.java" ! -path "*/target/*" ! -name "*IT.java" | wc -l)
INTEGRATION_TESTS=$(find . -name "*IT.java" ! -path "*/target/*" | wc -l)

echo "  Unit Tests:        $UNIT_TESTS test classes"
echo "  Integration Tests: $INTEGRATION_TESTS test classes"

# Parse surefire reports if available
if [ -d "target/surefire-reports" ]; then
    TOTAL_TESTS=$(grep -h "Tests run:" target/surefire-reports/*.txt 2>/dev/null | awk -F',' '{sum+=$1} END {print sum}' | grep -oE '[0-9]+')
    FAILURES=$(grep -h "Failures:" target/surefire-reports/*.txt 2>/dev/null | awk -F',' '{sum+=$2} END {print sum}' | grep -oE '[0-9]+')
    SKIPPED=$(grep -h "Skipped:" target/surefire-reports/*.txt 2>/dev/null | awk -F',' '{sum+=$3} END {print sum}' | grep -oE '[0-9]+')

    if [ -n "$TOTAL_TESTS" ]; then
        echo "  Total Tests Run:   ${TOTAL_TESTS:-0}"
        echo "  Failures:          ${FAILURES:-0}"
        echo "  Skipped:           ${SKIPPED:-0}"
    fi
fi

echo "─────────────────────────────────────────────────────"
echo ""
echo -e "${GREEN}Done${NC}"
