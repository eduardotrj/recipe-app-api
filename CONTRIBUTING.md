# Contributing to Recipe App API

We love your input! We want to make contributing to Recipe App API as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How to Contribute

### Reporting Bugs

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/yourusername/recipe-app-api/issues).

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description** of the suggested enhancement
- **Provide specific examples** to demonstrate the steps
- **Describe the current behavior** and **explain which behavior you expected to see instead**
- **Explain why this enhancement would be useful** to most Recipe App API users

### Pull Requests

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Development Setup

### Prerequisites

- Docker and Docker Compose
- Git
- Python 3.9+ (for local development)
- PostgreSQL (for local development without Docker)

### Setting up Development Environment

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/your-username/recipe-app-api.git
   cd recipe-app-api
   ```

2. **Create a development branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Start the development environment**
   ```bash
   docker-compose up --build
   ```

4. **Run migrations**
   ```bash
   docker-compose exec app python manage.py migrate
   ```

5. **Create a superuser (optional)**
   ```bash
   docker-compose exec app python manage.py createsuperuser
   ```

### Local Development Without Docker

1. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.dev.txt
   ```

3. **Set environment variables**
   ```bash
   export SECRET_KEY="your-secret-key"
   export DEBUG=1
   export DB_HOST=localhost
   export DB_NAME=recipeapp
   export DB_USER=postgres
   export DB_PASS=password
   ```

4. **Run migrations and start server**
   ```bash
   cd app
   python manage.py migrate
   python manage.py runserver
   ```

## Coding Standards

### Python Style Guide

We follow [PEP 8](https://www.python.org/dev/peps/pep-0008/) style guide with some modifications:

- Maximum line length: 88 characters (Black formatter default)
- Use 4 spaces for indentation
- Use double quotes for strings
- Use trailing commas in multi-line data structures

### Code Formatting

We use [Black](https://black.readthedocs.io/) for code formatting:

```bash
# Install black
pip install black

# Format code
black .

# Check formatting
black --check .
```

### Import Sorting

We use [isort](https://pycqa.github.io/isort/) for import sorting:

```bash
# Install isort
pip install isort

# Sort imports
isort .

# Check import sorting
isort --check-only .
```

### Linting

We use [flake8](https://flake8.pycqa.org/) for linting:

```bash
# Install flake8
pip install flake8

# Run linting
flake8 .
```

### Configuration Files

Create a `.flake8` file in the project root:
```ini
[flake8]
max-line-length = 88
extend-ignore = E203, E501, W503
exclude =
    migrations,
    __pycache__,
    manage.py,
    settings.py
```

Create a `pyproject.toml` file for Black and isort:
```toml
[tool.black]
line-length = 88
include = '\.pyi?$'
extend-exclude = '''
/(
  # directories
  migrations
  | __pycache__
)/
'''

[tool.isort]
profile = "black"
multi_line_output = 3
include_trailing_comma = true
force_grid_wrap = 0
use_parentheses = true
ensure_newline_before_comments = true
line_length = 88
skip_glob = ["*/migrations/*"]
```

## Testing

### Running Tests

```bash
# Run all tests
docker-compose exec app python manage.py test

# Run specific app tests
docker-compose exec app python manage.py test core
docker-compose exec app python manage.py test recipe
docker-compose exec app python manage.py test user

# Run with coverage
docker-compose exec app python -m pytest --cov=. --cov-report=html

# Run specific test
docker-compose exec app python manage.py test core.tests.test_models.UserModelTests.test_create_user
```

### Writing Tests

#### Test Structure

```python
from django.test import TestCase
from django.contrib.auth import get_user_model

User = get_user_model()


class UserModelTests(TestCase):
    """Test user model."""

    def test_create_user_with_email_successful(self):
        """Test creating a user with an email is successful."""
        email = 'test@example.com'
        password = 'testpass123'
        user = User.objects.create_user(
            email=email,
            password=password,
        )

        self.assertEqual(user.email, email)
        self.assertTrue(user.check_password(password))
```

#### API Test Structure

```python
from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status

User = get_user_model()


class RecipeAPITests(TestCase):
    """Test recipe API."""

    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='test@example.com',
            password='testpass123',
        )
        self.client.force_authenticate(self.user)

    def test_retrieve_recipes(self):
        """Test retrieving a list of recipes."""
        res = self.client.get('/api/recipe/recipes/')

        self.assertEqual(res.status_code, status.HTTP_200_OK)
```

### Test Coverage Requirements

- Minimum 80% test coverage for new code
- All new features must include tests
- All bug fixes must include regression tests

## Documentation

### Code Documentation

- Use docstrings for all classes and functions
- Follow [Google Style Python Docstrings](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings)

```python
def create_user(email, password=None, **extra_fields):
    """Create, save and return a new user.

    Args:
        email (str): User's email address.
        password (str, optional): User's password. Defaults to None.
        **extra_fields: Additional fields for the user model.

    Returns:
        User: The created user instance.

    Raises:
        ValueError: If email is not provided.
    """
```

### API Documentation

- Use drf-spectacular for API documentation
- Add schema descriptions for all endpoints
- Include example requests and responses

```python
@extend_schema(
    summary="Create a new recipe",
    description="Create a new recipe for the authenticated user.",
    request=RecipeSerializer,
    responses={
        201: RecipeDetailSerializer,
        400: "Bad Request",
        401: "Unauthorized"
    },
    examples=[
        OpenApiExample(
            'Recipe Creation Example',
            value={
                'title': 'Chocolate Cake',
                'time_minutes': 60,
                'price': '15.00'
            }
        )
    ]
)
def create(self, request):
    """Create a new recipe."""
```

## Git Workflow

### Branch Naming

- `feature/feature-name` - New features
- `bugfix/bug-description` - Bug fixes
- `hotfix/critical-fix` - Critical production fixes
- `refactor/component-name` - Code refactoring

### Commit Messages

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(recipe): add image upload functionality

fix(auth): resolve token expiration issue

docs(api): update authentication documentation

test(recipe): add tests for recipe filtering
```

### Pull Request Process

1. **Update documentation** for any new features
2. **Add tests** for all changes
3. **Run the test suite** and ensure all tests pass
4. **Update the README.md** if needed
5. **Request review** from maintainers

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass locally
- [ ] Added tests for new functionality
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings introduced
```

## Release Process

### Versioning

We use [Semantic Versioning](https://semver.org/):
- MAJOR version for incompatible API changes
- MINOR version for backwards-compatible functionality additions
- PATCH version for backwards-compatible bug fixes

### Release Checklist

1. Update version numbers
2. Update CHANGELOG.md
3. Create release branch
4. Run full test suite
5. Update documentation
6. Create release tag
7. Deploy to staging
8. Deploy to production

## Issue Templates

### Bug Report Template

```markdown
**Describe the bug**
A clear description of the bug.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
 - OS: [e.g. iOS]
 - Browser [e.g. chrome, safari]
 - Version [e.g. 22]

**Additional context**
Any other context about the problem.
```

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Other solutions you've considered.

**Additional context**
Any other context or screenshots about the feature request.
```

## Security

### Reporting Security Issues

Please do **NOT** create a public GitHub issue for security vulnerabilities. Instead:

1. Email security issues to [security@yourcompany.com]
2. Include detailed steps to reproduce
3. Wait for confirmation before disclosing publicly

### Security Guidelines

- Never commit secrets or sensitive data
- Use environment variables for configuration
- Keep dependencies updated
- Follow Django security best practices
- Use HTTPS in production
- Implement proper authentication and authorization

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Getting Help

- Read the documentation
- Search existing issues
- Ask questions in discussions
- Join our community chat

## Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Release notes
- Project website (if applicable)

Thank you for contributing to Recipe App API! 🎉
