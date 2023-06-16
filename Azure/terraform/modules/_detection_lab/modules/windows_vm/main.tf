### BEGIN: main.tf ###
### BEGIN: local variable manipulation and merging with default values ###
# converting local.virtual_machine typle to map
resource "terraform_data" "vm" {
  for_each = { for k,v in local.virtual_machine : k => v }
  input = each.value
}
# merging var.virtual_machine_defaults with local.virtual_machine tuple to create a new map of values
resource "terraform_data" "merge" {
  for_each = { for k,v in local.virtual_machine : k => v }
  input = merge(terraform_data.vm[each.key].input,(lookup(var.virtual_machine_defaults,terraform_data.vm[each.key].input.role)))
}
# storing the merged map to terraform_data resource
resource "terraform_data" "azurerm_virtual_machine" {
  for_each = { for k,v in terraform_data.merge : k => v }
  input = each.value
  output = each.value
}
### END: local variable manipulation and merging with default values ###
### BEGIN: resource "time_static" ###
# setting static date for deployment
resource "time_static" "deploy_date" {}
### END: resource "time_static" ###
### BEGIN: module "label" ###
module "label" {
  source = "./modules/label"
  enabled = module.this.enabled
  name = var.name
  namespace = var.namespace
  environment = var.environment
  stage = var.stage
  location = var.location
  label_order = ["name", "namespace", "environment", "location", "tenant", "attributes"]
  id_length_limit = 30
  context = module.this.context
}
### END: module "label" ###
### BEGIN: azurerm_resource_group "this" ###
# label definitions for resource group
module "rg_label" {
  source = "./modules/label"
  namespace = "rg"
  attributes = ["azurerm_resource_group"]
  context = module.label.context
}
# resource definition for resource group
resource "azurerm_resource_group" "this" {
  count = local.e ? 1 : 0
  name = module.rg_label.id
  location = var.location
  tags = module.rg_label.tags
}
### END: azurerm_resource_group "this" ###
### BEGIN: azurerm_virtual_network "this" ###
# label definitions for virtual network
module "vnet_label" {
  source = "./modules/label"
  namespace = "vnet"
  attributes = ["azurerm_virtual_network"]
  context = module.label.context
}
# resource definition for virtual network
resource "azurerm_virtual_network" "this" {
  count = local.e ? 1 : 0
  name = module.vnet_label.id
  resource_group_name = local.resource_group_name
  location = local.resource_group_location
  address_space = var.address_space
  tags = module.vnet_label.tags
}
### END: azurerm_virtual_network "this" ###
### BEGIN: azurerm_subnet "this" ###
# label definitions for subnet
module "subnet_label" {
  source = "./modules/label"
  namespace = "subnet"
  attributes = ["azurerm_subnet"]
  context = module.label.context
}
# resource definitions for subnet
resource "azurerm_subnet" "this" {
  count = local.e ? local.number_of_subnets : 0
  name = format("%s%02d", module.subnet_label.id, count.index + 1)
  resource_group_name = local.resource_group_name
  location = local.resource_group_location
  virtual_network_name = local.virtual_network_name
  address_prefixes = [element(local.ipv4_subnet_cidrs, count.index)]
}
### END: azurerm_subnet "this" ###
### BEGIN: azurerm_network_security_group "this" ###
# label definitions for network security group
module "nsg_label" {
  source = "./modules/label"
  namespace = "nsg"
  attributes = ["azurerm_network_security_group"]
  context = module.label.context
}
# resource definitions for network security group
resource "azurerm_network_security_group" "this" {
  count = local.e ? 1 : 0
  name = module.nsg_label.id
  resource_group_name = local.resource_group_name
  location = local.resource_group_location
  dynamic "security_rule" {
    for_each = local.security_rules
    iterator = rule
    content {
      name = rule.value.name
      priority = rule.value.priority
      direction = rule.value.direction
      access = rule.value.access
      protocol = rule.value.protocol
      source_port_range = rule.value.source_port_range
      destination_port_range = rule.value.destination_port_range
      source_address_prefix = rule.value.source_address_prefix
      source_address_prefixes = local.ip_whitelist
      destination_address_prefix = rule.value.destination_address_prefix
    }
  }
}
### END: azurerm_network_security_group "this" ###
### BEGIN: azurerm_storage_account "this" ###
# label definitions for storage account
module "strg_label" {
  source = "./modules/label"
  namespace = "strg"
  delimiter = ""
  id_length_limit = 24
  attributes = ["azurerm_storage_account"]
  context = module.label.context
}
# resource definitions for storage account
resource "azurerm_storage_account" "this" {
  # checkov:skip=BC_AZR_GENERAL_32: Ensure storage for critical data are encrypted with Customer Managed Key
  # checkov:skip=BC_AZR_GENERAL_38:Ensure that Storage Accounts use customer-managed key for encryption
  # checkov:skip=BC_AZR_LOGGING_4: Will add logging functionality later
  # checkov:skip=BC_AZR_STORAGE_2: min_tls_version is set to 1.2
  # checkov:skip=BC_AZR_NETWORKING_18: Ensure that Storage accounts disallow public access
  count = local.e ? 1 : 0
  name = module.strg_label.id
  resource_group_name = local.resource_group_name
  location = local.resource_group_location
  account_tier = local.storage_account_tier
  account_replication_type = local.storage_account_replication_type
  tags = module.strg_label.tags
}
### END: azurerm_storage_account "this" ###
### BEGIN: azurerm_public_ip "this" ###
# label definitions for public ip
module "pip_label" {
  source = "./modules/label"
  namespace = "pip"
  attributes = ["azurerm_public_ip"]
  context = module.label.context
}
# resource definitions for public ip
resource "azurerm_public_ip" "this" {
  count = local.e == true ? local.instance_count : 0
  name = format("%s%02d", module.pip_label.id, count.index + 1)
  resource_group_name = local.resource_group_name
  location = local.resource_group_location
  allocation_method = local.public_ip_allocation_method
  tags = module.pip_label.tags
}
### END: azurerm_public_ip "this" ###
### BEGIN: azurerm_network_interface "this" ###
# label definitions for network interface
module "nic_label" {
  source = "./modules/label"
  namespace = "nic"
  attributes = ["azurerm_network_interface"]
  context = module.label.context
}
# resource definitions for network interface
resource "azurerm_network_interface" "this" {
  for_each = local.e == true ? {for index in range(local.instance_count)} : {}
  name = format("%s%02d", module.nic_label.id, each.key + 1)
  depends_on = [azurerm_subnet.this, azurerm_public_ip.this]
  resource_group_name = local.resource_group_name
  location = local.resource_group_location
  enable_ip_forwarding = local.enable_ip_forwarding
  dynamic "ip_configuration" {
    for_each = 
  }
}
### END: azurerm_network_interface "this" ###
resource "azurerm_windows_virtual_machine" "this" {
  for_each = local.e == true ? terraform_data.azurerm_virtual_machine : {}
}

### END: main.tf ###

resource "terraform_data" "this" {
  for_each = terraform_data.azurerm_virtual_machine
  input = each.value.input.input["admin_username"]
}