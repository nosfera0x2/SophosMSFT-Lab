provider "azurerm" {
  features {}
}

locals {
  enabled   = true
  namespace = "rg"
  defaultList = {
    rg = {
      namespace   = "rg"
      tenant      = data.azurerm_client_config.current.tenant_id
      region      = local.region_map.location_cli
      attributes  = ["azurerm_resource_group"]
      label_order = ["name", "namespace", "stage", "environment", "tenant", "region"]
    },
    vnet = {
      namespace   = "vnet"
      tenant      = data.azurerm_client_config.current.tenant_id
      attributes  = ["azurerm_virtual_network"]
      label_order = ["name", "namespace", "environment", "region"]
    }
  }
  defaults = lookup(local.defaultList, local.namespace)

  region_map = {
    location       = join("", module.region.*.location)
    location_cli   = join("", module.region.*.location_cli)
    location_short = join("", module.region.*.location_short)
    location_slug  = join("", module.region.*.location_slug)
  }
}

data "azurerm_client_config" "current" {}

output "defaults" {
  value = local.defaults
}

module "region" {
  source       = "../../../azure_utils"
  count        = local.enabled ? 1 : 0
  azure_region = "Central US"
}