# Recipe App API

A RESTful API for managing recipes, ingredients, and tags built with Django REST Framework.

## Features

- **User Authentication**: Token-based authentication system
- **Recipe Management**: Create, read, update, and delete recipes
- **Ingredient Management**: Manage recipe ingredients
- **Tag System**: Organize recipes with tags
- **Image Upload**: Upload and manage recipe images
- **API Documentation**: Auto-generated API documentation with drf-spectacular
- **Filtering**: Filter recipes by tags and ingredients
- **Dockerized**: Fully containerized application with Docker and Docker Compose

## Tech Stack

- **Backend**: Django 4.0, Django REST Framework
- **Database**: PostgreSQL
- **Authentication**: Token Authentication
- **Documentation**: drf-spectacular (OpenAPI/Swagger)
- **Image Processing**: Pillow
- **Containerization**: Docker, Docker Compose
- **Web Server**: uWSGI (production)
- **Reverse Proxy**: Nginx (production)

## Project Structure

```
recipe-app-api/
├── app/                    # Django application
│   ├── app/               # Main Django project
│   │   ├── settings.py    # Django settings
│   │   ├── urls.py        # URL configuration
│   │   └── wsgi.py        # WSGI configuration
│   ├── core/              # Core app (models, admin)
│   │   ├── models.py      # Database models
│   │   ├── admin.py       # Admin interface
│   │   └── management/    # Custom management commands
│   ├── recipe/            # Recipe API app
│   │   ├── views.py       # API views
│   │   ├── serializers.py # API serializers
│   │   └── urls.py        # Recipe URLs
│   └── user/              # User API app
│       ├── views.py       # User API views
│       ├── serializers.py # User serializers
│       └── urls.py        # User URLs
├── proxy/                 # Nginx configuration
├── scripts/               # Deployment scripts
├── docker-compose.yml     # Development environment
├── docker-compose-deploy.yml # Production environment
└── Dockerfile            # Docker image configuration
```

## Quick Start

### Prerequisites

- Docker
- Docker Compose

### Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd recipe-app-api
   ```

2. **Build and run with Docker Compose**
   ```bash
   docker-compose up --build
   ```

3. **Access the application**
   - API: http://localhost:8005/
   - API Documentation: http://localhost:8005/api/docs/
   - Admin Interface: http://localhost:8005/admin/

4. **Create a superuser (optional)**
   ```bash
   docker-compose exec app python manage.py createsuperuser
   ```

### Production Deployment

1. **Use the production Docker Compose file**
   ```bash
   docker-compose -f docker-compose-deploy.yml up --build
   ```

2. **Set environment variables**
   ```bash
   export SECRET_KEY="your-secret-key"
   export DEBUG=0
   export DB_HOST="your-db-host"
   export DB_NAME="your-db-name"
   export DB_USER="your-db-user"
   export DB_PASS="your-db-password"
   ```

## API Endpoints

### Authentication
- `POST /api/user/create/` - Create a new user
- `POST /api/user/token/` - Obtain authentication token
- `PUT /api/user/me/` - Update user profile

### Recipes
- `GET /api/recipe/recipes/` - List all recipes
- `POST /api/recipe/recipes/` - Create a new recipe
- `GET /api/recipe/recipes/{id}/` - Retrieve a specific recipe
- `PUT /api/recipe/recipes/{id}/` - Update a recipe
- `DELETE /api/recipe/recipes/{id}/` - Delete a recipe
- `POST /api/recipe/recipes/{id}/upload-image/` - Upload recipe image

### Tags
- `GET /api/recipe/tags/` - List all tags
- `POST /api/recipe/tags/` - Create a new tag
- `GET /api/recipe/tags/{id}/` - Retrieve a specific tag
- `PUT /api/recipe/tags/{id}/` - Update a tag
- `DELETE /api/recipe/tags/{id}/` - Delete a tag

### Ingredients
- `GET /api/recipe/ingredients/` - List all ingredients
- `POST /api/recipe/ingredients/` - Create a new ingredient
- `GET /api/recipe/ingredients/{id}/` - Retrieve a specific ingredient
- `PUT /api/recipe/ingredients/{id}/` - Update an ingredient
- `DELETE /api/recipe/ingredients/{id}/` - Delete an ingredient

## API Usage Examples

### Create a User
```bash
curl -X POST http://localhost:8005/api/user/create/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "testpass123",
    "name": "Test User"
  }'
```

### Obtain Token
```bash
curl -X POST http://localhost:8005/api/user/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "testpass123"
  }'
```

### Create a Recipe
```bash
curl -X POST http://localhost:8005/api/recipe/recipes/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Token your-token-here" \
  -d '{
    "title": "Chocolate Cake",
    "time_minutes": 60,
    "price": "15.00",
    "description": "Delicious chocolate cake recipe",
    "link": "https://example.com/recipe",
    "tags": [{"name": "dessert"}],
    "ingredients": [{"name": "chocolate"}]
  }'
```

### Filter Recipes
```bash
# Filter by tags
curl "http://localhost:8005/api/recipe/recipes/?tags=dessert,cake"

# Filter by ingredients
curl "http://localhost:8005/api/recipe/recipes/?ingredients=chocolate,flour"
```

## Testing

Run the test suite with:

```bash
# Run all tests
docker-compose exec app python manage.py test

# Run specific app tests
docker-compose exec app python manage.py test core
docker-compose exec app python manage.py test recipe
docker-compose exec app python manage.py test user

# Run with coverage
docker-compose exec app python -m pytest --cov=.
```

## Database

The application uses PostgreSQL as the database. The database schema includes:

- **User**: Custom user model with email authentication
- **Recipe**: Recipe model with title, description, time, price, and image
- **Tag**: Tag model for categorizing recipes
- **Ingredient**: Ingredient model for recipe components

### Migrations

```bash
# Create migrations
docker-compose exec app python manage.py makemigrations

# Apply migrations
docker-compose exec app python manage.py migrate
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SECRET_KEY` | Django secret key | `changeme` |
| `DEBUG` | Debug mode (0 or 1) | `0` |
| `DB_HOST` | Database host | `db` |
| `DB_NAME` | Database name | `devdb` |
| `DB_USER` | Database user | `devuser` |
| `DB_PASS` | Database password | `changeme` |
| `ALLOWED_HOSTS` | Allowed hosts | `127.0.0.1` |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Development Guidelines

- Follow PEP 8 style guide
- Write tests for new features
- Update documentation as needed
- Use meaningful commit messages

## Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Ensure PostgreSQL container is running
   - Check database environment variables

2. **Permission Denied Errors**
   - Check file permissions in volume mounts
   - Ensure docker-user has proper permissions

3. **Static Files Not Loading**
   - Run `collectstatic` command
   - Check volume mounts for static files

### Logs

```bash
# View application logs
docker-compose logs app

# View database logs
docker-compose logs db

# Follow logs in real-time
docker-compose logs -f app
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Eduardo Trujillo - [Your Email]

Project Link: [https://github.com/yourusername/recipe-app-api](https://github.com/yourusername/recipe-app-api)
