output "azurerm_resources" {
  value = {
    resources = {
      resource_group = data.azurerm_resources.resource_group
    }
  }
}