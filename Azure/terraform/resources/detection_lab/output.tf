output "resource_group" {
  value = {
    name = data.azurerm_resource_group.default[0].name
    id = data.azurerm_resources.resource_group[0].id
    location = module.resource_group.location
  }
}

output "virtual_network" {
  value = {
    name = try(data.azurerm_virtual_network.default[0].name, null)
   # id = data.azurerm_resources.vnet[0].resources[0].id
    location = module.virtual_network.location
  }
}

output "azurerm_resources" {
  value = {
    resources = {
        resource_group = try(data.azurerm_resources.resource_group[0].name, null)
        virtual_network = try(data.azurerm_resources.vnet, null)
      }
  }
}