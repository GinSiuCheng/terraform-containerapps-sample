terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {}

# Resource group 
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}