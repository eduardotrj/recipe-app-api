# Recipe App API - Architecture Documentation

This document describes the architecture, design patterns, and technical decisions used in the Recipe App API.

## Table of Contents
- [Overview](#overview)
- [Architecture Patterns](#architecture-patterns)
- [System Architecture](#system-architecture)
- [Database Design](#database-design)
- [API Design](#api-design)
- [Security Architecture](#security-architecture)
- [Performance Considerations](#performance-considerations)
- [Deployment Architecture](#deployment-architecture)

## Overview

The Recipe App API is a RESTful web service built using Django and Django REST Framework. It follows modern architectural patterns and best practices for building scalable, maintainable web applications.

### Key Characteristics

- **RESTful Design**: Follows REST architectural principles
- **Microservice Ready**: Designed to be easily containerized and scaled
- **API-First**: Pure API with no frontend coupling
- **Token-Based Authentication**: Stateless authentication mechanism
- **Database Agnostic**: Uses Django ORM for database abstraction
- **Containerized**: Fully dockerized for consistent deployment

## Architecture Patterns

### 1. Model-View-Controller (MVC) Pattern

The application follows Django's MVT (Model-View-Template) pattern, adapted for API development:

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Models    │    │    Views    │    │ Serializers │
│ (Data Layer)│◄──►│(Logic Layer)│◄──►│(Data Format)│
└─────────────┘    └─────────────┘    └─────────────┘
```

- **Models**: Define data structure and business logic
- **Views**: Handle HTTP requests and responses
- **Serializers**: Handle data validation and serialization

### 2. Repository Pattern

Django's ORM serves as a repository pattern implementation:

```python
# Model acts as repository
class Recipe(models.Model):
    # Model definition

    @classmethod
    def get_user_recipes(cls, user):
        return cls.objects.filter(user=user)
```

### 3. Service Layer Pattern

Business logic is encapsulated in model methods and manager classes:

```python
class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        # Business logic for user creation
        pass
```

### 4. Dependency Injection

Django's built-in dependency injection through settings and apps:

```python
# settings.py
INSTALLED_APPS = [
    'core',
    'user',
    'recipe',
]

# Automatic dependency resolution
```

## System Architecture

### High-Level Architecture

```
┌─────────────────┐
│   Load Balancer │
└─────────┬───────┘
          │
┌─────────▼───────┐    ┌─────────────────┐
│  Reverse Proxy  │    │  Static Files   │
│     (Nginx)     │◄──►│     (CDN)       │
└─────────┬───────┘    └─────────────────┘
          │
┌─────────▼───────┐    ┌─────────────────┐
│  Application    │    │     Cache       │
│   (Django)      │◄──►│    (Redis)      │
└─────────┬───────┘    └─────────────────┘
          │
┌─────────▼───────┐    ┌─────────────────┐
│    Database     │    │  File Storage   │
│  (PostgreSQL)   │    │     (S3)        │
└─────────────────┘    └─────────────────┘
```

### Application Layer Architecture

```
app/
├── app/                    # Project configuration
│   ├── settings.py        # Application settings
│   ├── urls.py            # URL routing
│   └── wsgi.py            # WSGI application
├── core/                  # Core business logic
│   ├── models.py          # Data models
│   ├── admin.py           # Admin interface
│   └── management/        # Custom commands
├── user/                  # User management
│   ├── views.py           # User API endpoints
│   ├── serializers.py     # User data serialization
│   └── urls.py            # User URL patterns
└── recipe/                # Recipe management
    ├── views.py           # Recipe API endpoints
    ├── serializers.py     # Recipe data serialization
    └── urls.py            # Recipe URL patterns
```

## Database Design

### Entity Relationship Diagram

```
┌─────────────────┐      ┌─────────────────┐
│      User       │      │     Recipe      │
├─────────────────┤      ├─────────────────┤
│ id (PK)         │◄────┐│ id (PK)         │
│ email           │     └│ user_id (FK)    │
│ name            │      │ title           │
│ password        │      │ description     │
│ is_active       │      │ time_minutes    │
│ is_staff        │      │ price           │
│ created_at      │      │ link            │
└─────────────────┘      │ image           │
                         │ created_at      │
                         └─────────┬───────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        │                          │                          │
┌───────▼───────┐         ┌────────▼────────┐        ┌───────▼───────┐
│     Tag       │         │  RecipeTag      │        │  Ingredient   │
├───────────────┤         ├─────────────────┤        ├───────────────┤
│ id (PK)       │◄───────┐│ recipe_id (FK)  │┌──────►│ id (PK)       │
│ name          │        └│ tag_id (FK)     ││       │ name          │
│ user_id (FK)  │         └─────────────────┘│       │ user_id (FK)  │
└───────────────┘                            │       └───────────────┘
                                             │
                         ┌───────────────────┘
                         │
                ┌────────▼────────┐
                │ RecipeIngredient│
                ├─────────────────┤
                │ recipe_id (FK)  │
                │ ingredient_id   │
                └─────────────────┘
```

### Model Relationships

```python
# One-to-Many: User -> Recipes
class Recipe(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)

# Many-to-Many: Recipe <-> Tags
class Recipe(models.Model):
    tags = models.ManyToManyField(Tag)

# Many-to-Many: Recipe <-> Ingredients
class Recipe(models.Model):
    ingredients = models.ManyToManyField(Ingredient)
```

### Database Indexes

```python
class Recipe(models.Model):
    class Meta:
        indexes = [
            models.Index(fields=['user', 'title']),
            models.Index(fields=['created_at']),
        ]
```

## API Design

### RESTful Endpoints

The API follows REST conventions:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/recipe/recipes/` | List recipes |
| POST | `/api/recipe/recipes/` | Create recipe |
| GET | `/api/recipe/recipes/{id}/` | Get recipe |
| PUT | `/api/recipe/recipes/{id}/` | Update recipe |
| DELETE | `/api/recipe/recipes/{id}/` | Delete recipe |

### Request/Response Format

#### Standard Response Format
```json
{
  "id": 1,
  "title": "Recipe Title",
  "description": "Recipe description",
  "time_minutes": 30,
  "price": "10.00",
  "user": 1,
  "tags": [
    {"id": 1, "name": "dinner"}
  ],
  "ingredients": [
    {"id": 1, "name": "tomato"}
  ]
}
```

#### Error Response Format
```json
{
  "detail": "Error message",
  "field_errors": {
    "field_name": ["Field specific error"]
  }
}
```

### API Versioning Strategy

```python
# URL versioning
urlpatterns = [
    path('api/v1/', include('recipe.urls')),
]

# Header versioning (future)
# Accept: application/json; version=1.0
```

### Pagination

```python
# settings.py
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20
}
```

## Security Architecture

### Authentication Flow

```
Client                    Server
  │                        │
  │ 1. POST /api/user/token/│
  │ {email, password}      │
  ├───────────────────────►│
  │                        │ 2. Validate credentials
  │                        │
  │ 3. Return token        │
  │◄───────────────────────┤
  │                        │
  │ 4. GET /api/recipes/   │
  │ Authorization: Token X │
  ├───────────────────────►│
  │                        │ 5. Validate token
  │                        │
  │ 6. Return data         │
  │◄───────────────────────┤
```

### Authorization Model

```python
# Permission classes
class IsOwnerOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user
```

### Security Layers

1. **Network Security**: HTTPS/TLS encryption
2. **Authentication**: Token-based authentication
3. **Authorization**: Object-level permissions
4. **Input Validation**: Serializer validation
5. **SQL Injection Protection**: Django ORM
6. **XSS Protection**: DRF built-in protection
7. **CSRF Protection**: Token-based API

## Performance Considerations

### Database Optimization

```python
# Eager loading with select_related
Recipe.objects.select_related('user').all()

# Prefetch many-to-many relationships
Recipe.objects.prefetch_related('tags', 'ingredients').all()

# Database indexing
class Meta:
    indexes = [
        models.Index(fields=['user', '-created_at']),
    ]
```

### Caching Strategy

```python
# Redis caching configuration
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
    }
}

# View-level caching
@cache_page(60 * 15)  # 15 minutes
def recipe_list(request):
    pass
```

### Query Optimization

```python
# Efficient filtering
def get_queryset(self):
    queryset = Recipe.objects.select_related('user')
    tags = self.request.query_params.get('tags')
    if tags:
        queryset = queryset.filter(tags__id__in=tags.split(','))
    return queryset
```

### File Upload Optimization

```python
# Image processing
def recipe_image_file_path(instance, filename):
    ext = os.path.splitext(filename)[1]
    filename = f'{uuid.uuid4()}{ext}'
    return os.path.join('uploads', 'recipe', filename)

# PIL optimization for images
def process_image(image):
    if image.size > (800, 600):
        image.thumbnail((800, 600), Image.ANTIALIAS)
    return image
```

## Deployment Architecture

### Containerization Strategy

```dockerfile
# Multi-stage build
FROM python:3.9-alpine3.13 as builder
# Build dependencies

FROM python:3.9-alpine3.13
# Runtime image
COPY --from=builder /app /app
```

### Container Orchestration

```yaml
# docker-compose.yml
version: '3.9'
services:
  app:
    build: .
    depends_on:
      - db
      - redis
    environment:
      - DATABASE_URL=postgresql://...
      - REDIS_URL=redis://...

  db:
    image: postgres:12-alpine

  redis:
    image: redis:6-alpine
```

### Scaling Considerations

```yaml
# Horizontal scaling
services:
  app:
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
```

### Health Checks

```python
# health_check/views.py
class HealthCheckView(APIView):
    def get(self, request):
        return Response({
            'status': 'healthy',
            'timestamp': timezone.now(),
            'database': self.check_database(),
            'cache': self.check_cache(),
        })
```

## Monitoring and Observability

### Logging Architecture

```python
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/var/log/django/app.log',
            'maxBytes': 1024*1024*15,  # 15MB
            'backupCount': 10,
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['file'],
        'level': 'INFO',
    },
}
```

### Metrics Collection

```python
# Custom middleware for metrics
class MetricsMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        start_time = time.time()
        response = self.get_response(request)
        duration = time.time() - start_time

        # Log metrics
        logger.info(f"Request {request.method} {request.path} - {response.status_code} - {duration}s")
        return response
```

## Future Architecture Considerations

### Microservices Migration

```
Current Monolith:
┌─────────────────────────────┐
│        Django App           │
│ ┌─────┐ ┌─────┐ ┌─────────┐ │
│ │User │ │Recipe│ │  Core   │ │
│ └─────┘ └─────┘ └─────────┘ │
└─────────────────────────────┘

Future Microservices:
┌─────────┐  ┌─────────┐  ┌─────────┐
│  User   │  │ Recipe  │  │  Media  │
│ Service │  │ Service │  │ Service │
└─────────┘  └─────────┘  └─────────┘
     │            │            │
     └────────────┼────────────┘
                  │
         ┌─────────▼─────────┐
         │   API Gateway     │
         └───────────────────┘
```

### Event-Driven Architecture

```python
# Future event system
class RecipeCreatedEvent:
    def __init__(self, recipe_id, user_id):
        self.recipe_id = recipe_id
        self.user_id = user_id
        self.timestamp = timezone.now()

# Event handlers
@receiver(post_save, sender=Recipe)
def handle_recipe_created(sender, instance, created, **kwargs):
    if created:
        event = RecipeCreatedEvent(instance.id, instance.user.id)
        event_bus.publish(event)
```

This architecture documentation provides a comprehensive overview of the system design and serves as a guide for developers working on the project.
