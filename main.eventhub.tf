resource "azurerm_eventhub" "example" {
  for_each = var.event_hubs

  name                = each.key
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group_name
  partition_count     = each.value.partition_count
  message_retention   = each.value.message_retention
  status              = each.value.status

  capture_description {
    enabled             = each.value.capture_description.enabled
    encoding            = each.value.capture_description.encoding
    interval_in_seconds = each.value.capture_description.interval_in_seconds
    size_limit_in_bytes = each.value.capture_description.size_limit_in_bytes
    skip_empty_archives = each.value.capture_description.skip_empty_archives

    destination {
      name                = each.value.capture_description.destination.name
      archive_name_format = each.value.capture_description.destination.archive_name_format
      blob_container_name = each.value.capture_description.destination.blob_container_name
      storage_account_id  = each.value.capture_description.destination.storage_account_id
    }
  }
}

