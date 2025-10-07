# UniCloud Git Commit Guidelines

## Commit Message Format

Each commit message consists of a **header**, a **body** (optional), and a **footer** (optional).

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

Must be one of the following:

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (formatting, whitespace, etc)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding or correcting tests
- **build**: Changes to build system or dependencies (Maven, Docker)
- **ci**: Changes to CI configuration (GitHub Actions, Jenkins)
- **chore**: Other changes that don't modify src or test files

### Scope

The scope specifies the module or area affected:

- **auth**: Authentication/authorization
- **user**: User management
- **google-drive**: Google Drive integration
- **onedrive**: OneDrive integration
- **icloud**: iCloud integration
- **file**: File operations
- **storage**: Storage quota management
- **desktop**: Desktop UI
- **backend**: Backend API
- **database**: Database/JPA changes
- **config**: Configuration changes

### Subject

- Use imperative, present tense: "add" not "added" nor "adds"
- Don't capitalize first letter
- No period (.) at the end
- Maximum 50 characters

### Body (Optional)

- Use imperative, present tense
- Include motivation for change
- Contrast with previous behavior
- Wrap at 72 characters

### Footer (Optional)

- Reference issues: `Closes #123`
- Breaking changes: `BREAKING CHANGE: description`

## Examples

### Simple commit

```bash
feat(auth): add JWT token generation
```

### Commit with scope and description

```bash
fix(google-drive): resolve timeout on large file uploads

Increased timeout from 30s to 5m for files larger than 100MB.
Added retry logic for network interruptions.
```

### Breaking change

```bash
feat(api)!: change authentication endpoint structure

BREAKING CHANGE: /api/auth/login is now /api/v1/auth/login
All authentication endpoints are now versioned.
```

### Multiple changes

```bash
feat(file): add batch upload functionality

- Support multiple file selection
- Add progress tracking for each file
- Implement parallel upload with thread pool

Closes #45
```

### Bug fix

```bash
fix(onedrive): correct OAuth redirect URI

The redirect URI was missing the protocol prefix causing
OAuth authentication to fail in production environment.

Fixes #78
```

## Quick Reference

| Starting work | Command                                                     |
| ------------- | ----------------------------------------------------------- |
| New feature   | `git commit -m "feat(scope): add feature description"`      |
| Bug fix       | `git commit -m "fix(scope): resolve bug description"`       |
| Documentation | `git commit -m "docs: update section name"`                 |
| Tests         | `git commit -m "test(scope): add test description"`         |
| Refactoring   | `git commit -m "refactor(scope): improve code description"` |

## Best Practices

1. **Commit often**: Small, focused commits are better than large ones
2. **One logical change per commit**: Don't mix refactoring with bug fixes
3. **Test before committing**: Ensure code compiles and tests pass
4. **Write meaningful messages**: Future you will thank present you
5. **Reference issues**: Link commits to issue tracker when applicable

## Examples for UniCloud

### Good Commit Messages

```bash
# Backend development
git commit -m "feat(auth): implement user registration endpoint"
git commit -m "feat(auth): add password encryption with BCrypt"
git commit -m "fix(auth): validate email format on registration"
git commit -m "test(auth): add unit tests for login service"
git commit -m "refactor(auth): simplify JWT token validation logic"

# Cloud integration
git commit -m "feat(google-drive): implement OAuth 2.0 flow"
git commit -m "feat(google-drive): add file upload functionality"
git commit -m "fix(google-drive): handle expired access tokens"
git commit -m "refactor(google-drive): extract token refresh logic"
git commit -m "perf(onedrive): optimize large file upload with chunking"

# Desktop UI
git commit -m "feat(desktop): create login screen layout"
git commit -m "feat(desktop): add file list view component"
git commit -m "fix(desktop): correct button alignment on main window"
git commit -m "style(desktop): apply consistent color scheme"
git commit -m "refactor(desktop): extract file list into separate component"

# Database
git commit -m "feat(database): create User entity and repository"
git commit -m "feat(database): add CloudAccount entity with relationships"
git commit -m "refactor(database): optimize file query with indexes"
git commit -m "fix(database): correct foreign key constraint on files table"

# Infrastructure
git commit -m "build(maven): add PostgreSQL dependency"
git commit -m "build(maven): upgrade Spring Boot to 3.4.1"
git commit -m "ci: configure GitHub Actions workflow"
git commit -m "chore(docker): update postgres image to 15-alpine"
git commit -m "docs(readme): add Docker setup instructions"

# Multi-line commits with body
git commit -m "feat(file): add batch upload functionality

- Support multiple file selection
- Add progress tracking for each file
- Implement parallel upload with thread pool
- Add cancel operation for in-progress uploads

Closes #45"

git commit -m "fix(onedrive): resolve timeout on large file uploads

Increased timeout from 30s to 5m for files larger than 100MB.
Added retry logic with exponential backoff for network interruptions.

Fixes #78"
```

### Bad Commit Messages

```bash
# Don't do this!
git commit -m "fixed stuff"
git commit -m "WIP"
git commit -m "asdfasdf"
git commit -m "Changes"
git commit -m "Update file"
git commit -m "Final version"
git commit -m "Really final version"
git commit -m "fix bug"
git commit -m "more changes"
git commit -m "."
```

### Why the bad examples are bad:

- Not descriptive - what was fixed?
- No context - which module?
- Not searchable - can't find later
- No commit type - feat? fix? docs?
- Unprofessional - looks careless

## Enforcing Standards

Consider using these tools:

1. **Commitlint**: Validates commit messages
2. **Husky**: Git hooks to check commits before push
3. **Commitizen**: Interactive commit message builder

## Summary

- Use conventional commit format
- Keep commits small and focused
- Write clear, descriptive messages
- Reference related issues
- Be consistent across the team
