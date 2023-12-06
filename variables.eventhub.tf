variable "event_hubs" {
  description = "Map of Azure Event Hubs configurations"
  type = map(object({
    name                = string
    namespace_name      = string
    resource_group_name = string
    partition_count     = number
    message_retention   = number
    capture_description = object({
      enabled             = bool
      encoding            = string
      interval_in_seconds = optional(number)
      size_limit_in_bytes = optional(number)
      skip_empty_archives = optional(bool)
      destination = object({
        name                = string
        archive_name_format = string
        blob_container_name = string
        storage_account_id  = string
      })
    })
    status = string
    // Add more parameters if needed
  }))
  default = {}
}
