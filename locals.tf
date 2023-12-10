locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}

# Private endpoint application security group associations
# Remove if this resource does not support private endpoints
locals {
  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
}

locals {
  event_hub_role_assignments = { for ra in flatten([
    for sk, sv in var.event_hubs : [
      for rk, rv in sv.role_assignments : {
        event_hub_key   = sk
        ra_key          = rk
        role_assignment = rv
      }
    ]
  ]) : "${ra.event_hub_key}-${ra.ra_key}" => ra }
}
