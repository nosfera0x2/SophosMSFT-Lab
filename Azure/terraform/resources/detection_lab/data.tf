data "azurerm_resources" "resource_group" {
  count = var.create_resource_group ? 1 : 0
  name  = module.resource_group.name
  type  = "Microsoft.Resources/resourceGroups"
  required_tags = merge(
    { namespace = "rg" },
    var.tags
  )
}

data "azurerm_resources" "vnet" {
  count = var.create_vnet ? 1 : 0
  name = module.virtual_network.name
  type = "Microsoft.Network/virtualNetworks"
  required_tags = merge(
    { namespace = "vnet" },
    var.tags
  )
}

data "azurerm_resource_group" "default" {
  count = var.create_resource_group ? 1 : 0
  name = data.azurerm_resources.resource_group[count.index].name
}

data "azurerm_virtual_network" "default" {
  count = var.create_vnet ? 1 : 0
  name = data.azurerm_resources.vnet[count.index].resources[count.index].name
  resource_group_name = data.azurerm_resource_group.default[count.index].name
}


#data "azurerm_subnet" "default" {
#  count = var.create_subnet ? length(data.azurerm_virtual_network.default[0].subnets) : 0
#  name = element([ for v in data.azurerm_virtual_network.default[count.index].subnets : v], count.index)
#  virtual_network_name = data.azurerm_virtual_network.default[count.index].name
#  resource_group_name = data.azurerm_resource_group.default[count.index].name
#}