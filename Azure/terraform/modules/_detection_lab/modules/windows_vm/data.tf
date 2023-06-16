### BEGIN: data.tf ###
### BEGIN: azurerm_resource_group data ###
data "azurerm_resource_group" "default" {
  count = local.e ? 1 : 0
  name = azurerm_resource_group.this.name
}
### END: azurerm_resource_group data ###
### END: data.tf ###