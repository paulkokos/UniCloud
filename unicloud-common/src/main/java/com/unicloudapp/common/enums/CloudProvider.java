package com.unicloudapp.common.enums;

public enum CloudProvider {
    GOOGLE_DRIVE("Google Drive", "drive.google.com"),
    ONEDRIVE("OneDrive", "onedrive.live.com"),
    ICLOUD("iCloud", "icloud.com");
    
    private final String displayName;
    private final String domain;
    
    CloudProvider(String displayName, String domain) {
        this.displayName = displayName;
        this.domain = domain;
    }
    
    public String getDisplayName() {
        return displayName;
    }
    
    public String getDomain() {
        return domain;
    }
    
    @Override
    public String toString() {
        return displayName;
    }
}
