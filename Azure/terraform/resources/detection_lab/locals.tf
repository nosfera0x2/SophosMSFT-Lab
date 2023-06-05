locals {
  enabled = var.enabled
  e = local.enabled == true && var.create_resource_group == true && var.create_vnet == true

  azurerm_resources = {
    resource = {
      name = try(module.resource_group.name, null)
      type = "Microsoft.Resources/resourceGroups"
      tag = "rg"
    },
    resource = {
      name = try(module.virtual_network.name, null)
      type = "Microsoft.Network/virtualNetworks"
      tag = "vnet"
    }
  }
}