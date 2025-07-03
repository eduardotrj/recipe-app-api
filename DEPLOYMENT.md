# Deployment Guide

This guide covers various deployment strategies for the Recipe App API.

## Table of Contents
- [Docker Deployment](#docker-deployment)
- [Production Environment Setup](#production-environment-setup)
- [AWS Deployment](#aws-deployment)
- [DigitalOcean Deployment](#digitalocean-deployment)
- [Environment Variables](#environment-variables)
- [SSL/HTTPS Setup](#sslhttps-setup)
- [Monitoring and Logging](#monitoring-and-logging)

## Docker Deployment

### Local Development
```bash
# Build and run development environment
docker-compose up --build

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop services
docker-compose down
```

### Production Deployment
```bash
# Use production docker-compose file
docker-compose -f docker-compose-deploy.yml up --build -d

# Scale the application
docker-compose -f docker-compose-deploy.yml up --scale app=3 -d
```

## Production Environment Setup

### 1. Server Requirements
- **CPU**: Minimum 1 vCPU, Recommended 2+ vCPU
- **RAM**: Minimum 1GB, Recommended 2GB+
- **Storage**: Minimum 10GB SSD
- **OS**: Ubuntu 20.04 LTS or newer

### 2. Install Dependencies
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

### 3. Clone and Setup Application
```bash
# Clone repository
git clone <your-repo-url> recipe-app-api
cd recipe-app-api

# Create environment file
cp .env.example .env
nano .env  # Edit with your production values
```

### 4. Environment Configuration
Create a `.env` file:
```env
# Django Settings
SECRET_KEY=your-very-secure-secret-key-here
DEBUG=0
ALLOWED_HOSTS=your-domain.com,www.your-domain.com

# Database Settings
DB_HOST=db
DB_NAME=recipeapp
DB_USER=recipeuser
DB_PASS=secure-database-password

# Security
SECURE_SSL_REDIRECT=1
SECURE_HSTS_SECONDS=31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS=1
SECURE_HSTS_PRELOAD=1
```

### 5. Deploy Application
```bash
# Start production services
docker-compose -f docker-compose-deploy.yml up -d

# Check status
docker-compose -f docker-compose-deploy.yml ps

# View logs
docker-compose -f docker-compose-deploy.yml logs -f
```

## AWS Deployment

### Using AWS ECS with Fargate

1. **Create ECR Repository**
```bash
# Create repository
aws ecr create-repository --repository-name recipe-app-api

# Get login command
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com

# Build and push image
docker build -t recipe-app-api .
docker tag recipe-app-api:latest 123456789012.dkr.ecr.us-west-2.amazonaws.com/recipe-app-api:latest
docker push 123456789012.dkr.ecr.us-west-2.amazonaws.com/recipe-app-api:latest
```

2. **Create ECS Task Definition**
```json
{
  "family": "recipe-app-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "recipe-app",
      "image": "123456789012.dkr.ecr.us-west-2.amazonaws.com/recipe-app-api:latest",
      "portMappings": [
        {
          "containerPort": 8005,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "DB_HOST",
          "value": "your-rds-endpoint"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/recipe-app-api",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

3. **Create RDS Database**
```bash
aws rds create-db-instance \
  --db-instance-identifier recipe-app-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username recipeuser \
  --master-user-password securepassword \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-12345678
```

### Using AWS Elastic Beanstalk

1. **Install EB CLI**
```bash
pip install awsebcli
```

2. **Initialize Elastic Beanstalk**
```bash
eb init recipe-app-api --platform docker --region us-west-2
```

3. **Create Environment**
```bash
eb create production --instance-type t3.small
```

4. **Deploy**
```bash
eb deploy
```

## DigitalOcean Deployment

### Using DigitalOcean App Platform

1. **Create App Spec** (`app.yaml`):
```yaml
name: recipe-app-api
services:
- name: api
  source_dir: /
  github:
    repo: your-username/recipe-app-api
    branch: main
  run_command: scripts/run.sh
  environment_slug: python
  instance_count: 1
  instance_size_slug: basic-xxs
  http_port: 8005
  envs:
  - key: SECRET_KEY
    value: your-secret-key
  - key: DEBUG
    value: "0"
  - key: DB_HOST
    value: ${db.HOSTNAME}
  - key: DB_NAME
    value: ${db.DATABASE}
  - key: DB_USER
    value: ${db.USERNAME}
  - key: DB_PASS
    value: ${db.PASSWORD}

databases:
- name: db
  engine: PG
  num_nodes: 1
  size: db-s-dev-database
  version: "12"
```

2. **Deploy with doctl**
```bash
# Install doctl
snap install doctl

# Authenticate
doctl auth init

# Create app
doctl apps create app.yaml

# Get app info
doctl apps list
```

### Using DigitalOcean Droplet

1. **Create Droplet**
```bash
doctl compute droplet create recipe-app \
  --size s-1vcpu-1gb \
  --image ubuntu-20-04-x64 \
  --region nyc1 \
  --ssh-keys your-ssh-key-id
```

2. **Setup Domain and Firewall**
```bash
# Create domain record
doctl compute domain records create your-domain.com \
  --record-type A \
  --record-name @ \
  --record-data your-droplet-ip

# Create firewall
doctl compute firewall create recipe-app-firewall \
  --inbound-rules "protocol:tcp,ports:22,source_addresses:0.0.0.0/0,source_addresses:::/0 protocol:tcp,ports:80,source_addresses:0.0.0.0/0,source_addresses:::/0 protocol:tcp,ports:443,source_addresses:0.0.0.0/0,source_addresses:::/0"
```

## Environment Variables

### Required Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `SECRET_KEY` | Django secret key | `your-secret-key-here` |
| `DEBUG` | Debug mode | `0` |
| `DB_HOST` | Database host | `localhost` |
| `DB_NAME` | Database name | `recipeapp` |
| `DB_USER` | Database user | `recipeuser` |
| `DB_PASS` | Database password | `securepassword` |

### Optional Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `ALLOWED_HOSTS` | Allowed hosts | `127.0.0.1` |
| `DB_PORT` | Database port | `5432` |
| `STATIC_URL` | Static files URL | `/static/` |
| `MEDIA_URL` | Media files URL | `/media/` |

### Security Variables (Production)
```env
SECURE_SSL_REDIRECT=1
SECURE_HSTS_SECONDS=31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS=1
SECURE_HSTS_PRELOAD=1
SECURE_CONTENT_TYPE_NOSNIFF=1
SECURE_BROWSER_XSS_FILTER=1
CSRF_COOKIE_SECURE=1
SESSION_COOKIE_SECURE=1
```

## SSL/HTTPS Setup

### Using Let's Encrypt with Nginx

1. **Install Certbot**
```bash
sudo apt install certbot python3-certbot-nginx
```

2. **Obtain Certificate**
```bash
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

3. **Auto-renewal**
```bash
sudo crontab -e
# Add this line:
0 12 * * * /usr/bin/certbot renew --quiet
```

### Using Cloudflare

1. **Configure DNS** in Cloudflare dashboard
2. **Enable SSL/TLS** (Full or Full Strict)
3. **Configure Origin Certificates** for backend

## Monitoring and Logging

### Health Check Endpoint
The application includes a health check endpoint at `/api/health-check/`.

### Docker Health Checks
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8005/api/health-check/ || exit 1
```

### Logging Configuration

1. **Centralized Logging with ELK Stack**
```yaml
# docker-compose-logging.yml
version: '3.9'
services:
  elasticsearch:
    image: elasticsearch:7.14.0
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"

  logstash:
    image: logstash:7.14.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf

  kibana:
    image: kibana:7.14.0
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
```

2. **Application Logging**
```python
# settings.py
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.FileHandler',
            'filename': '/vol/web/django.log',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'INFO',
            'propagate': True,
        },
    },
}
```

### Monitoring with Prometheus

1. **Add Django Prometheus metrics**
```bash
pip install django-prometheus
```

2. **Configure settings**
```python
INSTALLED_APPS = [
    'django_prometheus',
    # ... other apps
]

MIDDLEWARE = [
    'django_prometheus.middleware.PrometheusBeforeMiddleware',
    # ... other middleware
    'django_prometheus.middleware.PrometheusAfterMiddleware',
]
```

### Backup Strategy

1. **Database Backups**
```bash
# Create backup script
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose exec -T db pg_dump -U $DB_USER $DB_NAME > $BACKUP_DIR/backup_$DATE.sql

# Keep only last 7 days
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete
```

2. **Media Files Backup**
```bash
# Sync to S3
aws s3 sync /vol/web/media/ s3://your-bucket/media/ --delete
```

## Troubleshooting

### Common Issues

1. **Container fails to start**
   - Check logs: `docker-compose logs app`
   - Verify environment variables
   - Check port conflicts

2. **Database connection errors**
   - Verify database credentials
   - Check network connectivity
   - Ensure database is running

3. **Static files not serving**
   - Run collectstatic: `docker-compose exec app python manage.py collectstatic`
   - Check volume mounts
   - Verify nginx configuration

### Performance Optimization

1. **Database Optimization**
   - Add database indexes
   - Use connection pooling
   - Optimize queries

2. **Caching**
   - Implement Redis caching
   - Use Django cache framework
   - Add CDN for static files

3. **Application Scaling**
   - Use multiple app instances
   - Implement load balancing
   - Use container orchestration (Kubernetes)

## Security Checklist

- [ ] Set secure SECRET_KEY
- [ ] Disable DEBUG in production
- [ ] Configure ALLOWED_HOSTS
- [ ] Enable HTTPS/SSL
- [ ] Set security headers
- [ ] Use environment variables for secrets
- [ ] Regular security updates
- [ ] Database access restrictions
- [ ] API rate limiting
- [ ] Input validation
- [ ] CORS configuration
- [ ] Regular backups
