package com.unicloudapp.backend.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;

/**
 * JwtUtils - JWT Token Management Utility
 * Compatible with older JWT library versions (uses deprecated methods as fallback)
 */
@Component
public class JwtUtils {
    
    private static final Logger logger = LoggerFactory.getLogger(JwtUtils.class);
    
    @Value("${jwt.secret:default-secret-key-change-this-in-production-make-it-at-least-32-characters-long}")
    private String jwtSecret;
    
    @Value("${jwt.expiration:86400000}")
    private long jwtExpirationMs;
    
    /**
     * Generate JWT token from Authentication
     */
    public String generateToken(Authentication authentication) {
        UserDetails userPrincipal = (UserDetails) authentication.getPrincipal();
        return generateTokenFromUsername(userPrincipal.getUsername());
    }
    
    /**
     * Generate JWT token from username
     */
    public String generateTokenFromUsername(String username) {
        return generateToken(username, new HashMap<>());
    }
    
    /**
     * Generate JWT token with custom claims
     */
    public String generateToken(String username, Map<String, Object> extraClaims) {
        return Jwts.builder()
                .setClaims(extraClaims)
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpirationMs))
                .signWith(getSigningKey(), SignatureAlgorithm.HS512)
                .compact();
    }
    
    /**
     * Generate refresh token (longer expiration)
     */
    public String generateRefreshToken(String username) {
        long refreshTokenExpiration = jwtExpirationMs * 7; // 7 times longer than access token
        
        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + refreshTokenExpiration))
                .signWith(getSigningKey(), SignatureAlgorithm.HS512)
                .compact();
    }
    
    /**
     * Extract username from JWT token
     */
    public String getUsernameFromToken(String token) {
        return getClaimFromToken(token, Claims::getSubject);
    }
    
    /**
     * Extract expiration date from JWT token
     */
    public Date getExpirationDateFromToken(String token) {
        return getClaimFromToken(token, Claims::getExpiration);
    }
    
    /**
     * Extract issued at date from JWT token
     */
    public Date getIssuedAtDateFromToken(String token) {
        return getClaimFromToken(token, Claims::getIssuedAt);
    }
    
    /**
     * Extract specific claim from JWT token
     */
    public <T> T getClaimFromToken(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = getAllClaimsFromToken(token);
        return claimsResolver.apply(claims);
    }
    
    /**
     * Extract all claims from JWT token - Uses older parser() method
     */
    @SuppressWarnings("deprecation")
    private Claims getAllClaimsFromToken(String token) {
        return Jwts.parser()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
    
    /**
     * Check if JWT token is expired
     */
    public Boolean isTokenExpired(String token) {
        final Date expiration = getExpirationDateFromToken(token);
        return expiration.before(new Date());
    }
    
    /**
     * Validate JWT token against user details
     */
    public Boolean validateToken(String token, UserDetails userDetails) {
        try {
            final String username = getUsernameFromToken(token);
            return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
        } catch (Exception e) {
            logger.error("Token validation failed: {}", e.getMessage());
            return false;
        }
    }
    
    /**
     * Validate JWT token structure and signature - Uses older parser() method
     */
    @SuppressWarnings("deprecation")
    public boolean validateToken(String token) {
        try {
            Jwts.parser()
                .setSigningKey(getSigningKey()).build()
                .parseClaimsJws(token);
            return true;
        } catch (SignatureException e) {
            logger.error("Invalid JWT signature: {}", e.getMessage());
        } catch (MalformedJwtException e) {
            logger.error("Invalid JWT token: {}", e.getMessage());
        } catch (ExpiredJwtException e) {
            logger.error("JWT token is expired: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            logger.error("JWT token is unsupported: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            logger.error("JWT claims string is empty: {}", e.getMessage());
        }
        return false;
    }
    
    /**
     * Get signing key for JWT tokens
     */
    private SecretKey getSigningKey() {
        byte[] keyBytes = jwtSecret.getBytes();
        return Keys.hmacShaKeyFor(keyBytes);
    }
    
    /**
     * Extract token from Authorization header
     */
    public String extractTokenFromHeader(String authorizationHeader) {
        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            return authorizationHeader.substring(7);
        }
        return null;
    }
    
    /**
     * Get token remaining validity in seconds
     */
    public long getTokenValidityInSeconds(String token) {
        try {
            Date expiration = getExpirationDateFromToken(token);
            long now = System.currentTimeMillis();
            return Math.max(0, (expiration.getTime() - now) / 1000);
        } catch (Exception e) {
            logger.error("Error getting token validity: {}", e.getMessage());
            return 0;
        }
    }
    
    /**
     * Check if token is close to expiration (within 5 minutes)
     */
    public boolean isTokenCloseToExpiration(String token) {
        long validity = getTokenValidityInSeconds(token);
        return validity > 0 && validity < 300; // 5 minutes
    }
    
    /**
     * Generate token with custom expiration
     */
    public String generateTokenWithExpiration(String username, long expirationMs) {
        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expirationMs))
                .signWith(getSigningKey(), SignatureAlgorithm.HS512)
                .compact();
    }
}
