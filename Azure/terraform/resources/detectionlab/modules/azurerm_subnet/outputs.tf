output "name" {
  value = join("", azurerm_subnet.this.*.name)
}

#output "id" {
#  value = data.azurerm_resources.default
#}

#output "location" {
#  value = join("", azurerm_subnet.this.*.location)
#}

#output "azurerm_resources" {
#  value = data.azurerm_resources.default
#}

output "azurerm_resources" {
  value = data.azurerm_resources.default
}