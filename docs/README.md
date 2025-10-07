# UniCloud Documentation

This directory contains all project documentation, organized by topic.

## Directory Structure

```
docs/
├── setup/            # Setup and configuration guides
├── debugging/        # Debugging guides and tools
├── api/              # API documentation
└── CHANGELOG.md      # Version history
```

## Documentation Index

### Setup & Configuration (`setup/`)

- **COMMIT_GUIDELINES.md** - Git commit message standards and examples

### Debugging (`debugging/`)

- **DEBUG.md** - Comprehensive debugging guide for all IDEs
- **NVIM-DEBUG.md** - AstroNvim/Neovim debugging setup and usage

### API Documentation (`api/`)

- Coming soon: OpenAPI/Swagger documentation
- Coming soon: REST API examples and endpoints

### Project Documentation

- **CHANGELOG.md** - Version history and release notes
- **../README.md** - Main project documentation (in root)

## Quick Links

### For Developers

1. **Getting Started**
   - Read: `../README.md` (Project overview)
   - Setup: Follow Quick Start in README
   - Contribute: Read `setup/COMMIT_GUIDELINES.md`

2. **Debugging**
   - IDE users: Read `debugging/DEBUG.md`
   - Neovim users: Read `debugging/NVIM-DEBUG.md`
   - Quick debug: Run `../scripts/debug/start-backend-debug.sh`

3. **Testing**
   - Read: `../README.md` → Testing & CI/CD section
   - Run tests: `../scripts/testing/run-tests.sh`

### For DevOps

1. **Deployment**
   - Docker: See `../README.md` → Docker Deployment
   - Environment: See `../README.md` → Environment Variables

2. **CI/CD**
   - Pipeline: `.github/workflows/ci.yml`
   - Documentation: `../README.md` → Continuous Integration

### For Contributors

1. **Before Contributing**
   - Read: `setup/COMMIT_GUIDELINES.md`
   - Read: `../README.md` → Contributing section

2. **Development Workflow**
   - Create branch: `git checkout -b feature/your-feature`
   - Make changes
   - Commit: Follow commit guidelines
   - Test: `../scripts/testing/run-tests.sh`
   - Push and create PR

## Documentation Standards

When adding documentation:

1. **File Naming**
   - Use UPPERCASE for important files: `README.md`, `CHANGELOG.md`
   - Use kebab-case for others: `api-guide.md`, `setup-instructions.md`

2. **Markdown Format**
   - Use headers hierarchically (# → ## → ###)
   - Include table of contents for long documents
   - Use code blocks with language specification
   - Include examples and screenshots when helpful

3. **Content Organization**
   - Start with overview/purpose
   - Include quick start section
   - Provide detailed explanations
   - Add troubleshooting section
   - Link to related documentation

4. **Keep Updated**
   - Update when features change
   - Add to CHANGELOG when documenting changes
   - Review documentation during code review

## Contributing to Documentation

Documentation improvements are always welcome!

1. Found unclear documentation? Open an issue
2. Want to improve docs? Submit a PR
3. Adding new features? Include documentation updates
4. Found a typo? Fix it and submit a PR

## Future Documentation

Planned documentation to be added:

- [ ] API Reference (OpenAPI/Swagger)
- [ ] Architecture Decision Records (ADRs)
- [ ] Database Schema Documentation
- [ ] Deployment Guides (AWS, Azure, GCP)
- [ ] Security Best Practices
- [ ] Performance Tuning Guide
- [ ] Troubleshooting Guide
- [ ] User Manual (for desktop app)
