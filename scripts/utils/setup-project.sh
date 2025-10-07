#!/bin/bash

# UniCloud Project Setup Script - PostgreSQL 17 Edition
# Creates complete Maven multi-module project structure with PostgreSQL 17 support

set -e  # Exit on any error

echo "🚀 Setting up UniCloud Project Structure with PostgreSQL 17"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_info "Checking requirements..."
    
    # Check Java 17
    if java -version 2>&1 | grep -q "17\|21"; then
        print_status "Java 17+ detected"
    else
        print_error "Java 17 or higher is required"
        exit 1
    fi
    
    # Check Maven
    if command -v mvn &> /dev/null; then
        print_status "Maven detected"
    else
        print_error "Maven is required"
        exit 1
    fi
    
    # Check Docker
    if command -v docker &> /dev/null; then
        print_status "Docker detected"
    else
        print_warning "Docker not found - manual PostgreSQL 16 setup will be required"
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        print_status "Docker Compose detected"
    elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
        print_status "Docker Compose (v2) detected"
    else
        print_warning "Docker Compose not found - manual PostgreSQL 17 setup will be required"
    fi
}

# Create root directory structure
create_root_structure() {
    print_info "Creating root project structure..."
    
    # Main directories
    mkdir -p {docs/{api,architecture,user-guide},scripts,docker/{postgres/{init,conf},pgadmin,prometheus,grafana/{provisioning/{dashboards,datasources}}}}
    
    # Configuration directories
    mkdir -p {config/{dev,test,prod},src/main/resources/{db/migration,static,templates}}
    
    # Logs and uploads directories
    mkdir -p {logs,uploads,temp}
    
    print_status "Root directory structure created"
}

# Create Maven multi-module structure
create_maven_structure() {
    print_info "Creating Maven multi-module structure..."
    
    # Backend module
    mkdir -p unicloud-backend/src/{main/{java/com/unicloud/{config,controller,dto,entity,repository,service,security,cloud/{google,microsoft,icloud},exception},resources/{db/migration,static,templates}},test/{java/com/unicloud/{controller,service,repository,integration},resources}}
    
    # Desktop client module
    mkdir -p unicloud-desktop/src/{main/{java/com/unicloud/desktop/{controller,view,service,config,model,util},resources/{fxml,css,images}},test/{java/com/unicloud/desktop,resources}}
    
    # Common module
    mkdir -p unicloud-common/src/{main/java/com/unicloud/common/{dto,util,constants,exception},test/java/com/unicloud/common}
    
    print_status "Maven module structure created"
}

# Create Docker configuration files
create_docker_config() {
    print_info "Creating Docker configuration files..."
    
    # PostgreSQL 17 init script
    cat > docker/postgres/init/01-init-db.sql << 'EOF'
-- Initialize PostgreSQL 17 for UniCloud
CREATE DATABASE uniclouddb_dev;
CREATE DATABASE uniclouddb_test;

-- Create application user
CREATE USER unicloud_app WITH PASSWORD 'app_password';
GRANT ALL PRIVILEGES ON DATABASE uniclouddb TO unicloud_app;
GRANT ALL PRIVILEGES ON DATABASE uniclouddb_dev TO unicloud_app;
GRANT ALL PRIVILEGES ON DATABASE uniclouddb_test TO unicloud_app;

-- Enable required extensions
\c uniclouddb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

\c uniclouddb_dev;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

\c uniclouddb_test;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
EOF

    # PostgreSQL 17 configuration
    cat > docker/postgres/conf/postgresql.conf << 'EOF'
# PostgreSQL 17 Configuration for UniCloud
# Performance and optimization settings

# Connection Settings
max_connections = 200
shared_preload_libraries = 'pg_stat_statements'

# Memory Settings
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
work_mem = 4MB

# Checkpoint Settings
checkpoint_completion_target = 0.9
wal_buffers = 16MB

# Query Planner Settings
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200

# Write Ahead Logging
min_wal_size = 1GB
max_wal_size = 4GB

# Parallel Query Settings
max_worker_processes = 8
max_parallel_workers_per_gather = 4
max_parallel_workers = 8
max_parallel_maintenance_workers = 4

# Logging
log_destination = 'stderr'
logging_collector = on
log_directory = '/var/log/postgresql'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_min_messages = warning
log_min_error_statement = error
log_min_duration_statement = 1000

# Performance Monitoring
pg_stat_statements.track = all
pg_stat_statements.max = 10000
pg_stat_statements.track_utility = on
EOF

    # PgAdmin servers configuration
    cat > docker/pgadmin/servers.json << 'EOF'
{
    "Servers": {
        "1": {
            "Name": "UniCloud PostgreSQL 17",
            "Group": "Servers",
            "Host": "postgres",
            "Port": 5432,
            "MaintenanceDB": "uniclouddb",
            "Username": "unicloud_dev",
            "Password": "dev_password",
            "SSLMode": "prefer"
        }
    }
}
EOF

    print_status "Docker configuration files created"
}

# Create application configuration files
create_app_config() {
    print_info "Creating application configuration files..."
    
    # Development properties
    cat > config/dev/application-dev.properties << 'EOF'
# Development Configuration - PostgreSQL 17
spring.application.name=unicloud-backend-dev

# PostgreSQL 17 Database
spring.datasource.url=jdbc:postgresql://localhost:5432/uniclouddb_dev
spring.datasource.username=unicloud_dev
spring.datasource.password=dev_password
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect

# Flyway
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=true

# Logging
logging.level.com.unicloud=DEBUG
logging.level.org.springframework.security=DEBUG
logging.level.org.hibernate.SQL=DEBUG

# File Upload
spring.servlet.multipart.max-file-size=100MB
spring.servlet.multipart.max-request-size=100MB

# Server
server.port=8080
EOF

    # Test properties
    cat > config/test/application-test.properties << 'EOF'
# Test Configuration - PostgreSQL 17
spring.application.name=unicloud-backend-test

# PostgreSQL 17 Test Database
spring.datasource.url=jdbc:postgresql://localhost:5433/uniclouddb_test
spring.datasource.username=unicloud_test
spring.datasource.password=test_password

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=false

# Disable Flyway for tests
spring.flyway.enabled=false

    # Logging
logging.level.com.unicloud=INFO
logging.level.org.springframework.security=WARN
EOF

    # Production properties template
    cat > config/prod/application-prod.properties << 'EOF'
# Production Configuration - PostgreSQL 17
spring.application.name=unicloud-backend

# PostgreSQL 17 Production Database
spring.datasource.url=${DATABASE_URL}
spring.datasource.username=${POSTGRES_USERNAME}
spring.datasource.password=${POSTGRES_PASSWORD}

# Connection Pool Settings
spring.datasource.hikari.maximum-pool-size=50
spring.datasource.hikari.minimum-idle=10
spring.datasource.hikari.connection-timeout=30000

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false

# Flyway
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=false

# Logging
logging.level.com.unicloud=INFO
logging.level.root=WARN

# Security
server.ssl.enabled=true
EOF

    print_status "Application configuration files created"
}

# Create module pom.xml files
create_module_poms() {
    print_info "Creating module POM files..."
    
    # Backend module pom.xml
    cat > unicloud-backend/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.unicloud</groupId>
        <artifactId>unicloud-parent</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>unicloud-backend</artifactId>
    <packaging>jar</packaging>
    <name>UniCloud Backend</name>
    <description>Backend REST API service with PostgreSQL 17 support</description>

    <dependencies>
        <!-- Spring Boot Starters -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- PostgreSQL 17 Driver -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
        </dependency>

        <!-- Database Migration -->
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>

        <!-- JWT -->
        <dependency>
            <groupId>com.auth0</groupId>
            <artifactId>java-jwt</artifactId>
        </dependency>

        <!-- Cloud APIs -->
        <dependency>
            <groupId>com.google.apis</groupId>
            <artifactId>google-api-services-drive</artifactId>
        </dependency>
        
        <dependency>
            <groupId>com.microsoft.graph</groupId>
            <artifactId>microsoft-graph</artifactId>
        </dependency>

        <!-- Common Module -->
        <dependency>
            <groupId>com.unicloud</groupId>
            <artifactId>unicloud-common</artifactId>
            <version>${project.version}</version>
        </dependency>

        <!-- Development Tools -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>postgresql</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <mainClass>com.unicloud.UniCloudBackendApplication</mainClass>
                </configuration>
            </plugin>
            
            <plugin>
                <groupId>org.flywaydb</groupId>
                <artifactId>flyway-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

    # Desktop module pom.xml
    cat > unicloud-desktop/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.unicloud</groupId>
        <artifactId>unicloud-parent</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>unicloud-desktop</artifactId>
    <packaging>jar</packaging>
    <name>UniCloud Desktop</name>
    <description>JavaFX desktop client application</description>

    <dependencies>
        <!-- JavaFX -->
        <dependency>
            <groupId>org.openjfx</groupId>
            <artifactId>javafx-controls</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.openjfx</groupId>
            <artifactId>javafx-fxml</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.openjfx</groupId>
            <artifactId>javafx-web</artifactId>
        </dependency>

        <!-- HTTP Client -->
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
        </dependency>

        <!-- Common Module -->
        <dependency>
            <groupId>com.unicloud</groupId>
            <artifactId>unicloud-common</artifactId>
            <version>${project.version}</version>
        </dependency>

        <!-- TestFX for JavaFX Testing -->
        <dependency>
            <groupId>org.testfx</groupId>
            <artifactId>testfx-core</artifactId>
            <version>${testfx.version}</version>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>org.testfx</groupId>
            <artifactId>testfx-junit5</artifactId>
            <version>${testfx.version}</version>
            <scope>test</scope>
        </dependency>
        
        <!-- TestFX Monocle for Headless Testing -->
        <dependency>
            <groupId>org.testfx</groupId>
            <artifactId>openjfx-monocle</artifactId>
            <version>jdk-12.0.1+2</version>
            <scope>test</scope>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
            </plugin>
            
            <plugin>
                <groupId>org.openjfx</groupId>
                <artifactId>javafx-maven-plugin</artifactId>
                <configuration>
                    <mainClass>com.unicloud.desktop.UniCloudDesktopApplication</mainClass>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF

    # Common module pom.xml
    cat > unicloud-common/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.unicloud</groupId>
        <artifactId>unicloud-parent</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>unicloud-common</artifactId>
    <packaging>jar</packaging>
    <name>UniCloud Common</name>
    <description>Shared DTOs, utilities, and constants</description>

    <dependencies>
        <!-- JSON Processing -->
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
        </dependency>
        
        <!-- Validation -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>
EOF

    print_status "Module POM files created"
}

# Create basic application classes
create_basic_classes() {
    print_info "Creating basic application classes..."
    
    # Backend main class
    cat > unicloud-backend/src/main/java/com/unicloud/UniCloudBackendApplication.java << 'EOF'
package com.unicloud;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * UniCloud Backend Application - PostgreSQL 16 Support
 * Multi-cloud file management backend service
 */
@SpringBootApplication
@EnableTransactionManagement
public class UniCloudBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(UniCloudBackendApplication.class, args);
        System.out.println("🚀 UniCloud Backend started successfully with PostgreSQL 16 support!");
    }
}
EOF

    # Desktop main class
    cat > unicloud-desktop/src/main/java/com/unicloud/desktop/UniCloudDesktopApplication.java << 'EOF'
package com.unicloud.desktop;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;

/**
 * UniCloud Desktop Application
 * JavaFX client for multi-cloud file management
 */
public class UniCloudDesktopApplication extends Application {

    @Override
    public void start(Stage primaryStage) throws Exception {
        FXMLLoader fxmlLoader = new FXMLLoader(
            UniCloudDesktopApplication.class.getResource("/fxml/main-view.fxml")
        );
        Scene scene = new Scene(fxmlLoader.load(), 1200, 800);
        
        primaryStage.setTitle("UniCloud - Multi-Cloud File Manager");
        primaryStage.setScene(scene);
        primaryStage.show();
        
        System.out.println("🖥️  UniCloud Desktop started successfully!");
    }

    public static void main(String[] args) {
        launch(args);
    }
}
EOF

    # Sample entity class
    cat > unicloud-backend/src/main/java/com/unicloud/entity/User.java << 'EOF'
package com.unicloud.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * User Entity for PostgreSQL 17
 * Enhanced with UUID primary key and optimized for PostgreSQL 17 features
 */
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_users_username", columnList = "username"),
    @Index(name = "idx_users_email", columnList = "email"),
    @Index(name = "idx_users_active", columnList = "is_active")
})
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(name = "username", unique = true, nullable = false, length = 50)
    private String username;

    @Column(name = "email", unique = true, nullable = false, length = 100)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(name = "first_name", length = 50)
    private String firstName;

    @Column(name = "last_name", length = 50)
    private String lastName;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "is_verified")
    private Boolean isVerified = false;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;

    // Constructors
    public User() {}

    public User(String username, String email, String passwordHash) {
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
    }

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public Boolean getIsVerified() { return isVerified; }
    public void setIsVerified(Boolean isVerified) { this.isVerified = isVerified; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }

    public LocalDateTime getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(LocalDateTime lastLoginAt) { this.lastLoginAt = lastLoginAt; }

    @Override
    public String toString() {
        return "User{id=" + id + ", username='" + username + "', email='" + email + "'}";
    }
}
EOF

    print_status "Basic application classes created"
}

# Create README files
create_readme_files() {
    print_info "Creating README files..."
    
    # Main README
    cat > README.md << 'EOF'
# UniCloud - Multi-Cloud File Management System

## PostgreSQL 17 Edition

UniCloud is a modern multi-cloud file management application that enables users to seamlessly upload, manage, and download files across multiple cloud storage providers through a unified desktop interface.

### 🚀 Key Features

- **Multi-Cloud Support**: Google Drive, OneDrive, and iCloud integration
- **PostgreSQL 17**: Latest database with enhanced performance and security
- **Desktop Client**: Cross-platform JavaFX application
- **Secure Authentication**: JWT-based security with OAuth2 integration
- **Modern Architecture**: Spring Boot 3.2 with Java 17

### 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  JavaFX Desktop │    │  Spring Boot    │    │  PostgreSQL 17  │
│     Client      │◄──►│   REST API      │◄──►│    Database     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                    ┌─────────┼─────────┐
                    ▼         ▼         ▼
            ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
            │ Google      │ │ Microsoft   │ │   iCloud    │
            │ Drive API   │ │ Graph API   │ │  CloudKit   │
            └─────────────┘ └─────────────┘ └─────────────┘
```

### 🛠️ Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Backend Framework | Spring Boot | 3.2.0 |
| Language | Java | 17 |
| Desktop UI | JavaFX | 21 |
| Database | PostgreSQL | 17+ |
| Build Tool | Maven | 3.9+ |
| Security | Spring Security + JWT | 6.x |

### 🚀 Quick Start

#### Prerequisites
- Java 17 or higher
- Maven 3.9+
- Docker and Docker Compose (recommended)
- PostgreSQL 16 (if not using Docker)

#### Using Docker (Recommended)
```bash
# Clone the repository
git clone <repository-url>
cd unicloud

# Start PostgreSQL 17 and services
docker-compose up -d postgres redis

# Run the backend
cd unicloud-backend
mvn spring-boot:run

# Run the desktop client (in another terminal)
cd unicloud-desktop
mvn javafx:run
```

#### Manual Setup
```bash
# Install PostgreSQL 17
# Configure database connection in application.yml

# Build and run backend
cd unicloud-backend
mvn clean install
mvn spring-boot:run

# Build and run desktop client
cd unicloud-desktop
mvn clean install
mvn javafx:run
```

### 📊 Database Features (PostgreSQL 17)

- **Incremental Backup**: Built-in incremental backup reduces backup time by 90%
- **Enhanced Performance**: Optimized queries and improved parallel processing
- **JSONB Support**: Flexible metadata storage for files with new JSON functions
- **UUID Primary Keys**: Better distributed system support  
- **Advanced Security**: Enhanced Row Level Security (RLS) and authentication
- **Monitoring**: Built-in performance tracking with better wait event analysis

### 🔧 Development

#### Project Structure
```
unicloud/
├── unicloud-backend/          # Spring Boot REST API
├── unicloud-desktop/          # JavaFX Desktop Client  
├── unicloud-common/           # Shared DTOs and utilities
├── docker/                    # Docker configurations
├── scripts/                   # Build and deployment scripts
└── docs/                      # Documentation
```

#### Running Tests
```bash
# Backend tests with TestContainers
cd unicloud-backend
mvn test

# Integration tests
mvn verify

# Desktop tests
cd unicloud-desktop
mvn test
```

### 📖 Documentation

- [API Documentation](docs/api/README.md)
- [Architecture Guide](docs/architecture/README.md)
- [User Guide](docs/user-guide/README.md)

### 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

### 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

### 🆘 Support

For support and questions:
- Create an issue on GitHub
- Check the documentation
- Review the troubleshooting guide

---
**Built with ❤️ using Spring Boot, JavaFX, and PostgreSQL 17**
EOF

    print_status "README files created"
}

# Create .gitignore file
create_gitignore() {
    print_info "Creating .gitignore file..."
    
    cat > .gitignore << 'EOF'
# UniCloud Project - Git Ignore Rules

# Compiled class files
*.class

# Log files
*.log
logs/

# BlueJ files
*.ctxt

# Mobile Tools for Java (J2ME)
.mtj.tmp/

# Package Files
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar

# Virtual machine crash logs
hs_err_pid*
replay_pid*

# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml
buildNumber.properties
.mvn/timing.properties
.mvn/wrapper/maven-wrapper.jar

# Gradle
.gradle
build/
!gradle/wrapper/gradle-wrapper.jar
!**/src/main/**/build/
!**/src/test/**/build/

# IntelliJ IDEA
.idea/
*.iws
*.iml
*.ipr
out/
!**/src/main/**/out/
!**/src/test/**/out/

# Eclipse
.apt_generated
.classpath
.factorypath
.project
.settings
.springBeans
.sts4-cache
bin/
!**/src/main/**/bin/
!**/src/test/**/bin/

# NetBeans
/nbproject/private/
/nbbuild/
/dist/
/nbdist/
/.nb-gradle/

# VS Code
.vscode/

# Mac
.DS_Store

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# PostgreSQL
*.sql~
*.backup

# Application specific
uploads/
temp/
logs/
*.log

# Environment variables
.env
.env.local
.env.production

# Database
/data/
/postgres-data/

# Docker
.docker/

# Security
application-secret.yml
application-prod.properties
oauth-credentials.json
*.pem
*.key
*.crt

# IDE specific
.metadata
.recommenders

# Spring Boot
.spring-boot-devtools.properties

# JavaFX
*.fxml~

# Temporary files
*.tmp
*.temp
*~

# Test results
/test-results/
/test-reports/

# Coverage reports
/coverage/
jacoco.exec
EOF

    print_status ".gitignore file created"
}

# Create environment files
create_environment_files() {
    print_info "Creating environment configuration files..."
    
    # Development environment
    cat > .env.example << 'EOF'
# UniCloud Environment Configuration Example
# Copy this file to .env and update with your values

# Database Configuration (PostgreSQL 16)
POSTGRES_USERNAME=unicloud_dev
POSTGRES_PASSWORD=your_secure_password
DATABASE_URL=jdbc:postgresql://localhost:5432/uniclouddb

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_here_minimum_32_characters

# Google Drive API
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Microsoft OneDrive API  
MICROSOFT_CLIENT_ID=your_microsoft_client_id
MICROSOFT_CLIENT_SECRET=your_microsoft_client_secret

# iCloud Configuration
ICLOUD_CONTAINER_ID=your_icloud_container_id
ICLOUD_API_TOKEN=your_icloud_api_token

# File Storage
UPLOAD_DIR=./uploads
TEMP_DIR=./temp
MAX_FILE_SIZE=100MB

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Monitoring
PROMETHEUS_ENABLED=false
GRAFANA_ADMIN_PASSWORD=admin_password
EOF

    print_status "Environment configuration files created"
}

# Setup database
setup_database() {
    print_info "Setting up PostgreSQL 16 database..."
    
    if command -v docker-compose &> /dev/null || (command -v docker &> /dev/null && docker compose version &> /dev/null); then
        print_info "Starting PostgreSQL 17 with Docker..."
        if command -v docker-compose &> /dev/null; then
            docker-compose up -d postgres
        else
            docker compose up -d postgres
        fi
        
        # Wait for PostgreSQL to be ready
        print_info "Waiting for PostgreSQL 17 to be ready..."
        sleep 10
        
        # Run database migrations
        if [ -f "unicloud-backend/pom.xml" ]; then
            cd unicloud-backend
            mvn flyway:migrate -Dspring.profiles.active=dev
            cd ..
            print_status "Database migrations completed"
        fi
    else
        print_warning "Docker not available. Please set up PostgreSQL 17 manually:"
        echo "1. Install PostgreSQL 17"
        echo "2. Create database 'uniclouddb'"
        echo "3. Create user 'unicloud_dev' with password 'dev_password'"
        echo "4. Run: mvn flyway:migrate -Dspring.profiles.active=dev"
    fi
}

# Main execution flow
main() {
    echo "===========================================" 
    echo "🚀 UniCloud PostgreSQL 17 Setup Script"
    echo "==========================================="
    echo ""
    
    check_requirements
    echo ""
    
    create_root_structure
    create_maven_structure
    create_docker_config
    create_app_config
    create_module_poms
    create_basic_classes
    create_readme_files
    create_gitignore
    create_environment_files
    
    echo ""
    print_status "Project structure created successfully!"
    echo ""
    
    setup_database
    
    echo ""
    echo "🎉 UniCloud project setup completed!"
    echo ""
    echo "Next steps:"
    echo "1. Copy .env.example to .env and configure your settings"
    echo "2. Set up your OAuth credentials for cloud providers"
    echo "3. Start the backend: cd unicloud-backend && mvn spring-boot:run"
    echo "4. Start the desktop client: cd unicloud-desktop && mvn javafx:run"
    echo ""
    echo "For detailed instructions, see README.md"
    echo ""
    print_status "Happy coding! 🚀"
}

# Run the main function
main "$@"
