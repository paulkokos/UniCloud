package com.unicloud.backend.repository;

import com.unicloud.common.model.User;
import com.unicloud.common.model.UserStatus;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

  /** Find user by username (case-sensitive) */
  Optional<User> findByUsername(String username);

  /** Find user by email (case-insensitive) */
  Optional<User> findByEmail(String email);

  /** Find user by email verification token */
  Optional<User> findByEmailVerificationToken(String token);

  /** Find user by password reset token */
  Optional<User> findByPasswordResetToken(String token);

  /** Find all users with a specific status */
  List<User> findByStatus(UserStatus status);

  /** Find users by email verification status */
  List<User> findByEmailVerified(boolean emailVerified);

  /** Search users by username or email (case-insensitive partial match) */
  List<User> findByUsernameContainingIgnoreCaseOrEmailContainingIgnoreCase(
      String username, String email);

  /** Count users by status */
  long countByStatus(UserStatus status);

  /** Check if username exists */
  boolean existsByUsername(String username);

  /** Check if email exists */
  boolean existsByEmail(String email);

  /** Find all active users */
  default List<User> findAllActiveUsers() {
    return findByStatus(UserStatus.ACTIVE);
  }
}
