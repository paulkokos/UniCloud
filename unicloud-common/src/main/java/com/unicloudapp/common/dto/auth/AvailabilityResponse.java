package com.unicloudapp.common.dto.auth;

public class AvailabilityResponse {
    
    private String field;
    private String value;
    private boolean available;
    
    public AvailabilityResponse() {}
    
    public AvailabilityResponse(String field, String value, boolean available) {
        this.field = field;
        this.value = value;
        this.available = available;
    }
    
    public String getField() { return field; }
    public void setField(String field) { this.field = field; }
    
    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
    
    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }
}
