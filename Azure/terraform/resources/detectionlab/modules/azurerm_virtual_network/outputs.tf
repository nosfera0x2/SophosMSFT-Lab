output "name" {
  value = join("", azurerm_virtual_network.this.*.name)
}

output "location" {
  value = join("", azurerm_virtual_network.this.*.location)
}