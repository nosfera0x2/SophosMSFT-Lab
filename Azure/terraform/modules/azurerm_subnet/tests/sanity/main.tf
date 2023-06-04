provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "subnet_sanity_testRG"
  location = "Central US"
  tags     = var.tags
}

output "azurerm_resource_group" {
  value = azurerm_resource_group.this
}

resource "azurerm_virtual_network" "this" {
  name                = "subnet_sanity_testVNET"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["192.168.0.0/16"]
  location            = "Central US"
  tags                = var.tags
}

output "azurerm_virtual_network" {
  value = azurerm_virtual_network.this
}

variable "subnet" {
  type = map(object({
    enabled            = optional(bool)
    create_resource    = optional(bool)
    resource_count     = optional(number)
    resource_group     = optional(string)
    max_resource_count = optional(number)
    virtual_network    = optional(string)
    address_prefixes   = optional(list(string))
    name               = optional(string)
    environment        = optional(string)
    stage              = optional(string)
    location           = optional(string)
    tags               = optional(map(string))
  }))
}

variable "tags" {
  type = map(string)
  default = {
    test = "sanity"
  }
}

module "subnet" {
  source             = "../../"
  depends_on         = [azurerm_resource_group.this, azurerm_virtual_network.this]
  for_each           = var.subnet
  enabled            = each.value.enabled
  create_resource    = each.value.create_resource
  resource_count     = each.value.resource_count
  max_resource_count = each.value.max_resource_count
  resource_group     = azurerm_resource_group.this.name
  virtual_network    = azurerm_virtual_network.this.name
  address_prefixes   = each.value.address_prefixes
  name               = each.value.name
  environment        = each.value.environment
  stage              = each.value.stage
  location           = each.value.location
  tags               = var.tags
}

output "subnet" {
  value = module.subnet
}