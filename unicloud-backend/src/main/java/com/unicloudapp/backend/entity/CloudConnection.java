package com.unicloudapp.backend.entity;

import com.unicloudapp.common.enums.CloudProvider;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

/**
 * CloudConnection Entity - Represents user's cloud service connections Stores
 * OAuth tokens and
 * connection metadata for each cloud provider
 */
@Entity
@Table(name = "cloud_connections", uniqueConstraints = @UniqueConstraint(columnNames = { "user_id",
        "provider" }), indexes = {
                @Index(name = "idx_cloud_user", columnList = "user_id"),
                @Index(name = "idx_cloud_provider", columnList = "provider"),
                @Index(name = "idx_cloud_active", columnList = "is_active")
        })
public class CloudConnection {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @NotNull(message = "Cloud provider is required")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private CloudProvider provider;

    @Column(name = "provider_user_id", length = 100)
    private String providerUserId;

    @Column(name = "provider_email", length = 100)
    private String providerEmail;

    @Column(name = "provider_name", length = 100)
    private String providerName;

    @Column(name = "access_token", columnDefinition = "TEXT")
    private String accessToken;

    @Column(name = "refresh_token", columnDefinition = "TEXT")
    private String refreshToken;

    @Column(name = "token_expires_at")
    private LocalDateTime tokenExpiresAt;

    @Column(name = "scope", length = 500)
    private String scope;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "last_sync")
    private LocalDateTime lastSync;

    @Column(name = "quota_total")
    private Long quotaTotal;

    @Column(name = "quota_used")
    private Long quotaUsed;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Constructors
    public CloudConnection() {
    }

    public CloudConnection(User user, CloudProvider provider) {
        this.user = user;
        this.provider = provider;
        this.createdAt = LocalDateTime.now();
        this.isActive = true;
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

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public CloudProvider getProvider() {
        return provider;
    }

    public void setProvider(CloudProvider provider) {
        this.provider = provider;
    }

    public String getProviderUserId() {
        return providerUserId;
    }

    public void setProviderUserId(String providerUserId) {
        this.providerUserId = providerUserId;
    }

    public String getProviderEmail() {
        return providerEmail;
    }

    public void setProviderEmail(String providerEmail) {
        this.providerEmail = providerEmail;
    }

    public String getProviderName() {
        return providerName;
    }

    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public LocalDateTime getTokenExpiresAt() {
        return tokenExpiresAt;
    }

    public void setTokenExpiresAt(LocalDateTime tokenExpiresAt) {
        this.tokenExpiresAt = tokenExpiresAt;
    }

    public String getScope() {
        return scope;
    }

    public void setScope(String scope) {
        this.scope = scope;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public LocalDateTime getLastSync() {
        return lastSync;
    }

    public void setLastSync(LocalDateTime lastSync) {
        this.lastSync = lastSync;
    }

    public Long getQuotaTotal() {
        return quotaTotal;
    }

    public void setQuotaTotal(Long quotaTotal) {
        this.quotaTotal = quotaTotal;
    }

    public Long getQuotaUsed() {
        return quotaUsed;
    }

    public void setQuotaUsed(Long quotaUsed) {
        this.quotaUsed = quotaUsed;
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

    // Helper methods
    public boolean isTokenExpired() {
        return tokenExpiresAt != null && LocalDateTime.now().isAfter(tokenExpiresAt);
    }

    public boolean needsTokenRefresh() {
        return isTokenExpired()
                || (tokenExpiresAt != null && LocalDateTime.now().plusMinutes(5).isAfter(tokenExpiresAt));
    }

    public Long getAvailableQuota() {
        if (quotaTotal == null || quotaUsed == null) {
            return null;
        }
        return quotaTotal - quotaUsed;
    }

    public double getQuotaUsagePercentage() {
        if (quotaTotal == null || quotaUsed == null || quotaTotal == 0) {
            return 0.0;
        }
        return (quotaUsed.doubleValue() / quotaTotal.doubleValue()) * 100.0;
    }

    public void updateLastSync() {
        this.lastSync = LocalDateTime.now();
    }

    @Override
    public String toString() {
        return String.format(
                "CloudConnection{id=%d, provider=%s, user=%s, active=%s}",
                id, provider, user != null ? user.getUsername() : "null", isActive);
    }
}
