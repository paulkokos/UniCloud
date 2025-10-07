package com.unicloudapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class UniCloudApplication {
    public static void main(String[] args) {
        SpringApplication.run(UniCloudApplication.class, args);
    }
}

@RestController
class HelloController {
    @GetMapping("/")
    public String hello() {
        return "UniCloud Multi-Cloud File Management System is running!";
    }
    
    @GetMapping("/health")
    public String health() {
        return "Status: UP";
    }
}
