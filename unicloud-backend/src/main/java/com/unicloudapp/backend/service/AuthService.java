package com.unicloudapp.backend.service;

import com.unicloudapp.backend.entity.User;
import com.unicloudapp.backend.repository.UserRepository;
import com.unicloudapp.backend.security.JwtUtils;
import com.unicloudapp.common.dto.auth.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * AuthService - Authentication Service Implementation
 * Handles user registration, login, and token management
 */
@Service
@Transactional
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private AuthenticationManager authenticationManager;

    /**
     * Register a new user
     */
    public AuthResponse registerUser(RegisterRequest request) {
        logger.info("Registering new user: {}", request.getUsername());

        // Check if username already exists
        if (userRepository.existsByUsernameIgnoreCase(request.getUsername())) {
            throw new RuntimeException("Username is already taken!");
        }

        // Check if email already exists
        if (userRepository.existsByEmailIgnoreCase(request.getEmail())) {
            throw new RuntimeException("Email is already in use!");
        }

        // Create new user
        User user = new User(
                request.getUsername(),
                request.getEmail(),
                passwordEncoder.encode(request.getPassword())
        );

        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setIsEmailVerified(true); // For now, skip email verification

        User savedUser = userRepository.save(user);

        // Generate JWT tokens
        String accessToken = jwtUtils.generateTokenFromUsername(savedUser.getUsername());
        String refreshToken = jwtUtils.generateRefreshToken(savedUser.getUsername());

        // Create user info for response
        UserInfo userInfo = new UserInfo(
                savedUser.getId(),
                savedUser.getUsername(),
                savedUser.getEmail(),
                savedUser.getFirstName(),
                savedUser.getLastName(),
                savedUser.getIsEmailVerified()
        );

        logger.info("User registered successfully: {}", savedUser.getUsername());

        return new AuthResponse(accessToken, refreshToken, 86400L, userInfo); // 24 hours
    }

    /**
     * Authenticate user login
     */
    public AuthResponse authenticateUser(LoginRequest request) {
        logger.info("Authenticating user: {}", request.getUsernameOrEmail());

        try {
            // Authenticate with Spring Security
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getUsernameOrEmail(),
                            request.getPassword()
                    )
            );

            User user = (User) authentication.getPrincipal();

            // Generate JWT tokens
            String accessToken = jwtUtils.generateToken(authentication);
            String refreshToken = jwtUtils.generateRefreshToken(user.getUsername());

            // Create user info for response
            UserInfo userInfo = new UserInfo(
                    user.getId(),
                    user.getUsername(),
                    user.getEmail(),
                    user.getFirstName(),
                    user.getLastName(),
                    user.getIsEmailVerified()
            );

            logger.info("User authenticated successfully: {}", user.getUsername());

            return new AuthResponse(accessToken, refreshToken, 86400L, userInfo); // 24 hours

        } catch (AuthenticationException e) {
            logger.error("Authentication failed for user: {} - {}", request.getUsernameOrEmail(), e.getMessage());
            throw new RuntimeException("Invalid username/email or password");
        }
    }

    /**
     * Refresh JWT token
     */
    public AuthResponse refreshToken(String refreshToken) {
        logger.debug("Refreshing JWT token");

        if (!jwtUtils.validateToken(refreshToken)) {
            throw new RuntimeException("Invalid refresh token");
        }

        String username = jwtUtils.getUsernameFromToken(refreshToken);
        User user = userRepository.findByUsernameIgnoreCase(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Generate new tokens
        String newAccessToken = jwtUtils.generateTokenFromUsername(username);
        String newRefreshToken = jwtUtils.generateRefreshToken(username);

        UserInfo userInfo = new UserInfo(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getFirstName(),
                user.getLastName(),
                user.getIsEmailVerified()
        );

        logger.debug("Token refreshed successfully for user: {}", username);

        return new AuthResponse(newAccessToken, newRefreshToken, 86400L, userInfo);
    }

    /**
     * Logout user (placeholder - in a real app, you'd blacklist the token)
     */
    public void logoutUser(String authHeader) {
        String token = jwtUtils.extractTokenFromHeader(authHeader);
        if (token != null) {
            String username = jwtUtils.getUsernameFromToken(token);
            logger.info("User logged out: {}", username);
        }
        // In a real implementation, you would:
        // 1. Add token to blacklist
        // 2. Remove from active sessions
        // 3. Clear any cached data
    }

    /**
     * Verify email address (placeholder implementation)
     */
    public void verifyEmail(String token) {
        // In a real implementation:
        // 1. Validate email verification token
        // 2. Find user by token
        // 3. Mark email as verified
        // 4. Delete verification token
        logger.info("Email verification requested with token: {}", token.substring(0, Math.min(10, token.length())) + "...");
        throw new RuntimeException("Email verification not implemented yet");
    }

    /**
     * Initiate password reset (placeholder implementation)
     */
    public void initiatePasswordReset(String email) {
        logger.info("Password reset requested for email: {}", email);
        // In a real implementation:
        // 1. Find user by email
        // 2. Generate reset token
        // 3. Send reset email
        // For now, just log it
    }

    /**
     * Reset password with token (placeholder implementation)
     */
    public void resetPassword(String token, String newPassword) {
        logger.info("Password reset attempt with token");
        // In a real implementation:
        // 1. Validate reset token
        // 2. Find user by token
        // 3. Update password
        // 4. Delete reset token
        throw new RuntimeException("Password reset not implemented yet");
    }

    /**
     * Check if username is available
     */
    public boolean isUsernameAvailable(String username) {
        return !userRepository.existsByUsernameIgnoreCase(username);
    }

    /**
     * Check if email is available
     */
    public boolean isEmailAvailable(String email) {
        return !userRepository.existsByEmailIgnoreCase(email);
    }

    /**
     * Validate JWT token
     */
    public TokenValidationResponse validateToken(String authHeader) {
        String token = jwtUtils.extractTokenFromHeader(authHeader);
        
        if (token == null) {
            return new TokenValidationResponse(false, null, 0, false);
        }

        boolean isValid = jwtUtils.validateToken(token);
        if (!isValid) {
            return new TokenValidationResponse(false, null, 0, false);
        }

        String username = jwtUtils.getUsernameFromToken(token);
        long expiresIn = jwtUtils.getTokenValidityInSeconds(token);
        boolean needsRefresh = jwtUtils.isTokenCloseToExpiration(token);

        return new TokenValidationResponse(true, username, expiresIn, needsRefresh);
    }
}
