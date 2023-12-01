data "azurerm_resource_group" "parent" {
  count = var.location == null ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_eventhub_namespace" "this" {
  name                          = var.name # calling code must supply the name
  resource_group_name           = var.resource_group_name
  location                      = try(data.azurerm_resource_group.parent[0].location, var.location)
  sku                           = var.eventhub_namespace_sku
  capacity                      = var.eventhub_namespace_capacity
  auto_inflate_enabled          = var.eventhub_namespace_auto_inflate_enabled
  dedicated_cluster_id          = var.eventhub_namespace_dedicated_cluster_id
  local_authentication_enabled  = var.eventhub_namespace_local_authentication_enabled
  maximum_throughput_units      = var.eventhub_namespace_maximum_throughput_units
  minimum_tls_version           = 1.2
  public_network_access_enabled = var.public_network_access_enabled

  zone_redundant = var.eventhub_namespace_zone_redundant

  dynamic "identity" {
    for_each = var.managed_identities != null ? { this = var.managed_identities } : {}
    content {
      type         = identity.value.system_assigned && length(identity.value.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(identity.value.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }


  dynamic "network_rulesets" {
    for_each = var.eventhub_network_rulesets != null ? { this = var.eventhub_network_rulesets } : {}
    content {
      default_action                 = network_rule_sets.value.default_action
      public_network_access_enabled  = network_rule_sets.value.public_network_access_enabled
      trusted_service_access_enabled = network_rule_sets.value.trusted_service_access_enabled

      dynamic "ip_rule" {
        for_each = network_rulesets.value.ip_rule
        content {
          action  = ip_rule.value.action
          ip_mask = ip_rule.value.ip_mask
        }
      }
      dynamic "virtual_network_rule" {
        for_each = network_rulesets.value.virtual_network_rule
        content {
          ignore_missing_virtual_network_service_endpoint = virtual_network_rule.value.ignore_missing_virtual_network_service_endpoint
          subnet_id                                       = virtual_network_rule.value.subnet_id
        }
      }
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.eventhub_namespace_maximum_throughput_units == null && !var.eventhub_namespace_auto_inflate_enabled
      error_message = "Cannot set MaximumThroughputUnits property if AutoInflate is not enabled."
    }

  }
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count      = var.lock.kind != "None" ? 1 : 0
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azurerm_eventhub_namespace.this.id
  lock_level = var.lock.kind
}

resource "azurerm_role_assignment" "this" {
  for_each                               = var.role_assignments
  scope                                  = azurerm_eventhub_namespace.this.id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  principal_id                           = each.value.principal_id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
}
