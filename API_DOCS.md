# API Documentation

This document provides detailed information about the Recipe App API endpoints, request/response formats, and authentication.

## Base URL

Development: `http://localhost:8005/api/`
Production: `https://your-domain.com/api/`

## Authentication

The API uses Token-based authentication. Include the token in the Authorization header:

```
Authorization: Token your-token-here
```

## User Endpoints

### Create User
**POST** `/user/create/`

Create a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe"
}
```

**Response (201):**
```json
{
  "email": "user@example.com",
  "name": "John Doe"
}
```

### Obtain Token
**POST** `/user/token/`

Obtain authentication token for login.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "token": "your-auth-token-here"
}
```

### Get/Update User Profile
**GET/PUT** `/user/me/`

Retrieve or update the current user's profile.

**Headers:** `Authorization: Token your-token-here`

**Request Body (PUT):**
```json
{
  "name": "Updated Name",
  "password": "newpassword123"
}
```

## Recipe Endpoints

### List Recipes
**GET** `/recipe/recipes/`

Retrieve a list of recipes for the authenticated user.

**Headers:** `Authorization: Token your-token-here`

**Query Parameters:**
- `tags`: Comma-separated list of tag IDs to filter by
- `ingredients`: Comma-separated list of ingredient IDs to filter by

**Response (200):**
```json
[
  {
    "id": 1,
    "title": "Chocolate Cake",
    "time_minutes": 60,
    "price": "15.00",
    "link": "https://example.com/recipe",
    "tags": [
      {
        "id": 1,
        "name": "dessert"
      }
    ],
    "ingredients": [
      {
        "id": 1,
        "name": "chocolate"
      }
    ]
  }
]
```

### Create Recipe
**POST** `/recipe/recipes/`

Create a new recipe.

**Headers:** `Authorization: Token your-token-here`

**Request Body:**
```json
{
  "title": "Chocolate Cake",
  "time_minutes": 60,
  "price": "15.00",
  "description": "Delicious chocolate cake",
  "link": "https://example.com/recipe",
  "tags": [{"name": "dessert"}],
  "ingredients": [{"name": "chocolate"}]
}
```

### Get Recipe Details
**GET** `/recipe/recipes/{id}/`

Retrieve detailed information about a specific recipe.

**Headers:** `Authorization: Token your-token-here`

**Response (200):**
```json
{
  "id": 1,
  "title": "Chocolate Cake",
  "time_minutes": 60,
  "price": "15.00",
  "description": "A rich and moist chocolate cake...",
  "link": "https://example.com/recipe",
  "image": "http://localhost:8005/media/uploads/recipe/image.jpg",
  "tags": [
    {
      "id": 1,
      "name": "dessert"
    }
  ],
  "ingredients": [
    {
      "id": 1,
      "name": "chocolate"
    }
  ]
}
```

### Update Recipe
**PUT/PATCH** `/recipe/recipes/{id}/`

Update an existing recipe.

**Headers:** `Authorization: Token your-token-here`

**Request Body:**
```json
{
  "title": "Updated Chocolate Cake",
  "time_minutes": 75
}
```

### Delete Recipe
**DELETE** `/recipe/recipes/{id}/`

Delete a recipe.

**Headers:** `Authorization: Token your-token-here`

**Response:** `204 No Content`

### Upload Recipe Image
**POST** `/recipe/recipes/{id}/upload-image/`

Upload an image for a recipe.

**Headers:**
- `Authorization: Token your-token-here`
- `Content-Type: multipart/form-data`

**Request Body:**
```
image: [binary file data]
```

**Response (200):**
```json
{
  "id": 1,
  "image": "http://localhost:8005/media/uploads/recipe/image.jpg"
}
```

## Tag Endpoints

### List Tags
**GET** `/recipe/tags/`

Retrieve all tags for the authenticated user.

**Headers:** `Authorization: Token your-token-here`

**Query Parameters:**
- `assigned_only`: Set to `1` to only return tags assigned to recipes

**Response (200):**
```json
[
  {
    "id": 1,
    "name": "dessert"
  },
  {
    "id": 2,
    "name": "breakfast"
  }
]
```

### Create Tag
**POST** `/recipe/tags/`

Create a new tag.

**Headers:** `Authorization: Token your-token-here`

**Request Body:**
```json
{
  "name": "vegan"
}
```

### Update Tag
**PUT/PATCH** `/recipe/tags/{id}/`

Update an existing tag.

**Headers:** `Authorization: Token your-token-here`

**Request Body:**
```json
{
  "name": "updated-tag-name"
}
```

### Delete Tag
**DELETE** `/recipe/tags/{id}/`

Delete a tag.

**Headers:** `Authorization: Token your-token-here`

**Response:** `204 No Content`

## Ingredient Endpoints

### List Ingredients
**GET** `/recipe/ingredients/`

Retrieve all ingredients for the authenticated user.

**Headers:** `Authorization: Token your-token-here`

**Query Parameters:**
- `assigned_only`: Set to `1` to only return ingredients assigned to recipes

**Response (200):**
```json
[
  {
    "id": 1,
    "name": "chocolate"
  },
  {
    "id": 2,
    "name": "flour"
  }
]
```

### Create Ingredient
**POST** `/recipe/ingredients/`

Create a new ingredient.

**Headers:** `Authorization: Token your-token-here`

**Request Body:**
```json
{
  "name": "vanilla extract"
}
```

### Update Ingredient
**PUT/PATCH** `/recipe/ingredients/{id}/`

Update an existing ingredient.

**Headers:** `Authorization: Token your-token-here`

**Request Body:**
```json
{
  "name": "updated-ingredient-name"
}
```

### Delete Ingredient
**DELETE** `/recipe/ingredients/{id}/`

Delete an ingredient.

**Headers:** `Authorization: Token your-token-here`

**Response:** `204 No Content`

## Error Responses

### 400 Bad Request
```json
{
  "field_name": ["Error message describing the issue"]
}
```

### 401 Unauthorized
```json
{
  "detail": "Authentication credentials were not provided."
}
```

### 403 Forbidden
```json
{
  "detail": "You do not have permission to perform this action."
}
```

### 404 Not Found
```json
{
  "detail": "Not found."
}
```

### 500 Internal Server Error
```json
{
  "detail": "A server error occurred."
}
```

## Rate Limiting

The API implements rate limiting to prevent abuse:
- 1000 requests per hour for authenticated users
- 100 requests per hour for anonymous users

## Pagination

List endpoints support pagination with the following parameters:
- `page`: Page number (default: 1)
- `page_size`: Number of items per page (default: 20, max: 100)

**Response format:**
```json
{
  "count": 100,
  "next": "http://localhost:8005/api/recipe/recipes/?page=2",
  "previous": null,
  "results": [...]
}
```

## Interactive Documentation

Visit the interactive API documentation at:
- Swagger UI: `http://localhost:8005/api/docs/`
- ReDoc: `http://localhost:8005/api/redoc/`
- OpenAPI Schema: `http://localhost:8005/api/schema/`
