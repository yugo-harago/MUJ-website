#!/bin/bash

# MUT Prototype - Production Deployment Script
# Usage: ./deploy.sh [start|stop|restart|logs|status|update]

set -e

COMPOSE_FILE="docker-compose.prod.yml"
ENV_FILE=".env.prod"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env.prod exists
check_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${RED}Error: $ENV_FILE not found!${NC}"
        echo "Please create it from .env.prod.example:"
        echo "  cp .env.prod.example .env.prod"
        echo "  nano .env.prod"
        exit 1
    fi
}

# Start services
start() {
    echo -e "${GREEN}Starting production services...${NC}"
    check_env_file
    docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE up -d --build
    echo -e "${GREEN}Services started!${NC}"
    echo ""
    echo "Run migrations with: ./deploy.sh migrate"
    echo "View logs with: ./deploy.sh logs"
}

# Stop services
stop() {
    echo -e "${YELLOW}Stopping production services...${NC}"
    docker-compose -f $COMPOSE_FILE down
    echo -e "${GREEN}Services stopped!${NC}"
}

# Restart services
restart() {
    echo -e "${YELLOW}Restarting production services...${NC}"
    stop
    start
}

# View logs
logs() {
    docker-compose -f $COMPOSE_FILE logs -f
}

# Show status
status() {
    echo -e "${GREEN}Service Status:${NC}"
    docker-compose -f $COMPOSE_FILE ps
    echo ""
    echo -e "${GREEN}Health Check:${NC}"
    curl -s http://localhost/api/health-check/ | jq . || echo "Health check failed or jq not installed"
}

# Run migrations
migrate() {
    echo -e "${GREEN}Running database migrations...${NC}"
    docker-compose -f $COMPOSE_FILE exec backend python manage.py migrate
    echo -e "${GREEN}Migrations complete!${NC}"
}

# Update application
update() {
    echo -e "${GREEN}Updating application...${NC}"
    git pull origin main
    docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE up -d --build
    docker-compose -f $COMPOSE_FILE exec backend python manage.py migrate
    echo -e "${GREEN}Update complete!${NC}"
}

# Create superuser
createsuperuser() {
    echo -e "${GREEN}Creating Django superuser...${NC}"
    docker-compose -f $COMPOSE_FILE exec backend python manage.py createsuperuser
}

# Backup database
backup() {
    BACKUP_FILE="backup-$(date +%Y%m%d-%H%M%S).json"
    echo -e "${GREEN}Creating backup: $BACKUP_FILE${NC}"
    docker-compose -f $COMPOSE_FILE exec backend python manage.py dumpdata > $BACKUP_FILE
    echo -e "${GREEN}Backup created: $BACKUP_FILE${NC}"
}

# Show help
help() {
    echo "MUT Prototype - Production Deployment Script"
    echo ""
    echo "Usage: ./deploy.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start           - Build and start all services"
    echo "  stop            - Stop all services"
    echo "  restart         - Restart all services"
    echo "  logs            - View service logs (follow mode)"
    echo "  status          - Show service status and health"
    echo "  migrate         - Run database migrations"
    echo "  update          - Pull latest code and rebuild"
    echo "  createsuperuser - Create Django admin user"
    echo "  backup          - Backup database to JSON file"
    echo "  help            - Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh start"
    echo "  ./deploy.sh logs"
    echo "  ./deploy.sh status"
}

# Main script logic
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    logs)
        logs
        ;;
    status)
        status
        ;;
    migrate)
        migrate
        ;;
    update)
        update
        ;;
    createsuperuser)
        createsuperuser
        ;;
    backup)
        backup
        ;;
    help|--help|-h)
        help
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        echo ""
        help
        exit 1
        ;;
esac
