# Changelog

All notable changes to UniCloud will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- IEEE Semantic Versioning 2.0.0 implementation
- Version management script (`set-version.sh`)
- Comprehensive CI/CD pipeline with GitHub Actions
- JaCoCo code coverage reporting (40% minimum)
- Code quality tools (Checkstyle, SpotBugs, OWASP)
- Test infrastructure with TestContainers
- Test runner script (`run-tests.sh`)
- Maven Versions Plugin for version management
- Complete API documentation in README
- Startup scripts for various development scenarios
- Database setup with PostgreSQL schema
- User management REST API
- User model with JPA relationships
- Security configuration with BCrypt
- Multi-module Maven project structure

### Changed
- Project version from `1.0.0-SNAPSHOT` to `0.1.0-SNAPSHOT` (IEEE compliant)
- Updated README with comprehensive documentation
- Consolidated duplicate User model to common module
- Fixed JPA entity annotations and relationships

### Fixed
- Missing `@Id` annotation on User entity
- Duplicate User model between backend and common modules
- Missing PasswordEncoder bean in SecurityConfig
- Docker port conflicts (PostgreSQL)
- UserDTO status field mapping

### Security
- BCrypt password hashing
- JWT token-based authentication
- Spring Security configuration
- OWASP dependency checking in CI pipeline

---

## Version History

### [0.1.0-SNAPSHOT] - Development

**Status**: Active Development
- Initial project setup
- Core infrastructure complete
- API foundation ready
- Tests infrastructure ready (tests pending implementation)
- Cloud provider integration pending

**Not Production Ready**:
- Limited test coverage
- API may change
- Cloud integrations not implemented

---

## Release Checklist Template

Use this checklist for future releases:

### Pre-Release
- [ ] All tests passing (`./run-tests.sh`)
- [ ] Code coverage meets minimum (40%+)
- [ ] No critical security vulnerabilities (OWASP)
- [ ] Code quality checks pass (Checkstyle, SpotBugs)
- [ ] Documentation updated
- [ ] CHANGELOG.md updated

### Release
- [ ] Version updated (`./set-version.sh release`)
- [ ] Git tag created (`git tag -a vX.Y.Z`)
- [ ] Tag pushed to remote
- [ ] GitHub Release created
- [ ] Docker images built and tagged

### Post-Release
- [ ] Version bumped to next SNAPSHOT (`./set-version.sh patch`)
- [ ] Announcement published (if applicable)

---

## Format Guidelines

### Categories
- **Added** - New features
- **Changed** - Changes to existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Security fixes/improvements

### Version Format
```
## [X.Y.Z] - YYYY-MM-DD

### Added
- Feature description

### Fixed
- Bug fix description
```

---

**Note**: This changelog will be maintained starting with version `0.1.0`. Future releases will document all significant changes following this format.
