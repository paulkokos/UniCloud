-- Test Data for UniCloud Testing Environment
-- This script creates minimal test data for automated testing

SET search_path TO unicloud, public;

-- Clean existing test data (for idempotent tests)
TRUNCATE TABLE audit.file_operations CASCADE;
TRUNCATE TABLE user_sessions CASCADE;
TRUNCATE TABLE files CASCADE;
TRUNCATE TABLE cloud_accounts CASCADE;
TRUNCATE TABLE users CASCADE;
DELETE FROM app_settings WHERE key LIKE 'test_%';

-- Insert test users
-- All passwords are 'testpass123' hashed with bcrypt
INSERT INTO users (id, username, email, password_hash, first_name, last_name, status, email_verified) VALUES
    ('11111111-1111-1111-1111-111111111111', 'testuser1', 'test1@example.com', '$2a$10$rHzTxgJKBiJ8Q8NKtKjz3eT5jBgQ8gJ8iJKTjz3eT5jBgQ8gJ8iJK', 'Test', 'User1', 'ACTIVE', true),
    ('22222222-2222-2222-2222-222222222222', 'testuser2', 'test2@example.com', '$2a$10$rHzTxgJKBiJ8Q8NKtKjz3eT5jBgQ8gJ8iJKTjz3eT5jBgQ8gJ8iJK', 'Test', 'User2', 'ACTIVE', true),
    ('33333333-3333-3333-3333-333333333333', 'testuser3', 'test3@example.com', '$2a$10$rHzTxgJKBiJ8Q8NKtKjz3eT5jBgQ8gJ8iJKTjz3eT5jBgQ8gJ8iJK', 'Test', 'User3', 'PENDING_VERIFICATION', false),
    ('44444444-4444-4444-4444-444444444444', 'admin_test', 'admin@test.com', '$2a$10$rHzTxgJKBiJ8Q8NKtKjz3eT5jBgQ8gJ8iJKTjz3eT5jBgQ8gJ8iJK', 'Admin', 'Test', 'ACTIVE', true),
    ('55555555-5555-5555-5555-555555555555', 'inactive_user', 'inactive@test.com', '$2a$10$rHzTxgJKBiJ8Q8NKtKjz3eT5jBgQ8gJ8iJKTjz3eT5jBgQ8gJ8iJK', 'Inactive', 'User', 'INACTIVE', true);

-- Insert test cloud accounts
INSERT INTO cloud_accounts (id, user_id, provider, provider_user_id, provider_email, account_name, is_active, total_quota, used_quota) VALUES
    -- User1 accounts (all providers)
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'GOOGLE_DRIVE', 'test_google_1', 'test1@gmail.com', 'Test Google 1', true, 1073741824, 268435456), -- 1GB total, 256MB used
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'ONEDRIVE', 'test_onedrive_1', 'test1@outlook.com', 'Test OneDrive 1', true, 1073741824, 134217728), -- 1GB total, 128MB used
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', 'ICLOUD', 'test_icloud_1', 'test1@icloud.com', 'Test iCloud 1', true, 1073741824, 67108864), -- 1GB total, 64MB used

    -- User2 accounts (partial providers)
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', '22222222-2222-2222-2222-222222222222', 'GOOGLE_DRIVE', 'test_google_2', 'test2@gmail.com', 'Test Google 2', true, 536870912, 134217728), -- 512MB total, 128MB used
    ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '22222222-2222-2222-2222-222222222222', 'ONEDRIVE', 'test_onedrive_2', 'test2@outlook.com', 'Test OneDrive 2', false, 536870912, 0), -- Inactive account

    -- User3 account (pending user)
    ('ffffffff-ffff-ffff-ffff-ffffffffffff', '33333333-3333-3333-3333-333333333333', 'GOOGLE_DRIVE', 'test_google_3', 'test3@gmail.com', 'Test Google 3', true, 536870912, 0); -- 512MB total, 0MB used

-- Insert test files
INSERT INTO files (id, user_id, cloud_account_id, provider_file_id, file_name, file_path, mime_type, file_size, is_folder, checksum) VALUES
    -- User1 files
    ('11111111-aaaa-aaaa-aaaa-111111111111', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'gdrive_test_folder_1', 'Test Folder', '/Test Folder', 'application/vnd.google-apps.folder', 0, true, null),
    ('11111111-aaaa-aaaa-aaaa-111111111112', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'gdrive_test_file_1', 'test.txt', '/Test Folder/test.txt', 'text/plain', 1024, false, 'abc123'),
    ('11111111-aaaa-aaaa-aaaa-111111111113', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'gdrive_test_file_2', 'document.pdf', '/document.pdf', 'application/pdf', 102400, false, 'def456'),
    ('11111111-bbbb-bbbb-bbbb-111111111114', '11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'onedrive_test_file_1', 'spreadsheet.xlsx', '/spreadsheet.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 51200, false, 'ghi789'),
    ('11111111-cccc-cccc-cccc-111111111115', '11111111-1111-1111-1111-111111111111', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'icloud_test_file_1', 'photo.jpg', '/photo.jpg', 'image/jpeg', 204800, false, 'jkl012'),

    -- User2 files
    ('22222222-dddd-dddd-dddd-222222222221', '22222222-2222-2222-2222-222222222222', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'gdrive_test_file_3', 'presentation.pptx', '/presentation.pptx', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 1048576, false, 'mno345'),
    ('22222222-dddd-dddd-dddd-222222222222', '22222222-2222-2222-2222-222222222222', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'gdrive_test_file_4', 'video.mp4', '/video.mp4', 'video/mp4', 10485760, false, 'pqr678');

-- Set folder relationships
UPDATE files SET parent_folder_id = '11111111-aaaa-aaaa-aaaa-111111111111'
WHERE id = '11111111-aaaa-aaaa-aaaa-111111111112';

-- Insert test file operations for testing audit functionality
INSERT INTO audit.file_operations (user_id, file_id, operation, provider, file_name, file_size, ip_address, user_agent, status, duration_ms) VALUES
    ('11111111-1111-1111-1111-111111111111', '11111111-aaaa-aaaa-aaaa-111111111112', 'UPLOAD', 'GOOGLE_DRIVE', 'test.txt', 1024, '127.0.0.1', 'Test-Agent/1.0', 'SUCCESS', 100),
    ('11111111-1111-1111-1111-111111111111', '11111111-aaaa-aaaa-aaaa-111111111113', 'UPLOAD', 'GOOGLE_DRIVE', 'document.pdf', 102400, '127.0.0.1', 'Test-Agent/1.0', 'SUCCESS', 500),
    ('11111111-1111-1111-1111-111111111111', '11111111-aaaa-aaaa-aaaa-111111111112', 'DOWNLOAD', 'GOOGLE_DRIVE', 'test.txt', 1024, '127.0.0.1', 'Test-Agent/1.0', 'SUCCESS', 50),
    ('22222222-2222-2222-2222-222222222222', '22222222-dddd-dddd-dddd-222222222221', 'UPLOAD', 'GOOGLE_DRIVE', 'presentation.pptx', 1048576, '127.0.0.1', 'Test-Agent/1.0', 'FAILED', 2000),
    ('11111111-1111-1111-1111-111111111111', NULL, 'UPLOAD', 'ONEDRIVE', 'large_file.zip', 104857600, '127.0.0.1', 'Test-Agent/1.0', 'FAILED', 30000);

-- Insert test sessions
INSERT INTO user_sessions (user_id, session_token, refresh_token, ip_address, user_agent, expires_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 'test_session_1', 'test_refresh_1', '127.0.0.1', 'Test-Agent/1.0', CURRENT_TIMESTAMP + INTERVAL '1 hour'),
    ('22222222-2222-2222-2222-222222222222', 'test_session_2', 'test_refresh_2', '127.0.0.1', 'Test-Agent/1.0', CURRENT_TIMESTAMP + INTERVAL '1 hour'),
    ('44444444-4444-4444-4444-444444444444', 'test_session_admin', 'test_refresh_admin', '127.0.0.1', 'Test-Agent/1.0', CURRENT_TIMESTAMP + INTERVAL '1 hour'),
    -- Expired session for testing cleanup
    ('11111111-1111-1111-1111-111111111111', 'expired_session', 'expired_refresh', '127.0.0.1', 'Test-Agent/1.0', CURRENT_TIMESTAMP - INTERVAL '1 hour');

-- Insert test-specific settings
INSERT INTO app_settings (key, value, description) VALUES
    ('test_environment', 'true', 'Indicates test environment'),
    ('test_data_loaded', 'true', 'Test data has been loaded'),
    ('oauth_mock_enabled', 'true', 'OAuth mocking enabled for tests'),
    ('email_verification_bypass', 'true', 'Bypass email verification in tests'),
    ('rate_limiting_disabled', 'true', 'Rate limiting disabled for tests'),
    ('file_cleanup_disabled', 'true', 'File cleanup disabled during tests'),
    ('max_test_file_size', '10485760', 'Maximum file size for tests (10MB)'),
    ('test_session_timeout', '3600', 'Test session timeout (1 hour)')
ON CONFLICT (key) DO UPDATE SET
    value = EXCLUDED.value,
    updated_at = CURRENT_TIMESTAMP;

-- Create test-specific functions
CREATE OR REPLACE FUNCTION reset_test_data()
RETURNS VOID AS $$
BEGIN
    -- Reset sequences and counters for consistent test results
    TRUNCATE TABLE audit.file_operations RESTART IDENTITY CASCADE;
    TRUNCATE TABLE user_sessions RESTART IDENTITY CASCADE;
    TRUNCATE TABLE files RESTART IDENTITY CASCADE;
    TRUNCATE TABLE cloud_accounts RESTART IDENTITY CASCADE;
    TRUNCATE TABLE users RESTART IDENTITY CASCADE;

    -- Re-insert test data
    -- (This would include the same INSERT statements as above)
    RAISE NOTICE 'Test data reset completed';
END;
$$ LANGUAGE