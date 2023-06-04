data "azurerm_resources" "default" {
  count = local.enabled ? 1 : 0
  type  = "Microsoft.Network/virtualNetworks"
  required_tags = {
    namespace = "vnet"
  }
}

data "azurerm_virtual_network" "default" {
  count               = local.enabled ? 1 : 0
  name                = data.azurerm_resources.default[count.index].resources[count.index].name
  resource_group_name = data.azurerm_resources.default[count.index].resources[count.index].resource_group_name
}