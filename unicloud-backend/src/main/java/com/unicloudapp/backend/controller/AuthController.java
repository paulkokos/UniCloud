package com.unicloudapp.backend.controller;

import com.unicloudapp.backend.service.AuthService;
import com.unicloudapp.common.dto.auth.*;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * AuthController - Authentication REST API Handles user registration, login,
 * logout, and token
 * management
 */
@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthController {

  private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

  @Autowired
  private AuthService authService;

  /** Register new user POST /api/v1/auth/register */
  @PostMapping("/register")
  public ResponseEntity<?> registerUser(@Valid @RequestBody RegisterRequest registerRequest) {
    try {
      logger.info("Registration attempt for username: {}", registerRequest.getUsername());

      AuthResponse response = authService.registerUser(registerRequest);

      logger.info("User registered successfully: {}", registerRequest.getUsername());
      return ResponseEntity.status(HttpStatus.CREATED).body(response);

    } catch (RuntimeException e) {
      logger.error(
          "Registration failed for username: {} - {}",
          registerRequest.getUsername(),
          e.getMessage());
      return ResponseEntity.badRequest()
          .body(new ErrorResponse("Registration failed", e.getMessage()));
    } catch (Exception e) {
      logger.error("Unexpected error during registration", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(new ErrorResponse("Internal server error", "Registration temporarily unavailable"));
    }
  }

  /** Authenticate user login POST /api/v1/auth/login */
  @PostMapping("/login")
  public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {
    try {
      logger.info("Login attempt for user: {}", loginRequest.getUsernameOrEmail());

      AuthResponse response = authService.authenticateUser(loginRequest);

      logger.info("User logged in successfully: {}", loginRequest.getUsernameOrEmail());
      return ResponseEntity.ok(response);

    } catch (RuntimeException e) {
      logger.error(
          "Login failed for user: {} - {}", loginRequest.getUsernameOrEmail(), e.getMessage());
      return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
          .body(new ErrorResponse("Authentication failed", e.getMessage()));
    } catch (Exception e) {
      logger.error("Unexpected error during login", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(
              new ErrorResponse("Internal server error", "Authentication temporarily unavailable"));
    }
  }

  /** Refresh JWT token POST /api/v1/auth/refresh */
  @PostMapping("/refresh")
  public ResponseEntity<?> refreshToken(@Valid @RequestBody RefreshTokenRequest refreshRequest) {
    try {
      logger.debug("Token refresh attempt");

      AuthResponse response = authService.refreshToken(refreshRequest.getRefreshToken());

      logger.debug("Token refreshed successfully");
      return ResponseEntity.ok(response);

    } catch (RuntimeException e) {
      logger.error("Token refresh failed: {}", e.getMessage());
      return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
          .body(new ErrorResponse("Token refresh failed", e.getMessage()));
    } catch (Exception e) {
      logger.error("Unexpected error during token refresh", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(
              new ErrorResponse("Internal server error", "Token refresh temporarily unavailable"));
    }
  }

  /** Logout user POST /api/v1/auth/logout */
  @PostMapping("/logout")
  public ResponseEntity<?> logoutUser(@RequestHeader("Authorization") String authHeader) {
    try {
      logger.debug("Logout attempt");

      authService.logoutUser(authHeader);

      logger.debug("User logged out successfully");
      return ResponseEntity.ok(new MessageResponse("User logged out successfully"));

    } catch (Exception e) {
      logger.error("Error during logout", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(new ErrorResponse("Logout error", "Logout failed"));
    }
  }

  /**
   * Verify email address GET /api/v1/auth/verify-email?token=<verification-token>
   */
  @GetMapping("/verify-email")
  public ResponseEntity<?> verifyEmail(@RequestParam String token) {
    try {
      logger.info("Email verification attempt with token");

      authService.verifyEmail(token);

      logger.info("Email verified successfully");
      return ResponseEntity.ok(new MessageResponse("Email verified successfully"));

    } catch (RuntimeException e) {
      logger.error("Email verification failed: {}", e.getMessage());
      return ResponseEntity.badRequest()
          .body(new ErrorResponse("Email verification failed", e.getMessage()));
    } catch (Exception e) {
      logger.error("Unexpected error during email verification", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(
              new ErrorResponse(
                  "Internal server error", "Email verification temporarily unavailable"));
    }
  }

  /** Request password reset POST /api/v1/auth/forgot-password */
  @PostMapping("/forgot-password")
  public ResponseEntity<?> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
    try {
      logger.info("Password reset request for email: {}", request.getEmail());

      authService.initiatePasswordReset(request.getEmail());

      logger.info("Password reset email sent");
      return ResponseEntity.ok(new MessageResponse("Password reset email sent"));

    } catch (Exception e) {
      logger.error("Error processing password reset request", e);
      // Don't reveal whether email exists or not for security
      return ResponseEntity.ok(
          new MessageResponse("If the email exists, a password reset link has been sent"));
    }
  }

  /** Reset password with token POST /api/v1/auth/reset-password */
  @PostMapping("/reset-password")
  public ResponseEntity<?> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
    try {
      logger.info("Password reset attempt with token");

      authService.resetPassword(request.getToken(), request.getNewPassword());

      logger.info("Password reset successfully");
      return ResponseEntity.ok(new MessageResponse("Password reset successfully"));

    } catch (RuntimeException e) {
      logger.error("Password reset failed: {}", e.getMessage());
      return ResponseEntity.badRequest()
          .body(new ErrorResponse("Password reset failed", e.getMessage()));
    } catch (Exception e) {
      logger.error("Unexpected error during password reset", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(
              new ErrorResponse("Internal server error", "Password reset temporarily unavailable"));
    }
  }

  /**
   * Check if username is available GET
   * /api/v1/auth/check-username?username=<username>
   */
  @GetMapping("/check-username")
  public ResponseEntity<?> checkUsername(@RequestParam String username) {
    try {
      boolean available = authService.isUsernameAvailable(username);
      return ResponseEntity.ok(new AvailabilityResponse("username", username, available));
    } catch (Exception e) {
      logger.error("Error checking username availability", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(
              new ErrorResponse("Internal server error", "Username check temporarily unavailable"));
    }
  }

  /** Check if email is available GET /api/v1/auth/check-email?email=<email> */
  @GetMapping("/check-email")
  public ResponseEntity<?> checkEmail(@RequestParam String email) {
    try {
      boolean available = authService.isEmailAvailable(email);
      return ResponseEntity.ok(new AvailabilityResponse("email", email, available));
    } catch (Exception e) {
      logger.error("Error checking email availability", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(new ErrorResponse("Internal server error", "Email check temporarily unavailable"));
    }
  }

  /** Validate JWT token GET /api/v1/auth/validate */
  @GetMapping("/validate")
  public ResponseEntity<?> validateToken(@RequestHeader("Authorization") String authHeader) {
    try {
      TokenValidationResponse response = authService.validateToken(authHeader);
      return ResponseEntity.ok(response);
    } catch (RuntimeException e) {
      logger.error("Token validation failed: {}", e.getMessage());
      return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
          .body(new ErrorResponse("Token validation failed", e.getMessage()));
    } catch (Exception e) {
      logger.error("Unexpected error during token validation", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(
              new ErrorResponse(
                  "Internal server error", "Token validation temporarily unavailable"));
    }
  }
}
