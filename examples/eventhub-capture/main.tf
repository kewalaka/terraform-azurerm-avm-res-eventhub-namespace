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
For more information see <https://aka.ms/avm/telemetryinfo>.
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

# Get the current client details of the principal running terraform, used to apply RBAC permissions
data "azurerm_client_config" "this" {}

resource "azurerm_storage_account" "this" {
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "this" {
  name                  = "capture"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "this" {
  principal_id         = data.azurerm_client_config.this.object_id
  scope                = azurerm_storage_container.this.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
}

locals {
  event_hubs = {
    eh_capture_example = {
      namespace_name      = module.event_hub.resource.id
      partition_count     = 1
      message_retention   = 7
      resource_group_name = module.event_hub.resource.name

      capture_description = {
        enabled  = true
        encoding = "Avro"
        destination = {
          archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
          blob_container_name = azurerm_storage_container.this.name
          storage_account_id  = azurerm_storage_account.this.id
        }
      }
    }
    # Add more event hubs if needed
  }
}

module "event_hub" {
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
