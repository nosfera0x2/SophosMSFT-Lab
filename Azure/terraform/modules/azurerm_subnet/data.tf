data "azurerm_client_config" "current" {}

data "azurerm_resources" "vnet" {
  count = local.e ? 1 : 0
  type  = "Microsoft.Network/virtualNetworks"
  required_tags = merge(
    { namespace = "vnet" },
    var.tags
  )
}

data "azurerm_resources" "resource_group" {
  count = local.e ? 1 : 0
  type  = "Microsoft.Resources/resourceGroups"
  required_tags = merge(
    { namespace = "rg" },
    var.tags
  )
}

data "azurerm_resource_group" "default" {
  count = local.e ? 1 : 0
  name  = data.azurerm_resources.resource_group[count.index].resources[count.index].name
}

data "azurerm_virtual_network" "default" {
  count               = local.e ? 1 : 0
  name                = data.azurerm_resources.vnet[count.index].resources[count.index].name
  resource_group_name = data.azurerm_resource_group.default[count.index].name
}

data "azurerm_subnet" "default" {
  count                = local.e ? length(data.azurerm_virtual_network.default[0].subnets) : 0
  name                 = element([for v in data.azurerm_virtual_network.default[count.index].subnets : v], count.index)
  virtual_network_name = data.azurerm_virtual_network.default[count.index].name
  resource_group_name  = data.azurerm_resource_group.default[count.index].name
}