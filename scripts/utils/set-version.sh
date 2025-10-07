#!/bin/bash

# UniCloud Version Management Script
# IEEE Semantic Versioning: MAJOR.MINOR.PATCH

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Display current version
CURRENT_VERSION=$(grep -m1 '<version>' pom.xml | sed 's/.*<version>\(.*\)<\/version>.*/\1/')

echo "========================================"
echo "UniCloud Version Management"
echo "========================================"
echo ""
echo "Current version: ${YELLOW}${CURRENT_VERSION}${NC}"
echo ""

# If no argument, show help
if [ $# -eq 0 ]; then
    echo "Usage: ./set-version.sh [VERSION|COMMAND]"
    echo ""
    echo "Commands:"
    echo "  patch         Increment patch version (0.1.0 → 0.1.1)"
    echo "  minor         Increment minor version (0.1.5 → 0.2.0)"
    echo "  major         Increment major version (0.5.2 → 1.0.0)"
    echo "  release       Remove -SNAPSHOT (0.1.0-SNAPSHOT → 0.1.0)"
    echo "  snapshot      Add -SNAPSHOT (0.1.0 → 0.1.0-SNAPSHOT)"
    echo ""
    echo "Direct version:"
    echo "  ./set-version.sh 0.2.0-SNAPSHOT"
    echo "  ./set-version.sh 1.0.0"
    echo ""
    echo "Examples:"
    echo "  ./set-version.sh patch     # Bug fix release"
    echo "  ./set-version.sh minor     # New feature release"
    echo "  ./set-version.sh major     # Breaking changes"
    echo "  ./set-version.sh release   # Remove SNAPSHOT for production"
    echo ""
    exit 0
fi

NEW_VERSION=""

# Parse command
case "$1" in
    patch)
        NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{
            split($3, p, "-");
            printf "%d.%d.%d-SNAPSHOT", $1, $2, p[1]+1
        }')
        ;;
    minor)
        NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{
            printf "%d.%d.0-SNAPSHOT", $1, $2+1
        }')
        ;;
    major)
        NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{
            printf "%d.0.0-SNAPSHOT", $1+1
        }')
        ;;
    release)
        NEW_VERSION=$(echo $CURRENT_VERSION | sed 's/-SNAPSHOT//')
        ;;
    snapshot)
        if [[ $CURRENT_VERSION == *"-SNAPSHOT" ]]; then
            echo -e "${RED}Version already has -SNAPSHOT${NC}"
            exit 1
        fi
        NEW_VERSION="${CURRENT_VERSION}-SNAPSHOT"
        ;;
    *)
        # Direct version specified
        NEW_VERSION="$1"
        ;;
esac

# Validate version format (basic check)
if ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-SNAPSHOT)?$ ]]; then
    echo -e "${RED}Invalid version format: ${NEW_VERSION}${NC}"
    echo "Expected format: MAJOR.MINOR.PATCH[-SNAPSHOT]"
    echo "Example: 0.1.0-SNAPSHOT or 1.0.0"
    exit 1
fi

echo "New version: ${GREEN}${NEW_VERSION}${NC}"
echo ""

# Confirm
read -p "Update all modules to ${NEW_VERSION}? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Update versions using Maven Versions Plugin
echo ""
echo "Updating POMs..."
mvn versions:set -DnewVersion=$NEW_VERSION -DgenerateBackupPoms=false

# Verify
UPDATED_VERSION=$(grep -m1 '<version>' pom.xml | sed 's/.*<version>\(.*\)<\/version>.*/\1/')

if [ "$UPDATED_VERSION" == "$NEW_VERSION" ]; then
    echo ""
    echo -e "${GREEN}Successfully updated to version ${NEW_VERSION}${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review changes: git diff"
    echo "  2. Test build: mvn clean install"
    if [[ ! $NEW_VERSION == *"-SNAPSHOT" ]]; then
        echo "  3. Create Git tag: git tag -a v${NEW_VERSION} -m 'Release ${NEW_VERSION}'"
        echo "  4. Push tag: git push origin v${NEW_VERSION}"
    fi
else
    echo -e "${RED}Version update failed${NC}"
    exit 1
fi
