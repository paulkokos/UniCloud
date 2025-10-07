package com.unicloudapp.backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

/**
 * User Entity - Represents application users Implements Spring Security UserDetails for
 * authentication
 */
@Entity
@Table(
    name = "users",
    indexes = {
      @Index(name = "idx_user_email", columnList = "email"),
      @Index(name = "idx_user_username", columnList = "username")
    })
public class User implements UserDetails {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @NotBlank(message = "Username is required")
  @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
  @Column(unique = true, nullable = false, length = 50)
  private String username;

  @NotBlank(message = "Email is required")
  @Email(message = "Email should be valid")
  @Column(unique = true, nullable = false, length = 100)
  private String email;

  @NotBlank(message = "Password is required")
  @Size(min = 8, message = "Password must be at least 8 characters")
  @Column(nullable = false)
  private String password;

  @Column(name = "first_name", length = 50)
  private String firstName;

  @Column(name = "last_name", length = 50)
  private String lastName;

  @Column(name = "is_active", nullable = false)
  private Boolean isActive = true;

  @Column(name = "is_email_verified", nullable = false)
  private Boolean isEmailVerified = false;

  @Column(name = "last_login")
  private LocalDateTime lastLogin;

  @Column(name = "created_at", nullable = false)
  private LocalDateTime createdAt;

  @Column(name = "updated_at")
  private LocalDateTime updatedAt;

  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  private Set<CloudConnection> cloudConnections = new HashSet<>();

  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  private Set<FileMetadata> files = new HashSet<>();

  // Constructors
  public User() {}

  public User(String username, String email, String password) {
    this.username = username;
    this.email = email;
    this.password = password;
    this.createdAt = LocalDateTime.now();
  }

  // PrePersist and PreUpdate callbacks
  @PrePersist
  protected void onCreate() {
    this.createdAt = LocalDateTime.now();
    this.updatedAt = LocalDateTime.now();
  }

  @PreUpdate
  protected void onUpdate() {
    this.updatedAt = LocalDateTime.now();
  }

  // Spring Security UserDetails implementation
  @Override
  public Collection<? extends GrantedAuthority> getAuthorities() {
    return List.of(new SimpleGrantedAuthority("ROLE_USER"));
  }

  @Override
  public String getPassword() {
    return password;
  }

  @Override
  public String getUsername() {
    return username;
  }

  @Override
  public boolean isAccountNonExpired() {
    return true;
  }

  @Override
  public boolean isAccountNonLocked() {
    return isActive;
  }

  @Override
  public boolean isCredentialsNonExpired() {
    return true;
  }

  @Override
  public boolean isEnabled() {
    return isActive && isEmailVerified;
  }

  // Getters and Setters
  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
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

  public void setPassword(String password) {
    this.password = password;
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

  public Boolean getIsActive() {
    return isActive;
  }

  public void setIsActive(Boolean isActive) {
    this.isActive = isActive;
  }

  public Boolean getIsEmailVerified() {
    return isEmailVerified;
  }

  public void setIsEmailVerified(Boolean isEmailVerified) {
    this.isEmailVerified = isEmailVerified;
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

  public Set<CloudConnection> getCloudConnections() {
    return cloudConnections;
  }

  public void setCloudConnections(Set<CloudConnection> cloudConnections) {
    this.cloudConnections = cloudConnections;
  }

  public Set<FileMetadata> getFiles() {
    return files;
  }

  public void setFiles(Set<FileMetadata> files) {
    this.files = files;
  }

  // Helper methods
  public String getFullName() {
    if (firstName == null && lastName == null) {
      return username;
    }
    return String.format(
            "%s %s", firstName != null ? firstName : "", lastName != null ? lastName : "")
        .trim();
  }

  public void updateLastLogin() {
    this.lastLogin = LocalDateTime.now();
  }

  @Override
  public String toString() {
    return String.format(
        "User{id=%d, username='%s', email='%s', active=%s}", id, username, email, isActive);
  }
}
