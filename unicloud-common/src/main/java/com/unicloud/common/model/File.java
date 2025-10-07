package com.unicloud.common.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "files", schema = "unicloud", uniqueConstraints = @UniqueConstraint(columnNames = { "cloud_account_id",
    "provider_file_id" }))
public class File {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  @Column(columnDefinition = "UUID")
  private UUID id;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "cloud_account_id", nullable = false)
  private CloudAccount cloudAccount;

  @Column(name = "provider_file_id", nullable = false, length = 500)
  private String providerFileId;

  @Column(name = "file_name", nullable = false, length = 500)
  private String fileName;

  @Column(name = "file_path", length = 1000)
  private String filePath;

  @Column(name = "mime_type", length = 100)
  private String mimeType;

  @Column(name = "file_size", nullable = false)
  private Long fileSize = 0L;

  @Column(length = 64)
  private String checksum;

  @Column(name = "is_folder", nullable = false)
  private Boolean isFolder = false;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "parent_folder_id")
  private File parentFolder;

  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  @Column(name = "updated_at", nullable = false)
  private LocalDateTime updatedAt;

  @Column(name = "provider_created_at")
  private LocalDateTime providerCreatedAt;

  @Column(name = "provider_updated_at")
  private LocalDateTime providerUpdatedAt;

  // Constructors
  public File() {
    this.createdAt = LocalDateTime.now();
    this.updatedAt = LocalDateTime.now();
  }

  public File(User user, CloudAccount cloudAccount, String providerFileId, String fileName) {
    this();
    this.user = user;
    this.cloudAccount = cloudAccount;
    this.providerFileId = providerFileId;
    this.fileName = fileName;
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

  public CloudAccount getCloudAccount() {
    return cloudAccount;
  }

  public void setCloudAccount(CloudAccount cloudAccount) {
    this.cloudAccount = cloudAccount;
  }

  public String getProviderFileId() {
    return providerFileId;
  }

  public void setProviderFileId(String providerFileId) {
    this.providerFileId = providerFileId;
  }

  public String getFileName() {
    return fileName;
  }

  public void setFileName(String fileName) {
    this.fileName = fileName;
  }

  public String getFilePath() {
    return filePath;
  }

  public void setFilePath(String filePath) {
    this.filePath = filePath;
  }

  public String getMimeType() {
    return mimeType;
  }

  public void setMimeType(String mimeType) {
    this.mimeType = mimeType;
  }

  public Long getFileSize() {
    return fileSize;
  }

  public void setFileSize(Long fileSize) {
    this.fileSize = fileSize;
  }

  public String getChecksum() {
    return checksum;
  }

  public void setChecksum(String checksum) {
    this.checksum = checksum;
  }

  public Boolean getIsFolder() {
    return isFolder;
  }

  public void setIsFolder(Boolean isFolder) {
    this.isFolder = isFolder;
  }

  public File getParentFolder() {
    return parentFolder;
  }

  public void setParentFolder(File parentFolder) {
    this.parentFolder = parentFolder;
  }

  public LocalDateTime getCreatedAt() {
    return createdAt;
  }

  public LocalDateTime getUpdatedAt() {
    return updatedAt;
  }

  public LocalDateTime getProviderCreatedAt() {
    return providerCreatedAt;
  }

  public void setProviderCreatedAt(LocalDateTime providerCreatedAt) {
    this.providerCreatedAt = providerCreatedAt;
  }

  public LocalDateTime getProviderUpdatedAt() {
    return providerUpdatedAt;
  }

  public void setProviderUpdatedAt(LocalDateTime providerUpdatedAt) {
    this.providerUpdatedAt = providerUpdatedAt;
  }

  public String getFileExtension() {
    if (fileName == null || !fileName.contains(".")) {
      return "";
    }
    return fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
  }

  public String getFileSizeFormatted() {
    if (fileSize == null)
      return "0 B";

    String[] units = { "B", "KB", "MB", "GB", "TB" };
    int unitIndex = 0;
    double size = fileSize.doubleValue();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return String.format("%.2f %s", size, units[unitIndex]);
  }
}
