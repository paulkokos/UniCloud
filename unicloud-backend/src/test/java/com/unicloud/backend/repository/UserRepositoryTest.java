package com.unicloud.backend.repository;

import com.unicloud.common.model.User;
import com.unicloud.common.model.UserStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Repository tests for UserRepository
 * Uses @DataJpaTest for lightweight JPA testing with H2
 */
@DataJpaTest
@ActiveProfiles("test")
class UserRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private UserRepository userRepository;

    private User testUser;

    @BeforeEach
    void setUp() {
        // Clean database before each test to ensure isolation
        userRepository.deleteAll();
        entityManager.flush();
        entityManager.clear();

        testUser = new User();
        testUser.setUsername("repotest");
        testUser.setEmail("repo@example.com");
        testUser.setPasswordHash("hashedPassword");
        testUser.setFirstName("Repo");
        testUser.setLastName("Test");
        testUser.setStatus(UserStatus.ACTIVE);
    }

    @Test
    void testSaveUser() {
        // When
        User saved = userRepository.save(testUser);

        // Then
        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getUsername()).isEqualTo("repotest");
        assertThat(saved.getCreatedAt()).isNotNull();
    }

    @Test
    void testFindByUsername_Found() {
        // Given
        entityManager.persist(testUser);
        entityManager.flush();

        // When
        Optional<User> found = userRepository.findByUsername("repotest");

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getEmail()).isEqualTo("repo@example.com");
    }

    @Test
    void testFindByUsername_NotFound() {
        // When
        Optional<User> found = userRepository.findByUsername("nonexistent");

        // Then
        assertThat(found).isEmpty();
    }

    @Test
    void testFindByEmail_Found() {
        // Given
        entityManager.persist(testUser);
        entityManager.flush();

        // When
        Optional<User> found = userRepository.findByEmail("repo@example.com");

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getUsername()).isEqualTo("repotest");
    }

    @Test
    void testFindByEmail_NotFound() {
        // When
        Optional<User> found = userRepository.findByEmail("nonexistent@example.com");

        // Then
        assertThat(found).isEmpty();
    }

    @Test
    void testExistsByUsername_True() {
        // Given
        entityManager.persist(testUser);
        entityManager.flush();

        // When
        boolean exists = userRepository.existsByUsername("repotest");

        // Then
        assertThat(exists).isTrue();
    }

    @Test
    void testExistsByUsername_False() {
        // When
        boolean exists = userRepository.existsByUsername("nonexistent");

        // Then
        assertThat(exists).isFalse();
    }

    @Test
    void testExistsByEmail_True() {
        // Given
        entityManager.persist(testUser);
        entityManager.flush();

        // When
        boolean exists = userRepository.existsByEmail("repo@example.com");

        // Then
        assertThat(exists).isTrue();
    }

    @Test
    void testExistsByEmail_False() {
        // When
        boolean exists = userRepository.existsByEmail("nonexistent@example.com");

        // Then
        assertThat(exists).isFalse();
    }

    @Test
    void testDeleteUser() {
        // Given
        User saved = entityManager.persist(testUser);
        entityManager.flush();

        // When
        userRepository.deleteById(saved.getId());

        // Then
        Optional<User> deleted = userRepository.findById(saved.getId());
        assertThat(deleted).isEmpty();
    }

    @Test
    void testFindAll() {
        // Given
        User user1 = new User();
        user1.setUsername("user1");
        user1.setEmail("user1@example.com");
        user1.setPasswordHash("hash1");
        user1.setFirstName("User");
        user1.setLastName("One");
        user1.setStatus(UserStatus.ACTIVE);

        User user2 = new User();
        user2.setUsername("user2");
        user2.setEmail("user2@example.com");
        user2.setPasswordHash("hash2");
        user2.setFirstName("User");
        user2.setLastName("Two");
        user2.setStatus(UserStatus.ACTIVE);

        entityManager.persist(user1);
        entityManager.persist(user2);
        entityManager.flush();

        // When
        var users = userRepository.findAll();

        // Then
        assertThat(users).hasSize(2);
    }

    @Test
    void testUserStatusPersistence() {
        // Given
        testUser.setStatus(UserStatus.PENDING_VERIFICATION);
        User saved = entityManager.persist(testUser);
        entityManager.flush();
        entityManager.clear(); // Clear persistence context

        // When
        Optional<User> found = userRepository.findById(saved.getId());

        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getStatus()).isEqualTo(UserStatus.PENDING_VERIFICATION);
    }
}
