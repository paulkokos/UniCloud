-- V1.0.0__Initial_Schema_PostgreSQL17.sql
-- UniCloud Initial Database Schema for PostgreSQL 17

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- PostgreSQL 17 specific extensions
CREATE EXTENSION IF NOT EXISTS "pg_walinspect";  -- For WAL analysis
CREATE EXTENSION IF NOT EXISTS "pg_buffercache"; -- For buffer cache monitoring

-- Create custom types
CREATE TYPE cloud_provider AS ENUM ('GOOGLE_DRIVE', 'ONEDRIVE', 'ICLOUD');
CREATE TYPE file_status AS ENUM ('UPLOADING', 'UPLOADED', 'FAILED', 'DELETED');
CREATE TYPE oauth_token_status AS ENUM ('ACTIVE', 'EXPIRED', 'REVOKED');

-- Create custom types
CREATE TYPE cloud_provider AS ENUM ('GOOGLE_DRIVE', 'ONEDRIVE', 'ICLOUD');
CREATE TYPE file_status AS ENUM ('UPLOADING', 'UPLOADED', 'FAILED', 'DELETED');
CREATE TYPE oauth_token_status AS ENUM ('ACTIVE', 'EXPIRED', 'REVOKED');

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE,
    
    -- PostgreSQL 16 features
    CONSTRAINT users_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT users_username_format CHECK (username ~* '^[A-Za-z0-9_]{3,50}$')
);

-- Create indexes for users table
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_active ON users(is_active) WHERE is_active = true;
CREATE INDEX idx_users_created_at ON users(created_at);

-- Cloud accounts table
CREATE TABLE cloud_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider cloud_provider NOT NULL,
    account_email VARCHAR(100) NOT NULL,
    account_name VARCHAR(100),
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure one primary account per provider per user
    CONSTRAINT unique_primary_per_provider UNIQUE (user_id, provider, is_primary) 
        DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT cloud_accounts_unique_user_provider_email 
        UNIQUE (user_id, provider, account_email)
);

-- Create indexes for cloud accounts
CREATE INDEX idx_cloud_accounts_user_id ON cloud_accounts(user_id);
CREATE INDEX idx_cloud_accounts_provider ON cloud_accounts(provider);
CREATE INDEX idx_cloud_accounts_active ON cloud_accounts(is_active) WHERE is_active = true;

-- OAuth tokens table with enhanced security for PostgreSQL 16
CREATE TABLE oauth_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cloud_account_id UUID NOT NULL REFERENCES cloud_accounts(id) ON DELETE CASCADE,
    access_token TEXT NOT NULL,
    refresh_token TEXT,
    token_type VARCHAR(50) DEFAULT 'Bearer',
    scope TEXT,
    expires_at TIMESTAMP WITH TIME ZONE,
    status oauth_token_status DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Enhanced security constraints
    CONSTRAINT oauth_tokens_access_token_not_empty CHECK (length(access_token) > 0),
    CONSTRAINT oauth_tokens_valid_expiry CHECK (expires_at > created_at)
);

-- Create indexes for OAuth tokens
CREATE INDEX idx_oauth_tokens_cloud_account ON oauth_tokens(cloud_account_id);
CREATE INDEX idx_oauth_tokens_expires_at ON oauth_tokens(expires_at);
CREATE INDEX idx_oauth_tokens_status ON oauth_tokens(status);

-- Files table with JSONB support for metadata (PostgreSQL 16 feature)
CREATE TABLE files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    cloud_account_id UUID NOT NULL REFERENCES cloud_accounts(id) ON DELETE CASCADE,
    original_filename VARCHAR(255) NOT NULL,
    file_size BIGINT NOT NULL CHECK (file_size >= 0),
    mime_type VARCHAR(100),
    cloud_file_id VARCHAR(255) NOT NULL,
    cloud_file_url TEXT,
    status file_status DEFAULT 'UPLOADING',
    upload_progress INTEGER DEFAULT 0 CHECK (upload_progress >= 0 AND upload_progress <= 100),
    checksum VARCHAR(64),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    uploaded_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT files_filename_not_empty CHECK (length(original_filename) > 0),
    CONSTRAINT files_cloud_file_id_not_empty CHECK (length(cloud_file_id) > 0)
);

-- Create indexes for files table with PostgreSQL 17 optimizations
CREATE INDEX idx_files_user_id ON files(user_id);
CREATE INDEX idx_files_cloud_account_id ON files(cloud_account_id);
CREATE INDEX idx_files_status ON files(status);
CREATE INDEX idx_files_created_at ON files(created_at);
CREATE INDEX idx_files_filename_gin ON files USING gin(to_tsvector('english', original_filename));
CREATE INDEX idx_files_metadata_gin ON files USING gin(metadata);
CREATE INDEX idx_files_mime_type ON files(mime_type) WHERE mime_type IS NOT NULL;

-- File operations log for audit trail
CREATE TABLE file_operations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_id UUID NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    operation VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    error_message TEXT,
    operation_metadata JSONB DEFAULT '{}',
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    duration_ms INTEGER,
    
    CONSTRAINT file_operations_valid_duration 
        CHECK (duration_ms IS NULL OR duration_ms >= 0)
);

-- Create indexes for file operations
CREATE INDEX idx_file_operations_file_id ON file_operations(file_id);
CREATE INDEX idx_file_operations_user_id ON file_operations(user_id);
CREATE INDEX idx_file_operations_started_at ON file_operations(started_at);
CREATE INDEX idx_file_operations_operation ON file_operations(operation);

-- User sessions table for JWT management
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    refresh_token VARCHAR(255) NOT NULL UNIQUE,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    
    CONSTRAINT user_sessions_valid_expiry CHECK (expires_at > created_at)
);

-- Create indexes for user sessions
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);
CREATE INDEX idx_user_sessions_active ON user_sessions(is_active) WHERE is_active = true;

-- Storage quota tracking
CREATE TABLE storage_quotas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cloud_account_id UUID NOT NULL REFERENCES cloud_accounts(id) ON DELETE CASCADE,
    total_quota BIGINT NOT NULL CHECK (total_quota >= 0),
    used_quota BIGINT NOT NULL CHECK (used_quota >= 0),
    available_quota BIGINT GENERATED ALWAYS AS (total_quota - used_quota) STORED,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT storage_quota_valid CHECK (used_quota <= total_quota)
);

-- Create indexes for storage quotas
CREATE INDEX idx_storage_quotas_cloud_account ON storage_quotas(cloud_account_id);
CREATE INDEX idx_storage_quotas_last_updated ON storage_quotas(last_updated);

-- Application settings table
CREATE TABLE application_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    settings_data JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unique_user_settings UNIQUE (user_id)
);

-- Create indexes for application settings
CREATE INDEX idx_app_settings_user_id ON application_settings(user_id);
CREATE INDEX idx_app_settings_data_gin ON application_settings USING gin(settings_data);

-- Functions for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cloud_accounts_updated_at 
    BEFORE UPDATE ON cloud_accounts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_oauth_tokens_updated_at 
    BEFORE UPDATE ON oauth_tokens 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_files_updated_at 
    BEFORE UPDATE ON files 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_application_settings_updated_at 
    BEFORE UPDATE ON application_settings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to cleanup expired sessions
CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM user_sessions 
    WHERE expires_at < CURRENT_TIMESTAMP OR is_active = false;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to update storage quota
CREATE OR REPLACE FUNCTION update_storage_quota(
    p_cloud_account_id UUID,
    p_total_quota BIGINT,
    p_used_quota BIGINT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO storage_quotas (cloud_account_id, total_quota, used_quota, last_updated)
    VALUES (p_cloud_account_id, p_total_quota, p_used_quota, CURRENT_TIMESTAMP)
    ON CONFLICT (cloud_account_id) 
    DO UPDATE SET 
        total_quota = EXCLUDED.total_quota,
        used_quota = EXCLUDED.used_quota,
        last_updated = CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Create views for common queries
CREATE VIEW active_users_with_accounts AS
SELECT 
    u.id,
    u.username,
    u.email,
    u.first_name,
    u.last_name,
    u.created_at,
    u.last_login_at,
    COUNT(ca.id) as cloud_accounts_count
FROM users u
LEFT JOIN cloud_accounts ca ON u.id = ca.user_id AND ca.is_active = true
WHERE u.is_active = true
GROUP BY u.id, u.username, u.email, u.first_name, u.last_name, u.created_at, u.last_login_at;

CREATE VIEW file_statistics AS
SELECT 
    u.id as user_id,
    u.username,
    ca.provider,
    COUNT(f.id) as total_files,
    SUM(f.file_size) as total_size,
    COUNT(CASE WHEN f.status = 'UPLOADED' THEN 1 END) as uploaded_files,
    COUNT(CASE WHEN f.status = 'UPLOADING' THEN 1 END) as uploading_files,
    COUNT(CASE WHEN f.status = 'FAILED' THEN 1 END) as failed_files
FROM users u
JOIN cloud_accounts ca ON u.id = ca.user_id
LEFT JOIN files f ON ca.id = f.cloud_account_id AND f.deleted_at IS NULL
WHERE u.is_active = true AND ca.is_active = true
GROUP BY u.id, u.username, ca.provider;

-- Row Level Security (RLS) for enhanced security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE cloud_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
ALTER TABLE file_operations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE application_settings ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (these will be refined based on application security requirements)
CREATE POLICY users_policy ON users
    FOR ALL TO authenticated_users
    USING (id = current_user_id());

CREATE POLICY cloud_accounts_policy ON cloud_accounts
    FOR ALL TO authenticated_users
    USING (user_id = current_user_id());

CREATE POLICY files_policy ON files
    FOR ALL TO authenticated_users
    USING (user_id = current_user_id());

-- Grant permissions to application role
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'unicloud_app') THEN
        CREATE ROLE unicloud_app;
    END IF;
END
$$;

GRANT CONNECT ON DATABASE uniclouddb TO unicloud_app;
GRANT USAGE ON SCHEMA public TO unicloud_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO unicloud_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO unicloud_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO unicloud_app;

-- Insert initial admin user (password: admin123 - change in production!)
INSERT INTO users (username, email, password_hash, first_name, last_name, is_verified)
VALUES (
    'admin',
    'admin@unicloud.com',
    '$2a$10$xXx.WZrF8mwPEZgBSqkQ8uG8K.HrJqC6JmH3GdF8qR7P1nN4K9xbO', -- bcrypt hash of 'admin123'
    'System',
    'Administrator',
    true
);

-- Performance monitoring view for PostgreSQL 17
CREATE VIEW system_performance AS
SELECT 
    'users' as table_name,
    pg_size_pretty(pg_total_relation_size('users')) as table_size,
    (SELECT COUNT(*) FROM users) as row_count,
    (SELECT pg_size_pretty(pg_indexes_size('users'))) as indexes_size
UNION ALL
SELECT 
    'files' as table_name,
    pg_size_pretty(pg_total_relation_size('files')) as table_size,
    (SELECT COUNT(*) FROM files) as row_count,
    (SELECT pg_size_pretty(pg_indexes_size('files'))) as indexes_size
UNION ALL
SELECT 
    'cloud_accounts' as table_name,
    pg_size_pretty(pg_total_relation_size('cloud_accounts')) as table_size,
    (SELECT COUNT(*) FROM cloud_accounts) as row_count,
    (SELECT pg_size_pretty(pg_indexes_size('cloud_accounts'))) as indexes_size;

COMMENT ON DATABASE uniclouddb IS 'UniCloud Multi-Cloud File Management System - PostgreSQL 17';
COMMENT ON TABLE users IS 'Application users with enhanced security features';
COMMENT ON TABLE cloud_accounts IS 'User cloud storage account connections';
COMMENT ON TABLE files IS 'File metadata with JSONB support for extensibility';
COMMENT ON TABLE oauth_tokens IS 'OAuth tokens for cloud service authentication';
COMMENT ON EXTENSION pg_stat_statements IS 'Query performance monitoring for PostgreSQL 17';
COMMENT ON EXTENSION pg_buffercache IS 'Buffer cache monitoring for PostgreSQL 17';
