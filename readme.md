# SHORTRACE Redirect Service

Módulo encargado de manejar redirecciones de URLs cortas usando AWS Lambda, API Gateway y DynamoDB.

## Endpoint

GET /{codigo}

## Tecnologías

- AWS Lambda
- API Gateway
- DynamoDB
- Terraform
- Node.js

## Ejemplo

GET /google

→ Redirect 302 a https://google.com