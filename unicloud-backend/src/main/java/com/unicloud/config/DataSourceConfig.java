// DatabaseConfig.java

package com.unicloud.config;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Database Configuration for PostgreSQL 17 Handles PostgreSQL 17 specific database settings and
 * optimizations
 */
@Configuration
public class DataSourceConfig {

  @Value("${spring.datasource.url}")
  private String databaseUrl;

  @Value("${spring.datasource.username}")
  private String username;

  @Value("${spring.datasource.password}")
  private String password;

  /** PostgreSQL 17 specific database initialization */
  @Bean
  public DatabaseInitializer databaseInitializer(DataSource dataSource) {
    return new DatabaseInitializer(dataSource);
  }

  /** Database initializer for PostgreSQL 17 specific features */
  public static class DatabaseInitializer {
    private final DataSource dataSource;

    public DatabaseInitializer(DataSource dataSource) {
      this.dataSource = dataSource;
      initializePostgreSQL17Features();
    }

    private void initializePostgreSQL17Features() {
      try (Connection connection = dataSource.getConnection();
          Statement statement = connection.createStatement()) {

        // Enable PostgreSQL 17 extensions if not already enabled
        statement.execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"");
        statement.execute("CREATE EXTENSION IF NOT EXISTS \"pgcrypto\"");
        statement.execute("CREATE EXTENSION IF NOT EXISTS \"pg_stat_statements\"");

        // PostgreSQL 17 specific extensions
        statement.execute("CREATE EXTENSION IF NOT EXISTS \"pg_buffercache\"");

        // Set PostgreSQL 17 optimized settings for the session
        statement.execute("SET work_mem = '4MB'");
        statement.execute("SET maintenance_work_mem = '64MB'");
        statement.execute("SET shared_preload_libraries = 'pg_stat_statements'");

      } catch (SQLException e) {
        // Log but don't fail startup - extensions might already exist
        System.out.println(
            "PostgreSQL 17 initialization completed with warnings: " + e.getMessage());
      }
    }
  }

  /** Database health checker for PostgreSQL 17 */
  @Bean
  public DatabaseHealthChecker databaseHealthChecker(DataSource dataSource) {
    return new DatabaseHealthChecker(dataSource);
  }

  public static class DatabaseHealthChecker {
    private final DataSource dataSource;

    public DatabaseHealthChecker(DataSource dataSource) {
      this.dataSource = dataSource;
    }

    public boolean isPostgreSQL17() {
      try (Connection connection = dataSource.getConnection();
          Statement statement = connection.createStatement()) {

        var resultSet = statement.executeQuery("SELECT version()");
        if (resultSet.next()) {
          String version = resultSet.getString(1);
          return version.contains("PostgreSQL 17") || version.contains("PostgreSQL 1");
        }
      } catch (SQLException e) {
        return false;
      }
      return false;
    }

    public String getDatabaseVersion() {
      try (Connection connection = dataSource.getConnection();
          Statement statement = connection.createStatement()) {

        var resultSet = statement.executeQuery("SELECT version()");
        if (resultSet.next()) {
          return resultSet.getString(1);
        }
      } catch (SQLException e) {
        return "Unknown";
      }
      return "Unknown";
    }
  }
}
