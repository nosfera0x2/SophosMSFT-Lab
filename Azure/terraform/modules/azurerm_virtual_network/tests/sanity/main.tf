provider "azurerm" {
  features {}
}
variable "virtual_network" {
  type = map(object({
    enabled         = optional(bool)
    create_resource = optional(bool)
    resource_count  = optional(number)
    resource_group  = optional(string)
    address_space   = list(string)
    name            = optional(string)
    environment     = optional(string)
    stage           = optional(string)
    location        = optional(string)
    tags            = optional(map(string))
  }))
}

resource "azurerm_resource_group" "this" {
  name     = "vnet_sanity_testRG"
  location = "Central US"
  tags = {
    test = "sanity"
  }
}

module "virtual_network" {
  source          = "../../"
  depends_on      = [azurerm_resource_group.this]
  for_each        = var.virtual_network
  enabled         = each.value.enabled
  create_resource = each.value.create_resource
  resource_count  = each.value.resource_count
  resource_group  = azurerm_resource_group.this.name
  address_space   = each.value.address_space
  name            = each.value.name
  environment     = each.value.environment
  stage           = each.value.stage
  location        = each.value.location
  tags = {
    test = "sanity"
  }
}

output "vnet" {
  value = module.virtual_network
}