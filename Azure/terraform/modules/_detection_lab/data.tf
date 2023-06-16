### BEGIN: data.tf ###
## Current AzureRM client configuration
data "azurerm_client_config" "current" {}

## Collecting resource data via Resource Group and Virtual Network types
data "azurerm_resources" "default" {
  for_each      = local.azurerm_resources
  name          = each.value.name
  type          = each.value.type
  required_tags = module.labels.tags
}
### BEGIN: ip whitelist data ###
data "http" "ip_whitelist" {
  url = "https://ifconfig.co/ip"
  request_headers = {
    Accept = "application/json"
  }
}
### END: ip whitelist data ###
### BEGIN: resource group data ###
data "azurerm_resource_group" "default" {
  count = local.e ? 1 : 0
  name  = azurerm_resource_group.this[0].name
}
### END: resource group data ###
### BEGIN: virtual network data ###
data "azurerm_virtual_network" "default" {
  count               = local.e ? 1 : 0
  name                = azurerm_virtual_network.this[0].name
  resource_group_name = azurerm_resource_group.this[0].name
}
### END: virtual network data ###
### BEGIN: platform image data ###
data "azurerm_platform_image" "win_server" {
  count     = (local.e == true && local.vm.win_server == true) ? 1 : 0
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2016-Datacenter"
  location  = var.location
}
data "azurerm_platform_image" "win_desktop" {
  count     = (local.e == true && local.vm.win_server == false) ? 1 : 0
  publisher = "WindowsDesktop"
  offer     = "Windows-10"
  sku       = "19h1-pro"
  location  = var.location
}
### END: platform image data ###
### END: data.tf ###