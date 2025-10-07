-- Production Database Initialization Script
-- This script sets up production-specific configurations and optimizations

SET search_path TO unicloud, public;

-- Production-specific settings
INSERT INTO app_settings (key, value, description) VALUES
    ('environment', 'production', 'Current environment'),
    ('maintenance_mode', 'false', 'Whether application is in maintenance mode'),
    ('registration_enabled', 'true', 'Whether new user registration is enabled'),
    ('email_verification_required', 'true', 'Whether email verification is required'),
    ('oauth_enabled', 'true', 'Whether OAuth authentication is enabled'),
    ('audit_enabled', 'true', 'Whether audit logging is enabled'),
    ('metrics_enabled', 'true', 'Whether metrics collection is enabled'),
    ('backup_enabled', 'true', 'Whether automated backups are enabled'),
    ('rate_limiting_enabled', 'true', 'Whether API rate limiting is enabled'),
    ('ssl_required', 'true', 'Whether SSL/TLS is required for all connections'),

    -- File handling settings
    ('max_file_size', '104857600', 'Maximum file size in bytes (100MB)'),
    ('max_files_per_user', '10000', 'Maximum number of files per user'),
    ('allowed_file_types', 'pdf,doc,docx,xls,xlsx,ppt,pptx,txt,jpg,jpeg,png,gif,mp4,mp3,zip,rar', 'Allowed file extensions'),
    ('virus_scanning_enabled', 'true', 'Whether virus scanning is enabled'),
    ('file_retention_days', '365', 'Number of days to retain deleted files'),

    -- Security settings
    ('session_timeout', '86400', 'Session timeout in seconds (24 hours)'),
    ('max_login_attempts', '5', 'Maximum failed login attempts before lockout'),
    ('password_min_length', '8', 'Minimum password length'),
    ('password_require_special', 'true', 'Whether passwords require special characters'),
    ('jwt_expiration', '86400', 'JWT token expiration in seconds'),
    ('refresh_token_expiration', '604800', 'Refresh token expiration in seconds (7 days)'),

    -- Performance settings
    ('cache_enabled', 'true', 'Whether caching is enabled'),
    ('cache_ttl', '3600', 'Cache time-to-live in seconds'),
    ('db_connection_pool_size', '20', 'Database connection pool size'),
    ('async_processing_enabled', 'true', 'Whether async processing is enabled'),

    -- Monitoring settings
    ('health_check_interval', '30', 'Health check interval in seconds'),
    ('log_level', 'INFO', 'Application log level'),
    ('metrics_retention_days', '30', 'Number of days to retain metrics'),
    ('alert_email', '', 'Email address for alerts (to be configured)')
ON CONFLICT (key) DO NOTHING;

-- Create production-specific indexes for performance
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_last_login
ON users(last_login) WHERE last_login IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_created_at_status
ON users(created_at, status) WHERE status = 'ACTIVE';

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_cloud_accounts_updated_at
ON cloud_accounts(updated_at) WHERE is_active = true;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_files_size_created
ON files(file_size, created_at) WHERE file_size > 0;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_files_mime_type
ON files(mime_type) WHERE mime_type IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_file_operations_created_status
ON audit.file_operations(created_at, status);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_file_operations_user_created
ON audit.file_operations(user_id, created_at);

-- Create partial indexes for common queries
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_files_active_user_folders
ON files(user_id, is_folder) WHERE is_folder = true;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sessions_active
ON user_sessions(user_id, expires_at) WHERE expires_at > CURRENT_TIMESTAMP;

-- Create production monitoring views
CREATE OR REPLACE VIEW prod_system_health AS
SELECT
    'database_size' as metric,
    pg_size_pretty(pg_database_size(current_database())) as value,
    'Database size' as description
UNION ALL
SELECT
    'active_connections' as metric,
    COUNT(*)::TEXT as value,
    'Active database connections' as description
FROM pg_stat_activity
WHERE state = 'active'
UNION ALL
SELECT
    'total_users' as metric,
    COUNT(*)::TEXT as value,
    'Total registered users' as description
FROM users
UNION ALL
SELECT
    'active_users' as metric,
    COUNT(*)::TEXT as value,
    'Active users' as description
FROM users WHERE status = 'ACTIVE'
UNION ALL
SELECT
    'total_files' as metric,
    COUNT(*)::TEXT as value,
    'Total files stored' as description
FROM files
UNION ALL
SELECT
    'total_storage_used' as metric,
    pg_size_pretty(SUM(file_size)) as value,
    'Total storage used' as description
FROM files;

CREATE OR REPLACE VIEW prod_user_activity AS
SELECT
    DATE(fo.created_at) as activity_date,
    COUNT(DISTINCT fo.user_id) as active_users,
    COUNT(*) as total_operations,
    SUM(CASE WHEN fo.operation = 'UPLOAD' THEN 1 ELSE 0 END) as uploads,
    SUM(CASE WHEN fo.operation = 'DOWNLOAD' THEN 1 ELSE 0 END) as downloads,
    SUM(CASE WHEN fo.status = 'SUCCESS' THEN 1 ELSE 0 END) as successful_operations,
    SUM(CASE WHEN fo.status = 'FAILED' THEN 1 ELSE 0 END) as failed_operations,
    AVG(fo.duration_ms) as avg_duration_ms
FROM audit.file_operations fo
WHERE fo.created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(fo.created_at)
ORDER BY activity_date DESC;

CREATE OR REPLACE VIEW prod_storage_summary AS
SELECT
    ca.provider,
    COUNT(DISTINCT ca.user_id) as users_count,
    COUNT(ca.id) as accounts_count,
    SUM(ca.total_quota) as total_quota_bytes,
    SUM(ca.used_quota) as used_quota_bytes,
    AVG(ca.used_quota::NUMERIC / NULLIF(ca.total_quota, 0) * 100) as avg_usage_percent
FROM cloud_accounts ca
WHERE ca.is_active = true
GROUP BY ca.provider;

-- Create production maintenance functions
CREATE OR REPLACE FUNCTION cleanup_expired_data()
RETURNS TABLE(
    operation TEXT,
    rows_affected INTEGER,
    execution_time INTERVAL
) AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    affected_rows INTEGER;
BEGIN
    -- Clean expired sessions
    start_time := CURRENT_TIMESTAMP;
    DELETE FROM user_sessions WHERE expires_at < CURRENT_TIMESTAMP;
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    end_time := CURRENT_TIMESTAMP;

    RETURN QUERY SELECT 'expired_sessions'::TEXT, affected_rows, (end_time - start_time);

    -- Clean old audit logs (older than 1 year)
    start_time := CURRENT_TIMESTAMP;
    DELETE FROM audit.file_operations
    WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '1 year';
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    end_time := CURRENT_TIMESTAMP;

    RETURN QUERY SELECT 'old_audit_logs'::TEXT, affected_rows, (end_time - start_time);

    -- Clean orphaned files (files without valid cloud accounts)
    start_time := CURRENT_TIMESTAMP;
    DELETE FROM files f
    WHERE NOT EXISTS (
        SELECT 1 FROM cloud_accounts ca
        WHERE ca.id = f.cloud_account_id AND ca.is_active = true
    );
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    end_time := CURRENT_TIMESTAMP;

    RETURN QUERY SELECT 'orphaned_files'::TEXT, affected_rows, (end_time - start_time);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_daily_report()
RETURNS TABLE(
    report_date DATE,
    total_users INTEGER,
    new_users_today INTEGER,
    active_users_today INTEGER,
    total_operations_today INTEGER,
    successful_operations_today INTEGER,
    failed_operations_today INTEGER,
    total_storage_used BIGINT,
    avg_operation_duration_ms NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CURRENT_DATE as report_date,
        (SELECT COUNT(*)::INTEGER FROM users) as total_users,
        (SELECT COUNT(*)::INTEGER FROM users WHERE DATE(created_at) = CURRENT_DATE) as new_users_today,
        (SELECT COUNT(DISTINCT user_id)::INTEGER FROM audit.file_operations
         WHERE DATE(created_at) = CURRENT_DATE) as active_users_today,
        (SELECT COUNT(*)::INTEGER FROM audit.file_operations
         WHERE DATE(created_at) = CURRENT_DATE) as total_operations_today,
        (SELECT COUNT(*)::INTEGER FROM audit.file_operations
         WHERE DATE(created_at) = CURRENT_DATE AND status = 'SUCCESS') as successful_operations_today,
        (SELECT COUNT(*)::INTEGER FROM audit.file_operations
         WHERE DATE(created_at) = CURRENT_DATE AND status = 'FAILED') as failed_operations_today,
        (SELECT COALESCE(SUM(file_size), 0) FROM files) as total_storage_used,
        (SELECT COALESCE(AVG(duration_ms), 0) FROM audit.file_operations
         WHERE DATE(created_at) = CURRENT_DATE) as avg_operation_duration_ms;
END;
$$ LANGUAGE plpgsql;

-- Create backup verification function
CREATE OR REPLACE FUNCTION verify_backup_integrity()
RETURNS TABLE(
    table_name TEXT,
    row_count BIGINT,
    last_updated TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 'users'::TEXT, COUNT(*), MAX(updated_at) FROM users
    UNION ALL
    SELECT 'cloud_accounts'::TEXT, COUNT(*), MAX(updated_at) FROM cloud_accounts
    UNION ALL
    SELECT 'files'::TEXT, COUNT(*), MAX(updated_at) FROM files
    UNION ALL
    SELECT 'file_operations'::TEXT, COUNT(*), MAX(created_at) FROM audit.file_operations
    UNION ALL
    SELECT 'user_sessions'::TEXT, COUNT(*), MAX(created_at) FROM user_sessions;
END;
$$ LANGUAGE plpgsql;

-- Set up automatic statistics collection
UPDATE pg_stat_statements_info SET dealloc = 0 WHERE dealloc IS NOT NULL;

-- Configure automatic vacuuming for high-traffic tables
ALTER TABLE audit.file_operations SET (autovacuum_vacuum_scale_factor = 0.1);
ALTER TABLE user_sessions SET (autovacuum_vacuum_scale_factor = 0.2);
ALTER TABLE files SET (autovacuum_analyze_scale_factor = 0.05);

-- Create security policies (Row Level Security)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE cloud_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE files ENABLE ROW LEVEL SECURITY;

-- Production logging settings
INSERT INTO app_settings (key, value, description) VALUES
    ('prod_initialized_at', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)::TEXT, 'Production initialization timestamp'),
    ('prod_version', '1.0.0', 'Production database version'),
    ('last_maintenance', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)::TEXT, 'Last maintenance timestamp')
ON CONFLICT (key) DO UPDATE SET
    value = EXCLUDED.value,
    updated_at = CURRENT_TIMESTAMP;

-- Grant minimal required permissions for production
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA unicloud TO PUBLIC;
GRANT USAGE ON SCHEMA audit TO PUBLIC;

-- Log production initialization
INSERT INTO audit.file_operations (user_id, operation, provider, file_name, status, ip_address, user_agent)
VALUES (NULL, 'UPLOAD', 'GOOGLE_DRIVE', 'SYSTEM_INIT', 'SUCCESS', '127.0.0.1', 'PostgreSQL-Init');

COMMIT;