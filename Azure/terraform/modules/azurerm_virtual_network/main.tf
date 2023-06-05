module "region" {
  count        = var.enabled ? 1 : 0
  source       = "../azure_utils"
  azure_region = var.location
}

module "label" {
  source  = "../label"
  context = local.context
}

resource "azurerm_virtual_network" "this" {
  count               = local.e ? local.resource_count : 0
  name                = format("${module.label.id}%02d", count.index + 1)
  resource_group_name = var.resource_group
  location            = var.location
  address_space       = var.address_space
  tags                = module.label.tags
}