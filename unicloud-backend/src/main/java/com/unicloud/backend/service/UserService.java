package com.unicloud.backend.service;

import com.unicloud.backend.repository.UserRepository;
import com.unicloud.common.model.User;
import com.unicloud.common.model.UserStatus;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /** Retrieve all users from the database */
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    /** Find a user by their unique ID */
    public Optional<User> findById(UUID id) {
        return userRepository.findById(id);
    }

    /** Find a user by username */
    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    /** Find a user by email */
    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    /** Get users by status (ACTIVE, INACTIVE, SUSPENDED, PENDING_VERIFICATION) */
    public List<User> getUsersByStatus(UserStatus status) {
        return userRepository.findByStatus(status);
    }

    /** Search users by username or email */
    public List<User> searchUsers(String searchTerm) {
        return userRepository.findByUsernameContainingIgnoreCaseOrEmailContainingIgnoreCase(
                searchTerm, searchTerm);
    }

    /** Create a new user with the provided details */
    public User createUser(
            String username, String email, String password, String firstName, String lastName) {
        // Check if username already exists
        if (userRepository.findByUsername(username).isPresent()) {
            throw new IllegalArgumentException("Username already exists: " + username);
        }

        // Check if email already exists
        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("Email already exists: " + email);
        }

        // Create new user
        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(password));
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setStatus(UserStatus.PENDING_VERIFICATION);
        user.setEmailVerified(false);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        user.setVersion(0);

        // Generate email verification token
        user.setEmailVerificationToken(UUID.randomUUID().toString());

        return userRepository.save(user);
    }

    /** Update an existing user */
    public User updateUser(UUID userId, User updatedUser) {
        User existingUser = userRepository
                .findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        // Update fields (only if provided)
        if (updatedUser.getFirstName() != null) {
            existingUser.setFirstName(updatedUser.getFirstName());
        }
        if (updatedUser.getLastName() != null) {
            existingUser.setLastName(updatedUser.getLastName());
        }
        if (updatedUser.getEmail() != null && !updatedUser.getEmail().equals(existingUser.getEmail())) {
            // Check if new email already exists
            if (userRepository.findByEmail(updatedUser.getEmail()).isPresent()) {
                throw new IllegalArgumentException("Email already exists: " + updatedUser.getEmail());
            }
            existingUser.setEmail(updatedUser.getEmail());
            existingUser.setEmailVerified(false); // Require re-verification
        }

        existingUser.setUpdatedAt(LocalDateTime.now());
        return userRepository.save(existingUser);
    }

    /** Delete a user by ID */
    public boolean deleteUser(UUID userId) {
        if (!userRepository.existsById(userId)) {
            return false;
        }
        userRepository.deleteById(userId);
        return true;
    }

    /** Verify a user's email using the verification token */
    public User verifyEmail(UUID userId) {
        User user = userRepository
                .findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        user.setEmailVerified(true);
        user.setEmailVerificationToken(null);
        user.setStatus(UserStatus.ACTIVE);
        user.setUpdatedAt(LocalDateTime.now());

        return userRepository.save(user);
    }

    /** Update user status (ACTIVE, INACTIVE, SUSPENDED, etc.) */
    public User updateUserStatus(UUID userId, UserStatus newStatus) {
        User user = userRepository
                .findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        user.setStatus(newStatus);
        user.setUpdatedAt(LocalDateTime.now());

        return userRepository.save(user);
    }

    /** Change user password */
    public void changePassword(UUID userId, String currentPassword, String newPassword) {
        User user = userRepository
                .findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        // Verify current password
        if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
            throw new IllegalArgumentException("Current password is incorrect");
        }

        // Update to new password
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
    }

    /** Initiate password reset by generating a reset token */
    public void initiatePasswordReset(String email) {
        User user = userRepository
                .findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User not found with email: " + email));

        String resetToken = UUID.randomUUID().toString();
        user.setPasswordResetToken(resetToken);
        user.setPasswordResetExpires(LocalDateTime.now().plusHours(24)); // 24-hour expiry
        user.setUpdatedAt(LocalDateTime.now());

        userRepository.save(user);

        // TODO: Send password reset email with token
    }

    /** Complete password reset using the reset token */
    public void resetPassword(String resetToken, String newPassword) {
        User user = userRepository
                .findByPasswordResetToken(resetToken)
                .orElseThrow(() -> new IllegalArgumentException("Invalid or expired reset token"));

        // Check if token is expired
        if (user.getPasswordResetExpires().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Password reset token has expired");
        }

        // Update password and clear reset token
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        user.setPasswordResetToken(null);
        user.setPasswordResetExpires(null);
        user.setUpdatedAt(LocalDateTime.now());

        userRepository.save(user);
    }

    /** Update last login timestamp */
    public void updateLastLogin(UUID userId) {
        User user = userRepository
                .findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        user.setLastLogin(LocalDateTime.now());
        userRepository.save(user);
    }

    /** Check if a username is available */
    public boolean isUsernameAvailable(String username) {
        return !userRepository.findByUsername(username).isPresent();
    }

    /** Check if an email is available */
    public boolean isEmailAvailable(String email) {
        return !userRepository.findByEmail(email).isPresent();
    }

    /** Get active users count */
    public long getActiveUsersCount() {
        return userRepository.countByStatus(UserStatus.ACTIVE);
    }

    /** Get total users count */
    public long getTotalUsersCount() {
        return userRepository.count();
    }
}
