provider "azurerm" {
  features {}
}

locals {
  number_of_subnets = length(data.azurerm_virtual_network.default.subnets)
  subnet_names      = [for v in data.azurerm_virtual_network.default.subnets : v]
}

output "locals" {
  value = {
    number_of_subnets = local.number_of_subnets
    subnet_names      = local.subnet_names
  }
}

data "azurerm_resources" "default" {
  type = "Microsoft.Network/virtualNetworks"
  required_tags = {
    test = "sanity"
  }
}

data "azurerm_virtual_network" "default" {
  name                = "subnet_sanity_testVNET"
  resource_group_name = "subnet_sanity_testRG"
}

data "azurerm_subnet" "default" {
  count                = length(data.azurerm_virtual_network.default.subnets)
  name                 = element([for v in data.azurerm_virtual_network.default.subnets : v], count.index)
  virtual_network_name = data.azurerm_virtual_network.default.name
  resource_group_name  = data.azurerm_virtual_network.default.resource_group_name
}

output "azurerm_subnet" {
  value = data.azurerm_subnet.default
}