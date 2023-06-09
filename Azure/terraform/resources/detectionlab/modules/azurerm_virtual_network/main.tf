resource "time_static" "deploy_date" {}

resource "azurerm_virtual_network" "this" {
  count               = local.e ? 1 : 0
  name                = module.label.id
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = module.label.tags
}