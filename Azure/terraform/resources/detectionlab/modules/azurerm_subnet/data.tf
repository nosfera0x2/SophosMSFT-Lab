data "azurerm_client_config" "current" {}

data "azurerm_resources" "default" {
  for_each      = local.azurerm_resources
  name          = each.value.name
  type          = each.value.type
  required_tags = module.label.tags
}

data "azurerm_resource_group" "default" {
  count = local.e ? 1 : 0
  name  = try(data.azurerm_resources.default["resource_group"].name, var.resource_group_name, null)
}

data "azurerm_virtual_network" "default" {
  count               = local.e ? 1 : 0
  name                = try(data.azurerm_resources.default["virtual_network"].name, var.virtual_network_name, null)
  resource_group_name = try(data.azurerm_resource_group.default[0].name, data.azurerm_resources.default["resource_group"].name, var.resource_group_name, null)
}
