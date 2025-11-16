# Requirements Document

## Introduction

MUT (Mission Unusual Tokyo) is a prototype web application consisting of two Vue.js frontend applications (client and backoffice), a Django backend with SQLite database, and an Nginx reverse proxy. The initial prototype focuses on establishing the basic architecture and implementing a health-check endpoint that displays environment information and version details.

## Glossary

- **MUT System**: The complete web application including frontend applications, backend, and Nginx proxy
- **Client Frontend**: The Vue.js-based user interface for end users
- **Backoffice Frontend**: The Vue.js-based user interface for administrative users
- **Backend**: The Django-based API server component
- **Nginx Proxy**: The reverse proxy server that routes requests to appropriate services
- **Health-Check Endpoint**: An API endpoint that returns system status and configuration information
- **Environment Variable**: A configuration value indicating the deployment environment (PROD or DEV)
- **Version**: The current release version of the application

## Requirements

### Requirement 1

**User Story:** As a developer, I want to set up two separate Vue.js frontend applications, so that I can build distinct interfaces for client users and backoffice users

#### Acceptance Criteria

1. THE Client Frontend SHALL be implemented using Vue.js framework
2. THE Backoffice Frontend SHALL be implemented using Vue.js framework
3. THE Client Frontend SHALL use Bootstrap for UI styling and components
4. THE Backoffice Frontend SHALL use Bootstrap for UI styling and components
5. THE Client Frontend SHALL serve static assets and application code for end users
6. THE Backoffice Frontend SHALL serve static assets and application code for administrative users
7. THE Client Frontend SHALL communicate with the Backend through HTTP requests via the Nginx Proxy
8. THE Backoffice Frontend SHALL communicate with the Backend through HTTP requests via the Nginx Proxy

### Requirement 2

**User Story:** As a developer, I want to set up a Django backend with SQLite database, so that I can handle API requests and store data

#### Acceptance Criteria

1. THE Backend SHALL be implemented using Django framework
2. THE Backend SHALL use SQLite as the database engine
3. THE Backend SHALL expose RESTful API endpoints
4. THE Backend SHALL handle HTTP requests from the Client Frontend and Backoffice Frontend

### Requirement 3

**User Story:** As a system administrator, I want a health-check endpoint, so that I can verify the system status and configuration

#### Acceptance Criteria

1. THE Backend SHALL provide a health-check endpoint accessible via HTTP GET request
2. WHEN the health-check endpoint is requested, THE Backend SHALL return the current environment variable value
3. WHEN the health-check endpoint is requested, THE Backend SHALL return the current version number
4. THE Backend SHALL support environment variable values of "PROD" and "DEV"
5. THE Backend SHALL return health-check data in JSON format

### Requirement 4

**User Story:** As a user, I want to view the health-check information on the frontend, so that I can see the current environment and version

#### Acceptance Criteria

1. THE Client Frontend SHALL display the environment variable value retrieved from the health-check endpoint
2. THE Client Frontend SHALL display the version number retrieved from the health-check endpoint
3. THE Backoffice Frontend SHALL display the environment variable value retrieved from the health-check endpoint
4. THE Backoffice Frontend SHALL display the version number retrieved from the health-check endpoint
5. WHEN the Client Frontend loads, THE Client Frontend SHALL request health-check data from the Backend via the Nginx Proxy
6. WHEN the Backoffice Frontend loads, THE Backoffice Frontend SHALL request health-check data from the Backend via the Nginx Proxy
7. IF the health-check request fails, THEN THE Client Frontend SHALL display an error message to the user
8. IF the health-check request fails, THEN THE Backoffice Frontend SHALL display an error message to the user

### Requirement 5

**User Story:** As a developer, I want to set up an Nginx reverse proxy, so that I can route requests to the appropriate services and simplify the architecture

#### Acceptance Criteria

1. THE Nginx Proxy SHALL route requests to root path "/" to the Client Frontend
2. THE Nginx Proxy SHALL route requests to "/backoffice" path to the Backoffice Frontend
3. THE Nginx Proxy SHALL route requests to "/api" path to the Backend
4. THE Nginx Proxy SHALL be accessible on port 80
5. THE Nginx Proxy SHALL support WebSocket connections for development hot module replacement

### Requirement 6

**User Story:** As a developer, I want to containerize all services with Docker, so that I can ensure consistent development and deployment environments

#### Acceptance Criteria

1. THE Client Frontend SHALL run in a Docker container
2. THE Backoffice Frontend SHALL run in a Docker container
3. THE Backend SHALL run in a Docker container
4. THE Nginx Proxy SHALL run in a Docker container
5. THE MUT System SHALL use Docker Compose to orchestrate all containers
6. WHEN Docker Compose starts, THE MUT System SHALL make all services accessible through the Nginx Proxy
