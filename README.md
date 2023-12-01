<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-eventhub-namespace

This is a template repo for Event Hub resource in Azure.

Major version Zero (0.y.z) is for initial development. Anything MAY change at any time. A module SHOULD NOT be considered stable till at least it is major version one (1.0.0) or greater. Changes will always be via new versions being published and no changes will be made to existing published versions. For more details please go to <https://semver.org/>

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.71.0, < 4.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.71.0, < 4.0.0)

- <a name="provider_random"></a> [random](#provider\_random)

## Resources

The following resources are used by this module:

- [azurerm_eventhub.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) (resource)
- [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint_application_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) (resource)
- [azurerm_resource_group_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [azurerm_resource_group.parent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the this resource.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetryinfo.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_event_hubs"></a> [event\_hubs](#input\_event\_hubs)

Description: Map of Azure Event Hubs configurations

Type:

```hcl
map(object({
    partition_count   = number
    message_retention = number
    // Add more parameters if needed
  }))
```

Default: `{}`

### <a name="input_eventhub_local_authentication_enabled"></a> [eventhub\_local\_authentication\_enabled](#input\_eventhub\_local\_authentication\_enabled)

Description: Is SAS authentication enabled for the EventHub Namespace?

Type: `bool`

Default: `true`

### <a name="input_eventhub_namespace_auto_inflate_enabled"></a> [eventhub\_namespace\_auto\_inflate\_enabled](#input\_eventhub\_namespace\_auto\_inflate\_enabled)

Description: Is Auto Inflate enabled for the EventHub Namespace?

Type: `bool`

Default: `false`

### <a name="input_eventhub_namespace_capacity"></a> [eventhub\_namespace\_capacity](#input\_eventhub\_namespace\_capacity)

Description: Specifies the Capacity / Throughput Units for a Standard SKU namespace.  
Default capacity has a maximum of 2, but can be increased in blocks of 2 on a committed purchase basis.   
Defaults to 1.

Type: `number`

Default: `1`

### <a name="input_eventhub_namespace_dedicated_cluster_id"></a> [eventhub\_namespace\_dedicated\_cluster\_id](#input\_eventhub\_namespace\_dedicated\_cluster\_id)

Description: Specifies the ID of the EventHub Dedicated Cluster where this Namespace should be created.  Changing this forces a new resource to be created.

Type: `string`

Default: `null`

### <a name="input_eventhub_namespace_local_authentication_enabled"></a> [eventhub\_namespace\_local\_authentication\_enabled](#input\_eventhub\_namespace\_local\_authentication\_enabled)

Description: Is SAS authentication enabled for the EventHub Namespace? Defaults to `false`.

Type: `bool`

Default: `false`

### <a name="input_eventhub_namespace_maximum_throughput_units"></a> [eventhub\_namespace\_maximum\_throughput\_units](#input\_eventhub\_namespace\_maximum\_throughput\_units)

Description: Specifies the maximum number of throughput units when Auto Inflate is Enabled. Valid values range from 1 - 20.

Type: `number`

Default: `null`

### <a name="input_eventhub_namespace_sku"></a> [eventhub\_namespace\_sku](#input\_eventhub\_namespace\_sku)

Description: Defines which tier to use for the Event Hub Namespace. Valid options are Basic, Standard, and Premium.

Type: `string`

Default: `"Standard"`

### <a name="input_eventhub_namespace_zone_redundant"></a> [eventhub\_namespace\_zone\_redundant](#input\_eventhub\_namespace\_zone\_redundant)

Description: Specifies if the EventHub Namespace should be Zone Redundant (created across Availability Zones).

Type: `bool`

Default: `false`

### <a name="input_eventhub_network_rulesets"></a> [eventhub\_network\_rulesets](#input\_eventhub\_network\_rulesets)

Description: The network rule set configuration for the Container Registry.  
Requires Premium SKU.

- `default_action` - (Optional) The default action when no rule matches. Possible values are `Allow` and `Deny`. Defaults to `Deny`.
- `ip_rule` - (Optional) A list of IP rules in CIDR format. Defaults to `[]`.
  - `action` - Only "Allow" is permitted
  - `ip_mask` - The CIDR block from which requests will match the rule.
- `virtual_network_rule` - (Optional) When using with Service Endpoints, a list of subnet IDs to associate with the Container Registry. Defaults to `[]`.
  - `ignore_missing_virtual_network_service_endpoint` - Are missing virtual network service endpoints ignored?
  - `subnet_id` - The subnet id from which requests will match the rule.

Type:

```hcl
object({
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
```

Default: `null`

### <a name="input_eventhub_public_network_access_enabled"></a> [eventhub\_public\_network\_access\_enabled](#input\_eventhub\_public\_network\_access\_enabled)

Description: Is public network access enabled for the EventHub Namespace?

Type: `bool`

Default: `true`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location.

Type: `string`

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: The lock level to apply. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.

Type:

```hcl
object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
```

Default: `{}`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: n/a

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints)

Description: A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of this resource.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - The name of the IP configuration.
  - `private_ip_address` - The private IP address of the IP configuration.

Type:

```hcl
map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
    })), {})
    lock = optional(object({
      name = optional(string, null)
      kind = optional(string, "None")
    }), {})
    tags                                    = optional(map(any), null)
    subnet_resource_id                      = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
```

Default: `{}`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Is public network access enabled for the EventHub Namespace? Defaults to `false`.

Type: `bool`

Default: `false`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: n/a

Type: `map(any)`

Default: `{}`

### <a name="input_zone_redundant"></a> [zone\_redundant](#input\_zone\_redundant)

Description:  Specifies if the EventHub Namespace should be Zone Redundant (created across Availability Zones). Changing this forces a new resource to be created. Defaults to `true`.

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints)

Description: A map of private endpoints. The map key is the supplied input to var.private\_endpoints. The map value is the entire azurerm\_private\_endpoint resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->