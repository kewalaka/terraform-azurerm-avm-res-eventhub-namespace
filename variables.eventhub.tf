variable "event_hubs" {
  description = "Map of Azure Event Hubs configurations"
  type = map(object({
    partition_count   = number
    message_retention = number
    // Add more parameters if needed
  }))
  default = {}
}

