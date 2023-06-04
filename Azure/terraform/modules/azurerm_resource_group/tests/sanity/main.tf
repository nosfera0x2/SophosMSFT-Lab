provider "azurerm" {
  features {}
}

module "resource_group" {
  source          = "../../"
  for_each        = var.resource_group
  enabled         = each.value.enabled
  create_resource = each.value.create_resource
  resource_count  = each.value.resource_count
  name            = each.value.name
  environment     = each.value.environment
  stage           = each.value.stage
  location        = each.value.location
  tags = {
    test = "sanity"
  }
}

variable "resource_group" {
  type = map(object({
    enabled         = optional(bool)
    create_resource = optional(bool)
    resource_count  = optional(number)
    name            = optional(string)
    environment     = optional(string)
    stage           = optional(string)
    location        = optional(string)
    tags            = optional(map(string))
  }))
}

output "resource_group" {
  value = module.resource_group
}