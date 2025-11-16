# Production Quick Start

## 🚀 Deploy in 5 Minutes

### 1. Setup Environment
```bash
cp .env.prod.example .env.prod
nano .env.prod  # Edit with your values
```

**Required changes in `.env.prod`:**
- `DJANGO_SECRET_KEY`: Generate with `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"`
- `DJANGO_ALLOWED_HOSTS`: Add your domain(s)

### 2. Deploy
```bash
./deploy.sh start
```

### 3. Initialize Database
```bash
./deploy.sh migrate
```

### 4. Verify
```bash
./deploy.sh status
```

Visit:
- Client: http://localhost/
- Backoffice: http://localhost/backoffice
- API: http://localhost/api/health-check/

## 📋 Common Commands

```bash
./deploy.sh start           # Start services
./deploy.sh stop            # Stop services
./deploy.sh restart         # Restart services
./deploy.sh logs            # View logs
./deploy.sh status          # Check health
./deploy.sh migrate         # Run migrations
./deploy.sh update          # Update from git
./deploy.sh createsuperuser # Create admin user
./deploy.sh backup          # Backup database
```

## 🔧 Manual Commands

If you prefer manual control:

```bash
# Start
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d --build

# Stop
docker-compose -f docker-compose.prod.yml down

# Logs
docker-compose -f docker-compose.prod.yml logs -f

# Status
docker-compose -f docker-compose.prod.yml ps

# Migrate
docker-compose -f docker-compose.prod.yml exec backend python manage.py migrate
```

## 🔒 Security Checklist

Before going live:

- [ ] Set strong `DJANGO_SECRET_KEY`
- [ ] Set `DJANGO_DEBUG=False`
- [ ] Configure `DJANGO_ALLOWED_HOSTS`
- [ ] Set up HTTPS/SSL
- [ ] Configure firewall
- [ ] Set up monitoring
- [ ] Configure backups

## 📚 Full Documentation

- [DEPLOYMENT.md](DEPLOYMENT.md) - Complete deployment guide
- [README.md](README.md) - Development and production docs

## 🆘 Troubleshooting

**Services won't start:**
```bash
docker-compose -f docker-compose.prod.yml logs
```

**Health check fails:**
```bash
docker-compose -f docker-compose.prod.yml exec backend curl http://localhost:8000/api/health-check/
```

**Need to rebuild:**
```bash
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

## 🎯 What's Different in Production?

| Feature | Development | Production |
|---------|-------------|------------|
| Server | Django dev | Gunicorn |
| Frontend | Vite dev | Static build |
| Hot reload | ✅ | ❌ |
| Debug | ✅ | ❌ |
| Volumes | ✅ | ❌ |
| Health checks | ❌ | ✅ |
| Auto-restart | ❌ | ✅ |

## 📊 Monitoring

Check service health:
```bash
./deploy.sh status
```

View resource usage:
```bash
docker stats
```

## 🔄 Updates

To update the application:
```bash
./deploy.sh update
```

This will:
1. Pull latest code from git
2. Rebuild containers
3. Run migrations
4. Restart services
