data "azurerm_resources" "default" {
  for_each = local.azurerm_resources
  name = each.value.name
  type = each.value.type
  required_tags = merge(
    var.tags,
    { namespace = each.value.tag}
  )
}

#data "azurerm_resource_group" "default"{
#  count = var.create_resource_group ? 1 : 0
#  name = data.azurerm_resources.default[count.index].resource.resource_group_name
#}

#data "azurerm_resource_group" "default" {
#  count = var.create_resource_group ? 1 : 0
#  name = data.azurerm_resources.default["resource_group"].name
#}


#data "azurerm_subnet" "default" {
#  count = var.create_subnet ? length(data.azurerm_virtual_network.default[0].subnets) : 0
#  name = element([ for v in data.azurerm_virtual_network.default[count.index].subnets : v], count.index)
#  virtual_network_name = data.azurerm_virtual_network.default[count.index].name
#  resource_group_name = data.azurerm_resource_group.default[count.index].name
#}