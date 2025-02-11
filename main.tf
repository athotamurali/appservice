provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  description = "The name of the resource group"
}

variable "location" {
  description = "Azure region"
}

variable "app_service_plan_name" {
  description = "Name of the app service plan"
}

variable "app_service_name" {
  description = "Name of the app service"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
}

variable "app_image" {
  description = "The Docker image for the app"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# App Service Plan
resource "azurerm_app_service_plan" "app_plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Azure App Service (Blue)
resource "azurerm_app_service" "app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id

  site_config {
    linux_fx_version = "DOCKER|${var.app_image}"
  }
}

# Deployment Slot (Green)
resource "azurerm_app_service_slot" "green_slot" {
  name                = "green"
  app_service_name    = azurerm_app_service.app.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id

  site_config {
    linux_fx_version = "DOCKER|${var.app_image}"
  }
}

