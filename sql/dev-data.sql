-- Development Test Data for UniCloud
-- This script creates sample data for development and testing

SET search_path TO unicloud, public;

-- Insert development users
-- Password: 'password123' (hashed with bcrypt)
INSERT INTO users (id, username, email, password_hash, first_name, last_name, status, email_verified) VALUES
    ('550e8400-e29b-41d4-a716-446655440000', 'john_doe', 'john.doe@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iYqiSfFDYsFGcRqKlzY5DgkfhS2e', 'John', 'Doe', 'ACTIVE', true),
    ('550e8400-e29b-41d4-a716-446655440001', 'jane_smith', 'jane.smith@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iYqiSfFDYsFGcRqKlzY5DgkfhS2e', 'Jane', 'Smith', 'ACTIVE', true),
    ('550e8400-e29b-41d4-a716-446655440002', 'bob_johnson', 'bob.johnson@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iYqiSfFDYsFGcRqKlzY5DgkfhS2e', 'Bob', 'Johnson', 'ACTIVE', true),
    ('550e8400-e29b-41d4-a716-446655440003', 'alice_brown', 'alice.brown@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iYqiSfFDYsFGcRqKlzY5DgkfhS2e', 'Alice', 'Brown', 'PENDING_VERIFICATION', false),
    ('550e8400-e29b-41d4-a716-446655440004', 'testuser', 'test@unicloud.dev', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iYqiSfFDYsFGcRqKlzY5DgkfhS2e', 'Test', 'User', 'ACTIVE', true);

-- Insert development cloud accounts
INSERT INTO cloud_accounts (id, user_id, provider, provider_user_id, provider_email, account_name, is_active, total_quota, used_quota) VALUES
    -- John Doe's accounts
    ('660e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440000', 'GOOGLE_DRIVE', 'google_user_123', 'john.doe@gmail.com', 'John Personal Drive', true, 17179869184, 5368709120), -- 16GB total, 5GB used
    ('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'ONEDRIVE', 'onedrive_user_123', 'john.doe@outlook.com', 'John OneDrive', true, 10737418240, 2147483648), -- 10GB total, 2GB used

    -- Jane Smith's accounts
    ('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'GOOGLE_DRIVE', 'google_user_456', 'jane.smith@gmail.com', 'Jane Work Drive', true, 34359738368, 15032385536), -- 32GB total, 14GB used
    ('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', 'ICLOUD', 'icloud_user_456', 'jane.smith@icloud.com', 'Jane iCloud', true, 5368709120, 1073741824), -- 5GB total, 1GB used

    -- Bob Johnson's accounts
    ('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', 'ONEDRIVE', 'onedrive_user_789', 'bob.johnson@outlook.com', 'Bob Personal', true, 5368709120, 2684354560), -- 5GB total, 2.5GB used

    -- Test user's accounts (all providers)
    ('660e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440004', 'GOOGLE_DRIVE', 'google_test_user', 'test@gmail.com', 'Test Google Drive', true, 17179869184, 1073741824), -- 16GB total, 1GB used
    ('660e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440004', 'ONEDRIVE', 'onedrive_test_user', 'test@outlook.com', 'Test OneDrive', true, 10737418240, 536870912), -- 10GB total, 512MB used
    ('660e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440004', 'ICLOUD', 'icloud_test_user', 'test@icloud.com', 'Test iCloud', true, 5368709120, 268435456); -- 5GB total, 256MB used

-- Insert sample files
INSERT INTO files (id, user_id, cloud_account_id, provider_file_id, file_name, file_path, mime_type, file_size, is_folder, provider_created_at, provider_updated_at) VALUES
    -- John's Google Drive files
    ('770e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', 'gdrive_file_001', 'Documents', '/Documents', 'application/vnd.google-apps.folder', 0, true, CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '5 days'),
    ('770e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', 'gdrive_file_002', 'resume.pdf', '/Documents/resume.pdf', 'application/pdf', 2097152, false, CURRENT_TIMESTAMP - INTERVAL '25 days', CURRENT_TIMESTAMP - INTERVAL '20 days'),
    ('770e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', 'gdrive_file_003', 'presentation.pptx', '/Documents/presentation.pptx', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 15728640, false, CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_TIMESTAMP - INTERVAL '10 days'),
    ('770e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', 'gdrive_file_004', 'Photos', '/Photos', 'application/vnd.google-apps.folder', 0, true, CURRENT_TIMESTAMP - INTERVAL '60 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
    ('770e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000', 'gdrive_file_005', 'vacation.jpg', '/Photos/vacation.jpg', 'image/jpeg', 8388608, false, CURRENT_TIMESTAMP - INTERVAL '45 days', CURRENT_TIMESTAMP - INTERVAL '45 days'),

    -- John's OneDrive files
    ('770e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001', 'onedrive_file_001', 'Work Projects', '/Work Projects', 'application/vnd.ms-folder', 0, true, CURRENT_TIMESTAMP - INTERVAL '40 days', CURRENT_TIMESTAMP - INTERVAL '3 days'),
    ('770e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001', 'onedrive_file_002', 'project_plan.xlsx', '/Work Projects/project_plan.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 1048576, false, CURRENT_TIMESTAMP - INTERVAL '35 days', CURRENT_TIMESTAMP - INTERVAL '7 days'),

    -- Jane's Google Drive files
    ('770e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440002', 'gdrive_file_101', 'Research Papers', '/Research Papers', 'application/vnd.google-apps.folder', 0, true, CURRENT_TIMESTAMP - INTERVAL '90 days', CURRENT_TIMESTAMP - INTERVAL '2 days'),
    ('770e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440002', 'gdrive_file_102', 'thesis_draft.docx', '/Research Papers/thesis_draft.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 52428800, false, CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
    ('770e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440002', 'gdrive_file_103', 'dataset.csv', '/Research Papers/dataset.csv', 'text/csv', 104857600, false, CURRENT_TIMESTAMP - INTERVAL '20 days', CURRENT_TIMESTAMP - INTERVAL '5 days'),

    -- Test user files (various types)
    ('770e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440005', 'test_file_001', 'test_document.txt', '/test_document.txt', 'text/plain', 4096, false, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '2 days'),
    ('770e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440006', 'test_file_002', 'sample_image.png', '/sample_image.png', 'image/png', 1048576, false, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
    ('770e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440007', 'test_file_003', 'music_file.mp3', '/music_file.mp3', 'audio/mpeg', 4194304, false, CURRENT_TIMESTAMP - INTERVAL '7 days', CURRENT_TIMESTAMP - INTERVAL '7 days');

-- Set parent folder relationships
UPDATE files SET parent_folder_id = '770e8400-e29b-41d4-a716-446655440000'
WHERE id IN ('770e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440002');

UPDATE files SET parent_folder_id = '770e8400-e29b-41d4-a716-446655440003'
WHERE id = '770e8400-e29b-41d4-a716-446655440004';

UPDATE files SET parent_folder_id = '770e8400-e29b-41d4-a716-446655440005'
WHERE id = '770e8400-e29b-41d4-a716-446655440006';

UPDATE files SET parent_folder_id = '770e8400-e29b-41d4-a716-446655440007'
WHERE id IN ('770e8400-e29b-41d4-a716-446655440008', '770e8400-e29b-41d4-a716-446655440009');

-- Insert sample file operations audit records
INSERT INTO audit.file_operations (user_id, file_id, operation, provider, file_name, file_size, ip_address, user_agent, status, duration_ms) VALUES
    ('550e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440001', 'UPLOAD', 'GOOGLE_DRIVE', 'resume.pdf', 2097152, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'SUCCESS', 1250),
    ('550e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440001', 'DOWNLOAD', 'GOOGLE_DRIVE', 'resume.pdf', 2097152, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'SUCCESS', 850),
    ('550e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440008', 'UPLOAD', 'GOOGLE_DRIVE', 'thesis_draft.docx', 52428800, '10.0.0.50', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', 'SUCCESS', 15400),
    ('550e8400-e29b-41d4-a716-446655440004', '770e8400-e29b-41d4-a716-446655440010', 'UPLOAD', 'GOOGLE_DRIVE', 'test_document.txt', 4096, '172.16.0.25', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36', 'SUCCESS', 200),
    ('550e8400-e29b-41d4-a716-446655440000', NULL, 'UPLOAD', 'ONEDRIVE', 'failed_upload.zip', 209715200, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'FAILED', 30000);

-- Insert sample user sessions
INSERT INTO user_sessions (user_id, session_token, refresh_token, ip_address, user_agent, expires_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440000', 'session_token_john_123', 'refresh_token_john_123', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
    ('550e8400-e29b-41d4-a716-446655440001', 'session_token_jane_456', 'refresh_token_jane_456', '10.0.0.50', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
    ('550e8400-e29b-41d4-a716-446655440004', 'session_token_test_789', 'refresh_token_test_789', '172.16.0.25', 'UniCloud-Desktop-Client/1.0', CURRENT_TIMESTAMP + INTERVAL '24 hours');

-- Insert development-specific settings
INSERT INTO app_settings (key, value, description) VALUES
    ('environment', 'development', 'Current environment'),
    ('debug_mode', 'true', 'Enable debug logging'),
    ('mock_oauth', 'true', 'Use mock OAuth providers'),
    ('email_enabled', 'false', 'Disable email sending in development'),
    ('file_cleanup_enabled', 'false', 'Disable automatic file cleanup'),
    ('rate_limiting_enabled', 'false', 'Disable rate limiting in development')
ON CONFLICT (key) DO UPDATE SET
    value = EXCLUDED.value,
    updated_at = CURRENT_TIMESTAMP;

-- Create development views for easier data access
CREATE OR REPLACE VIEW dev_user_summary AS
SELECT
    u.id,
    u.username,
    u.email,
    u.first_name,
    u.last_name,
    u.status,
    COUNT(ca.id) as cloud_accounts_count,
    COUNT(f.id) as total_files,
    COALESCE(SUM(f.file_size), 0) as total_file_size,
    u.created_at,
    u.last_login
FROM users u
LEFT JOIN cloud_accounts ca ON u.id = ca.user_id AND ca.is_active = true
LEFT JOIN files f ON ca.id = f.cloud_account_id
GROUP BY u.id, u.username, u.email, u.first_name, u.last_name, u.status, u.created_at, u.last_login;

CREATE OR REPLACE VIEW dev_file_operations_summary AS
SELECT
    DATE(fo.created_at) as operation_date,
    fo.operation,
    fo.provider,
    fo.status,
    COUNT(*) as operation_count,
    AVG(fo.duration_ms) as avg_duration_ms,
    SUM(COALESCE(fo.file_size, 0)) as total_bytes
FROM audit.file_operations fo
GROUP BY DATE(fo.created_at), fo.operation, fo.provider, fo.status
ORDER BY operation_date DESC, operation, provider;

-- Log development data insertion
INSERT INTO app_settings (key, value, description) VALUES
    ('dev_data_loaded_at', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)::TEXT, 'Development data load timestamp')
ON CONFLICT (key) DO UPDATE SET
    value = EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)::TEXT,
    updated_at = CURRENT_TIMESTAMP;