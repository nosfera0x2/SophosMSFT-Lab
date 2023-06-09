resource "time_static" "deploy_date" {}

resource "azurerm_subnet" "this" {
  count                = var.subnet_count
  name                 = format("${module.label.id}%02d", count.index + 1)
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [element(local.ipv4_subnet_cidrs, count.index)]
}