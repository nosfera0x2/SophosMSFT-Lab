data "azurerm_client_config" "current" {}

data "azurerm_resources" "default" {
  for_each = local.azurerm_resources
  name     = each.value.name
  type     = each.value.type
  required_tags = merge(
    local.context.tags,
    { namespace = each.value.tag }
  )
}

data "azurerm_resource_group" "default" {
  count = local.e ? 1 : 0
  name  = azurerm_resource_group.this[0].name
}

data "azurerm_virtual_network" "default" {
  count               = local.e ? 1 : 0
  name                = azurerm_virtual_network.this[0].name
  resource_group_name = azurerm_resource_group.this[0].name
}

data "http" "ip_whitelist" {
  url = "https://ifconfig.co/ip"
  request_headers = {
    Accept = "application/json"
  }
}