# Resource Group Name
resource_group_name = "blue-green-rg"

# Azure Location
location = "East US"

# App Service Plan Name
app_service_plan_name = "blue-green-plan"

# App Service Name (for the Blue slot)
app_service_name = "myapp-bluegreen"

# Azure Container Registry Name
acr_name = "myacrregistry"

# Docker Image name to be used for the App Service
app_image = "myacrregistry.azurecr.io/myapp:latest"
