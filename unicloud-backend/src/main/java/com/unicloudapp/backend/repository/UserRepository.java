package com.unicloudapp.backend.repository;

import com.unicloudapp.backend.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * UserRepository - Data access layer for User entities
 * Provides CRUD operations and custom queries for user management
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    /**
     * Find user by username (case-insensitive)
     */
    Optional<User> findByUsernameIgnoreCase(String username);
    
    /**
     * Find user by email (case-insensitive)
     */
    Optional<User> findByEmailIgnoreCase(String email);
    
    /**
     * Find user by username or email (case-insensitive)
     */
    @Query("SELECT u FROM User u WHERE LOWER(u.username) = LOWER(:usernameOrEmail) OR LOWER(u.email) = LOWER(:usernameOrEmail)")
    Optional<User> findByUsernameOrEmailIgnoreCase(@Param("usernameOrEmail") String usernameOrEmail);
    
    /**
     * Check if username exists (case-insensitive)
     */
    boolean existsByUsernameIgnoreCase(String username);
    
    /**
     * Check if email exists (case-insensitive)
     */
    boolean existsByEmailIgnoreCase(String email);
    
    /**
     * Find all active users
     */
    List<User> findByIsActiveTrue();
    
    /**
     * Find all users with email verified
     */
    List<User> findByIsEmailVerifiedTrue();
    
    /**
     * Find active users with pagination
     */
    Page<User> findByIsActiveTrue(Pageable pageable);
    
    /**
     * Find users by first name or last name (case-insensitive)
     */
    @Query("SELECT u FROM User u WHERE LOWER(u.firstName) LIKE LOWER(CONCAT('%', :name, '%')) OR LOWER(u.lastName) LIKE LOWER(CONCAT('%', :name, '%'))")
    List<User> findByNameContainingIgnoreCase(@Param("name") String name);
    
    /**
     * Find users created after specific date
     */
    List<User> findByCreatedAtAfter(LocalDateTime date);
    
    /**
     * Find users with last login after specific date
     */
    List<User> findByLastLoginAfter(LocalDateTime date);
    
    /**
     * Find inactive users
     */
    List<User> findByIsActiveFalse();
    
    /**
     * Find users with unverified emails
     */
    List<User> findByIsEmailVerifiedFalse();
    
    /**
     * Count active users
     */
    long countByIsActiveTrue();
    
    /**
     * Count users with verified emails
     */
    long countByIsEmailVerifiedTrue();
    
    /**
     * Update user's last login time
     */
    @Modifying
    @Query("UPDATE User u SET u.lastLogin = :lastLogin WHERE u.id = :userId")
    int updateLastLogin(@Param("userId") Long userId, @Param("lastLogin") LocalDateTime lastLogin);
    
    /**
     * Update user's email verification status
     */
    @Modifying
    @Query("UPDATE User u SET u.isEmailVerified = :verified WHERE u.id = :userId")
    int updateEmailVerificationStatus(@Param("userId") Long userId, @Param("verified") Boolean verified);
    
    /**
     * Update user's active status
     */
    @Modifying
    @Query("UPDATE User u SET u.isActive = :active WHERE u.id = :userId")
    int updateActiveStatus(@Param("userId") Long userId, @Param("active") Boolean active);
    
    /**
     * Find users with cloud connections
     */
    @Query("SELECT DISTINCT u FROM User u INNER JOIN u.cloudConnections cc WHERE cc.isActive = true")
    List<User> findUsersWithActiveCloudConnections();
    
    /**
     * Find users with files
     */
    @Query("SELECT DISTINCT u FROM User u WHERE EXISTS (SELECT f FROM FileMetadata f WHERE f.user = u)")
    List<User> findUsersWithFiles();
    
    /**
     * Search users by multiple criteria
     */
    @Query("SELECT u FROM User u WHERE " +
           "(:username IS NULL OR LOWER(u.username) LIKE LOWER(CONCAT('%', :username, '%'))) AND " +
           "(:email IS NULL OR LOWER(u.email) LIKE LOWER(CONCAT('%', :email, '%'))) AND " +
           "(:active IS NULL OR u.isActive = :active) AND " +
           "(:verified IS NULL OR u.isEmailVerified = :verified)")
    Page<User> findBySearchCriteria(
        @Param("username") String username,
        @Param("email") String email,
        @Param("active") Boolean active,
        @Param("verified") Boolean verified,
        Pageable pageable
    );
}
