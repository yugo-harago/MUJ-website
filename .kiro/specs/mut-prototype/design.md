# Design Document

## Overview

The MUT (Mission Unusual Tokyo) prototype is a full-stack web application with a clear separation between frontend and backend. The application features two separate Vue.js frontends (client-facing and backoffice), a Django backend for API requests and data management, and an Nginx reverse proxy for routing. The initial prototype focuses on establishing the foundational architecture and implementing a health-check feature.

## Architecture

### System Architecture

```
                                    ┌─────────────────┐
                                    │                 │
                                    │     Nginx       │
                                    │  Reverse Proxy  │
                                    │   Port 80/443   │
                                    │                 │
                                    └────────┬────────┘
                                             │
                    ┌────────────────────────┼────────────────────────┐
                    │                        │                        │
                    ▼                        ▼                        ▼
         ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
         │                  │    │                  │    │                  │
         │  Vue.js Client   │    │ Vue.js Backoffice│    │  Django Backend  │
         │  Frontend        │    │  Frontend        │    │  API Server      │
         │  Port 5173       │    │  Port 5174       │    │  Port 8000       │
         │                  │    │                  │    │                  │
         └──────────────────┘    └──────────────────┘    └────────┬─────────┘
                    │                        │                     │
                    │                        │                     │
                    └────────────────────────┴─────────────────────┘
                                             │
                                             ▼
                                    ┌─────────────────┐
                                    │                 │
                                    │  SQLite         │
                                    │  Database       │
                                    │                 │
                                    └─────────────────┘

Routing:
- / → Client Frontend
- /backoffice → Backoffice Frontend  
- /api → Django Backend
```

### Technology Stack

**Client Frontend:**
- Vue.js 3.x
- Axios (for HTTP requests)
- Vite (build tool)
- Node.js 18+ (runtime)

**Backoffice Frontend:**
- Vue.js 3.x
- Axios (for HTTP requests)
- Vite (build tool)
- Node.js 18+ (runtime)

**Backend:**
- Django 4.x
- Django REST Framework
- SQLite (built-in with Django)
- Python 3.9+

**Infrastructure:**
- Docker
- Docker Compose (for orchestration)
- Nginx (reverse proxy and static file serving)

### Project Structure

```
mut-prototype/
├── frontend-client/          # Vue.js client application
│   ├── src/
│   │   ├── components/
│   │   ├── views/
│   │   ├── App.vue
│   │   └── main.js
│   ├── package.json
│   ├── vite.config.js
│   └── Dockerfile
│
├── frontend-backoffice/      # Vue.js backoffice application
│   ├── src/
│   │   ├── components/
│   │   ├── views/
│   │   ├── App.vue
│   │   └── main.js
│   ├── package.json
│   ├── vite.config.js
│   └── Dockerfile
│
├── backend/                  # Django application
│   ├── mut_backend/          # Django project
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   ├── api/                  # Django app for API
│   │   ├── views.py
│   │   ├── urls.py
│   │   └── models.py
│   ├── manage.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── nginx/
│   ├── nginx.conf
│   └── Dockerfile
│
├── docker-compose.yml
└── .env
```

## Components and Interfaces

### Backend Components

#### Health-Check Endpoint

**URL:** `/api/health-check/`

**Method:** GET

**Response Format:**
```json
{
  "status": "ok",
  "environment": "DEV",
  "version": "0.1.0"
}
```

**Implementation Details:**
- Django view function or class-based view
- Reads environment variable from Django settings or OS environment
- Version stored as a constant in settings or separate config file
- No authentication required for prototype

#### Django Settings Configuration

**Environment Variable:**
- Read from `ENVIRONMENT` environment variable
- Default to "DEV" if not set
- Valid values: "PROD", "DEV"

**Version:**
- Stored in `settings.py` as `VERSION = "0.1.0"`
- Can be updated manually for releases

#### CORS Configuration

- Enable CORS to allow frontend to communicate with backend during development
- Use `django-cors-headers` package
- Allow localhost origins for development

### Frontend Components

Both frontend applications (client and backoffice) will implement similar components with slight variations in styling and branding.

#### HealthCheck Component (Client Frontend)

**Purpose:** Display environment and version information for client users

**Data:**
- `environment`: String (PROD/DEV)
- `version`: String
- `loading`: Boolean
- `error`: String or null

**Methods:**
- `fetchHealthCheck()`: Async method to call backend API via Nginx proxy
- Called on component mount

**Template:**
- Display environment badge (color-coded: green for PROD, blue for DEV)
- Display version number
- Show loading state while fetching
- Display error message if request fails
- Client-friendly styling

#### HealthCheck Component (Backoffice Frontend)

**Purpose:** Display environment and version information for backoffice users

**Data:**
- Same as client component

**Methods:**
- Same as client component

**Template:**
- Display environment badge with admin-style UI
- Display version number
- Show loading state while fetching
- Display error message if request fails
- Admin/backoffice styling

#### API Service (Shared Pattern)

**Purpose:** Centralize HTTP requests to backend

**Configuration:**
- Base URL points to Nginx proxy: `/api`
- Relative URLs work through Nginx routing
- No CORS issues due to same-origin via proxy

**Methods:**
- `getHealthCheck()`: Returns Promise with health-check data

## Data Models

### Backend Models

For the initial prototype, no database models are required. The health-check endpoint returns static/configuration data only.

**Future Consideration:** If persistence is needed, models can be added to the Django `api` app.

## Error Handling

### Backend Error Handling

- Return appropriate HTTP status codes
- 200 OK for successful health-check
- 500 Internal Server Error for unexpected failures
- Include error messages in JSON response format

**Error Response Format:**
```json
{
  "status": "error",
  "message": "Error description"
}
```

### Frontend Error Handling

- Catch network errors from API requests
- Display user-friendly error messages
- Log errors to console for debugging
- Provide retry mechanism or manual refresh option

## Testing Strategy

### Backend Testing

- Unit tests for health-check view
- Test environment variable reading
- Test version retrieval
- Test JSON response format
- Use Django's TestCase class

### Frontend Testing

**Client Frontend:**
- Component tests for HealthCheck component
- Test API service methods
- Test error state rendering
- Test loading state rendering
- Use Vitest or Jest with Vue Test Utils

**Backoffice Frontend:**
- Component tests for HealthCheck component
- Test API service methods
- Test error state rendering
- Test loading state rendering
- Use Vitest or Jest with Vue Test Utils

### Integration Testing

- Test full flow from frontend request to backend response
- Verify CORS configuration
- Test with both PROD and DEV environment values

## Docker Configuration

### Container Architecture

The application runs in four separate Docker containers orchestrated by Docker Compose:

1. **Nginx Container**
   - Based on Nginx Alpine image
   - Exposes port 80 (and 443 for future SSL)
   - Routes requests to appropriate services
   - Serves as reverse proxy

2. **Backend Container**
   - Based on Python 3.9+ image
   - Internal port 8000
   - Runs Django development server
   - Volume mount for live code reloading during development

3. **Client Frontend Container**
   - Based on Node.js 18+ image
   - Internal port 5173
   - Runs Vite development server
   - Volume mount for live code reloading during development

4. **Backoffice Frontend Container**
   - Based on Node.js 18+ image
   - Internal port 5174
   - Runs Vite development server
   - Volume mount for live code reloading during development

### Docker Compose Services

**Services:**
- `nginx`: Reverse proxy and router
- `backend`: Django application
- `frontend-client`: Vue.js client application
- `frontend-backoffice`: Vue.js backoffice application

**Networking:**
- All services on same Docker network
- Nginx routes external requests to internal services
- Only Nginx exposes ports to host (80, 443)
- Services communicate via service names

### Nginx Configuration

**Routing Rules:**
- `/` → Proxy to `frontend-client:5173`
- `/backoffice` → Proxy to `frontend-backoffice:5174`
- `/api` → Proxy to `backend:8000`

**Features:**
- WebSocket support for HMR (Hot Module Replacement)
- Proxy headers for proper client IP forwarding
- CORS handling at proxy level
- Static file caching headers

### Dockerfile Specifications

**Nginx Dockerfile:**
- Use official Nginx Alpine image
- Copy custom nginx.conf
- Minimal configuration for development
- Production-ready with minor adjustments

**Backend Dockerfile:**
- Use official Python image
- Install dependencies from requirements.txt
- Copy application code
- Run Django development server with host 0.0.0.0
- Support for environment variables

**Frontend Dockerfiles (both client and backoffice):**
- Use official Node.js image
- Install dependencies from package.json
- Copy application code
- Run Vite dev server with host 0.0.0.0
- Configure API base URL to point to Nginx proxy

## Development Workflow

### Initial Setup

1. Clone repository
2. Create `.env` file with required variables
3. Run `docker-compose up --build`
4. Access application through Nginx:
   - Client frontend: `http://localhost/`
   - Backoffice frontend: `http://localhost/backoffice`
   - Backend API: `http://localhost/api/health-check`

### Backend Development

1. Code changes automatically reload via volume mount
2. Django migrations run on container start
3. Access Django admin if needed
4. View logs via `docker-compose logs backend`

### Frontend Development

**Client Frontend:**
1. Code changes automatically reload via volume mount
2. Hot module replacement (HMR) enabled through Nginx WebSocket proxy
3. View logs via `docker-compose logs frontend-client`

**Backoffice Frontend:**
1. Code changes automatically reload via volume mount
2. Hot module replacement (HMR) enabled through Nginx WebSocket proxy
3. View logs via `docker-compose logs frontend-backoffice`

### Environment Configuration

**Root `.env` file:**
```
# Backend
ENVIRONMENT=DEV
DJANGO_SECRET_KEY=<django-secret-key>
DJANGO_DEBUG=True

# Frontend (both use relative URLs through Nginx)
VITE_API_BASE_URL=/api
```

### Docker Commands

**Start services:**
```bash
docker-compose up
```

**Rebuild containers:**
```bash
docker-compose up --build
```

**Stop services:**
```bash
docker-compose down
```

**View logs:**
```bash
docker-compose logs -f
docker-compose logs -f nginx
docker-compose logs -f backend
docker-compose logs -f frontend-client
docker-compose logs -f frontend-backoffice
```

**Execute commands in containers:**
```bash
docker-compose exec backend python manage.py migrate
docker-compose exec frontend-client npm install <package>
docker-compose exec frontend-backoffice npm install <package>
```

## Deployment Considerations (Future)

While this is a prototype, the Docker architecture supports future deployment:

- **Development:** Docker Compose with development servers
- **Production:** 
  - Frontend: Multi-stage build with Nginx to serve static files
  - Backend: Gunicorn WSGI server with Nginx reverse proxy
  - Database: Migrate to PostgreSQL container
  - Container orchestration: Docker Swarm or Kubernetes
  - Environment variables: Managed through deployment platform or secrets management

### Production Docker Adjustments

- Use multi-stage builds to minimize image size
- Run as non-root user
- Use production-grade web servers (Gunicorn, Nginx)
- Implement health checks in Docker Compose
- Use Docker secrets for sensitive data
- Configure proper logging and monitoring
