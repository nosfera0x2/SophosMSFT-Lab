provider "azurerm" {
  features {}
}

locals {
  #azurerm_resources = { for r in data.azurerm_resources.default : r.name => r }

  #subnets = flatten([
  #  for resource in keys(var.subnet-map) : [
  #    for subnet in var.subnet-map[resource] : {
  #      resource          = resource
  #      cidr_block        = subnet.cidr_block
  #      availability_zone = subnet.availability_zone
  #    }
  #  ]
  #])
  enabled             = true
  name                = element(data.azurerm_resources.default.resources.*.name, 0)
  resource_group_name = element(data.azurerm_resources.default.resources.*.resource_group_name, 0)

  address_space = data.azurerm_virtual_network.default.*.address_space

}

data "azurerm_resources" "default" {
  type = "Microsoft.Network/virtualNetworks"
  required_tags = {
    namespace = "vnet"
  }
}

data "azurerm_virtual_network" "default" {
  count               = local.enabled ? 1 : 0
  name                = data.azurerm_resources.default.resources[0].name
  resource_group_name = data.azurerm_resources.default.resources[0].resource_group_name
}

output "locals" {
  value = {
    name                = local.name
    resource_group_name = local.resource_group_name
    address_space       = local.address_space
  }
}




