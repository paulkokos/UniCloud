# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-10-08

### Added

**Core Features:**
- Multi-cloud file management system supporting Google Drive, OneDrive, and iCloud
- Spring Boot 3.4 backend with REST API
- JavaFX 17 desktop application
- User authentication and management
- PostgreSQL 15 database with JPA/Hibernate
- Redis 7 for caching and session management
- JWT token-based authentication
- OAuth 2.0 integration for cloud providers

**API Endpoints:**
- User CRUD operations (GET, POST, PUT, DELETE)
- User search and filtering
- User statistics endpoint
- Email verification endpoint
- Status management endpoint

**Database:**
- Users table with email verification
- Cloud accounts table for OAuth tokens
- Files table for metadata storage
- Flyway database migrations
- Row-level security policies

**Development Tools:**
- Docker and Docker Compose support
- Development and production Dockerfiles
- Startup scripts for various environments
- Adminer for database management
- Redis Commander for cache management

**CI/CD:**
- GitHub Actions workflow
- Build and compile job
- Unit and integration tests
- Code coverage with JaCoCo
- Code quality checks (Checkstyle, SpotBugs)
- Security scanning (OWASP dependency check)
- Docker image build and validation
- CodeQL security analysis
- Dependabot for dependency updates

**Documentation:**
- Comprehensive README with badges
- Wiki with 7 pages (Getting Started, Architecture, API Docs, etc.)
- Commit guidelines (Conventional Commits)
- Contributing guidelines
- Code of Conduct
- Security policy
- Issue and PR templates

**Project Management:**
- 25 GitHub issues organized by milestone
- 4 milestones (v0.2.0, v0.3.0, v0.4.0, v1.0.0)
- GitHub Projects board
- Issue labels and categorization

### Fixed
- Docker build issues with multi-stage Dockerfile
- Startup scripts path resolution
- Checkstyle configuration in Docker builds
- PostgreSQL version inconsistencies

### Security
- BCrypt password hashing
- JWT token expiration (24 hours)
- OAuth token encryption in database
- SQL injection prevention with JPA
- Dependabot enabled for automated updates
- CodeQL scanning for vulnerabilities

### Infrastructure
- Docker Compose for development
- PostgreSQL on port 5433
- Redis on port 6379
- Backend on port 8080
- Debug port 5005
- Adminer on port 8081
- Redis Commander on port 8082

[Unreleased]: https://github.com/paulkokos/UniCloud/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/paulkokos/UniCloud/releases/tag/v0.1.0
