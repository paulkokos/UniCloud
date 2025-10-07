# UniCloud

<div align="center">

**A unified multi-cloud file management application**

[![Version](https://img.shields.io/badge/version-0.1.0--SNAPSHOT-blue.svg)](https://semver.org/)
[![Java](https://img.shields.io/badge/Java-17+-orange.svg)](https://openjdk.java.net/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue.svg)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

## Overview

UniCloud is a desktop application that provides a unified interface for managing files across multiple cloud storage providers including Google Drive, OneDrive, and iCloud. Built with Spring Boot and JavaFX, it offers seamless file synchronization, management, and a consistent user experience across different cloud platforms.

## Features

- **Unified Authentication** - Single sign-on for multiple cloud providers
- **Cross-Platform File Management** - Manage files across Google Drive, OneDrive, and iCloud
- **Real-Time Synchronization** - Keep your files in sync across all platforms
- **Modern Desktop UI** - Intuitive JavaFX-based interface
- **Secure Storage** - JWT authentication with OAuth 2.0 integration
- **Storage Analytics** - Track usage across all connected accounts
- **High Performance** - Built with Spring Boot and PostgreSQL

## Architecture

### Technology Stack

**Backend:**
- Java 17
- Spring Boot 3.4
- Spring Security with JWT
- Spring Data JPA
- PostgreSQL 15
- Redis 7 (caching & sessions)
- Hibernate ORM

**Frontend:**
- JavaFX 17
- FXML for UI layouts

**DevOps:**
- Docker & Docker Compose
- Maven (build tool)
- Nginx (reverse proxy)

### Project Structure

```
UniCloud/
├── unicloud-backend/       # Spring Boot REST API
│   ├── src/main/java/
│   │   └── com/unicloud/backend/
│   │       ├── config/     # Security, database config
│   │       ├── controller/ # REST endpoints
│   │       ├── service/    # Business logic
│   │       └── repository/ # Data access layer
│   └── src/main/resources/
│       └── application.properties
├── unicloud-common/        # Shared models & DTOs
│   └── src/main/java/
│       └── com/unicloud/common/
│           ├── model/      # JPA entities
│           └── dto/        # Data transfer objects
├── unicloud-desktop/       # JavaFX desktop app
│   └── src/main/java/
│       └── com/unicloud/desktop/
└── sql/                    # Database migrations
```

## Quick Start

### Prerequisites

- **Java 17+** ([OpenJDK](https://openjdk.org/) or [Oracle JDK](https://www.oracle.com/java/technologies/downloads/))
- **Maven 3.8+** ([Download](https://maven.apache.org/download.cgi))
- **Docker & Docker Compose** ([Install Docker](https://docs.docker.com/get-docker/))
- **Git** ([Download](https://git-scm.com/downloads))

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/paulkokos/UniCloud.git
cd UniCloud
```

2. **Set up environment variables** (optional)
```bash
cp .env.template .env
# Edit .env with your configuration
nano .env
```

3. **Choose your development mode**

#### Option A: Full Stack (Recommended for Development)
```bash
./start-fullstack.sh
```
This starts:
- PostgreSQL in Docker (port 5433)
- Backend locally with hot-reload (port 8080) - **debuggable**
- Desktop application

#### Option B: Backend Only
```bash
./start-backend.sh
```
Perfect for API development and testing.

#### Option C: Docker Everything
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```
All services containerized.

### Accessing Services

Once started, you can access:

| Service | URL | Credentials |
|---------|-----|-------------|
| Backend API | http://localhost:8080 | - |
| API Health Check | http://localhost:8080/actuator/health | - |
| Database Admin (Adminer) | http://localhost:8081 | user: `dev_user`, pass: `dev_password` |
| Redis Commander | http://localhost:8082 | - |
| Debug Port | localhost:5005 | For remote debugging |

## Development

### Available Scripts

| Script | Description | Use Case |
|--------|-------------|----------|
| `./start-backend.sh` | Backend + Docker PostgreSQL | API development with debugging |
| `./start-backend-local.sh` | Backend + Local PostgreSQL | Development without Docker |
| `./start-desktop.sh` | Desktop app only | UI development |
| `./start-fullstack.sh` | Backend + Desktop (local) | **Full development** (recommended) |
| `./start-fullstack-docker.sh` | Backend (Docker) + Desktop | Testing production setup |
| `./stop-backend.sh` | Stop backend services | Cleanup |

### Building the Project

```bash
# Build all modules
mvn clean install

# Build without tests
mvn clean install -DskipTests

# Build specific module
mvn clean package -pl unicloud-backend

# Run tests
mvn test
```

### Running in IDE

**IntelliJ IDEA / Eclipse / VS Code:**

1. Import as Maven project
2. Set Java SDK to 17+
3. Run `UniCloudBackendApplication.java` for backend
4. Run `UniCloudDesktopApplication.java` for desktop

**Neovim:**
```bash
# Start backend with debug port
mvn spring-boot:run -pl unicloud-backend \
  -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
```

### Database Access

**Docker PostgreSQL (port 5433):**
```bash
PGPASSWORD=dev_password psql -h localhost -p 5433 -U dev_user -d unicloud_dev
```

**Local PostgreSQL (port 5432):**
```bash
PGPASSWORD=dev_password psql -h localhost -p 5432 -U dev_user -d unicloud_dev
```

**View tables:**
```sql
\c unicloud_dev
\dn  -- List schemas
\dt unicloud.*  -- List tables in unicloud schema
SELECT * FROM unicloud.users;
```

## Testing & CI/CD

### Running Tests Locally

**Quick Test Script:**
```bash
./run-tests.sh                    # Run all tests (unit + integration)
./run-tests.sh --skip-integration # Unit tests only (faster)
./run-tests.sh --coverage         # With code coverage report
./run-tests.sh --module unicloud-backend  # Specific module
```

**Maven Commands:**
```bash
# Unit tests only
mvn test

# Integration tests (requires Docker)
mvn verify

# With code coverage
mvn clean verify jacoco:report

# Skip tests during build
mvn clean install -DskipTests

# Run specific test class
mvn test -Dtest=UserServiceTest

# Run specific test method
mvn test -Dtest=UserServiceTest#testCreateUser
```

**View Coverage Report:**
```bash
# After running tests with coverage
open unicloud-backend/target/site/jacoco/index.html
```

### Continuous Integration

This project uses **GitHub Actions** for automated CI/CD pipeline.

**Pipeline Jobs:**
1. **Build & Compile** - Maven build validation
2. **Unit Tests** - Fast, in-memory H2 database tests
3. **Integration Tests** - Real PostgreSQL via TestContainers
4. **Code Coverage** - JaCoCo reports with 40% minimum
5. **Code Quality** - Checkstyle, SpotBugs, OWASP security scan
6. **Docker Build** - Container image build & health check
7. **Build Summary** - Consolidated results

**Triggers:**
- Push to `master`, `develop`, or `feature/**` branches
- Pull requests to `master` or `develop`

**View CI Status:**
- Check the **Actions** tab in GitHub
- Badge will show: ![CI Status](https://github.com/paulkokos/UniCloud/workflows/UniCloud%20CI%20Pipeline/badge.svg)

**Coverage Reports:**
- Uploaded to Codecov (if configured)
- Available as workflow artifacts for 30 days
- PR comments show coverage changes

### Code Quality Tools

**Checkstyle (Code Style):**
```bash
mvn checkstyle:check
```

**SpotBugs (Bug Detection):**
```bash
mvn spotbugs:check
```

**OWASP Dependency Check (Security):**
```bash
mvn dependency-check:check
```

### Manual API Testing

```bash
# Health check
curl http://localhost:8080/actuator/health

# Get all users
curl http://localhost:8080/api/users

# Create a user
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john@example.com",
    "password": "SecurePass123",
    "firstName": "John",
    "lastName": "Doe"
  }'

# Get user by ID
curl http://localhost:8080/api/users/{uuid}
```

## Docker Deployment

### Development Environment

```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

**Features:**
- Hot reload enabled
- Debug port exposed (5005)
- Adminer & Redis Commander included
- Development logging

### Production Environment

```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

**Features:**
- Optimized JVM settings
- SSL/TLS with Nginx
- Health checks
- Resource limits
- Production logging
- Monitoring with Filebeat

### Environment Variables

Create a `.env` file in the project root:

```bash
# Database
DB_PASSWORD=your_secure_password
REDIS_PASSWORD=your_redis_password

# JWT Configuration
JWT_SECRET=your-256-bit-secret-key-min-32-chars
JWT_EXPIRATION=86400

# OAuth 2.0 Credentials
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
MICROSOFT_CLIENT_ID=your_microsoft_client_id
MICROSOFT_CLIENT_SECRET=your_microsoft_client_secret
ICLOUD_CLIENT_ID=your_icloud_client_id
ICLOUD_CLIENT_SECRET=your_icloud_client_secret
```

## Database Schema

### Main Entities

**Users** (`unicloud.users`)
- User authentication and profile information
- Email verification and password reset tokens
- Status management (ACTIVE, INACTIVE, SUSPENDED, PENDING_VERIFICATION)

**Cloud Accounts** (`unicloud.cloud_accounts`)
- OAuth tokens for cloud providers
- Storage quota tracking
- Provider-specific configurations

**Files** (`unicloud.files`)
- File metadata from all cloud providers
- Hierarchical folder structure
- Checksums for deduplication

### Database Migrations

SQL scripts are located in `sql/` directory:
- `init.sql` - Initial schema
- `dev-data.sql` - Development seed data
- `test-data.sql` - Test fixtures
- `prod-init.sql` - Production initialization

## Security

### Authentication Flow

1. User registers/logs in via REST API
2. Backend issues JWT token
3. Client includes JWT in subsequent requests
4. Optional OAuth 2.0 for cloud provider access

### Security Features

- BCrypt password hashing
- JWT token-based authentication
- OAuth 2.0 integration
- CSRF protection disabled for API
- Stateless session management
- Secure token storage
- SQL injection prevention (JPA)

### Production Security Checklist

- [ ] Change default passwords in `.env`
- [ ] Generate secure JWT secret (256-bit minimum)
- [ ] Enable HTTPS/SSL
- [ ] Configure OAuth credentials
- [ ] Set up firewall rules
- [ ] Enable database backups
- [ ] Review Spring Security configuration

## Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Follow commit message guidelines**
   - See [COMMIT_GUIDELINES.md](COMMIT_GUIDELINES.md)
   - Format: `type: description` (e.g., `feat: add user authentication`)
4. **Write tests for new features**
5. **Ensure all tests pass**
   ```bash
   mvn test
   ```
6. **Submit a pull request**

### Development Guidelines

- Follow Java naming conventions
- Use meaningful variable names
- Add JavaDoc comments for public methods
- Keep methods small and focused
- Write unit tests for business logic
- Use DTOs for API responses (never expose entities)

## Versioning

This project follows **IEEE Semantic Versioning 2.0.0** (SemVer).

### Version Format: `MAJOR.MINOR.PATCH[-SNAPSHOT]`

- **MAJOR** - Incompatible API changes (0.x.x → 1.0.0)
- **MINOR** - New features, backward compatible (0.1.x → 0.2.0)
- **PATCH** - Bug fixes, backward compatible (0.1.0 → 0.1.1)
- **SNAPSHOT** - Development version (not released)

### Current Version: **0.1.0-SNAPSHOT**

**Status**: Development phase
- API may change without notice
- Not recommended for production use
- Version `1.0.0` will be the first stable release

### Changing Version

Use the provided script for version management:

```bash
# Increment patch (bug fix): 0.1.0 → 0.1.1
./set-version.sh patch

# Increment minor (new feature): 0.1.5 → 0.2.0
./set-version.sh minor

# Increment major (breaking changes): 0.5.2 → 1.0.0
./set-version.sh major

# Remove SNAPSHOT for release
./set-version.sh release

# Set specific version
./set-version.sh 0.2.0-SNAPSHOT
```

### Release Process

**For Development Releases (0.x.x):**
1. Update version: `./set-version.sh minor` or `./set-version.sh patch`
2. Test: `mvn clean verify`
3. Commit: `git commit -am "chore: bump version to X.Y.Z"`
4. Continue development

**For Production Release (1.0.0+):**
1. Remove SNAPSHOT: `./set-version.sh release`
2. Run all tests: `./run-tests.sh`
3. Build: `mvn clean install`
4. Create tag: `git tag -a vX.Y.Z -m "Release X.Y.Z"`
5. Push: `git push && git push --tags`
6. Bump to next SNAPSHOT: `./set-version.sh patch`

### Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and [Releases](https://github.com/paulkokos/UniCloud/releases) for download links.

## API Documentation

### User Management

**Endpoints:**

```
GET    /api/users              - Get all users
GET    /api/users/{id}         - Get user by ID
GET    /api/users/username/{username} - Get user by username
GET    /api/users/email/{email} - Get user by email
POST   /api/users              - Create new user
PUT    /api/users/{id}         - Update user
DELETE /api/users/{id}         - Delete user
POST   /api/users/{id}/verify-email - Verify email
PUT    /api/users/{id}/status  - Update user status
GET    /api/users/stats        - Get user statistics
```

**Request/Response Examples:**

See API documentation at `/api-docs` (when Swagger is configured)

## Troubleshooting

### Common Issues

**Port 8080 already in use:**
```bash
lsof -ti:8080 | xargs kill -9
```

**Backend won't connect to database:**
```bash
# Check Docker PostgreSQL
docker ps | grep postgres
docker logs unicloud-postgres

# Restart services
docker-compose -f docker-compose.yml -f docker-compose.dev.yml restart
```

**Maven build fails:**
```bash
# Clean and rebuild
mvn clean install -U

# Skip tests if needed
mvn clean install -DskipTests
```

**Desktop app won't start:**
```bash
# Verify Java version (needs 17+)
java -version

# Check JavaFX
mvn javafx:run -pl unicloud-desktop
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Team

- **Paul Kokos** - *Lead Developer* - [@paulkokos](https://github.com/paulkokos)

## Acknowledgments

- Spring Boot team for the excellent framework
- PostgreSQL community
- OpenJFX team for JavaFX support

---

<div align="center">

**Made with care by the UniCloud Team**

[Report Bug](https://github.com/paulkokos/UniCloud/issues) · [Request Feature](https://github.com/paulkokos/UniCloud/issues)

</div>
