data "azurerm_resources" "resource_group" {
  count = local.e ? 1 : 0
  name = try(module.detection_lab.resource_group.name, null)
  type = "Microsoft.Resources/resourceGroups"
  required_tags = merge(
    { namespace = "rg" },
    var.tags
  )
}