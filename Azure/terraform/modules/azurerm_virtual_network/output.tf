output "name" {
  value = join("", azurerm_virtual_network.this.*.name)
}

output "id" {
  value = join("", azurerm_virtual_network.this.*.id)
}

output "location" {
  value = join("", azurerm_virtual_network.this.*.location)
}