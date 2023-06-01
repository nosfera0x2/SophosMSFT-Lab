# azurerm_resource_group module: main.tf
# Collect region data
module "region" {
  source       = "../azure_utils"
  count        = var.enabled ? 1 : 0
  azure_region = var.region
}
# Create label context
module "this" {
  source             = "../context"
  enabled            = var.enabled
  name               = var.name
  environment        = var.environment
  stage              = var.stage
  label_key_case     = "lower"
  label_value_case   = "lower"
  tenant             = data.azurerm_client_config.current.tenant_id
  region             = local.region_map.location_cli
  tags               = var.tags
  additional_tag_map = var.additional_tag_map
}

# Create resource group label
module "labelRg" {
  source      = "../context"
  namespace   = var.defaults["rg"].namespace
  attributes  = var.defaults["rg"].attributes
  label_order = var.defaults["rg"].label_order
  context     = module.this.context
}

# Create resource group
resource "azurerm_resource_group" "this" {
  count    = local.e ? 1 : 0
  name     = module.labelRg["id"]
  location = var.region
  tags     = merge(
    module.labelRg.tags,
    var.tags
  )
}

# Create virtual network label
module "labelVnet" {
  source = "../context"
  context = module.this.context
  namespace = var.defaults["vnet"].namespace
  attributes = var.defaults["vnet"].attributes
  label_order = var.defaults["vnet"].label_order
}

# Create virtual network
resource "azurerm_virtual_network" "this" {
  count = local.e ? 1 : 0
  name = var.name
  resource_group_name = "${data.azurerm_resource_group.this.name}"
  location = var.region
  address_space = var.address_space
  tags = merge(
    module.labelVnet.tags,
    var.tags
  )
}

# Create subnet label
module "labelSubnet" {
  source = "../context"
  for_each = lookup(var.defaults, "subnet")
  context = module.this.context
  namespace = var.defaults["subnet"].namespace
  attributes = var.defaults["subnet"].attributes
  label_order = var.defaults["subnet"].label_order
}

resource "azurerm_subnet" "this" {
  count = local.e ? length(local.ipv4_subnet_cidrs) : 0
  name = format("%s%s%s","${var.name}%02d",count.index+1)
  virtual_network_name = "${data.azurerm_virtual_network.this.name}"
  resource_group_name = "${data.azurerm_virtual_network.this.name}"
  address_prefixes = ["${local.ipv4_subnet_cidrs[count.index]}"]
}


