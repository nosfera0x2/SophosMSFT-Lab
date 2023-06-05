module "region" {
  count        = var.enabled ? 1 : 0
  source       = "../azure_utils"
  azure_region = var.location
}

module "label" {
  source  = "../label"
  context = local.context
}

resource "azurerm_subnet" "this" {
  count                = local.resource_count
  name                 = format("${module.label.id}-%02d", count.index + 1)
  resource_group_name  = var.resource_group
  virtual_network_name = var.virtual_network
  address_prefixes     = [element(local.ipv4_subnet_cidrs, count.index)]
}