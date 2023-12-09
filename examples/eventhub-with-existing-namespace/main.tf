terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name_unique
  location = "australiaeast"
}

resource "azurerm_eventhub_namespace" "this" {
  name                = module.naming.eventhub.name_unique
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"
}

locals {
  event_hubs = {
    event_hub_existing_namespace = {
      namespace_name      = module.event-hub.resource.id
      partition_count     = 2
      message_retention   = 3
      resource_group_name = module.event-hub.resource.name
    }
    // Add more event hubs if needed
  }
}

module "event-hub" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  # ...
  enable_telemetry         = false
  existing_parent_resource = { name = azurerm_eventhub_namespace.this.name }
  name                     = module.naming.eventhub_namespace.name_unique
  resource_group_name      = azurerm_resource_group.this.name

  event_hubs = local.event_hubs
}
