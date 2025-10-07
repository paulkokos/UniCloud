package com.unicloud.backend.repository;

import com.unicloud.common.model.CloudAccount;
import com.unicloud.common.model.CloudProvider;
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
public interface CloudAccountRepository extends JpaRepository<CloudAccount, UUID> {

  List<CloudAccount> findByUser(User user);

  List<CloudAccount> findByUserId(UUID userId);

  List<CloudAccount> findByUserAndIsActiveTrue(User user);

  List<CloudAccount> findByUserIdAndIsActiveTrue(UUID userId);

  List<CloudAccount> findByUserAndProvider(User user, CloudProvider provider);

  List<CloudAccount> findByUserIdAndProvider(UUID userId, CloudProvider provider);

  Optional<CloudAccount> findByUserAndProviderAndProviderUserId(
      User user, CloudProvider provider, String providerUserId);

  Optional<CloudAccount> findByUserIdAndProviderAndProviderUserId(
      UUID userId, CloudProvider provider, String providerUserId);

  boolean existsByUserIdAndProviderAndProviderUserId(
      UUID userId, CloudProvider provider, String providerUserId);

  List<CloudAccount> findByProvider(CloudProvider provider);

  @Query("SELECT ca FROM CloudAccount ca WHERE ca.tokenExpiresAt <= "
      + ":expiryTime AND ca.isActive = true")
  List<CloudAccount> findAccountsWithExpiringTokens(@Param("expiryTime") LocalDateTime expiryTime);

  @Query("SELECT ca FROM CloudAccount ca WHERE ca.updatedAt < :lastUpdate " + "AND ca.isActive = true")
  List<CloudAccount> findAccountsNeedingQuotaRefresh(@Param("lastUpdate") LocalDateTime lastUpdate);

  long countByProviderAndIsActiveTrue(CloudProvider provider);

  long countByUserIdAndIsActiveTrue(UUID userId);

  @Query("SELECT ca FROM CloudAccount ca WHERE "
      + "(CAST(ca.usedQuota AS double) / NULLIF(ca.totalQuota, 0)) > :threshold "
      + "AND ca.isActive = true")
  List<CloudAccount> findAccountsApproachingQuotaLimit(@Param("threshold") double threshold);

  @Query("SELECT SUM(ca.usedQuota) FROM CloudAccount ca WHERE ca.user.id = "
      + ":userId AND ca.isActive = true")
  Long getTotalStorageUsageByUserId(@Param("userId") UUID userId);

  @Query("SELECT SUM(ca.totalQuota) FROM CloudAccount ca WHERE ca.user.id = "
      + ":userId AND ca.isActive = true")
  Long getTotalAvailableQuotaByUserId(@Param("userId") UUID userId);

  List<CloudAccount> findByIsActiveFalse();
}
