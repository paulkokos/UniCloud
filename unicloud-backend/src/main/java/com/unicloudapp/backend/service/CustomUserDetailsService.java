package com.unicloudapp.backend.service;

import com.unicloudapp.backend.entity.User;
import com.unicloudapp.backend.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * CustomUserDetailsService - Spring Security UserDetailsService Implementation
 * Loads user details from database for authentication
 */
@Service
public class CustomUserDetailsService implements UserDetailsService {

    private static final Logger logger = LoggerFactory.getLogger(CustomUserDetailsService.class);

    @Autowired
    private UserRepository userRepository;

    /**
     * Load user by username for Spring Security authentication
     * Supports both username and email login
     */
    @Override
    @Transactional
    public UserDetails loadUserByUsername(String usernameOrEmail) throws UsernameNotFoundException {
        logger.debug("Attempting to load user by username/email: {}", usernameOrEmail);
        
        User user = userRepository.findByUsernameOrEmailIgnoreCase(usernameOrEmail)
                .orElseThrow(() -> {
                    logger.error("User not found with username/email: {}", usernameOrEmail);
                    return new UsernameNotFoundException("User not found with username/email: " + usernameOrEmail);
                });

        logger.debug("Successfully loaded user: {} (ID: {})", user.getUsername(), user.getId());
        
        // Update last login time
        user.updateLastLogin();
        userRepository.save(user);
        
        return user; // User entity implements UserDetails
    }

    /**
     * Load user by ID (useful for JWT token validation)
     */
    @Transactional
    public UserDetails loadUserById(Long userId) throws UsernameNotFoundException {
        logger.debug("Attempting to load user by ID: {}", userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> {
                    logger.error("User not found with ID: {}", userId);
                    return new UsernameNotFoundException("User not found with ID: " + userId);
                });

        logger.debug("Successfully loaded user by ID: {} (username: {})", userId, user.getUsername());
        
        return user;
    }
}
