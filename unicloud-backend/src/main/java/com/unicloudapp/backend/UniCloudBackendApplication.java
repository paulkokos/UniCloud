package com.unicloudapp.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.autoconfigure.security.oauth2.client.servlet.OAuth2ClientAutoConfiguration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * UniCloud Backend Application - Spring Boot Main Class>
 *
 * <p>
 * Multi-cloud file management application backend Supports Google Drive,
 * OneDrive, and iCloud
 * integration
 */
@SpringBootApplication(scanBasePackages = "com.unicloudapp", exclude = { OAuth2ClientAutoConfiguration.class })
@EntityScan(basePackages = "com.unicloudapp.backend.entity")
@EnableJpaRepositories(basePackages = "com.unicloudapp.backend.repository")
@EnableAsync
@EnableTransactionManagement
public class UniCloudBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(UniCloudBackendApplication.class, args);
        System.out.println("\n🚀 UniCloud Backend Application Started Successfully!");
        System.out.println("📱 API available at: http://localhost:8080/api/v1");
        System.out.println("📚 API Documentation: http://localhost:8080/api/v1/swagger-ui.html");
        System.out.println("🔧 Health Check: http://localhost:8080/api/v1/actuator/health");
    }
}
