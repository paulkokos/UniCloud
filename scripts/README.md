# UniCloud Scripts

This directory contains all executable scripts for the UniCloud project, organized by purpose.

## Directory Structure

```
scripts/
├── startup/          # Application startup scripts
├── debug/            # Debugging scripts
├── testing/          # Test execution scripts
└── utils/            # Utility and maintenance scripts
```

## Quick Reference

### Startup Scripts (`startup/`)

| Script | Description | Use Case |
|--------|-------------|----------|
| `start-backend.sh` | Start backend with Docker PostgreSQL | API development |
| `start-backend-local.sh` | Start backend with local PostgreSQL | Development without Docker |
| `start-desktop.sh` | Start JavaFX desktop application | UI development |
| `start-fullstack.sh` | Start backend + desktop locally | Full stack development |
| `start-fullstack-docker.sh` | Start backend in Docker + desktop | Testing production setup |
| `stop-backend.sh` | Stop all backend services | Cleanup |

### Debug Scripts (`debug/`)

| Script | Description | Debug Port |
|--------|-------------|-----------|
| `start-backend-debug.sh` | Start with debug (no suspend) | 5005 |
| `start-backend-debug-suspend.sh` | Start with debug (wait for debugger) | 5005 |

### Testing Scripts (`testing/`)

| Script | Description | Options |
|--------|-------------|---------|
| `run-tests.sh` | Run all tests with coverage | --skip-integration, --coverage, --module |

### Utility Scripts (`utils/`)

| Script | Description | Usage |
|--------|-------------|-------|
| `set-version.sh` | Manage project version | patch/minor/major/release |
| `build.sh` | Build all modules | - |
| `compile.sh` | Compile without tests | - |
| `deploy.sh` | Deploy application | - |
| `database-setup.sh` | Initialize database | - |

## Usage Examples

### Development Workflow

```bash
# 1. Start backend with debug
./scripts/debug/start-backend-debug.sh

# 2. Run tests in another terminal
./scripts/testing/run-tests.sh --skip-integration

# 3. Stop when done
./scripts/startup/stop-backend.sh
```

### Full Stack Development

```bash
# Start everything locally (recommended)
./scripts/startup/start-fullstack.sh
```

### Version Management

```bash
# Increment version
./scripts/utils/set-version.sh minor

# Release version (remove SNAPSHOT)
./scripts/utils/set-version.sh release
```

## Adding New Scripts

When adding new scripts:

1. Choose the appropriate directory based on purpose
2. Make the script executable: `chmod +x script-name.sh`
3. Add documentation to this README
4. Follow naming convention: `verb-noun.sh` (e.g., `start-backend.sh`, `run-tests.sh`)

## Script Standards

All scripts should:
- Include shebang: `#!/bin/bash`
- Have descriptive comments
- Use `set -e` for error handling (when appropriate)
- Print informative messages
- Be idempotent when possible
- Clean up on failure
