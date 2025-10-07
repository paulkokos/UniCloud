package com.unicloud.backend.controller;

import com.unicloud.backend.service.UserService;
import com.unicloud.common.dto.CreateUserRequest;
import com.unicloud.common.dto.UpdateUserRequest;
import com.unicloud.common.dto.UserDTO;
import com.unicloud.common.model.User;
import com.unicloud.common.model.UserStatus;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

  @Autowired
  private UserService userService;

  /** Get all users */
  @GetMapping
  public ResponseEntity<List<UserDTO>> getAllUsers() {
    List<User> users = userService.getAllUsers();
    List<UserDTO> userDTOs = users.stream().map(this::convertToDTO).collect(Collectors.toList());
    return ResponseEntity.ok(userDTOs);
  }

  /** Get user by ID */
  @GetMapping("/{id}")
  public ResponseEntity<UserDTO> getUserById(@PathVariable UUID id) {
    return userService
        .findById(id)
        .map(user -> ResponseEntity.ok(convertToDTO(user)))
        .orElse(ResponseEntity.notFound().build());
  }

  /** Get user by username */
  @GetMapping("/username/{username}")
  public ResponseEntity<UserDTO> getUserByUsername(@PathVariable String username) {
    return userService
        .findByUsername(username)
        .map(user -> ResponseEntity.ok(convertToDTO(user)))
        .orElse(ResponseEntity.notFound().build());
  }

  /** Get user by email */
  @GetMapping("/email/{email}")
  public ResponseEntity<UserDTO> getUserByEmail(@PathVariable String email) {
    return userService
        .findByEmail(email)
        .map(user -> ResponseEntity.ok(convertToDTO(user)))
        .orElse(ResponseEntity.notFound().build());
  }

  /** Get users by status */
  @GetMapping("/status/{status}")
  public ResponseEntity<List<UserDTO>> getUsersByStatus(@PathVariable UserStatus status) {
    List<User> users = userService.getUsersByStatus(status);
    List<UserDTO> userDTOs = users.stream().map(this::convertToDTO).collect(Collectors.toList());
    return ResponseEntity.ok(userDTOs);
  }

  /** Search users */
  @GetMapping("/search")
  public ResponseEntity<List<UserDTO>> searchUsers(@RequestParam String query) {
    List<User> users = userService.searchUsers(query);
    List<UserDTO> userDTOs = users.stream().map(this::convertToDTO).collect(Collectors.toList());
    return ResponseEntity.ok(userDTOs);
  }

  /** Create new user */
  @PostMapping
  public ResponseEntity<UserDTO> createUser(@Valid @RequestBody CreateUserRequest request) {
    User user = userService.createUser(
        request.getUsername(),
        request.getEmail(),
        request.getPassword(),
        request.getFirstName(),
        request.getLastName());
    return ResponseEntity.status(HttpStatus.CREATED).body(convertToDTO(user));
  }

  /** Update user */
  @PutMapping("/{id}")
  public ResponseEntity<UserDTO> updateUser(
      @PathVariable UUID id, @Valid @RequestBody UpdateUserRequest request) {
    User userToUpdate = new User();
    userToUpdate.setFirstName(request.getFirstName());
    userToUpdate.setLastName(request.getLastName());
    userToUpdate.setEmail(request.getEmail());

    User updatedUser = userService.updateUser(id, userToUpdate);
    return ResponseEntity.ok(convertToDTO(updatedUser));
  }

  /** Delete user */
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteUser(@PathVariable UUID id) {
    boolean deleted = userService.deleteUser(id);
    if (deleted) {
      return ResponseEntity.noContent().build();
    }
    return ResponseEntity.notFound().build();
  }

  /** Verify email */
  @PostMapping("/{id}/verify-email")
  public ResponseEntity<UserDTO> verifyEmail(@PathVariable UUID id) {
    User user = userService.verifyEmail(id);
    return ResponseEntity.ok(convertToDTO(user));
  }

  /** Update user status */
  @PutMapping("/{id}/status")
  public ResponseEntity<UserDTO> updateUserStatus(
      @PathVariable UUID id, @RequestBody UserStatus status) {
    User user = userService.updateUserStatus(id, status);
    return ResponseEntity.ok(convertToDTO(user));
  }

  /** Get user statistics */
  @GetMapping("/stats")
  public ResponseEntity<UserStats> getUserStats() {
    UserStats stats = new UserStats();
    stats.setTotalUsers(userService.getTotalUsersCount());
    stats.setActiveUsers(userService.getActiveUsersCount());
    return ResponseEntity.ok(stats);
  }

  /** Check username availability */
  @GetMapping("/check-username/{username}")
  public ResponseEntity<Boolean> checkUsername(@PathVariable String username) {
    boolean available = userService.isUsernameAvailable(username);
    return ResponseEntity.ok(available);
  }

  /** Check email availability */
  @GetMapping("/check-email/{email}")
  public ResponseEntity<Boolean> checkEmail(@PathVariable String email) {
    boolean available = userService.isEmailAvailable(email);
    return ResponseEntity.ok(available);
  }

  // Helper method to convert User entity to UserDTO
  private UserDTO convertToDTO(User user) {
    UserDTO dto = new UserDTO();
    dto.setId(user.getId());
    dto.setUsername(user.getUsername());
    dto.setEmail(user.getEmail());
    dto.setFirstName(user.getFirstName());
    dto.setLastName(user.getLastName());
    dto.setStatus(user.getStatus());
    dto.setEmailVerified(user.isEmailVerified());
    dto.setLastLogin(user.getLastLogin());
    dto.setCreatedAt(user.getCreatedAt());
    dto.setUpdatedAt(user.getUpdatedAt());
    return dto;
  }

  // Inner class for user statistics
  public static class UserStats {
    private long totalUsers;
    private long activeUsers;

    public long getTotalUsers() {
      return totalUsers;
    }

    public void setTotalUsers(long totalUsers) {
      this.totalUsers = totalUsers;
    }

    public long getActiveUsers() {
      return activeUsers;
    }

    public void setActiveUsers(long activeUsers) {
      this.activeUsers = activeUsers;
    }
  }
}
