provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "blue-green-rg"
  location = "East US"
}

# App Service Plan
resource "azurerm_app_service_plan" "app_plan" {
  name                = "appserviceplan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Basic"
    size = "B1"
  }
}

# Main App Service (Production)
resource "azurerm_app_service" "app" {
  name                = "myapp-bluegreen"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id

  site_config {
    linux_fx_version = "DOCKER|nginx"  # Replace with your app's container
  }
}

# Blue Deployment Slot
resource "azurerm_app_service_slot" "blue" {
  name                = "blue"
  app_service_name    = azurerm_app_service.app.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Green Deployment Slot
resource "azurerm_app_service_slot" "green" {
  name                = "green"
  app_service_name    = azurerm_app_service.app.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Traffic Manager for Blue-Green Switching
resource "azurerm_traffic_manager_profile" "tm" {
  name                = "blue-green-traffic-manager"
  resource_group_name = azurerm_resource_group.rg.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "bluegreen-app"
    ttl          = 30
  }

  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "blue" {
  name                = "blue-endpoint"
  profile_id          = azurerm_traffic_manager_profile.tm.id
  target_resource_id  = azurerm_app_service_slot.blue.id
  endpoint_status     = "Enabled"
  priority            = 1
}

resource "azurerm_traffic_manager_endpoint" "green" {
  name                = "green-endpoint"
  profile_id          = azurerm_traffic_manager_profile.tm.id
  target_resource_id  = azurerm_app_service_slot.green.id
  endpoint_status     = "Enabled"
  priority            = 2
}
