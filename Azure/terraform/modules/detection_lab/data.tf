# azurerm_resource_group module: data.tf
## Default value for `var.tenant` is supplied via the azurerm_client_config data source.
data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "default" {
    count = local.e ? 1 : 0
    name = join("",azurerm_virtual_network.this.*.name)
    resource_group_name = join("", azurerm_resource_group.this.*.name)
}

data "azurerm_resource_group" "this" {
    depends_on = [azurerm_resource_group.this]
    name = var.name
}

data "azurerm_virtual_network" "this" {
    depends_on = [azurerm_virtual_network.this]
    name = var.name
    resource_group_name = data.azurerm_resource_group.this.name
}