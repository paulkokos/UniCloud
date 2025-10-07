#!/bin/bash

# UniCloud Deploy Script - PostgreSQL 17 Edition
# Deploys UniCloud application to various environments

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="UniCloud"
VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout 2>/dev/null || echo "1.0.0-SNAPSHOT")
DOCKER_REGISTRY="${DOCKER_REGISTRY:-docker.io}"
DOCKER_IMAGE_PREFIX="${DOCKER_IMAGE_PREFIX:-unicloud}"
POSTGRES_VERSION="17"

# Default values
ENVIRONMENT=""
SKIP_BUILD=false
SKIP_TESTS=false
DRY_RUN=false
FORCE_DEPLOY=false
BACKUP_DATABASE=true

# Functions for colored output
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

print_deploy() {
    echo -e "${PURPLE}🚀${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Show help
show_help() {
    cat << EOF
UniCloud Deploy Script - PostgreSQL 17

Usage: $0 [ENVIRONMENT] [OPTIONS]

Environments:
  dev                Deploy to development environment
  staging            Deploy to staging environment
  prod               Deploy to production environment
  local              Deploy to local Docker environment
  k8s                Deploy to Kubernetes cluster

Options:
  --skip-build       Skip building the application
  --skip-tests       Skip running tests
  --dry-run          Show what would be deployed without executing
  --force            Force deployment without confirmations
  --no-backup        Skip database backup (not recommended for prod)
  --version=VERSION  Deploy specific version
  --help             Show this help message

Environment Variables:
  DOCKER_REGISTRY          Docker registry URL (default: docker.io)
  DOCKER_IMAGE_PREFIX      Docker image prefix (default: unicloud)
  DATABASE_URL             PostgreSQL 17 connection URL
  POSTGRES_USERNAME        Database username
  POSTGRES_PASSWORD        Database password
  JWT_SECRET              JWT secret key
  GOOGLE_CLIENT_ID        Google OAuth client ID
  GOOGLE_CLIENT_SECRET    Google OAuth client secret
  MICROSOFT_CLIENT_ID     Microsoft OAuth client ID
  MICROSOFT_CLIENT_SECRET Microsoft OAuth client secret

Examples:
  $0 dev                      # Deploy to development
  $0 prod --no-backup         # Deploy to prod without backup
  $0 staging --dry-run        # Show staging deployment plan
  $0 k8s --version=1.2.0      # Deploy specific version to k8s

EOF
}

# Check requirements
check_requirements() {
    print_info "Checking deployment requirements..."
    
    # Check basic tools
    command -v java >/dev/null 2>&1 || { print_error "Java required but not installed"; exit 1; }
    command -v mvn >/dev/null 2>&1 || { print_error "Maven required but not installed"; exit 1; }
    
    # Check Docker for container deployments
    if [[ "$ENVIRONMENT" == "local" || "$ENVIRONMENT" == "k8s" ]]; then
        command -v docker >/dev/null 2>&1 || { print_error "Docker required for $ENVIRONMENT deployment"; exit 1; }
    fi
    
    # Check kubectl for Kubernetes
    if [[ "$ENVIRONMENT" == "k8s" ]]; then
        command -v kubectl >/dev/null 2>&1 || { print_error "kubectl required for Kubernetes deployment"; exit 1; }
        command -v helm >/dev/null 2>&1 || { print_warning "Helm not found - using kubectl only"; }
    fi
    
    print_status "Requirements check passed"
}

# Validate environment variables
validate_environment() {
    print_info "Validating environment configuration for $ENVIRONMENT..."
    
    case $ENVIRONMENT in
        "prod")
            # Production requires all secrets
            [ -z "$DATABASE_URL" ] && print_error "DATABASE_URL required for production" && exit 1
            [ -z "$POSTGRES_USERNAME" ] && print_error "POSTGRES_USERNAME required for production" && exit 1
            [ -z "$POSTGRES_PASSWORD" ] && print_error "POSTGRES_PASSWORD required for production" && exit 1
            [ -z "$JWT_SECRET" ] && print_error "JWT_SECRET required for production" && exit 1
            ;;
        "staging")
            # Staging requires database config
            [ -z "$DATABASE_URL" ] && print_warning "DATABASE_URL not set, using default staging database"
            ;;
        "dev"|"local")
            # Dev/local can use defaults
            print_info "Using development defaults where environment variables not set"
            ;;
    esac
    
    print_status "Environment validation passed"
}

# Build application
build_application() {
    if [ "$SKIP_BUILD" = true ]; then
        print_warning "Skipping build"
        return
    fi
    
    print_header "Building Application"
    
    # Use the build script
    if [ -f "./build.sh" ]; then
        if [ "$SKIP_TESTS" = true ]; then
            ./build.sh build --skip-tests --profile=$ENVIRONMENT
        else
            ./build.sh build --profile=$ENVIRONMENT
        fi
    else
        # Fallback to direct Maven
        print_info "Running Maven build..."
        if [ "$SKIP_TESTS" = true ]; then
            mvn clean package -DskipTests -P$ENVIRONMENT
        else
            mvn clean package -P$ENVIRONMENT
        fi
    fi
    
    print_status "Application built successfully"
}

# Build Docker images
build_docker_images() {
    print_header "Building Docker Images"
    
    print_info "Building backend image..."
    docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-backend:${VERSION} \
        -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-backend:latest \
        -f Dockerfile.backend .
    
    print_info "Building database image (PostgreSQL 17)..."
    docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-postgres:${VERSION} \
        -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-postgres:latest \
        -f Dockerfile.postgres .
    
    print_status "Docker images built"
}

# Push Docker images
push_docker_images() {
    print_header "Pushing Docker Images"
    
    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would push:"
        echo "  - ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-backend:${VERSION}"
        echo "  - ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-backend:latest"
        echo "  - ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-postgres:${VERSION}"
        echo "  - ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-postgres:latest"
        return
    fi
    
    print_info "Pushing backend images..."
    docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-backend:${VERSION}
    docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-backend:latest
    
    print_info "Pushing database images..."
    docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-postgres:${VERSION}
    docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-postgres:latest
    
    print_status "Docker images pushed"
}

# Backup database
backup_database() {
    if [ "$BACKUP_DATABASE" = false ]; then
        print_warning "Database backup skipped"
        return
    fi
    
    print_header "Creating Database Backup"
    
    local backup_file="backup_${ENVIRONMENT}_$(date +%Y%m%d_%H%M%S).sql"
    local backup_dir="./backups"
    
    mkdir -p $backup_dir
    
    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would create backup: $backup_dir/$backup_file"
        return
    fi
    
    case $ENVIRONMENT in
        "prod"|"staging")
            print_info "Creating production database backup..."
            pg_dump $DATABASE_URL > $backup_dir/$backup_file
            ;;
        "dev")
            print_info "Creating development database backup..."
            docker exec unicloud-postgres17 pg_dump -U unicloud_dev uniclouddb > $backup_dir/$backup_file
            ;;
        "local")
            print_info "Creating local database backup..."
            docker-compose exec postgres pg_dump -U unicloud_dev uniclouddb > $backup_dir/$backup_file
            ;;
    esac
    
    if [ -f "$backup_dir/$backup_file" ]; then
        print_status "Database backup created: $backup_dir/$backup_file"
    else
        print_error "Database backup failed"
        exit 1
    fi
}

# Deploy to development
deploy_dev() {
    print_header "Deploying to Development Environment"
    
    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Development deployment plan:"
        echo "  - Start PostgreSQL 17 container"
        echo "  - Run database migrations"
        echo "  - Deploy backend JAR"
        echo "  - Start services"
        return
    fi
    
    # Start PostgreSQL 17
    print_info "Starting PostgreSQL 17..."
    docker-compose up -d postgres
    sleep 10
    
    # Run migrations
    print_info "Running database migrations..."
    cd unicloud-backend
    mvn flyway:migrate -Pdev
    cd ..
    
    # Deploy backend
    print_info "Starting backend service..."
    nohup java -jar unicloud-backend/target/unicloud-backend-${VERSION}.jar \
        --spring.profiles.active=dev > logs/backend-dev.log 2>&1 &
    
    print_deploy "Development deployment completed!"
    print_info "Backend running on: http://localhost:8080"
    print_info "Database running on: localhost:5432"
}

# Deploy to staging
deploy_staging() {
    print_header "Deploying to Staging Environment"
    
    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Staging deployment plan:"
        echo "  - Build and push Docker images"
        echo "  - Update staging docker-compose.yml"
        echo "  - Run database migrations"
        echo "  - Deploy containers"
        return
    fi
    
    # Build and push images
    build_docker_images
    push_docker_images
    
    # Deploy with Docker Compose
    print_info "Deploying to staging with Docker Compose..."
    docker-compose -f docker-compose.staging.yml up -d --force-recreate
    
    # Wait for services
    sleep 30
    
    # Run migrations
    print_info "Running database migrations..."
    docker-compose -f docker-compose.staging.yml exec backend \
        java -jar app.jar --flyway.migrate=true
    
    print_deploy "Staging deployment completed!"
    print_info "Staging URL: http://staging.unicloud.local"
}

# Deploy to production
deploy_prod() {
    print_header "Deploying to Production Environment"
    
    # Production safety checks
    if [ "$FORCE_DEPLOY" = false ]; then
        echo -e "${YELLOW}WARNING: You are about to deploy to PRODUCTION${NC}"
        echo "This will affect live users and data."
        read -p "Are you sure you want to continue? (yes/no): " confirm
        
        if [ "$confirm" != "yes" ]; then
            print_info "Production deployment cancelled"
            exit 0
        fi
    fi
    
    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Production deployment plan:"
        echo "  - Create database backup"
        echo "  - Build and push Docker images"
        echo "  - Rolling update deployment"
        echo "  - Run database migrations"
        echo "  - Health checks"
        return
    fi
    
    # Build and push images
    build_docker_images
    push_docker_images
    
    # Production deployment (this would typically use k8s, ECS, etc.)
    print_info "Deploying to production infrastructure..."
    
    # Example for Docker Swarm
    if command -v docker >/dev/null 2>&1 && docker node ls >/dev/null 2>&1; then
        print_info "Deploying to Docker Swarm..."
        docker stack deploy -c docker-compose.prod.yml unicloud
    else
        print_info "Updating production containers..."
        docker-compose -f docker-compose.prod.yml up -d --force-recreate
    fi
    
    # Health check
    sleep 60
    health_check "https://api.unicloud.com/health"
    
    print_deploy "Production deployment completed!"
    print_info "Production URL: https://unicloud.com"
}

# Deploy to local Docker
deploy_local() {
    print_header "Deploying to Local Docker Environment"
    
    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Local Docker deployment plan:"
        echo "  - Build Docker images"
        echo "  - Start all services with docker-compose"
        echo "  - Run database setup"
        return
    fi
    
    # Build images
    build_docker_images
    
    # Start services
    print_info "Starting all services..."
    docker-compose up -d
    
    # Wait for PostgreSQL
    print_info "Waiting for PostgreSQL 17 to be ready..."
    sleep 15
    
    # Run migrations
    print_info "Running database migrations..."
    docker-compose exec backend java -jar app.jar --flyway.migrate=true
    
    print_deploy "Local deployment completed!"
    print_info "Backend: http://localhost:8080"
    print_info "Database: localhost:5432"
    print_info "PgAdmin: http://localhost:5050"
}

# Deploy to Kubernetes
deploy_k8s() {
    print_header "Deploying to Kubernetes"
    
    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Kubernetes deployment plan:"
        echo "  - Build and push Docker images"
        echo "  - Apply Kubernetes manifests"
        echo "  - Run database migrations job"
        echo "  - Verify deployment"
        return
    fi
    
    # Build and push images
    build_docker_images
    push_docker_images
    
    # Apply Kubernetes manifests
    print_info "Applying Kubernetes manifests..."
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/postgres-pvc.yaml
    kubectl apply -f k8s/postgres-deployment.yaml
    kubectl apply -f k8s/postgres-service.yaml
    kubectl apply -f k8s/backend-deployment.yaml
    kubectl apply -f k8s/backend-service.yaml
    kubectl apply -f k8s/ingress.yaml
    
    # Wait for PostgreSQL
    print_info "Waiting for PostgreSQL to be ready..."
    kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s
    
    # Run migrations
    print_info "Running database migrations..."
    kubectl create job --from=deployment/unicloud-backend migration-$(date +%s) \
        -- java -jar app.jar --flyway.migrate=true
    
    print_deploy "Kubernetes deployment completed!"
    print_info "Check status with: kubectl get pods"
}

# Health check
health_check() {
    local url=$1
    local max_attempts=30
    local attempt=1
    
    print_info "Performing health check on $url..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "$url" >/dev/null; then
            print_status "Health check passed"
            return 0
        fi
        
        print_info "Health check attempt $attempt/$max_attempts failed, retrying in 10s..."
        sleep 10
        ((attempt++))
    done
    
    print_error "Health check failed after $max_attempts attempts"
    return 1
}

# Rollback deployment
rollback() {
    local previous_version=$1
    
    print_header "Rolling Back Deployment"
    
    if [ -z "$previous_version" ]; then
        print_error "Previous version required for rollback"
        exit 1
    fi
    
    case $ENVIRONMENT in
        "k8s")
            print_info "Rolling back Kubernetes deployment..."
            kubectl rollout undo deployment/unicloud-backend
            ;;
        "prod"|"staging")
            print_info "Rolling back Docker deployment..."
            docker service update --image ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-backend:$previous_version unicloud_backend
            ;;
        *)
            print_info "Rolling back local deployment..."
            docker-compose down
            docker run -d --name unicloud-backend ${DOCKER_REGISTRY}/${DOCKER_IMAGE_PREFIX}-backend:$previous_version
            ;;
    esac
    
    print_status "Rollback completed to version $previous_version"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        dev|staging|prod|local|k8s)
            ENVIRONMENT="$1"
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE_DEPLOY=true
            shift
            ;;
        --no-backup)
            BACKUP_DATABASE=false
            shift
            ;;
        --version=*)
            VERSION="${1#*=}"
            shift
            ;;
        --rollback=*)
            ROLLBACK_VERSION="${1#*=}"
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
main() {
    echo "🚀 UniCloud Deploy Script - PostgreSQL 17 Edition"
    echo "=================================================="
    echo "Version: $VERSION"
    echo "Environment: $ENVIRONMENT"
    echo ""
    
    if [ -z "$ENVIRONMENT" ]; then
        print_error "Environment required"
        show_help
        exit 1
    fi
    
    if [ -n "$ROLLBACK_VERSION" ]; then
        rollback $ROLLBACK_VERSION
        exit 0
    fi
    
    check_requirements
    validate_environment
    
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN MODE - No actual deployment will occur"
    fi
    
    # Create backup before deployment
    backup_database
    
    # Build application if needed
    build_application
    
    # Deploy to specified environment
    case $ENVIRONMENT in
        "dev")
            deploy_dev
            ;;
        "staging")
            deploy_staging
            ;;
        "prod")
            deploy_prod
            ;;
        "local")
            deploy_local
            ;;
        "k8s")
            deploy_k8s
            ;;
        *)
            print_error "Unknown environment: $ENVIRONMENT"
            exit 1
            ;;
    esac
    
    print_status "Deployment completed successfully!"
}

# Run main function
main "$@"
