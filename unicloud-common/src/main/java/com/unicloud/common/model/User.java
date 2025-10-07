package com.unicloud.common.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "users", schema = "unicloud")
public class User {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  @Column(columnDefinition = "UUID")
  private UUID id;

  @NotBlank(message = "Username is required")
  @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
  @Column(unique = true, nullable = false, length = 50)
  private String username;

  @NotBlank(message = "Email is required")
  @Email(message = "Email must be valid")
  @Size(max = 255, message = "Email must not exceed 255 characters")
  @Column(unique = true, nullable = false, length = 255)
  private String email;

  @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
  @NotBlank(message = "Password is required")
  @Column(name = "password_hash", nullable = false, length = 255)
  private String passwordHash;

  @Column(name = "first_name", length = 100)
  private String firstName;

  @Column(name = "last_name", length = 100)
  private String lastName;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 30)
  private UserStatus status = UserStatus.PENDING_VERIFICATION;

  @Column(name = "email_verified", nullable = false)
  private boolean emailVerified = false;

  @JsonIgnore
  @Column(name = "email_verification_token", length = 255)
  private String emailVerificationToken;

  @JsonIgnore
  @Column(name = "password_reset_token", length = 255)
  private String passwordResetToken;

  @JsonIgnore
  @Column(name = "password_reset_expires")
  private LocalDateTime passwordResetExpires;

  @Column(name = "last_login")
  private LocalDateTime lastLogin;

  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  @Column(name = "updated_at", nullable = false)
  private LocalDateTime updatedAt;

  @Version
  @Column(nullable = false)
  private Integer version = 0;

  @JsonIgnore
  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
  private List<CloudAccount> cloudAccounts = new ArrayList<>();

  @JsonIgnore
  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
  private List<File> files = new ArrayList<>();

  // Constructors
  public User() {
    this.createdAt = LocalDateTime.now();
    this.updatedAt = LocalDateTime.now();
  }

  public User(String username, String email, String passwordHash) {
    this();
    this.username = username;
    this.email = email;
    this.passwordHash = passwordHash;
  }

  public User(
      String username, String email, String passwordHash, String firstName, String lastName) {
    this(username, email, passwordHash);
    this.firstName = firstName;
    this.lastName = lastName;
  }

  // Lifecycle callbacks
  @PrePersist
  protected void onCreate() {
    createdAt = LocalDateTime.now();
    updatedAt = LocalDateTime.now();
    if (status == null) {
      status = UserStatus.PENDING_VERIFICATION;
    }
  }

  @PreUpdate
  protected void onUpdate() {
    updatedAt = LocalDateTime.now();
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

  public String getPasswordHash() {
    return passwordHash;
  }

  public void setPasswordHash(String passwordHash) {
    this.passwordHash = passwordHash;
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

  public String getEmailVerificationToken() {
    return emailVerificationToken;
  }

  public void setEmailVerificationToken(String emailVerificationToken) {
    this.emailVerificationToken = emailVerificationToken;
  }

  public String getPasswordResetToken() {
    return passwordResetToken;
  }

  public void setPasswordResetToken(String passwordResetToken) {
    this.passwordResetToken = passwordResetToken;
  }

  public LocalDateTime getPasswordResetExpires() {
    return passwordResetExpires;
  }

  public void setPasswordResetExpires(LocalDateTime passwordResetExpires) {
    this.passwordResetExpires = passwordResetExpires;
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

  public Integer getVersion() {
    return version;
  }

  public void setVersion(Integer version) {
    this.version = version;
  }

  public List<CloudAccount> getCloudAccounts() {
    return cloudAccounts;
  }

  public void setCloudAccounts(List<CloudAccount> cloudAccounts) {
    this.cloudAccounts = cloudAccounts;
  }

  public List<File> getFiles() {
    return files;
  }

  public void setFiles(List<File> files) {
    this.files = files;
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

  public boolean isActive() {
    return status == UserStatus.ACTIVE;
  }

  public void addCloudAccount(CloudAccount cloudAccount) {
    cloudAccounts.add(cloudAccount);
    cloudAccount.setUser(this);
  }

  public void removeCloudAccount(CloudAccount cloudAccount) {
    cloudAccounts.remove(cloudAccount);
    cloudAccount.setUser(null);
  }

  // toString, equals, and hashCode
  @Override
  public String toString() {
    return "User{"
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
        + ", createdAt="
        + createdAt
        + ", updatedAt="
        + updatedAt
        + '}';
  }

  @Override
  public boolean equals(Object o) {
    if (this == o)
      return true;
    if (!(o instanceof User))
      return false;
    User user = (User) o;
    return id != null && id.equals(user.id);
  }

  @Override
  public int hashCode() {
    return getClass().hashCode();
  }
}
