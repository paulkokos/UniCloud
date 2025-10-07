package com.unicloud;

import java.util.HashMap;
import java.util.Map;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class UniCloudBackendApplication {

  public static void main(String[] args) {
    SpringApplication.run(UniCloudBackendApplication.class, args);
  }
}

@RestController
class ApiController {

  @GetMapping("/")
  public Map<String, Object> home() {
    Map<String, Object> response = new HashMap<>();
    response.put("application", "UniCloud Backend");
    response.put("version", "1.0.0");
    response.put("status", "running");
    response.put("timestamp", System.currentTimeMillis());
    return response;
  }

  @GetMapping("/api/health")
  public Map<String, String> health() {
    Map<String, String> health = new HashMap<>();
    health.put("status", "UP");
    health.put("service", "UniCloud Backend");
    return health;
  }
}
