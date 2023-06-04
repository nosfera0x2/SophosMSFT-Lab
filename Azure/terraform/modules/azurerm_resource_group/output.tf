output "name" {
  value = join("", azurerm_resource_group.this.*.name)
}

output "id" {
  value = join("", azurerm_resource_group.this.*.id)
}

output "location" {
  value = join("", azurerm_resource_group.this.*.location)
}