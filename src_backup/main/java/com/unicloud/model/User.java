//package com.unicloud.model.CloudAccount;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class User {
  private Long id;
  private String username;
  private String email;
  private String passwordHash;
  private String firstName;
  private String lastName;
  private LocalDateTime createdAt;
  private LocalDateTime updatedAt;
  private boolean isActive;
  //private List<CloudAccount> cloudAccount;

  // Constructors
  public User() {
    this.createdAt = LocalDateTime.now();
    this.updatedAt = LocalDateTime.now();
    this.isActive = true;
    //this.cloudAccount = new ArrayList<>();
  }

  public User(String username, String email, String passwordHash) {
    this();
    this.email = email;
    this.passwordHash = passwordHash;
    this.username = username;
  }

  public User(String username, String email, String passwordHash,
              String firstName, String lastName) {
    this(username, email, passwordHash);
    this.firstName = firstName;
    this.lastName = lastName;
  }
}
