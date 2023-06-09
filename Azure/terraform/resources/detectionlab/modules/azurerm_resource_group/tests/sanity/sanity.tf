provider "azurerm" {
  features {}
}

variable "resource" {
  type = map(object({
    enabled     = optional(bool)
    name        = optional(string)
    namespace   = optional(string)
    environment = optional(string)
    stage       = optional(string)
    location    = optional(string)
  }))
}

module "resource_group" {
  source      = "../../"
  for_each    = var.resource
  enabled     = each.value.enabled
  name        = each.value.name
  namespace   = each.value.namespace
  environment = each.value.environment
  stage       = each.value.stage
  location    = each.value.location
}

output "resource_group" {
  value = module.resource_group
}