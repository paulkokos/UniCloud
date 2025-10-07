package com.unicloud.common.model;

/** Enum representing the various states a user account can be in */
public enum UserStatus {
  /** User account is active and fully functional */
  ACTIVE,

  /** User account is inactive (voluntarily deactivated or not yet activated) */
  INACTIVE,

  /** User account has been suspended (usually due to policy violations) */
  SUSPENDED,

  /** User has registered but not yet verified their email address */
  PENDING_VERIFICATION
}
