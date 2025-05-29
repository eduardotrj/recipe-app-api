# recipe-app-api
Recipe API project:

## Description:
API to control an Application where users can create their recipes and organise based on tags and ingredients.

## Functions:
- Create/Read/Update/Delete Users
  - Email: String
  - Name: String
  - Is Active: Bool
  - Is Staff: Bool
- Create/Read/Update/Delete Recipes
  - Title: String
  - Time to prepare: Int
  - Price: Decimals
  - Link: String
  - Tags: String list
  - Ingredients: String list
  - Description: String (text)
  - Image: Media file
- Create/Read/Update/Delete Ingredients
- Create/Read/Update/Delete Tags
- Select recipes by ingredients
- Select recipes by tags

## Applications and Tools
- Django
- Django REST Framework
- Django Test Framework
- PostgreSQL
- Docker
- Docker-Compose
- DRF-Spectacular
- Swagger
- GitHub Actions
- nginx
- uWSGI

## Characteristics:
- 19 API Endpoints
- User Authentication
- Browsable Admin Interface
- Interactive API documentation
- Container environment
- Designed and prepared for deployment on AWS EC2 Server.
