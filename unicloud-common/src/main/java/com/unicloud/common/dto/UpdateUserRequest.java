package com.unicloud.common.dto;

import jakarta.validation.constraints.Email;

/** Request DTO for updating an existing user */
public class UpdateUserRequest {

  @Email(message = "Email must be valid")
  private String email;

  private String firstName;
  private String lastName;

  // Constructors
  public UpdateUserRequest() {
  }

  public UpdateUserRequest(String email, String firstName, String lastName) {
    this.email = email;
    this.firstName = firstName;
    this.lastName = lastName;
  }

  // Getters and Setters
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

  @Override
  public String toString() {
    return "UpdateUserRequest{"
        + "email='"
        + email
        + '\''
        + ", firstName='"
        + firstName
        + '\''
        + ", lastName='"
        + lastName
        + '\''
        + '}';
  }
}
