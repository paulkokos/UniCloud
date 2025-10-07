# Multi-stage build for UniCloud Spring Boot Backend
FROM maven:3.9-eclipse-temurin-17 AS build

# Set working directory
WORKDIR /app

# Copy Maven configuration files first (for better caching)
COPY pom.xml .
COPY unicloud-common/pom.xml unicloud-common/
COPY unicloud-backend/pom.xml unicloud-backend/
COPY unicloud-desktop/pom.xml unicloud-desktop/

# Copy source code
COPY unicloud-common/src unicloud-common/src
COPY unicloud-backend/src unicloud-backend/src

# Build the application
RUN mvn clean package -DskipTests -Dmaven.javadoc.skip=true -pl unicloud-backend -am

# Production stage
FROM eclipse-temurin:17-jre-alpine AS production

# Install curl for health checks and ca-certificates for SSL
RUN apk add --no-cache curl ca-certificates

# Create non-root user for security
RUN addgroup -g 1001 -S unicloudapp && \
    adduser -u 1001 -S unicloudapp -G unicloudapp

# Set working directory
WORKDIR /app

# Copy the built JAR from build stage
COPY --from=build /app/unicloud-backend/target/*.jar app.jar

# Create logs directory and set permissions
RUN mkdir -p /app/logs /app/temp && \
    chown -R unicloudapp:unicloudapp /app

# Switch to non-root user
USER unicloudapp

# Expose the application port
EXPOSE 8080

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Set JVM options for production
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UseStringDeduplication -Djava.security.egd=file:/dev/./urandom"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
