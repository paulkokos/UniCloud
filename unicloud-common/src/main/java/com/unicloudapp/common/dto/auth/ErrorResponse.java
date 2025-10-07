package com.unicloudapp.common.dto.auth;

public class ErrorResponse {
    
    private String error;
    private String message;
    private long timestamp;
    
    public ErrorResponse() {
        this.timestamp = System.currentTimeMillis();
    }
    
    public ErrorResponse(String error, String message) {
        this.error = error;
        this.message = message;
        this.timestamp = System.currentTimeMillis();
    }
    
    public String getError() { return error; }
    public void setError(String error) { this.error = error; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
}
