#!/bin/bash

# Create directories
mkdir -p unicloud-backend/src/main/java/com/unicloud/config
mkdir -p unicloud-backend/src/test/java/com/unicloud/config
mkdir -p unicloud-backend/src/test/java/com/unicloud/test/util
mkdir -p unicloud-backend/src/test/resources
mkdir -p unicloud-desktop/src/test/java/com/unicloud/desktop/test

# Create files
touch unicloud-backend/src/main/java/com/unicloud/config/DatabaseConfig.java
touch unicloud-backend/src/main/java/com/unicloud/config/DataSourceConfig.java
touch unicloud-backend/src/main/java/com/unicloud/config/JpaConfig.java
touch unicloud-backend/src/main/java/com/unicloud/config/PostgreSQLConfig.java
touch unicloud-backend/src/test/java/com/unicloud/config/TestConfig.java
touch unicloud-backend/src/test/java/com/unicloud/config/MockCloudServiceConfig.java
touch unicloud-backend/src/test/java/com/unicloud/test/BaseIntegrationTest.java
touch unicloud-backend/src/test/java/com/unicloud/test/BaseRepositoryTest.java
touch unicloud-backend/src/test/java/com/unicloud/test/BaseWebTest.java
touch unicloud-backend/src/test/java/com/unicloud/test/util/TestDataBuilder.java
touch unicloud-backend/src/test/java/com/unicloud/test/util/TestConstants.java
touch unicloud-backend/src/test/resources/test-schema.sql
touch unicloud-desktop/src/test/java/com/unicloud/desktop/test/TestFXBase.java

echo "All files created!"
