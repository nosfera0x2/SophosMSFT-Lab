module "resource_group" {
  source          = "../../modules/azurerm_resource_group"
  enabled         = var.enabled
  create_resource = var.create_resource_group
  name            = var.name
  environment     = var.environment
  stage           = var.stage
  location        = var.location
  tags            = var.tags
}

module "virtual_network" {
  source          = "../../modules/azurerm_virtual_network"
  enabled         = var.enabled
  create_resource = var.create_vnet
  name            = var.name
  environment     = var.environment
  stage           = var.stage
  resource_group  = var.resource_group_name
  address_space   = var.ipv4_address_space
  tags            = var.tags
  location        = var.location
}

module "subnet" {
  source             = "../../modules/azurerm_subnet"
  enabled            = var.enabled
  create_resource    = var.create_subnet
  resource_count     = var.resource_count
  max_resource_count = var.number_of_subnets
  virtual_network    = var.virtual_network_name
  resource_group     = var.resource_group_name
  environment        = var.environment
  stage              = var.stage
  address_prefixes   = var.address_prefixes
  tags               = var.tags
  location           = var.location
}