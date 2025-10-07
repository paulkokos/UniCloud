package com.unicloud.common.dto;

import com.unicloud.common.model.UserStatus;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Data Transfer Object for User entity Used to send user data to clients
 * without exposing sensitive
 * information
 */
public class UserDTO {

  private UUID id;
  private String username;
  private String email;
  private String firstName;
  private String lastName;
  private UserStatus status;
  private boolean emailVerified;
  private LocalDateTime lastLogin;
  private LocalDateTime createdAt;
  private LocalDateTime updatedAt;

  // Constructors
  public UserDTO() {
  }

  public UserDTO(UUID id, String username, String email, String firstName, String lastName) {
    this.id = id;
    this.username = username;
    this.email = email;
    this.firstName = firstName;
    this.lastName = lastName;
  }

  // Getters and Setters
  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }

  public String getEmail() {
    return email;
  }

  public void setEmail(String email) {
    this.email = email;
  }

  public String getFirstName() {
    return firstName;
  }

  public void setFirstName(String firstName) {
    this.firstName = firstName;
  }

  public String getLastName() {
    return lastName;
  }

  public void setLastName(String lastName) {
    this.lastName = lastName;
  }

  public UserStatus getStatus() {
    return status;
  }

  public void setStatus(UserStatus status) {
    this.status = status;
  }

  public boolean isEmailVerified() {
    return emailVerified;
  }

  public void setEmailVerified(boolean emailVerified) {
    this.emailVerified = emailVerified;
  }

  public LocalDateTime getLastLogin() {
    return lastLogin;
  }

  public void setLastLogin(LocalDateTime lastLogin) {
    this.lastLogin = lastLogin;
  }

  public LocalDateTime getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(LocalDateTime createdAt) {
    this.createdAt = createdAt;
  }

  public LocalDateTime getUpdatedAt() {
    return updatedAt;
  }

  public void setUpdatedAt(LocalDateTime updatedAt) {
    this.updatedAt = updatedAt;
  }

  // Utility methods
  public String getFullName() {
    if (firstName != null && lastName != null) {
      return firstName + " " + lastName;
    } else if (firstName != null) {
      return firstName;
    } else if (lastName != null) {
      return lastName;
    }
    return username;
  }

  @Override
  public String toString() {
    return "UserDTO{"
        + "id="
        + id
        + ", username='"
        + username
        + '\''
        + ", email='"
        + email
        + '\''
        + ", firstName='"
        + firstName
        + '\''
        + ", lastName='"
        + lastName
        + '\''
        + ", status="
        + status
        + ", emailVerified="
        + emailVerified
        + '}';
  }
}
