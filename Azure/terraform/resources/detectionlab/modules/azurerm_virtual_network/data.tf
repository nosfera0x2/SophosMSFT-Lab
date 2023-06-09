data "azurerm_client_config" "current" {}

data "azurerm_resources" "default" {
  count = local.e ? 1 : 0
  name = var.resource_group_name
  type = "Microsoft.Resources/resourceGroups"
  required_tags = module.label.tags
}