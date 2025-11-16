# MUT (Mission Unusual Tokyo) - Prototype

A full-stack web application prototype featuring two Vue.js frontend applications (client and backoffice), a Django backend with SQLite database, and an Nginx reverse proxy.

## Architecture

- **Client Frontend**: Vue.js application for end users (port 5173)
- **Backoffice Frontend**: Vue.js application for administrative users (port 5174)
- **Backend**: Django REST API with SQLite database (port 8000)
- **Nginx Proxy**: Reverse proxy routing requests to appropriate services (port 80)

## Prerequisites

- Docker
- Docker Compose

## Getting Started

### 1. Environment Configuration

The `.env` file contains all necessary environment variables. Default values are configured for development:

```env
# Backend Configuration
ENVIRONMENT=DEV
DJANGO_SECRET_KEY=your-secret-key-here-change-in-production
DJANGO_DEBUG=True

# Frontend Configuration
VITE_API_BASE_URL=/api
```

**Note**: Change `DJANGO_SECRET_KEY` before deploying to production.

### 2. Starting the Application

Build and start all services:

```bash
docker-compose up --build
```

Or start without rebuilding:

```bash
docker-compose up
```

Run in detached mode (background):

```bash
docker-compose up -d
```

### 3. Accessing the Application

Once all services are running, access the application through Nginx:

- **Client Frontend**: http://localhost/
- **Backoffice Frontend**: http://localhost/backoffice
- **Backend API Health Check**: http://localhost/api/health-check/

All requests are routed through the Nginx reverse proxy on port 80.

### 4. Stopping the Application

Stop all services:

```bash
docker-compose down
```

Stop and remove volumes:

```bash
docker-compose down -v
```

## Development

### Hot Reloading

All services are configured with volume mounts for development hot-reloading:

- **Frontend applications**: Changes to Vue.js code will automatically reload in the browser
- **Backend**: Changes to Django code will automatically restart the development server

### Viewing Logs

View logs for all services:

```bash
docker-compose logs -f
```

View logs for a specific service:

```bash
docker-compose logs -f nginx
docker-compose logs -f backend
docker-compose logs -f frontend-client
docker-compose logs -f frontend-backoffice
```

### Executing Commands in Containers

Run Django management commands:

```bash
docker-compose exec backend python manage.py migrate
docker-compose exec backend python manage.py createsuperuser
docker-compose exec backend python manage.py shell
```

Install npm packages in frontend applications:

```bash
docker-compose exec frontend-client npm install <package-name>
docker-compose exec frontend-backoffice npm install <package-name>
```

Run tests:

```bash
# Backend tests
docker-compose exec backend python manage.py test

# Frontend tests
docker-compose exec frontend-client npm test
docker-compose exec frontend-backoffice npm test
```

### Rebuilding Containers

If you make changes to Dockerfiles or dependencies:

```bash
docker-compose up --build
```

Rebuild a specific service:

```bash
docker-compose build backend
docker-compose up backend
```

## Debugging

### Check Service Status

```bash
docker-compose ps
```

### Inspect Container

```bash
docker-compose exec <service-name> sh
```

### Check Network Connectivity

Test connectivity between services:

```bash
docker-compose exec frontend-client ping backend
docker-compose exec nginx ping frontend-client
```

### Common Issues

**Port already in use:**
- Stop any services running on ports 80, 8000, 5173, or 5174
- Or modify the port mappings in `docker-compose.yml`

**Permission errors:**
- Ensure Docker has proper permissions
- On Linux, you may need to run with `sudo` or add your user to the docker group

**Hot reloading not working:**
- Check volume mounts in `docker-compose.yml`
- Verify WebSocket connections are working through Nginx proxy

## Project Structure

```
mut-prototype/
├── frontend-client/          # Vue.js client application
├── frontend-backoffice/      # Vue.js backoffice application
├── backend/                  # Django application
├── nginx/                    # Nginx configuration
├── docker-compose.yml        # Docker Compose orchestration
├── .env                      # Environment variables
└── README.md                 # This file
```

## Health Check Feature

The prototype includes a health-check endpoint that displays:
- Current environment (PROD/DEV)
- Application version

Both frontend applications fetch and display this information on load.

## Production Deployment

For production deployment, see:
- **[QUICKSTART-PRODUCTION.md](QUICKSTART-PRODUCTION.md)** - Quick 5-minute deployment guide
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Comprehensive deployment documentation
- **[PRODUCTION-FILES.md](PRODUCTION-FILES.md)** - Overview of all production files

Quick production deployment:
```bash
cp .env.prod.example .env.prod
nano .env.prod  # Configure your settings
./deploy.sh start
./deploy.sh migrate
```

## Version

Current version: 0.1.0

## Production Deployment

### Prerequisites for Production

- Docker
- Docker Compose
- A domain name (optional, but recommended)
- SSL certificate (recommended for production)

### Production Setup

#### 1. Create Production Environment File

Copy the example environment file and configure it:

```bash
cp .env.prod.example .env.prod
```

Edit `.env.prod` and set:
- `DJANGO_SECRET_KEY`: Generate a secure random string (use `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"`)
- `DJANGO_ALLOWED_HOSTS`: Add your domain names
- Other security settings as needed

#### 2. Build and Start Production Services

```bash
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
```

#### 3. Run Database Migrations

```bash
docker-compose -f docker-compose.prod.yml exec backend python manage.py migrate
```

#### 4. Create Superuser (Optional)

```bash
docker-compose -f docker-compose.prod.yml exec backend python manage.py createsuperuser
```

### Production vs Development

**Development (`docker-compose.yml`)**:
- Hot-reloading enabled for all services
- Django development server
- Vite dev server with HMR
- Volume mounts for live code updates
- Debug mode enabled
- Exposed ports for direct service access

**Production (`docker-compose.prod.yml`)**:
- Static builds of frontend applications
- Gunicorn WSGI server for Django
- Nginx serving static frontend files
- No volume mounts (code baked into images)
- Debug mode disabled
- Health checks enabled
- Automatic restart policies
- Optimized for performance and security

### Production Commands

**View logs:**
```bash
docker-compose -f docker-compose.prod.yml logs -f
```

**Stop services:**
```bash
docker-compose -f docker-compose.prod.yml down
```

**Rebuild and restart:**
```bash
docker-compose -f docker-compose.prod.yml up -d --build
```

**Check service health:**
```bash
docker-compose -f docker-compose.prod.yml ps
```

### Production Considerations

**Security:**
- Always use a strong `DJANGO_SECRET_KEY`
- Set `DJANGO_DEBUG=False` in production
- Configure `DJANGO_ALLOWED_HOSTS` with your actual domain names
- Use HTTPS/SSL in production (configure reverse proxy or load balancer)
- Keep dependencies updated
- Use environment-specific secrets management

**Performance:**
- Consider using a production database (PostgreSQL, MySQL) instead of SQLite
- Configure proper caching (Redis, Memcached)
- Set up CDN for static assets
- Monitor resource usage and scale as needed

**Monitoring:**
- Set up logging aggregation
- Configure application monitoring (APM)
- Set up alerts for service health
- Monitor disk space for volumes

**Backup:**
- Regularly backup database
- Backup media files if applicable
- Keep backups in separate location

### SSL/HTTPS Setup

For production, you should configure SSL/HTTPS. Options include:

1. **Using a reverse proxy** (recommended):
   - Place Nginx or Traefik in front of the application
   - Use Let's Encrypt for free SSL certificates
   - Configure automatic certificate renewal

2. **Using a cloud load balancer**:
   - AWS ALB, Google Cloud Load Balancer, etc.
   - Handle SSL termination at the load balancer level

3. **Modifying the Nginx configuration**:
   - Add SSL certificate files to the nginx container
   - Update nginx.conf to listen on port 443
   - Redirect HTTP to HTTPS

### Scaling

To scale services horizontally:

```bash
docker-compose -f docker-compose.prod.yml up -d --scale backend=3
```

Note: For proper load balancing, you'll need to configure Nginx or use an external load balancer.
