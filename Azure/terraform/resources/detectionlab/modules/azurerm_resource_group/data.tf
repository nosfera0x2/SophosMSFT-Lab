data "azurerm_client_config" "current" {}

data "azurerm_resources" "default" {
  count = local.e ? 1 : 0
  name = module.label.id
  type = "Microsoft.Resources/resourceGroups"
  required_tags = module.label.tags
}