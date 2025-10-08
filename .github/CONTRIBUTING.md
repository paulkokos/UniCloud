# Contributing to UniCloud

Thank you for your interest in contributing to UniCloud! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites

- Java 17 or higher
- Maven 3.8+
- Docker and Docker Compose
- Git
- PostgreSQL 15 (optional for local development)

### Setting Up Development Environment

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/UniCloud.git
   cd UniCloud
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/paulkokos/UniCloud.git
   ```
4. Install dependencies:
   ```bash
   mvn clean install
   ```
5. Start development environment:
   ```bash
   ./scripts/startup/start-fullstack.sh
   ```

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Test additions or modifications
- `chore/` - Maintenance tasks

### 2. Make Your Changes

- Write clear, readable code
- Follow our coding standards
- Add tests for new functionality
- Update documentation as needed

### 3. Test Your Changes

```bash
# Run all tests
mvn test

# Run integration tests
mvn verify

# Run code quality checks
mvn checkstyle:check
mvn spotbugs:check
```

### 4. Commit Your Changes

Follow our [Commit Message Guidelines](../../COMMIT_GUIDELINES.md).

```bash
git add .
git commit -m "feat: add user authentication"
```

### 5. Keep Your Branch Updated

```bash
git fetch upstream
git rebase upstream/master
```

### 6. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

## Commit Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. See [COMMIT_GUIDELINES.md](../../COMMIT_GUIDELINES.md) for detailed information.

**Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting, etc.)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks
- `perf` - Performance improvements
- `ci` - CI/CD changes

## Pull Request Process

### Before Submitting

1. Ensure all tests pass
2. Update documentation
3. Add entry to CHANGELOG.md (if applicable)
4. Ensure code follows style guidelines
5. Squash commits if necessary

### Submitting a Pull Request

1. Push your branch to your fork
2. Open a pull request against `master` branch
3. Fill out the PR template completely
4. Link related issues
5. Request review from maintainers

### PR Requirements

- All CI checks must pass
- At least one approving review required
- Code coverage must not decrease
- No merge conflicts
- Branch must be up to date with master

### PR Review Process

- Maintainers will review within 48 hours
- Address review comments
- Update PR as needed
- Once approved, maintainers will merge

## Coding Standards

### Java

- Follow [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
- Use meaningful variable names
- Keep methods small and focused
- Add JavaDoc for public methods
- Maximum line length: 100 characters

### Code Quality

Run before committing:
```bash
mvn checkstyle:check
mvn spotbugs:check
```

### Database

- Use Flyway migrations for schema changes
- Never modify existing migrations
- Add new migration files with incremental version numbers
- Test migrations on clean database

### API Design

- Use RESTful conventions
- Return DTOs, never entities
- Use proper HTTP status codes
- Document endpoints in Wiki

## Testing

### Unit Tests

- Write unit tests for all business logic
- Use JUnit 5
- Mock external dependencies
- Aim for >80% code coverage

```bash
mvn test
```

### Integration Tests

- Test database interactions
- Use TestContainers for PostgreSQL
- Test API endpoints end-to-end

```bash
mvn verify
```

### Test Naming

```java
@Test
void shouldReturnUserWhenValidIdProvided() {
    // Test implementation
}
```

## Documentation

### Code Documentation

- Add JavaDoc for public classes and methods
- Include parameter descriptions
- Document exceptions thrown
- Provide usage examples

### Wiki Documentation

Update relevant Wiki pages:
- [Getting Started](https://github.com/paulkokos/UniCloud/wiki/Getting-Started)
- [Architecture](https://github.com/paulkokos/UniCloud/wiki/Architecture)
- [API Documentation](https://github.com/paulkokos/UniCloud/wiki/API-Documentation)

### README Updates

Update README.md if:
- Adding new features
- Changing setup process
- Modifying API endpoints
- Adding dependencies

## Questions?

- Check existing [Issues](https://github.com/paulkokos/UniCloud/issues)
- Review [Wiki](https://github.com/paulkokos/UniCloud/wiki)
- Ask in pull request comments

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
