# UniCloud Project Structure

## Overview

```
UniCloud/
├── .config/                    # IDE and editor configurations
│   ├── nvim/                   # Neovim/AstroNvim debug configs
│   └── ide/                    # IDE-specific configurations
│       ├── vscode/             # VS Code launch configurations
│       └── intellij/           # IntelliJ IDEA run configurations
│
├── .github/                    # GitHub configuration
│   └── workflows/              # GitHub Actions CI/CD pipelines
│       └── ci.yml              # Main CI pipeline (7 jobs)
│
├── docs/                       # Project documentation
│   ├── api/                    # API documentation (OpenAPI/Swagger)
│   ├── debugging/              # Debugging guides
│   │   ├── DEBUG.md            # General debugging guide
│   │   └── NVIM-DEBUG.md       # Neovim debugging setup
│   ├── setup/                  # Setup and configuration
│   │   └── COMMIT_GUIDELINES.md
│   ├── CHANGELOG.md            # Version history
│   └── README.md               # Documentation index
│
├── scripts/                    # Executable scripts
│   ├── startup/                # Application startup scripts
│   │   ├── start-backend.sh
│   │   ├── start-backend-local.sh
│   │   ├── start-desktop.sh
│   │   ├── start-fullstack.sh
│   │   ├── start-fullstack-docker.sh
│   │   └── stop-backend.sh
│   ├── debug/                  # Debugging scripts
│   │   ├── start-backend-debug.sh
│   │   └── start-backend-debug-suspend.sh
│   ├── testing/                # Test execution scripts
│   │   └── run-tests.sh
│   ├── utils/                  # Utility scripts
│   │   ├── set-version.sh
│   │   ├── build.sh
│   │   └── deploy.sh
│   └── README.md               # Scripts documentation
│
├── sql/                        # Database scripts
│   ├── init.sql                # Initial schema
│   ├── dev-data.sql            # Development seed data
│   └── test-data.sql           # Test fixtures
│
├── unicloud-backend/           # Spring Boot backend
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/unicloud/backend/
│   │   │   │   ├── config/     # Spring configuration
│   │   │   │   │   └── SecurityConfig.java
│   │   │   │   ├── controller/ # REST controllers
│   │   │   │   │   └── UserController.java
│   │   │   │   ├── repository/ # Data access layer
│   │   │   │   │   ├── UserRepository.java
│   │   │   │   │   ├── CloudAccountRepository.java
│   │   │   │   │   └── FileRepository.java
│   │   │   │   ├── service/    # Business logic
│   │   │   │   │   └── UserService.java
│   │   │   │   └── UniCloudBackendApplication.java
│   │   │   └── resources/
│   │   │       └── application.properties
│   │   └── test/
│   │       ├── java/com/unicloud/backend/
│   │       │   ├── repository/
│   │       │   │   └── UserRepositoryTest.java
│   │       │   └── service/
│   │       │       └── UserServiceTest.java
│   │       └── resources/
│   │           ├── application-test.properties
│   │           └── schema.sql
│   └── pom.xml
│
├── unicloud-common/            # Shared models and DTOs
│   ├── src/main/java/com/unicloud/common/
│   │   ├── dto/                # Data Transfer Objects
│   │   │   ├── UserDTO.java
│   │   │   ├── CreateUserRequest.java
│   │   │   └── UpdateUserRequest.java
│   │   └── model/              # JPA Entities
│   │       ├── User.java
│   │       ├── CloudAccount.java
│   │       ├── File.java
│   │       ├── CloudProvider.java (enum)
│   │       └── UserStatus.java (enum)
│   └── pom.xml
│
├── unicloud-desktop/           # JavaFX desktop application
│   ├── src/main/java/com/unicloud/desktop/
│   │   └── UniCloudDesktopApplication.java
│   └── pom.xml
│
├── checkstyle.xml              # Code style configuration
├── owasp-suppressions.xml      # OWASP dependency check config
├── suppressions.xml            # General suppressions
├── docker-compose.yml          # Base Docker Compose
├── docker-compose.dev.yml      # Development overrides
├── docker-compose.prod.yml     # Production overrides
├── pom.xml                     # Parent Maven POM
└── README.md                   # Main project README
```

## Directory Purposes

### Configuration (`.config/`)
- IDE and editor configurations
- Debug configurations for multiple editors
- Shared across team members
- **See:** `.config/README.md`

### Documentation (`docs/`)
- All project documentation
- Organized by topic (setup, debugging, API)
- Includes guides, references, and changelogs
- **See:** `docs/README.md`

### Scripts (`scripts/`)
- Executable automation scripts
- Organized by purpose (startup, debug, testing, utils)
- All scripts are documented and ready to use
- **See:** `scripts/README.md`

### Source Code
- **`unicloud-backend/`** - Spring Boot REST API
- **`unicloud-common/`** - Shared models and DTOs
- **`unicloud-desktop/`** - JavaFX desktop application

### Build & Deploy
- **`pom.xml`** - Maven multi-module project
- **`docker-compose*.yml`** - Container orchestration
- **`checkstyle.xml`** - Code quality standards

## Quick Access Paths

### Development

```bash
# Start development environment
./scripts/startup/start-fullstack.sh

# Run tests
./scripts/testing/run-tests.sh

# Debug backend
./scripts/debug/start-backend-debug.sh
```

### Documentation

```bash
# Main docs
cat README.md

# Debug guide
cat docs/debugging/DEBUG.md

# Commit guidelines
cat docs/setup/COMMIT_GUIDELINES.md

# Version history
cat docs/CHANGELOG.md
```

### Configuration

```bash
# Neovim debug config
cat .config/nvim/astronvim-config.lua

# VS Code debug config
cat .config/ide/vscode/launch.json

# IntelliJ run configs
ls .config/ide/intellij/
```

## File Organization Principles

1. **Separation of Concerns**
   - Scripts separated from source code
   - Documentation separated from implementation
   - Configuration separated from code

2. **Discoverability**
   - Clear folder names
   - README in each major directory
   - Consistent naming conventions

3. **Maintainability**
   - Related files grouped together
   - Easy to find and update
   - Clear ownership of files

4. **Portability**
   - Relative paths used in scripts
   - No hardcoded absolute paths
   - Works across different systems

## Naming Conventions

### Files
- **Scripts:** `verb-noun.sh` (e.g., `start-backend.sh`)
- **Docs:** `UPPERCASE.md` for important, `kebab-case.md` for others
- **Config:** Descriptive names (e.g., `astronvim-config.lua`)

### Directories
- **Lowercase** with hyphens (e.g., `unicloud-backend`)
- **Descriptive names** indicating purpose
- **Plural for collections** (e.g., `scripts/`, `docs/`)

## Adding New Files

### New Script
```bash
# Create in appropriate subdirectory
touch scripts/utils/new-utility.sh
chmod +x scripts/utils/new-utility.sh

# Document in scripts/README.md
```

### New Documentation
```bash
# Create in appropriate subdirectory
touch docs/setup/new-guide.md

# Add to docs/README.md index
```

### New Configuration
```bash
# Create in .config/
touch .config/ide/new-editor/config.xml

# Document in .config/README.md
```

## Git Ignore Patterns

These directories/files are NOT committed:

```
target/                 # Maven build output
.idea/workspace.xml     # IntelliJ personal settings
.vscode/settings.json   # VS Code personal settings
*.log                   # Log files
.env                    # Environment variables
```

Committed IDE configs (in `.config/`) are team-wide defaults.

## Related Documentation

- **Main README:** `README.md`
- **Scripts Guide:** `scripts/README.md`
- **Docs Index:** `docs/README.md`
- **Config Guide:** `.config/README.md`
- **Version History:** `docs/CHANGELOG.md`
