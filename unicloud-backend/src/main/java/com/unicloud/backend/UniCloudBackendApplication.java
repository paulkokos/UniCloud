package com.unicloud.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EntityScan(basePackages = "com.unicloud.common.model")
@EnableJpaRepositories(basePackages = "com.unicloud.backend.repository")
@ComponentScan(basePackages = { "com.unicloud.backend", "com.unicloud.common" })
public class UniCloudBackendApplication {

  public static void main(String[] args) {
    SpringApplication.run(UniCloudBackendApplication.class, args);
  }
}
