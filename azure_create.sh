#!/bin/bash

# Define variables for image names
BACKEND_IMAGE="kornzysiek/backend:latest"
FRONTEND_IMAGE="kornzysiek/frontend:latest"

# Create resource group
az group create --name nprog --location eastus

# Create Container App environment
az containerapp env create \
  --name nprog-env \
  --resource-group nprog \
  --location eastus

# Create backend app
az containerapp create \
  --name backend-app \
  --resource-group nprog \
  --environment nprog-env \
  --image $BACKEND_IMAGE \
  --target-port 5001 \
  --ingress internal

# Get backend FQDN
BACKEND_FQDN=$(az containerapp show \
  --name backend-app \
  --resource-group nprog \
  --query properties.configuration.ingress.fqdn \
  --output tsv)

# Create frontend app
az containerapp create \
  --name frontend-app \
  --resource-group nprog \
  --environment nprog-env \
  --image $FRONTEND_IMAGE \
  --target-port 5000 \
  --ingress external \
  --env-vars BACKEND_URL=https://$BACKEND_FQDN

# Get frontend FQDN
FRONTEND_FQDN=$(az containerapp show \
  --name frontend-app \
  --resource-group nprog \
  --query properties.configuration.ingress.fqdn \
  --output tsv)

# Display the application URL
echo "Your application is accessible at: https://$FRONTEND_FQDN"