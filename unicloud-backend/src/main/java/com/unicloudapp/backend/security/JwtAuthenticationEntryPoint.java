package com.unicloudapp.backend.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationEntryPoint.class);

    @Override
    public void commence(HttpServletRequest request, 
                        HttpServletResponse response,
                        AuthenticationException authException) throws IOException, ServletException {
        
        logger.error("Unauthorized error: {}", authException.getMessage());
        
        response.setContentType("application/json");
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setCharacterEncoding("UTF-8");
        
        String jsonResponse = String.format(
            "{\"error\":\"Unauthorized\",\"message\":\"%s\",\"timestamp\":%d,\"path\":\"%s\"}",
            authException.getMessage(),
            System.currentTimeMillis(),
            request.getRequestURI()
        );
        
        response.getWriter().write(jsonResponse);
        response.getWriter().flush();
    }
}
