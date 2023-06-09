output "name" {
  value = join("", azurerm_resource_group.this.*.name)
}

output "id" {
  value = data.azurerm_resources.default[0].id
}

output "location" {
  value = join("",azurerm_resource_group.this.*.location)
}