package com.unicloudapp.common.dto.auth;

import com.fasterxml.jackson.annotation.JsonProperty;

public class UserInfo {

  private Long id;
  private String username;
  private String email;
  private String firstName;
  private String lastName;
  private boolean emailVerified;

  public UserInfo() {}

  public UserInfo(
      Long id,
      String username,
      String email,
      String firstName,
      String lastName,
      boolean emailVerified) {
    this.id = id;
    this.username = username;
    this.email = email;
    this.firstName = firstName;
    this.lastName = lastName;
    this.emailVerified = emailVerified;
  }

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
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

  @JsonProperty("emailVerified")
  public boolean isEmailVerified() {
    return emailVerified;
  }

  public void setEmailVerified(boolean emailVerified) {
    this.emailVerified = emailVerified;
  }

  public String getFullName() {
    if (firstName == null && lastName == null) return username;
    return String.format(
            "%s %s", firstName != null ? firstName : "", lastName != null ? lastName : "")
        .trim();
  }
}
