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

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
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

resource "azurerm_storage_account" "this" {
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "this" {
  name                  = "example-eventhub-capture"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "this" {
  principal_id         = "909224f2-bae6-48bd-9de7-52135d812691"
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
}


locals {
  event_hubs = {
    event_hub_capture = {
      name                = module.naming.eventhub.name_unique
      namespace_name      = module.event-hub.resource.id
      partition_count     = 4
      message_retention   = 7
      resource_group_name = module.event-hub.resource.name
      status              = "Active"

      capture_description = {
        enabled             = true
        encoding            = "Avro"
        interval_in_seconds = 300
        size_limit_in_bytes = 314572800
        skip_empty_archives = false

        destination = {
          name                = "EventHubArchive.AzureBlockBlob"
          archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
          blob_container_name = azurerm_storage_container.this.name
          storage_account_id  = azurerm_storage_account.this.id
        }
        // Add more default event hubs if needed
      }
    }
    // Add more default event hubs if needed
  }
}

# This is the module call
module "event-hub" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  # ...
  enable_telemetry    = var.enable_telemetry
  name                = module.naming.eventhub_namespace.name_unique
  resource_group_name = azurerm_resource_group.this.name

  event_hubs = local.event_hubs

  depends_on = [
    azurerm_role_assignment.this
  ]
}
