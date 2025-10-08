# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported |
| ------- | --------- |
| 0.1.x   | Yes       |
| < 0.1   | No        |

## Reporting a Vulnerability

If you discover a security vulnerability within UniCloud, please send an email to paulkokos@example.com. All security vulnerabilities will be promptly addressed.

**Please do not report security vulnerabilities through public GitHub issues.**

### What to Include

Please include the following information in your report:

- Type of vulnerability
- Full paths of source file(s) related to the vulnerability
- Location of the affected source code (tag/branch/commit or direct URL)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### What to Expect

- Acknowledgment of your report within 48 hours
- Regular updates on the progress of fixing the vulnerability
- Notification when the vulnerability is fixed
- Public disclosure coordinated with you

## Security Best Practices

When using UniCloud, we recommend:

1. **Keep dependencies updated** - Regularly update all dependencies to their latest secure versions
2. **Use strong passwords** - Minimum 12 characters with mixed case, numbers, and symbols
3. **Enable 2FA** - Use two-factor authentication for cloud provider accounts
4. **Secure your JWT secret** - Use a strong, randomly generated 256-bit key
5. **Use HTTPS** - Always use TLS/SSL in production
6. **Regular backups** - Backup your database regularly
7. **Monitor logs** - Review application logs for suspicious activity
8. **Least privilege** - Use minimal permissions for database users and cloud accounts

## Known Security Considerations

### OAuth 2.0 Tokens

- OAuth tokens are stored encrypted in the database
- Tokens are never logged or exposed in API responses
- Tokens expire according to provider policies

### Database Security

- All passwords are hashed using BCrypt
- Database connections use prepared statements to prevent SQL injection
- Row-level security policies protect user data

### JWT Tokens

- JWT tokens expire after 24 hours by default
- Tokens are signed with HS256 algorithm
- Refresh tokens should be rotated regularly

## Security Updates

Security updates will be released as patch versions (0.1.x) and documented in the CHANGELOG.

For critical vulnerabilities, we will:
1. Release a patch within 24-48 hours
2. Notify users via GitHub Security Advisories
3. Provide migration steps if needed
