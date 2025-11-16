# Production Deployment Files

This document lists all files created for production deployment.

## 📁 File Structure

```
mut-prototype/
├── docker-compose.prod.yml          # Production Docker Compose configuration
├── .env.prod.example                # Production environment template
├── deploy.sh                        # Deployment automation script
├── DEPLOYMENT.md                    # Complete deployment guide
├── QUICKSTART-PRODUCTION.md         # Quick start guide
│
├── backend/
│   ├── Dockerfile                   # Development Dockerfile
│   ├── Dockerfile.prod              # Production Dockerfile (Gunicorn)
│   └── .dockerignore                # Docker build exclusions
│
├── frontend-client/
│   ├── Dockerfile                   # Development Dockerfile
│   ├── Dockerfile.prod              # Production Dockerfile (multi-stage)
│   ├── nginx.prod.conf              # Nginx config for static files
│   └── .dockerignore                # Docker build exclusions
│
├── frontend-backoffice/
│   ├── Dockerfile                   # Development Dockerfile
│   ├── Dockerfile.prod              # Production Dockerfile (multi-stage)
│   ├── nginx.prod.conf              # Nginx config for static files
│   └── .dockerignore                # Docker build exclusions
│
└── nginx/
    ├── Dockerfile                   # Development Dockerfile
    ├── Dockerfile.prod              # Production Dockerfile
    ├── nginx.conf                   # Development configuration
    └── nginx.prod.conf              # Production configuration
```

## 📄 File Descriptions

### Core Configuration Files

#### `docker-compose.prod.yml`
Production Docker Compose configuration with:
- Production Dockerfiles for all services
- Health checks for backend and nginx
- Restart policies (unless-stopped)
- Volume management for static/media files
- No development volume mounts
- Optimized for production use

#### `.env.prod.example`
Template for production environment variables:
- Django configuration (secret key, debug, allowed hosts)
- Frontend API URL
- Database settings (for future PostgreSQL migration)
- Security settings

#### `deploy.sh`
Bash script for easy deployment management:
- Start/stop/restart services
- View logs and status
- Run migrations
- Create superuser
- Backup database
- Update application

### Backend Files

#### `backend/Dockerfile.prod`
Production backend Dockerfile:
- Uses Gunicorn WSGI server (4 workers)
- Collects static files
- Optimized for production
- No development dependencies

#### `backend/.dockerignore`
Excludes unnecessary files from Docker build:
- Python cache files
- Virtual environments
- Database files
- Git files

### Frontend Files

#### `frontend-client/Dockerfile.prod` & `frontend-backoffice/Dockerfile.prod`
Multi-stage production Dockerfiles:
- Stage 1: Build Vue.js application
- Stage 2: Serve with Nginx
- Optimized static builds
- Small final image size

#### `frontend-*/nginx.prod.conf`
Nginx configuration for serving static files:
- SPA routing support
- Gzip compression
- Cache headers for static assets
- Performance optimizations

#### `frontend-*/.dockerignore`
Excludes unnecessary files from Docker build:
- node_modules (rebuilt in container)
- dist directory
- Git files

### Nginx Files

#### `nginx/Dockerfile.prod`
Production nginx Dockerfile:
- Installs wget for health checks
- Uses production configuration
- Lightweight Alpine base

#### `nginx/nginx.prod.conf`
Production reverse proxy configuration:
- Routes to frontend containers on port 80
- Backend API routing
- Security headers
- Gzip compression
- Performance optimizations
- Health check endpoint

### Documentation Files

#### `DEPLOYMENT.md`
Comprehensive deployment guide covering:
- Architecture overview
- Environment configuration
- Step-by-step deployment
- Maintenance procedures
- Security checklist
- SSL/HTTPS setup
- Monitoring and troubleshooting
- Backup and recovery
- Performance optimization

#### `QUICKSTART-PRODUCTION.md`
Quick reference for common tasks:
- 5-minute deployment guide
- Common commands
- Security checklist
- Troubleshooting tips

## 🔄 Development vs Production

### Development Setup
```bash
docker-compose up
```
- Uses `Dockerfile` (dev servers)
- Hot-reloading enabled
- Volume mounts for live updates
- Debug mode enabled
- Direct port access

### Production Setup
```bash
./deploy.sh start
# or
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d
```
- Uses `Dockerfile.prod` (production servers)
- Static builds
- No volume mounts
- Debug mode disabled
- Health checks enabled
- Auto-restart policies

## 🚀 Quick Start

1. **Create environment file:**
   ```bash
   cp .env.prod.example .env.prod
   nano .env.prod
   ```

2. **Deploy:**
   ```bash
   ./deploy.sh start
   ```

3. **Initialize:**
   ```bash
   ./deploy.sh migrate
   ```

4. **Verify:**
   ```bash
   ./deploy.sh status
   ```

## 📊 Key Features

### Security
- Debug mode disabled
- Security headers configured
- Secret key management
- Allowed hosts configuration
- HTTPS ready

### Performance
- Gunicorn with multiple workers
- Static file optimization
- Gzip compression
- Cache headers
- Optimized Docker images

### Reliability
- Health checks
- Auto-restart policies
- Graceful shutdowns
- Volume persistence
- Logging

### Maintainability
- Automated deployment script
- Comprehensive documentation
- Easy updates
- Backup utilities
- Clear separation of dev/prod

## 🔧 Customization

### Scaling Backend
Edit `backend/Dockerfile.prod`:
```dockerfile
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "8", "backend.wsgi:application"]
```

### Adding Database
Edit `docker-compose.prod.yml`:
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
```

### SSL/HTTPS
Option 1: Use Traefik or Caddy as reverse proxy
Option 2: Modify `nginx/nginx.prod.conf` to include SSL certificates

## 📝 Notes

- All production files use `.prod` suffix for clarity
- Development files remain unchanged
- Both setups can coexist
- Easy to switch between dev and prod
- Production images are optimized for size and security

## 🆘 Support

For issues:
1. Check `./deploy.sh logs`
2. Review `DEPLOYMENT.md`
3. Check service health: `./deploy.sh status`
4. Verify environment variables in `.env.prod`
