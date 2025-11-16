# Production Deployment Guide

This guide covers deploying the MUT prototype application to production using Docker Compose.

## Quick Start

```bash
# 1. Create production environment file
cp .env.prod.example .env.prod

# 2. Edit .env.prod with your production values
nano .env.prod

# 3. Build and start services
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d --build

# 4. Run migrations
docker-compose -f docker-compose.prod.yml exec backend python manage.py migrate

# 5. Verify deployment
curl http://localhost/api/health-check/
```

## Architecture Overview

### Production Stack

- **Nginx**: Main reverse proxy and load balancer
- **Backend**: Django application running with Gunicorn (4 workers)
- **Frontend Client**: Static Vue.js build served by Nginx
- **Frontend Backoffice**: Static Vue.js build served by Nginx

### Key Differences from Development

| Feature | Development | Production |
|---------|-------------|------------|
| Backend Server | Django dev server | Gunicorn WSGI server |
| Frontend Serving | Vite dev server | Static files via Nginx |
| Hot Reloading | ✅ Enabled | ❌ Disabled |
| Debug Mode | ✅ Enabled | ❌ Disabled |
| Volume Mounts | ✅ Live code sync | ❌ Code in image |
| Health Checks | ❌ None | ✅ Enabled |
| Restart Policy | ❌ None | ✅ unless-stopped |
| Optimization | Development | Production builds |

## Environment Configuration

### Required Environment Variables

```bash
# Backend
ENVIRONMENT=PROD
DJANGO_SECRET_KEY=<generate-secure-key>
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# Frontend
VITE_API_BASE_URL=/api
```

### Generating Django Secret Key

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

## Deployment Steps

### 1. Prepare Environment

```bash
# Clone repository
git clone <repository-url>
cd mut-prototype

# Create production environment file
cp .env.prod.example .env.prod

# Edit with production values
vim .env.prod
```

### 2. Build Images

```bash
# Build all production images
docker-compose -f docker-compose.prod.yml --env-file .env.prod build

# Or build specific service
docker-compose -f docker-compose.prod.yml build backend
```

### 3. Start Services

```bash
# Start all services in detached mode
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Check service status
docker-compose -f docker-compose.prod.yml ps
```

### 4. Initialize Database

```bash
# Run migrations
docker-compose -f docker-compose.prod.yml exec backend python manage.py migrate

# Create superuser (optional)
docker-compose -f docker-compose.prod.yml exec backend python manage.py createsuperuser

# Collect static files (if needed)
docker-compose -f docker-compose.prod.yml exec backend python manage.py collectstatic --noinput
```

### 5. Verify Deployment

```bash
# Test health endpoint
curl http://localhost/api/health-check/

# Expected response:
# {"status":"ok","environment":"PROD","version":"0.1.0"}

# Test client frontend
curl -I http://localhost/

# Test backoffice frontend
curl -I http://localhost/backoffice
```

## Maintenance

### Viewing Logs

```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker-compose.prod.yml logs -f backend

# Last 100 lines
docker-compose -f docker-compose.prod.yml logs --tail=100
```

### Updating Application

```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d --build

# Run migrations if needed
docker-compose -f docker-compose.prod.yml exec backend python manage.py migrate
```

### Scaling Services

```bash
# Scale backend to 3 instances
docker-compose -f docker-compose.prod.yml up -d --scale backend=3

# Note: Requires load balancer configuration for proper distribution
```

### Stopping Services

```bash
# Stop all services
docker-compose -f docker-compose.prod.yml down

# Stop and remove volumes
docker-compose -f docker-compose.prod.yml down -v

# Stop specific service
docker-compose -f docker-compose.prod.yml stop backend
```

## Security Checklist

- [ ] Set strong `DJANGO_SECRET_KEY`
- [ ] Set `DJANGO_DEBUG=False`
- [ ] Configure `DJANGO_ALLOWED_HOSTS` with actual domains
- [ ] Use HTTPS/SSL (configure reverse proxy)
- [ ] Keep dependencies updated
- [ ] Use secrets management for sensitive data
- [ ] Configure firewall rules
- [ ] Enable rate limiting
- [ ] Set up monitoring and alerting
- [ ] Regular security audits

## SSL/HTTPS Setup

### Option 1: Using Let's Encrypt with Certbot

```bash
# Install certbot
apt-get install certbot python3-certbot-nginx

# Obtain certificate
certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal is configured automatically
```

### Option 2: Using Reverse Proxy (Traefik)

Create `docker-compose.traefik.yml`:

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v2.10
    command:
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.email=your@email.com"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./letsencrypt:/letsencrypt
    networks:
      - mut-network

  nginx:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.mut.rule=Host(`yourdomain.com`)"
      - "traefik.http.routers.mut.entrypoints=websecure"
      - "traefik.http.routers.mut.tls.certresolver=letsencrypt"
```

## Monitoring

### Health Checks

All services have health checks configured:

```bash
# Check health status
docker-compose -f docker-compose.prod.yml ps

# Services should show "healthy" status
```

### Resource Monitoring

```bash
# View resource usage
docker stats

# View specific service
docker stats muj-website-backend-1
```

## Backup and Recovery

### Database Backup

```bash
# Backup SQLite database
docker-compose -f docker-compose.prod.yml exec backend python manage.py dumpdata > backup.json

# Restore from backup
docker-compose -f docker-compose.prod.yml exec -T backend python manage.py loaddata < backup.json
```

### Volume Backup

```bash
# Backup volumes
docker run --rm -v muj-website_static_volume:/data -v $(pwd):/backup alpine tar czf /backup/static-backup.tar.gz /data

# Restore volumes
docker run --rm -v muj-website_static_volume:/data -v $(pwd):/backup alpine tar xzf /backup/static-backup.tar.gz -C /
```

## Troubleshooting

### Services Won't Start

```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs

# Check specific service
docker-compose -f docker-compose.prod.yml logs backend

# Rebuild from scratch
docker-compose -f docker-compose.prod.yml down -v
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

### Health Checks Failing

```bash
# Check service health
docker-compose -f docker-compose.prod.yml ps

# Test health endpoint manually
docker-compose -f docker-compose.prod.yml exec backend curl http://localhost:8000/api/health-check/

# Check nginx health
docker-compose -f docker-compose.prod.yml exec nginx wget -O- http://localhost/health
```

### High Memory Usage

```bash
# Check resource usage
docker stats

# Reduce Gunicorn workers in backend/Dockerfile.prod
# Change --workers 4 to --workers 2
```

### Database Issues

```bash
# Check database file permissions
docker-compose -f docker-compose.prod.yml exec backend ls -la db.sqlite3

# Run migrations
docker-compose -f docker-compose.prod.yml exec backend python manage.py migrate

# Check for migration issues
docker-compose -f docker-compose.prod.yml exec backend python manage.py showmigrations
```

## Performance Optimization

### Enable Caching

Consider adding Redis for caching:

```yaml
services:
  redis:
    image: redis:alpine
    networks:
      - mut-network
    restart: unless-stopped
```

### Database Optimization

For production, consider using PostgreSQL instead of SQLite:

```yaml
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: mutdb
      POSTGRES_USER: mutuser
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - mut-network
    restart: unless-stopped

volumes:
  postgres_data:
```

## Support

For issues or questions:
- Check logs: `docker-compose -f docker-compose.prod.yml logs`
- Review this guide
- Check Docker and Docker Compose versions
- Ensure all environment variables are set correctly
