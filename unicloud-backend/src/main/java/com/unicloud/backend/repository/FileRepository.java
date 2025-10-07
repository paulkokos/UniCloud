package com.unicloud.backend.repository;

import com.unicloud.common.model.CloudAccount;
import com.unicloud.common.model.CloudProvider;
import com.unicloud.common.model.File;
import com.unicloud.common.model.User;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface FileRepository extends JpaRepository<File, UUID> {

  List<File> findByUser(User user);

  List<File> findByUserId(UUID userId);

  List<File> findByCloudAccount(CloudAccount cloudAccount);

  List<File> findByCloudAccountId(UUID cloudAccountId);

  Optional<File> findByCloudAccountAndProviderFileId(
      CloudAccount cloudAccount, String providerFileId);

  Optional<File> findByCloudAccountIdAndProviderFileId(UUID cloudAccountId, String providerFileId);

  List<File> findByParentFolder(File parentFolder);

  List<File> findByParentFolderId(UUID parentFolderId);

  List<File> findByCloudAccountAndParentFolderIsNull(CloudAccount cloudAccount);

  List<File> findByCloudAccountIdAndParentFolderIsNull(UUID cloudAccountId);

  List<File> findByUserIdAndIsFolderTrue(UUID userId);

  List<File> findByCloudAccountIdAndIsFolderTrue(UUID cloudAccountId);

  @Query("SELECT f FROM File f WHERE f.user.id = :userId AND " + "f.cloudAccount.provider = :provider")
  List<File> findByUserIdAndProvider(
      @Param("userId") UUID userId, @Param("provider") CloudProvider provider);

  @Query("SELECT f FROM File f WHERE f.user.id = :userId AND "
      + "LOWER(f.fileName) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
  List<File> searchFilesByName(
      @Param("userId") UUID userId, @Param("searchTerm") String searchTerm);

  @Query("SELECT f FROM File f WHERE f.user.id = :userId AND "
      + "(LOWER(f.fileName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR "
      + "LOWER(f.filePath) LIKE LOWER(CONCAT('%', :searchTerm, '%')))")
  List<File> searchFiles(@Param("userId") UUID userId, @Param("searchTerm") String searchTerm);

  List<File> findByUserIdAndMimeType(UUID userId, String mimeType);

  @Query("SELECT f FROM File f WHERE f.user.id = :userId AND f.mimeType LIKE " + ":mimeTypePattern")
  List<File> findByUserIdAndMimeTypePattern(
      @Param("userId") UUID userId, @Param("mimeTypePattern") String mimeTypePattern);

  @Query("SELECT f FROM File f WHERE f.user.id = :userId AND f.fileSize > " + ":minSize")
  List<File> findLargeFiles(@Param("userId") UUID userId, @Param("minSize") Long minSize);

  List<File> findByUserIdAndCreatedAtAfter(UUID userId, LocalDateTime date);

  List<File> findByUserIdAndUpdatedAtAfter(UUID userId, LocalDateTime date);

  long countByUserId(UUID userId);

  long countByCloudAccountId(UUID cloudAccountId);

  long countByUserIdAndIsFolderTrue(UUID userId);

  @Query("SELECT COALESCE(SUM(f.fileSize), 0) FROM File f WHERE f.user.id = "
      + ":userId AND f.isFolder = false")
  Long getTotalFileSizeByUserId(@Param("userId") UUID userId);

  @Query("SELECT COALESCE(SUM(f.fileSize), 0) FROM File f WHERE "
      + "f.cloudAccount.id = :cloudAccountId AND f.isFolder = false")
  Long getTotalFileSizeByCloudAccountId(@Param("cloudAccountId") UUID cloudAccountId);

  @Query("SELECT f FROM File f WHERE f.user.id = :userId ORDER BY " + "f.createdAt DESC")
  List<File> findRecentFiles(@Param("userId") UUID userId);

  @Query("SELECT f FROM File f WHERE f.user.id = :userId AND f.checksum = "
      + ":checksum AND f.isFolder = false")
  List<File> findByUserIdAndChecksum(
      @Param("userId") UUID userId, @Param("checksum") String checksum);

  boolean existsByUserIdAndChecksum(UUID userId, String checksum);

  void deleteByCloudAccountId(UUID cloudAccountId);

  @Query("SELECT f FROM File f WHERE NOT EXISTS (SELECT 1 FROM CloudAccount "
      + "ca WHERE ca.id = f.cloudAccount.id AND ca.isActive = true)")
  List<File> findOrphanedFiles();
}
