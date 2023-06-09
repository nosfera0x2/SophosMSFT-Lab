resource "time_static" "deploy_date" {}

resource "azurerm_resource_group" "this" {
  count = local.e ? 1 : 0
  name = module.label.id
  location = var.location
  tags = module.label.tags
}