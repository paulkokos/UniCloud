package com.unicloudapp.common.dto.auth;

public class TokenValidationResponse {
    
    private boolean valid;
    private String username;
    private long expiresIn;
    private boolean needsRefresh;
    
    public TokenValidationResponse() {}
    
    public TokenValidationResponse(boolean valid, String username, long expiresIn, boolean needsRefresh) {
        this.valid = valid;
        this.username = username;
        this.expiresIn = expiresIn;
        this.needsRefresh = needsRefresh;
    }
    
    public boolean isValid() { return valid; }
    public void setValid(boolean valid) { this.valid = valid; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public long getExpiresIn() { return expiresIn; }
    public void setExpiresIn(long expiresIn) { this.expiresIn = expiresIn; }
    
    public boolean isNeedsRefresh() { return needsRefresh; }
    public void setNeedsRefresh(boolean needsRefresh) { this.needsRefresh = needsRefresh; }
}
