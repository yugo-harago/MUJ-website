# Implementation Plan

- [x] 1. Set up project structure and Docker configuration
  - Create root directory structure with folders for frontend-client, frontend-backoffice, backend, and nginx
  - Create docker-compose.yml file defining all four services with proper networking
  - Create .env file template with required environment variables
  - Create .gitignore file for Python, Node.js, and Docker artifacts
  - _Requirements: 6.5, 6.6_

- [x] 2. Implement Django backend with health-check endpoint
- [x] 2.1 Create Django project structure and Dockerfile
  - Initialize Django project named "mut_backend"
  - Create "api" Django app for health-check endpoint
  - Write backend/Dockerfile with Python base image and dependency installation
  - Create requirements.txt with Django, djangorestframework, django-cors-headers
  - _Requirements: 2.1, 2.2, 6.3_

- [x] 2.2 Configure Django settings for Docker environment
  - Configure settings.py to read ENVIRONMENT variable from environment
  - Add VERSION constant to settings.py (set to "0.1.0")
  - Configure CORS settings to allow requests from Nginx proxy
  - Set ALLOWED_HOSTS to include Docker service names
  - Configure SQLite database path
  - _Requirements: 2.1, 2.2, 3.2, 3.3, 3.4_

- [x] 2.3 Implement health-check API endpoint
  - Create health-check view in api/views.py that returns JSON with environment and version
  - Configure URL routing in api/urls.py for /health-check/ endpoint
  - Include api URLs in main urls.py with /api/ prefix
  - _Requirements: 3.1, 3.2, 3.3, 3.5_

- [x] 2.4 Write unit tests for health-check endpoint
  - Create test file for health-check view
  - Test successful response with correct JSON format
  - Test environment variable reading
  - Test version retrieval
  - _Requirements: 3.1, 3.2, 3.3, 3.5_

- [ ] 3. Implement Client Frontend Vue.js application
- [ ] 3.1 Create Vue.js project structure and Dockerfile
  - Initialize Vue.js project with Vite in frontend-client directory
  - Write frontend-client/Dockerfile with Node.js base image
  - Configure vite.config.js to listen on 0.0.0.0:5173
  - Create package.json with Vue, Axios, and Bootstrap dependencies
  - Install and configure Bootstrap in main.js
  - _Requirements: 1.1, 1.3, 1.5, 6.1_

- [ ] 3.2 Create API service layer
  - Create src/services/api.js with Axios instance configured for /api base URL
  - Implement getHealthCheck() method that calls /api/health-check/
  - Add error handling for network failures
  - _Requirements: 1.7, 4.5_

- [ ] 3.3 Implement HealthCheck component for client
  - Create HealthCheck.vue component in src/components/
  - Add data properties for environment, version, loading, and error states
  - Implement fetchHealthCheck() method that calls API service
  - Create template using Bootstrap components with environment badge (green for PROD, blue for DEV) and version display
  - Add error message display using Bootstrap alert component for failed requests
  - Style with Bootstrap classes for client-friendly UI
  - _Requirements: 1.3, 4.1, 4.2, 4.5, 4.7_

- [ ] 3.4 Wire up component in App.vue
  - Import and use HealthCheck component in App.vue
  - Add basic layout using Bootstrap container and grid system
  - Add MUT branding with Bootstrap styling
  - _Requirements: 1.3, 1.5, 4.1, 4.2_

- [ ] 3.5 Write component tests for client frontend
  - Create test file for HealthCheck component
  - Test component rendering with mock data
  - Test loading state display
  - Test error state display
  - Test API service integration
  - _Requirements: 4.1, 4.2, 4.5, 4.7_

- [ ] 4. Implement Backoffice Frontend Vue.js application
- [ ] 4.1 Create Vue.js project structure and Dockerfile
  - Initialize Vue.js project with Vite in frontend-backoffice directory
  - Write frontend-backoffice/Dockerfile with Node.js base image
  - Configure vite.config.js to listen on 0.0.0.0:5174 and set base path to /backoffice
  - Create package.json with Vue, Axios, and Bootstrap dependencies
  - Install and configure Bootstrap in main.js
  - _Requirements: 1.2, 1.4, 1.6, 6.2_

- [ ] 4.2 Create API service layer
  - Create src/services/api.js with Axios instance configured for /api base URL
  - Implement getHealthCheck() method that calls /api/health-check/
  - Add error handling for network failures
  - _Requirements: 1.8, 4.6_

- [ ] 4.3 Implement HealthCheck component for backoffice
  - Create HealthCheck.vue component in src/components/
  - Add data properties for environment, version, loading, and error states
  - Implement fetchHealthCheck() method that calls API service
  - Create template using Bootstrap components with environment badge and version display
  - Add error message display using Bootstrap alert component for failed requests
  - Style with Bootstrap classes for admin/backoffice UI theme
  - _Requirements: 1.4, 4.3, 4.4, 4.6, 4.8_

- [ ] 4.4 Wire up component in App.vue
  - Import and use HealthCheck component in App.vue
  - Add basic layout using Bootstrap container and grid system with backoffice/admin styling
  - Add MUT branding for backoffice with Bootstrap styling
  - _Requirements: 1.4, 1.6, 4.3, 4.4_

- [ ] 4.5 Write component tests for backoffice frontend
  - Create test file for HealthCheck component
  - Test component rendering with mock data
  - Test loading state display
  - Test error state display
  - Test API service integration
  - _Requirements: 4.3, 4.4, 4.6, 4.8_

- [ ] 5. Configure Nginx reverse proxy
- [ ] 5.1 Create Nginx configuration and Dockerfile
  - Write nginx/nginx.conf with routing rules for /, /backoffice, and /api
  - Configure proxy settings for WebSocket support (HMR)
  - Add proxy headers for proper client IP forwarding
  - Write nginx/Dockerfile using Nginx Alpine base image
  - _Requirements: 5.1, 5.2, 5.3, 5.5, 6.4_

- [ ] 5.2 Configure port exposure and service routing
  - Expose port 80 in Nginx Dockerfile
  - Configure upstream servers for frontend-client, frontend-backoffice, and backend services
  - Set up location blocks for proper request routing
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [ ] 6. Integrate all services with Docker Compose
- [ ] 6.1 Complete docker-compose.yml configuration
  - Define all four services with proper build contexts
  - Configure environment variables for each service
  - Set up Docker network for inter-service communication
  - Configure volume mounts for development hot-reloading
  - Set service dependencies to ensure proper startup order
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

- [ ] 6.2 Create startup and verification scripts
  - Document startup commands in README.md
  - Add instructions for accessing each frontend through Nginx
  - Add instructions for viewing logs and debugging
  - _Requirements: 6.6_

- [ ] 6.3 Test end-to-end integration
  - Start all services with docker-compose up
  - Verify client frontend accessible at http://localhost/
  - Verify backoffice frontend accessible at http://localhost/backoffice
  - Verify health-check endpoint returns correct data through both frontends
  - Verify hot-reloading works for all services
  - _Requirements: 1.5, 1.6, 4.5, 4.6, 5.1, 5.2, 5.3, 6.6_
