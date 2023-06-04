# azurerm_resource_group module: main.tf
module "region" {
  count        = var.enabled ? 1 : 0
  source       = "../azure_utils"
  azure_region = var.location
}

module "label" {
  source  = "../label"
  context = local.context
}

resource "azurerm_resource_group" "this" {
  count    = local.e ? local.resource_count : 0
  name     = format("${module.label.id}%02d", count.index + 1)
  location = local.location
  tags     = module.label.tags
}
