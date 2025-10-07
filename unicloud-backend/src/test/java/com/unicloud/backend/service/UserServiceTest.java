package com.unicloud.backend.service;

import com.unicloud.backend.repository.UserRepository;
import com.unicloud.common.model.User;
import com.unicloud.common.model.UserStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit tests for UserService
 * Tests business logic with mocked dependencies
 */
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserService userService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(UUID.randomUUID());
        testUser.setUsername("testuser");
        testUser.setEmail("test@example.com");
        testUser.setPasswordHash("hashedPassword");
        testUser.setFirstName("Test");
        testUser.setLastName("User");
        testUser.setStatus(UserStatus.ACTIVE);
    }

    @Test
    void testCreateUser_Success() {
        // Given
        when(userRepository.findByUsername("newuser")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("new@example.com")).thenReturn(Optional.empty());
        when(passwordEncoder.encode("password123")).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        User result = userService.createUser("newuser", "new@example.com", "password123", "New", "User");

        // Then
        assertThat(result).isNotNull();
        verify(passwordEncoder).encode("password123");
        verify(userRepository).save(any(User.class));
    }

    @Test
    void testCreateUser_UsernameExists() {
        // Given
        when(userRepository.findByUsername("existing")).thenReturn(Optional.of(testUser));

        // When & Then
        assertThatThrownBy(() ->
            userService.createUser("existing", "new@example.com", "password", "New", "User")
        )
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("Username already exists");
    }

    @Test
    void testCreateUser_EmailExists() {
        // Given
        when(userRepository.findByUsername("newuser")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("existing@example.com")).thenReturn(Optional.of(testUser));

        // When & Then
        assertThatThrownBy(() ->
            userService.createUser("newuser", "existing@example.com", "password", "New", "User")
        )
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("Email already exists");
    }

    @Test
    void testFindById_Found() {
        // Given
        UUID userId = testUser.getId();
        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

        // When
        Optional<User> result = userService.findById(userId);

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getId()).isEqualTo(userId);
        verify(userRepository).findById(userId);
    }

    @Test
    void testFindById_NotFound() {
        // Given
        UUID userId = UUID.randomUUID();
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // When
        Optional<User> result = userService.findById(userId);

        // Then
        assertThat(result).isEmpty();
    }

    @Test
    void testFindByUsername_Found() {
        // Given
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(testUser));

        // When
        Optional<User> result = userService.findByUsername("testuser");

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getUsername()).isEqualTo("testuser");
    }

    @Test
    void testFindByEmail_Found() {
        // Given
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));

        // When
        Optional<User> result = userService.findByEmail("test@example.com");

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getEmail()).isEqualTo("test@example.com");
    }

    @Test
    void testGetAllUsers() {
        // Given
        User user1 = new User();
        user1.setUsername("user1");
        User user2 = new User();
        user2.setUsername("user2");

        when(userRepository.findAll()).thenReturn(Arrays.asList(user1, user2));

        // When
        List<User> results = userService.getAllUsers();

        // Then
        assertThat(results).hasSize(2);
        verify(userRepository).findAll();
    }

    @Test
    void testGetUsersByStatus() {
        // Given
        when(userRepository.findByStatus(UserStatus.ACTIVE)).thenReturn(Arrays.asList(testUser));

        // When
        List<User> results = userService.getUsersByStatus(UserStatus.ACTIVE);

        // Then
        assertThat(results).hasSize(1);
        assertThat(results.get(0).getStatus()).isEqualTo(UserStatus.ACTIVE);
    }

    @Test
    void testPasswordIsEncoded() {
        // Given
        when(userRepository.findByUsername(anyString())).thenReturn(Optional.empty());
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.empty());
        when(passwordEncoder.encode("plainPassword")).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // When
        userService.createUser("newuser", "new@example.com", "plainPassword", "New", "User");

        // Then
        verify(passwordEncoder).encode("plainPassword");
    }
}
