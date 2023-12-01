resource "azurerm_eventhub" "example" {
  for_each = var.event_hubs

  name                = each.key
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group_name
  partition_count     = each.value.partition_count
  message_retention   = each.value.message_retention
}

