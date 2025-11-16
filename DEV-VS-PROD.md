# Development vs Production Comparison

## Quick Reference

| Use Case | Command | Config File |
|----------|---------|-------------|
| **Local Development** | `docker-compose up` | `docker-compose.yml` |
| **Production Deployment** | `./deploy.sh start` | `docker-compose.prod.yml` |

## Detailed Comparison

### 🔧 Backend Service

| Feature | Development | Production |
|---------|-------------|------------|
| **Server** | Django dev server | Gunicorn (4 workers) |
| **Dockerfile** | `Dockerfile` | `Dockerfile.prod` |
| **Debug Mode** | `True` | `False` |
| **Auto-reload** | ✅ Yes | ❌ No |
| **Volume Mount** | ✅ Yes (`./backend:/app`) | ❌ No |
| **Port Exposed** | `8000` | Internal only |
| **Health Check** | ❌ No | ✅ Yes |
| **Restart Policy** | None | `unless-stopped` |
| **Static Files** | Served by Django | Collected to volume |
| **Performance** | Optimized for dev | Optimized for prod |

**Development Command:**
```dockerfile
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
```

**Production Command:**
```dockerfile
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "backend.wsgi:application"]
```

---

### 🎨 Frontend Services (Client & Backoffice)

| Feature | Development | Production |
|---------|-------------|------------|
| **Server** | Vite dev server | Nginx (static files) |
| **Dockerfile** | `Dockerfile` | `Dockerfile.prod` (multi-stage) |
| **Build Type** | Development | Production build |
| **Hot Reload (HMR)** | ✅ Yes | ❌ No |
| **Volume Mount** | ✅ Yes (src, public, etc.) | ❌ No |
| **Port Exposed** | `5173`, `5174` | Internal only |
| **Build Time** | Fast (no build) | Slower (full build) |
| **Image Size** | ~1GB | ~50MB |
| **Optimization** | None | Minified, tree-shaken |
| **Source Maps** | ✅ Yes | ❌ No |

**Development:**
```dockerfile
FROM node:20
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]
```

**Production:**
```dockerfile
# Build stage
FROM node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Serve stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html/client
COPY nginx.prod.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]
```

---

### 🌐 Nginx Service

| Feature | Development | Production |
|---------|-------------|------------|
| **Config File** | `nginx.conf` | `nginx.prod.conf` |
| **Upstream Ports** | `5173`, `5174` (Vite) | `80` (Nginx containers) |
| **WebSocket** | ✅ Yes (for HMR) | ❌ No |
| **Health Check** | ❌ No | ✅ Yes |
| **Security Headers** | ❌ No | ✅ Yes |
| **Gzip** | Basic | Optimized |
| **Caching** | Minimal | Aggressive |

**Development Upstream:**
```nginx
upstream frontend_client {
    server frontend-client:5173;
}
```

**Production Upstream:**
```nginx
upstream frontend_client {
    server frontend-client:80;
}
```

---

### 📦 Docker Compose Configuration

| Feature | Development | Production |
|---------|-------------|------------|
| **File** | `docker-compose.yml` | `docker-compose.prod.yml` |
| **Volumes** | Source code mounted | Only data volumes |
| **Ports** | All exposed | Only nginx (80) |
| **Health Checks** | ❌ No | ✅ Yes |
| **Restart Policy** | None | `unless-stopped` |
| **Build Context** | Simple | Optimized |
| **Environment** | `.env` | `.env.prod` |

---

### 🔐 Environment Variables

| Variable | Development | Production |
|----------|-------------|------------|
| **ENVIRONMENT** | `DEV` | `PROD` |
| **DJANGO_DEBUG** | `True` | `False` |
| **DJANGO_SECRET_KEY** | Simple | Strong random |
| **DJANGO_ALLOWED_HOSTS** | `localhost` | Your domains |
| **VITE_API_BASE_URL** | `/api` | `/api` |

---

### 📊 Performance Comparison

| Metric | Development | Production |
|--------|-------------|------------|
| **Startup Time** | ~30 seconds | ~60 seconds (build) |
| **Memory Usage** | ~2GB | ~500MB |
| **CPU Usage** | Higher (HMR) | Lower |
| **Response Time** | Slower | Faster |
| **Bundle Size** | Large | Optimized |
| **Image Size** | ~3GB total | ~500MB total |

---

### 🛠️ Development Workflow

```bash
# Start development
docker-compose up

# Make code changes
# → Auto-reload happens
# → See changes immediately

# Stop
docker-compose down
```

**Advantages:**
- ✅ Instant feedback
- ✅ Easy debugging
- ✅ Source maps available
- ✅ Fast iteration

**Disadvantages:**
- ❌ Slower performance
- ❌ Higher resource usage
- ❌ Not production-ready

---

### 🚀 Production Workflow

```bash
# Deploy
./deploy.sh start

# Code changes require rebuild
git pull
./deploy.sh update

# Stop
./deploy.sh stop
```

**Advantages:**
- ✅ Optimized performance
- ✅ Small image sizes
- ✅ Production-ready
- ✅ Secure configuration
- ✅ Health monitoring

**Disadvantages:**
- ❌ Slower iteration
- ❌ Requires rebuild for changes
- ❌ No hot-reload

---

## When to Use Each

### Use Development When:
- 👨‍💻 Actively coding
- 🐛 Debugging issues
- 🧪 Testing new features
- 📚 Learning the codebase
- 🔄 Need instant feedback

### Use Production When:
- 🌐 Deploying to server
- 👥 Serving real users
- 🔒 Security is critical
- ⚡ Performance matters
- 📊 Need monitoring

---

## Switching Between Environments

### From Development to Production

```bash
# Stop development
docker-compose down

# Start production
./deploy.sh start
```

### From Production to Development

```bash
# Stop production
./deploy.sh stop

# Start development
docker-compose up
```

**Note:** Both can run simultaneously on different ports if needed.

---

## File Organization

```
mut-prototype/
├── Development Files
│   ├── docker-compose.yml
│   ├── .env
│   ├── */Dockerfile
│   └── nginx/nginx.conf
│
└── Production Files
    ├── docker-compose.prod.yml
    ├── .env.prod
    ├── */Dockerfile.prod
    ├── nginx/nginx.prod.conf
    ├── deploy.sh
    ├── DEPLOYMENT.md
    └── QUICKSTART-PRODUCTION.md
```

---

## Best Practices

### Development
1. Keep `.env` in `.gitignore`
2. Use volume mounts for code
3. Enable debug mode
4. Use development servers
5. Expose all ports for debugging

### Production
1. Keep `.env.prod` in `.gitignore`
2. Bake code into images
3. Disable debug mode
4. Use production servers (Gunicorn, Nginx)
5. Only expose necessary ports
6. Enable health checks
7. Use restart policies
8. Implement monitoring
9. Regular backups
10. Security headers

---

## Common Mistakes

### ❌ Don't Do This

1. **Using dev config in production**
   ```bash
   # Wrong!
   docker-compose up -d  # in production
   ```

2. **Debug mode in production**
   ```env
   DJANGO_DEBUG=True  # in .env.prod
   ```

3. **Weak secret key in production**
   ```env
   DJANGO_SECRET_KEY=your-secret-key-here  # in .env.prod
   ```

4. **Volume mounts in production**
   ```yaml
   # Wrong in docker-compose.prod.yml!
   volumes:
     - ./backend:/app
   ```

### ✅ Do This Instead

1. **Use correct config**
   ```bash
   ./deploy.sh start  # in production
   docker-compose up  # in development
   ```

2. **Disable debug in production**
   ```env
   DJANGO_DEBUG=False
   ```

3. **Strong secret key**
   ```bash
   python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
   ```

4. **No volume mounts in production**
   ```yaml
   # Code is in the image, not mounted
   ```

---

## Quick Commands Reference

### Development
```bash
docker-compose up              # Start
docker-compose down            # Stop
docker-compose logs -f         # Logs
docker-compose ps              # Status
docker-compose restart backend # Restart service
```

### Production
```bash
./deploy.sh start              # Start
./deploy.sh stop               # Stop
./deploy.sh logs               # Logs
./deploy.sh status             # Status
./deploy.sh restart            # Restart all
./deploy.sh update             # Update & rebuild
```

---

## Summary

| Aspect | Development | Production |
|--------|-------------|------------|
| **Goal** | Fast iteration | Stable, secure, fast |
| **Optimization** | Developer experience | User experience |
| **Debugging** | Easy | Limited |
| **Performance** | Lower | Higher |
| **Security** | Relaxed | Strict |
| **Monitoring** | Minimal | Comprehensive |
| **Updates** | Instant | Requires rebuild |

Choose the right environment for your needs! 🎯
