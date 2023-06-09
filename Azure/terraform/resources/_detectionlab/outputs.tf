#output "outputs" {
#  value = {
#    "microsoft_detections_lab" = {
#      deployment_date = local.default_tags.deployment_date,
#      resource_group = {
#        name = join("", azurerm_resource_group.this.*.name)
#        id   = data.azurerm_resources.default["resource_group"].id
#      },
#      location = join("", azurerm_resource_group.this.*.location),
#      virtual_network = {
#        name = join("", azurerm_virtual_network.this.*.name)
#        id   = join("", azurerm_virtual_network.this.*.id)
#      },
#      subnets = local.subnet_output
#    }
#  }
#}

output "resource_group_name" {
  value = join("",azurerm_resource_group.this.*.name)
}

output "resource_group_id" {
  value = data.azurerm_resources.default["resource_group"].id
}

output "virtual_network_name" {
  value = join("",azurerm_virtual_network.this.*.name)
}
output "virtual_network_id" {
  value = data.azurerm_resources.default["virtual_network"].id
}

output "address_prefixes" {
  value = azurerm_subnet.this.*.address_prefixes
}

output "security_group_name" {
  value = join("",azurerm_network_security_group.this.*.name)
}

output "security_rules" {
  value = "${azurerm_network_security_group.this.*.security_rule}"
}
