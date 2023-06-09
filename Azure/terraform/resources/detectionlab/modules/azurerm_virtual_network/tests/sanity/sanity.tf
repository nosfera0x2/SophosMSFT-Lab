provider "azurerm" {
  features {}
}

variable "resource" {
  type = map(object({
    enabled             = optional(bool)
    name                = optional(string)
    namespace           = optional(string)
    environment         = optional(string)
    stage               = optional(string)
    location            = optional(string)
    address_space       = optional(list(string))
    resource_group_name = optional(string)
  }))
}

module "rg" {
  source      = "../../../azurerm_resource_group"
  for_each    = var.resource
  enabled     = each.value.enabled
  name        = each.value.name
  namespace   = each.value.namespace
  environment = each.value.environment
  stage       = each.value.stage
  location    = each.value.location
}

output "rg" {
  value = module.rg["resource"].name
}

module "vnet" {
  source              = "../../"
  for_each            = var.resource
  enabled             = each.value.enabled
  name                = each.value.name
  namespace           = each.value.namespace
  environment         = each.value.environment
  stage               = each.value.stage
  location            = each.value.location
  address_space       = each.value.address_space
  resource_group_name = module.rg["resource"].name
}

output "vnet" {
  value = module.vnet
}