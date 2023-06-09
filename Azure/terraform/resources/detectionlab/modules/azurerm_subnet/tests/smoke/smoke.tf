locals {
    azurerm_resources = {
    resource_group = {
      name = var.resource_group_name
      type = "Microsoft.Resources/resourceGroups"
    },
    virtual_network = {
      name = var.virtual_network_name
      type = "Microsoft.Network/virtualNetworks"
    }
  }
}

variable "resource_group_name" {
  description = <<EOD
  The name of the resource group where the VNET will be created
  EOD
  type        = string
  default     = null
}

variable "virtual_network_name" {
  description = <<EOD
  The name of the VNET where the subnet will be created
  EOD
  type        = string
  default     = null
}

provider "azurerm" {
  features {}
}

data "azurerm_resources" "default" {
  for_each      = local.azurerm_resources
  name          = each.value.name
  type          = each.value.type
}

output "azurerm_resources" {
  value = data.azurerm_resources.default
}