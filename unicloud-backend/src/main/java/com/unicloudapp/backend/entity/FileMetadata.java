package com.unicloudapp.backend.entity;

import com.unicloudapp.common.enums.CloudProvider;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;

/**
 * FileMetadata Entity - Represents file information across cloud providers
 * Stores metadata for
 * files managed through UniCloud
 */
@Entity
@Table(name = "file_metadata", indexes = {
        @Index(name = "idx_file_user", columnList = "user_id"),
        @Index(name = "idx_file_provider", columnList = "provider"),
        @Index(name = "idx_file_provider_id", columnList = "provider_file_id"),
        @Index(name = "idx_file_name", columnList = "file_name"),
        @Index(name = "idx_file_created", columnList = "created_at")
})
public class FileMetadata {

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

    @NotBlank(message = "Provider file ID is required")
    @Column(name = "provider_file_id", nullable = false, length = 255)
    private String providerFileId;

    @NotBlank(message = "File name is required")
    @Size(max = 255, message = "File name cannot exceed 255 characters")
    @Column(name = "file_name", nullable = false)
    private String fileName;

    @Column(name = "file_path", length = 1000)
    private String filePath;

    @Column(name = "file_size")
    private Long fileSize;

    @Column(name = "mime_type", length = 100)
    private String mimeType;

    @Column(name = "checksum", length = 64)
    private String checksum;

    @Column(name = "download_url", columnDefinition = "TEXT")
    private String downloadUrl;

    @Column(name = "preview_url", columnDefinition = "TEXT")
    private String previewUrl;

    @Column(name = "is_folder", nullable = false)
    private Boolean isFolder = false;

    @Column(name = "parent_folder_id", length = 255)
    private String parentFolderId;

    @Column(name = "shared", nullable = false)
    private Boolean shared = false;

    @Column(name = "share_url", columnDefinition = "TEXT")
    private String shareUrl;

    @Column(name = "created_at_provider")
    private LocalDateTime createdAtProvider;

    @Column(name = "modified_at_provider")
    private LocalDateTime modifiedAtProvider;

    @Column(name = "synced_at")
    private LocalDateTime syncedAt;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Constructors
    public FileMetadata() {
    }

    public FileMetadata(User user, CloudProvider provider, String providerFileId, String fileName) {
        this.user = user;
        this.provider = provider;
        this.providerFileId = providerFileId;
        this.fileName = fileName;
        this.createdAt = LocalDateTime.now();
        this.syncedAt = LocalDateTime.now();
    }

    // PrePersist and PreUpdate callbacks
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.syncedAt == null) {
            this.syncedAt = LocalDateTime.now();
        }
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

    public Long getFileSize() {
        return fileSize;
    }

    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }

    public String getMimeType() {
        return mimeType;
    }

    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }

    public String getChecksum() {
        return checksum;
    }

    public void setChecksum(String checksum) {
        this.checksum = checksum;
    }

    public String getDownloadUrl() {
        return downloadUrl;
    }

    public void setDownloadUrl(String downloadUrl) {
        this.downloadUrl = downloadUrl;
    }

    public String getPreviewUrl() {
        return previewUrl;
    }

    public void setPreviewUrl(String previewUrl) {
        this.previewUrl = previewUrl;
    }

    public Boolean getIsFolder() {
        return isFolder;
    }

    public void setIsFolder(Boolean isFolder) {
        this.isFolder = isFolder;
    }

    public String getParentFolderId() {
        return parentFolderId;
    }

    public void setParentFolderId(String parentFolderId) {
        this.parentFolderId = parentFolderId;
    }

    public Boolean getShared() {
        return shared;
    }

    public void setShared(Boolean shared) {
        this.shared = shared;
    }

    public String getShareUrl() {
        return shareUrl;
    }

    public void setShareUrl(String shareUrl) {
        this.shareUrl = shareUrl;
    }

    public LocalDateTime getCreatedAtProvider() {
        return createdAtProvider;
    }

    public void setCreatedAtProvider(LocalDateTime createdAtProvider) {
        this.createdAtProvider = createdAtProvider;
    }

    public LocalDateTime getModifiedAtProvider() {
        return modifiedAtProvider;
    }

    public void setModifiedAtProvider(LocalDateTime modifiedAtProvider) {
        this.modifiedAtProvider = modifiedAtProvider;
    }

    public LocalDateTime getSyncedAt() {
        return syncedAt;
    }

    public void setSyncedAt(LocalDateTime syncedAt) {
        this.syncedAt = syncedAt;
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
    public String getFormattedFileSize() {
        if (fileSize == null) {
            return "Unknown";
        }

        if (fileSize < 1024) {
            return fileSize + " B";
        } else if (fileSize < 1024 * 1024) {
            return String.format("%.1f KB", fileSize / 1024.0);
        } else if (fileSize < 1024 * 1024 * 1024) {
            return String.format("%.1f MB", fileSize / (1024.0 * 1024.0));
        } else {
            return String.format("%.1f GB", fileSize / (1024.0 * 1024.0 * 1024.0));
        }
    }

    public String getFileExtension() {
        if (fileName == null || !fileName.contains(".")) {
            return "";
        }
        return fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
    }

    public boolean isOutdated() {
        return modifiedAtProvider != null && syncedAt != null && modifiedAtProvider.isAfter(syncedAt);
    }

    public void updateSyncTime() {
        this.syncedAt = LocalDateTime.now();
    }

    @Override
    public String toString() {
        return String.format(
                "FileMetadata{id=%d, fileName='%s', provider=%s, size=%s}",
                id, fileName, provider, getFormattedFileSize());
    }
}
