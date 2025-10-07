const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(morgan('combined'));

// Mock OAuth configurations
const OAUTH_CONFIGS = {
  google: {
    client_id: 'mock-google-client-id',
    client_secret: 'mock-google-client-secret',
    redirect_uri: 'http://localhost:8080/oauth2/callback/google',
    scope: 'https://www.googleapis.com/auth/drive',
    auth_url: 'https://accounts.google.com/oauth/authorize',
    token_url: 'https://oauth2.googleapis.com/token'
  },
  microsoft: {
    client_id: 'mock-microsoft-client-id',
    client_secret: 'mock-microsoft-client-secret',
    redirect_uri: 'http://localhost:8080/oauth2/callback/microsoft',
    scope: 'https://graph.microsoft.com/Files.ReadWrite',
    auth_url: 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize',
    token_url: 'https://login.microsoftonline.com/common/oauth2/v2.0/token'
  },
  icloud: {
    client_id: 'mock-icloud-client-id',
    client_secret: 'mock-icloud-client-secret',
    redirect_uri: 'http://localhost:8080/oauth2/callback/icloud',
    scope: 'https://www.icloud.com/cloudkit',
    auth_url: 'https://www.icloud.com/oauth/authorize',
    token_url: 'https://www.icloud.com/oauth/token'
  }
};

// Mock user data
const MOCK_USERS = {
  google: {
    'test-user-1': {
      id: 'google-user-123',
      email: 'test1@gmail.com',
      name: 'Test User 1',
      picture: 'https://example.com/avatar1.jpg'
    },
    'test-user-2': {
      id: 'google-user-456',
      email: 'test2@gmail.com',
      name: 'Test User 2',
      picture: 'https://example.com/avatar2.jpg'
    }
  },
  microsoft: {
    'test-user-1': {
      id: 'microsoft-user-123',
      mail: 'test1@outlook.com',
      displayName: 'Test User 1',
      userPrincipalName: 'test1@outlook.com'
    },
    'test-user-2': {
      id: 'microsoft-user-456',
      mail: 'test2@outlook.com',
      displayName: 'Test User 2',
      userPrincipalName: 'test2@outlook.com'
    }
  },
  icloud: {
    'test-user-1': {
      id: 'icloud-user-123',
      email: 'test1@icloud.com',
      firstName: 'Test',
      lastName: 'User 1'
    },
    'test-user-2': {
      id: 'icloud-user-456',
      email: 'test2@icloud.com',
      firstName: 'Test',
      lastName: 'User 2'
    }
  }
};

// In-memory storage for tokens and codes
const authCodes = new Map();
const accessTokens = new Map();
const refreshTokens = new Map();

// Helper functions
function generateAuthCode() {
  return uuidv4();
}

function generateAccessToken(provider, userId) {
  const payload = {
    provider,
    userId,
    scope: OAUTH_CONFIGS[provider].scope,
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 3600 // 1 hour
  };
  return jwt.sign(payload, 'mock-secret-key');
}

function generateRefreshToken() {
  return uuidv4();
}

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'UniCloud Mock OAuth Provider',
    version: '1.0.0',
    providers: Object.keys(OAUTH_CONFIGS),
    endpoints: {
      google: {
        authorize: '/oauth/google/authorize',
        token: '/oauth/google/token',
        userinfo: '/oauth/google/userinfo'
      },
      microsoft: {
        authorize: '/oauth/microsoft/authorize',
        token: '/oauth/microsoft/token',
        userinfo: '/oauth/microsoft/userinfo'
      },
      icloud: {
        authorize: '/oauth/icloud/authorize',
        token: '/oauth/icloud/token',
        userinfo: '/oauth/icloud/userinfo'
      }
    }
  });
});

// Google OAuth endpoints
app.get('/oauth/google/authorize', (req, res) => {
  const { client_id, redirect_uri, scope, state, response_type } = req.query;

  if (response_type !== 'code') {
    return res.status(400).json({ error: 'unsupported_response_type' });
  }

  if (client_id !== OAUTH_CONFIGS.google.client_id) {
    return res.status(400).json({ error: 'invalid_client' });
  }

  // Generate authorization code
  const code = generateAuthCode();
  authCodes.set(code, {
    provider: 'microsoft',
    client_id,
    redirect_uri,
    scope,
    userId: 'test-user-1',
    createdAt: Date.now()
  });

  const redirectUrl = new URL(redirect_uri);
  redirectUrl.searchParams.append('code', code);
  if (state) redirectUrl.searchParams.append('state', state);

  res.redirect(redirectUrl.toString());
});

app.post('/oauth/microsoft/token', (req, res) => {
  const { grant_type, code, client_id, client_secret, refresh_token } = req.body;

  if (grant_type === 'authorization_code') {
    const authData = authCodes.get(code);
    if (!authData || authData.provider !== 'microsoft') {
      return res.status(400).json({ error: 'invalid_grant' });
    }

    if (client_id !== OAUTH_CONFIGS.microsoft.client_id ||
        client_secret !== OAUTH_CONFIGS.microsoft.client_secret) {
      return res.status(400).json({ error: 'invalid_client' });
    }

    const accessToken = generateAccessToken('microsoft', authData.userId);
    const refreshToken = generateRefreshToken();

    accessTokens.set(accessToken, {
      provider: 'microsoft',
      userId: authData.userId,
      scope: authData.scope,
      createdAt: Date.now()
    });

    refreshTokens.set(refreshToken, {
      provider: 'microsoft',
      userId: authData.userId,
      accessToken,
      createdAt: Date.now()
    });

    authCodes.delete(code);

    res.json({
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: 'Bearer',
      expires_in: 3600,
      scope: authData.scope
    });

  } else if (grant_type === 'refresh_token') {
    const refreshData = refreshTokens.get(refresh_token);
    if (!refreshData || refreshData.provider !== 'microsoft') {
      return res.status(400).json({ error: 'invalid_grant' });
    }

    const newAccessToken = generateAccessToken('microsoft', refreshData.userId);
    accessTokens.set(newAccessToken, {
      provider: 'microsoft',
      userId: refreshData.userId,
      scope: OAUTH_CONFIGS.microsoft.scope,
      createdAt: Date.now()
    });

    refreshData.accessToken = newAccessToken;

    res.json({
      access_token: newAccessToken,
      token_type: 'Bearer',
      expires_in: 3600
    });

  } else {
    res.status(400).json({ error: 'unsupported_grant_type' });
  }
});

app.get('/oauth/microsoft/userinfo', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      error: {
        code: 'InvalidAuthenticationToken',
        message: 'Access token is missing or invalid'
      }
    });
  }

  const token = authHeader.substring(7);
  const tokenData = accessTokens.get(token);

  if (!tokenData || tokenData.provider !== 'microsoft') {
    return res.status(401).json({
      error: {
        code: 'InvalidAuthenticationToken',
        message: 'Access token validation failure'
      }
    });
  }

  // Check token expiration
  if (Date.now() - tokenData.createdAt > 3600 * 1000) {
    accessTokens.delete(token);
    return res.status(401).json({
      error: {
        code: 'TokenExpired',
        message: 'Access token has expired'
      }
    });
  }

  const user = MOCK_USERS.microsoft[tokenData.userId];
  if (!user) {
    return res.status(404).json({
      error: {
        code: 'UserNotFound',
        message: 'User not found'
      }
    });
  }

  // Microsoft Graph API /me endpoint format
  const graphResponse = {
    '@odata.context': 'https://graph.microsoft.com/v1.0/$metadata#users/$entity',
    id: user.id,
    displayName: user.displayName,
    mail: user.mail,
    userPrincipalName: user.userPrincipalName,
    givenName: user.displayName.split(' ')[0] || 'Test',
    surname: user.displayName.split(' ').slice(1).join(' ') || 'User',
    jobTitle: 'Software Developer',
    businessPhones: [],
    mobilePhone: null,
    officeLocation: 'Remote',
    preferredLanguage: 'en-US'
  };

  console.log(`Microsoft userinfo requested for user ${tokenData.userId}`);
  res.json(graphResponse);
});

// Microsoft Graph API specific endpoints for file operations
app.get('/oauth/microsoft/me/drive', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      error: {
        code: 'InvalidAuthenticationToken',
        message: 'Access token is missing or invalid'
      }
    });
  }

  const token = authHeader.substring(7);
  const tokenData = accessTokens.get(token);

  if (!tokenData || tokenData.provider !== 'microsoft') {
    return res.status(401).json({
      error: {
        code: 'InvalidAuthenticationToken',
        message: 'Access token validation failure'
      }
    });
  }

  // Mock OneDrive info
  res.json({
    '@odata.context': 'https://graph.microsoft.com/v1.0/$metadata#drives/$entity',
    id: '1234567890ABCDEF',
    driveType: 'personal',
    name: 'OneDrive',
    quota: {
      total: 5368709120, // 5GB
      used: 1073741824,  // 1GB
      remaining: 4294967296, // 4GB
      deleted: 0,
      state: 'normal'
    },
    owner: {
      user: {
        id: tokenData.userId,
        displayName: MOCK_USERS.microsoft[tokenData.userId].displayName
      }
    }
  });
});

// iCloud OAuth endpoints
app.get('/oauth/icloud/authorize', (req, res) => {
  const { client_id, redirect_uri, scope, state, response_type } = req.query;

  if (response_type !== 'code') {
    return res.status(400).json({ error: 'unsupported_response_type' });
  }

  if (client_id !== OAUTH_CONFIGS.icloud.client_id) {
    return res.status(400).json({ error: 'invalid_client' });
  }

  const code = generateAuthCode();
  authCodes.set(code, {
    provider: 'icloud',
    client_id,
    redirect_uri,
    scope,
    userId: 'test-user-1',
    createdAt: Date.now()
  });

  const redirectUrl = new URL(redirect_uri);
  redirectUrl.searchParams.append('code', code);
  if (state) redirectUrl.searchParams.append('state', state);

  res.redirect(redirectUrl.toString());
});

app.post('/oauth/icloud/token', (req, res) => {
  const { grant_type, code, client_id, client_secret, refresh_token } = req.body;

  if (grant_type === 'authorization_code') {
    const authData = authCodes.get(code);
    if (!authData || authData.provider !== 'icloud') {
      return res.status(400).json({ error: 'invalid_grant' });
    }

    if (client_id !== OAUTH_CONFIGS.icloud.client_id ||
        client_secret !== OAUTH_CONFIGS.icloud.client_secret) {
      return res.status(400).json({ error: 'invalid_client' });
    }

    const accessToken = generateAccessToken('icloud', authData.userId);
    const refreshToken = generateRefreshToken();

    accessTokens.set(accessToken, {
      provider: 'icloud',
      userId: authData.userId,
      scope: authData.scope,
      createdAt: Date.now()
    });

    refreshTokens.set(refreshToken, {
      provider: 'icloud',
      userId: authData.userId,
      accessToken,
      createdAt: Date.now()
    });

    authCodes.delete(code);

    res.json({
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: 'Bearer',
      expires_in: 3600,
      scope: authData.scope
    });

  } else if (grant_type === 'refresh_token') {
    const refreshData = refreshTokens.get(refresh_token);
    if (!refreshData || refreshData.provider !== 'icloud') {
      return res.status(400).json({ error: 'invalid_grant' });
    }

    const newAccessToken = generateAccessToken('icloud', refreshData.userId);
    accessTokens.set(newAccessToken, {
      provider: 'icloud',
      userId: refreshData.userId,
      scope: OAUTH_CONFIGS.icloud.scope,
      createdAt: Date.now()
    });

    refreshData.accessToken = newAccessToken;

    res.json({
      access_token: newAccessToken,
      token_type: 'Bearer',
      expires_in: 3600
    });

  } else {
    res.status(400).json({ error: 'unsupported_grant_type' });
  }
});

app.get('/oauth/icloud/userinfo', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'invalid_token' });
  }

  const token = authHeader.substring(7);
  const tokenData = accessTokens.get(token);

  if (!tokenData || tokenData.provider !== 'icloud') {
    return res.status(401).json({ error: 'invalid_token' });
  }

  const user = MOCK_USERS.icloud[tokenData.userId];
  if (!user) {
    return res.status(404).json({ error: 'user_not_found' });
  }

  res.json(user);
});

// Mock file storage endpoints for testing file operations
app.get('/api/:provider/files', (req, res) => {
  const { provider } = req.params;
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'invalid_token' });
  }

  const token = authHeader.substring(7);
  const tokenData = accessTokens.get(token);

  if (!tokenData || tokenData.provider !== provider) {
    return res.status(401).json({ error: 'invalid_token' });
  }

  // Mock file list
  const mockFiles = [
    {
      id: `${provider}-file-1`,
      name: 'test-document.pdf',
      size: 1024,
      mimeType: 'application/pdf',
      createdTime: new Date().toISOString(),
      modifiedTime: new Date().toISOString()
    },
    {
      id: `${provider}-file-2`,
      name: 'sample-image.jpg',
      size: 2048,
      mimeType: 'image/jpeg',
      createdTime: new Date().toISOString(),
      modifiedTime: new Date().toISOString()
    }
  ];

  res.json({ files: mockFiles });
});

app.post('/api/:provider/files/upload', (req, res) => {
  const { provider } = req.params;
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'invalid_token' });
  }

  const token = authHeader.substring(7);
  const tokenData = accessTokens.get(token);

  if (!tokenData || tokenData.provider !== provider) {
    return res.status(401).json({ error: 'invalid_token' });
  }

  // Mock successful upload
  const mockFile = {
    id: `${provider}-file-${Date.now()}`,
    name: req.body.name || 'uploaded-file.txt',
    size: req.body.size || 1024,
    mimeType: req.body.mimeType || 'text/plain',
    createdTime: new Date().toISOString(),
    modifiedTime: new Date().toISOString()
  };

  res.status(201).json(mockFile);
});

// Admin endpoints for testing
app.get('/admin/tokens', (req, res) => {
  if (process.env.NODE_ENV !== 'test') {
    return res.status(403).json({ error: 'forbidden' });
  }

  res.json({
    authCodes: Array.from(authCodes.entries()),
    accessTokens: Array.from(accessTokens.entries()),
    refreshTokens: Array.from(refreshTokens.entries())
  });
});

app.post('/admin/reset', (req, res) => {
  if (process.env.NODE_ENV !== 'test') {
    return res.status(403).json({ error: 'forbidden' });
  }

  authCodes.clear();
  accessTokens.clear();
  refreshTokens.clear();

  res.json({ message: 'All tokens cleared' });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    activeTokens: {
      authCodes: authCodes.size,
      accessTokens: accessTokens.size,
      refreshTokens: refreshTokens.size
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'internal_server_error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'not_found',
    message: 'Endpoint not found'
  });
});

// Token cleanup job (every 5 minutes)
setInterval(() => {
  const now = Date.now();
  const oneHour = 60 * 60 * 1000;

  // Clean expired auth codes (valid for 10 minutes)
  for (const [code, data] of authCodes.entries()) {
    if (now - data.createdAt > 10 * 60 * 1000) {
      authCodes.delete(code);
    }
  }

  // Clean expired access tokens (valid for 1 hour)
  for (const [token, data] of accessTokens.entries()) {
    if (now - data.createdAt > oneHour) {
      accessTokens.delete(token);
    }
  }

  console.log(`Token cleanup: ${authCodes.size} auth codes, ${accessTokens.size} access tokens, ${refreshTokens.size} refresh tokens`);
}, 5 * 60 * 1000);

// Start server
app.listen(PORT, () => {
  console.log(`Mock OAuth server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log('Available providers:', Object.keys(OAUTH_CONFIGS));
});

module.exports = app;set(code, {
    provider: 'google',
    client_id,
    redirect_uri,
    scope,
    userId: 'test-user-1', // Default test user
    createdAt: Date.now()
  });

  // Redirect back with code
  const redirectUrl = new URL(redirect_uri);
  redirectUrl.searchParams.append('code', code);
  if (state) redirectUrl.searchParams.append('state', state);

  res.redirect(redirectUrl.toString());
});

app.post('/oauth/google/token', (req, res) => {
  const { grant_type, code, client_id, client_secret, refresh_token } = req.body;

  if (grant_type === 'authorization_code') {
    const authData = authCodes.get(code);
    if (!authData || authData.provider !== 'google') {
      return res.status(400).json({ error: 'invalid_grant' });
    }

    if (client_id !== OAUTH_CONFIGS.google.client_id ||
        client_secret !== OAUTH_CONFIGS.google.client_secret) {
      return res.status(400).json({ error: 'invalid_client' });
    }

    // Generate tokens
    const accessToken = generateAccessToken('google', authData.userId);
    const refreshToken = generateRefreshToken();

    accessTokens.set(accessToken, {
      provider: 'google',
      userId: authData.userId,
      scope: authData.scope,
      createdAt: Date.now()
    });

    refreshTokens.set(refreshToken, {
      provider: 'google',
      userId: authData.userId,
      accessToken,
      createdAt: Date.now()
    });

    // Clean up auth code
    authCodes.delete(code);

    res.json({
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: 'Bearer',
      expires_in: 3600,
      scope: authData.scope
    });

  } else if (grant_type === 'refresh_token') {
    const refreshData = refreshTokens.get(refresh_token);
    if (!refreshData || refreshData.provider !== 'google') {
      return res.status(400).json({ error: 'invalid_grant' });
    }

    // Generate new access token
    const newAccessToken = generateAccessToken('google', refreshData.userId);
    accessTokens.set(newAccessToken, {
      provider: 'google',
      userId: refreshData.userId,
      scope: OAUTH_CONFIGS.google.scope,
      createdAt: Date.now()
    });

    // Update refresh token data
    refreshData.accessToken = newAccessToken;

    res.json({
      access_token: newAccessToken,
      token_type: 'Bearer',
      expires_in: 3600
    });

  } else {
    res.status(400).json({ error: 'unsupported_grant_type' });
  }
});

app.get('/oauth/google/userinfo', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'invalid_token' });
  }

  const token = authHeader.substring(7);
  const tokenData = accessTokens.get(token);

  if (!tokenData || tokenData.provider !== 'google') {
    return res.status(401).json({ error: 'invalid_token' });
  }

  const user = MOCK_USERS.google[tokenData.userId];
  if (!user) {
    return res.status(404).json({ error: 'user_not_found' });
  }

  res.json(user);
});
