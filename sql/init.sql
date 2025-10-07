-- UniCloud Database Initialization Script
-- This script sets up the basic database structure and extensions

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Create schemas
CREATE SCHEMA IF NOT EXISTS unicloud;
CREATE SCHEMA IF NOT EXISTS audit;

-- Set default schema
SET search_path TO unicloud, public;

-- Create enum types
CREATE TYPE user_status AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING_VERIFICATION');
CREATE TYPE cloud_provider AS ENUM ('GOOGLE_DRIVE', 'ONEDRIVE', 'ICLOUD');
CREATE TYPE file_operation AS ENUM ('UPLOAD', 'DOWNLOAD', 'DELETE', 'VIEW', 'SHARE');

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    status user_status DEFAULT 'PENDING_VERIFICATION',
    email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255),
    password_reset_token VARCHAR(255),
    password_reset_expires TIMESTAMP,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    version INTEGER DEFAULT 0
);

-- Cloud accounts table
CREATE TABLE IF NOT EXISTS cloud_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider cloud_provider NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    provider_email VARCHAR(255),
    account_name VARCHAR(255),
    access_token TEXT,
    refresh_token TEXT,
    token_expires_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    total_quota BIGINT DEFAULT 0,
    used_quota BIGINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, provider, provider_user_id)
);

-- Files table
CREATE TABLE IF NOT EXISTS files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    cloud_account_id UUID NOT NULL REFERENCES cloud_accounts(id) ON DELETE CASCADE,
    provider_file_id VARCHAR(500) NOT NULL,
    file_name VARCHAR(500) NOT NULL,
    file_path VARCHAR(1000),
    mime_type VARCHAR(100),
    file_size BIGINT NOT NULL DEFAULT 0,
    checksum VARCHAR(64),
    is_folder BOOLEAN DEFAULT FALSE,
    parent_folder_id UUID REFERENCES files(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    provider_created_at TIMESTAMP,
    provider_updated_at TIMESTAMP,
    UNIQUE(cloud_account_id, provider_file_id)
);

-- File operations audit table
CREATE TABLE IF NOT EXISTS audit.file_operations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    file_id UUID REFERENCES files(id),
    operation file_operation NOT NULL,
    provider cloud_provider NOT NULL,
    file_name VARCHAR(500),
    file_size BIGINT,
    ip_address INET,
    user_agent TEXT,
    status VARCHAR(20) NOT NULL, -- SUCCESS, FAILED, PENDING
    error_message TEXT,
    duration_ms INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User sessions table
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_accessed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Application settings table
CREATE TABLE IF NOT EXISTS app_settings (
    key VARCHAR(100) PRIMARY KEY,
    value TEXT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

CREATE INDEX IF NOT EXISTS idx_cloud_accounts_user_id ON cloud_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_cloud_accounts_provider ON cloud_accounts(provider);
CREATE INDEX IF NOT EXISTS idx_cloud_accounts_is_active ON cloud_accounts(is_active);

CREATE INDEX IF NOT EXISTS idx_files_user_id ON files(user_id);
CREATE INDEX IF NOT EXISTS idx_files_cloud_account_id ON files(cloud_account_id);
CREATE INDEX IF NOT EXISTS idx_files_file_name ON files(file_name);
CREATE INDEX IF NOT EXISTS idx_files_parent_folder_id ON files(parent_folder_id);
CREATE INDEX IF NOT EXISTS idx_files_is_folder ON files(is_folder);
CREATE INDEX IF NOT EXISTS idx_files_created_at ON files(created_at);

CREATE INDEX IF NOT EXISTS idx_file_operations_user_id ON audit.file_operations(user_id);
CREATE INDEX IF NOT EXISTS idx_file_operations_operation ON audit.file_operations(operation);
CREATE INDEX IF NOT EXISTS idx_file_operations_provider ON audit.file_operations(provider);
CREATE INDEX IF NOT EXISTS idx_file_operations_created_at ON audit.file_operations(created_at);
CREATE INDEX IF NOT EXISTS idx_file_operations_status ON audit.file_operations(status);

CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_session_token ON user_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires_at ON user_sessions(expires_at);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cloud_accounts_updated_at BEFORE UPDATE ON cloud_accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_files_updated_at BEFORE UPDATE ON files
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_app_settings_updated_at BEFORE UPDATE ON app_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default application settings
INSERT INTO app_settings (key, value, description) VALUES
    ('max_file_size', '104857600', 'Maximum file size in bytes (100MB)'),
    ('max_files_per_user', '10000', 'Maximum number of files per user'),
    ('session_timeout', '86400', 'Session timeout in seconds (24 hours)'),
    ('email_verification_required', 'true', 'Whether email verification is required'),
    ('maintenance_mode', 'false', 'Whether application is in maintenance mode')
ON CONFLICT (key) DO NOTHING;

-- Create function to clean up expired sessions
CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM user_sessions WHERE expires_at < CURRENT_TIMESTAMP;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Create function to get user storage statistics
CREATE OR REPLACE FUNCTION get_user_storage_stats(user_uuid UUID)
RETURNS TABLE(
    provider cloud_provider,
    total_files BIGINT,
    total_size BIGINT,
    used_quota BIGINT,
    total_quota BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ca.provider,
        COUNT(f.id) as total_files,
        COALESCE(SUM(f.file_size), 0) as total_size,
        ca.used_quota,
        ca.total_quota
    FROM cloud_accounts ca
    LEFT JOIN files f ON ca.id = f.cloud_account_id
    WHERE ca.user_id = user_uuid AND ca.is_active = true
    GROUP BY ca.provider, ca.used_quota, ca.total_quota;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT USAGE ON SCHEMA unicloud TO PUBLIC;
GRANT USAGE ON SCHEMA audit TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA unicloud TO PUBLIC;
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA audit TO PUBLIC;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA unicloud TO PUBLIC;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA audit TO PUBLIC;

-- Log initialization completion
INSERT INTO app_settings (key, value, description) VALUES
    ('db_initialized_at', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)::TEXT, 'Database initialization timestamp')
ON CONFLICT (key) DO UPDATE SET
    value = EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)::TEXT,
    updated_at = CURRENT_TIMESTAMP;