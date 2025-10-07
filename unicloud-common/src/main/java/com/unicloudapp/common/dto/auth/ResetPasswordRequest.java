package com.unicloudapp.common.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class ResetPasswordRequest {
    
    @NotBlank(message = "Reset token is required")
    private String token;
    
    @NotBlank(message = "New password is required")
    @Size(min = 8, max = 128, message = "Password must be between 8 and 128 characters")
    private String newPassword;
    
    public ResetPasswordRequest() {}
    
    public ResetPasswordRequest(String token, String newPassword) {
        this.token = token;
        this.newPassword = newPassword;
    }
    
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    
    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
}
