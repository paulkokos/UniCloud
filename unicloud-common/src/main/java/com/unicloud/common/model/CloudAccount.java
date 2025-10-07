package com.unicloud.common.model;

import jakarta.persistence.*;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "cloud_accounts", schema = "unicloud", uniqueConstraints = @UniqueConstraint(columnNames = { "user_id",
    "provider", "provider_user_id" }))
public class CloudAccount {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  @Column(columnDefinition = "UUID")
  private UUID id;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private CloudProvider provider;

  @Column(name = "provider_user_id", nullable = false)
  private String providerUserId;

  @Column(name = "provider_email")
  private String providerEmail;

  @Column(name = "account_name")
  private String accountName;

  @Column(name = "access_token", columnDefinition = "TEXT")
  private String accessToken;

  @Column(name = "refresh_token", columnDefinition = "TEXT")
  private String refreshToken;

  @Column(name = "token_expires_at")
  private LocalDateTime tokenExpiresAt;

  @Column(name = "is_active", nullable = false)
  private Boolean isActive = true;

  @Column(name = "total_quota", nullable = false)
  private Long totalQuota = 0L;

  @Column(name = "used_quota", nullable = false)
  private Long usedQuota = 0L;

  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  @Column(name = "updated_at", nullable = false)
  private LocalDateTime updatedAt;

  // Constructors
  public CloudAccount() {
    this.createdAt = LocalDateTime.now();
    this.updatedAt = LocalDateTime.now();
  }

  public CloudAccount(User user, CloudProvider provider, String providerUserId) {
    this();
    this.user = user;
    this.provider = provider;
    this.providerUserId = providerUserId;
  }

  // Lifecycle callbacks
  @PrePersist
  protected void onCreate() {
    createdAt = LocalDateTime.now();
    updatedAt = LocalDateTime.now();
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

  public String getAccountName() {
    return accountName;
  }

  public void setAccountName(String accountName) {
    this.accountName = accountName;
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

  public Boolean getIsActive() {
    return isActive;
  }

  public void setIsActive(Boolean isActive) {
    this.isActive = isActive;
  }

  public Long getTotalQuota() {
    return totalQuota;
  }

  public void setTotalQuota(Long totalQuota) {
    this.totalQuota = totalQuota;
  }

  public Long getUsedQuota() {
    return usedQuota;
  }

  public void setUsedQuota(Long usedQuota) {
    this.usedQuota = usedQuota;
  }

  public LocalDateTime getCreatedAt() {
    return createdAt;
  }

  public LocalDateTime getUpdatedAt() {
    return updatedAt;
  }

  public Long getRemainingQuota() {
    return totalQuota - usedQuota;
  }

  public Double getQuotaUsagePercentage() {
    if (totalQuota == 0)
      return 0.0;
    return (usedQuota.doubleValue() / totalQuota.doubleValue()) * 100;
  }
}
