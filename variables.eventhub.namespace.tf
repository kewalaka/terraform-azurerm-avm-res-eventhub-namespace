variable "eventhub_namespace_sku" {
  description = "Defines which tier to use for the Event Hub Namespace. Valid options are Basic, Standard, and Premium."
  type        = string
  default     = "Standard" # You can set a default value or leave it blank depending on your requirements
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.eventhub_namespace_sku)
    error_message = "The default_action value must be either `Basic`, `Standard`, or `Premium`."
  }
}

variable "eventhub_namespace_capacity" {
  description = <<DESCRIPTION
Specifies the Capacity / Throughput Units for a Standard SKU namespace.
Default capacity has a maximum of 2, but can be increased in blocks of 2 on a committed purchase basis.
Defaults to 1.
DESCRIPTION
  type        = number
  default     = 1
}

variable "eventhub_namespace_auto_inflate_enabled" {
  description = "Is Auto Inflate enabled for the EventHub Namespace?"
  type        = bool
  default     = false
}

variable "eventhub_namespace_dedicated_cluster_id" {
  description = "Specifies the ID of the EventHub Dedicated Cluster where this Namespace should be created.  Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "eventhub_namespace_maximum_throughput_units" {
  description = "Specifies the maximum number of throughput units when Auto Inflate is Enabled. Valid values range from 1 - 20."
  type        = number
  default     = null

  validation {
    condition     = var.eventhub_namespace_maximum_throughput_units == null ? true : var.eventhub_namespace_maximum_throughput_units < 1 || var.eventhub_namespace_maximum_throughput_units > 20
    error_message = "Maximum throughput units must be in the range of 1 to 20"
  }
}

variable "eventhub_namespace_zone_redundant" {
  description = "Specifies if the EventHub Namespace should be Zone Redundant (created across Availability Zones). Changing this forces a new resource to be created. Defaults to `true`."
  type        = bool
  default     = true
}

variable "eventhub_namespace_local_authentication_enabled" {
  description = "Is SAS authentication enabled for the EventHub Namespace?.  Defaults to `false`."
  type        = bool
  default     = false
}

variable "eventhub_namespace_public_network_access_enabled" {
  description = "Is public network access enabled for the EventHub Namespace?  Defaults to `false`."
  type        = bool
  default     = false
}

variable "eventhub_network_rulesets" {
  type = object({
    default_action = optional(string, "Deny")
    ip_rule = optional(list(object({
      # since the `action` property only permits `Allow`, this is hard-coded.
      action  = optional(string, "Allow")
      ip_mask = string
    })), [])
    virtual_network_rule = optional(list(object({
      # since the `action` property only permits `Allow`, this is hard-coded.
      ignore_missing_virtual_network_service_endpoint = optional(bool)
      subnet_id                                       = string
    })), [])
  })
  default = null
  validation {
    condition     = var.eventhub_network_rulesets == null ? true : contains(["Allow", "Deny"], var.eventhub_network_rulesets.default_action)
    error_message = "The default_action value must be either `Allow` or `Deny`."
  }
  description = <<DESCRIPTION
The network rule set configuration for the Container Registry.
Requires Premium SKU.

- `default_action` - (Optional) The default action when no rule matches. Possible values are `Allow` and `Deny`. Defaults to `Deny`.
- `ip_rule` - (Optional) A list of IP rules in CIDR format. Defaults to `[]`.
  - `action` - Only "Allow" is permitted
  - `ip_mask` - The CIDR block from which requests will match the rule.
- `virtual_network_rule` - (Optional) When using with Service Endpoints, a list of subnet IDs to associate with the Container Registry. Defaults to `[]`.
  - `ignore_missing_virtual_network_service_endpoint` - Are missing virtual network service endpoints ignored?
  - `subnet_id` - The subnet id from which requests will match the rule.

DESCRIPTION
}
