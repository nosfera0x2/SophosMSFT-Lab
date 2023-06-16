### BEGIN: main.tf ###
## Set static time for deployment date.
## Will be used in calculating lifecycle of provisioned resources.
resource "time_static" "deploy_date" {}
## Using terraform_data as data placeholders
resource "terraform_data" "this" {
  input = {
    resource_group  = data.azurerm_resources.default["resource_group"].name
    virtual_network = data.azurerm_resources.default["virtual_network"].name
  }
}
### BEGIN: Default Label Context definition ###
module "labels" {
  source          = "./modules/label"
  enabled         = module.this.enabled
  name            = var.name
  namespace       = "detectionlab"
  environment     = "azure"
  stage           = var.stage
  location        = var.location
  label_order     = ["name", "namespace", "environment", "location"]
  id_length_limit = 30
  context         = module.this.context
}
### END: Default Label Context definition ###
### BEGIN: Resource Group Creation ###
module "resource_group_label" {
  source     = "./modules/label"
  namespace  = "rg"
  attributes = ["azurerm_resource_group"]
  context    = module.labels.context
}
resource "azurerm_resource_group" "this" {
  count    = local.e ? 1 : 0
  name     = module.resource_group_label.id
  location = var.location
  tags     = module.resource_group_label.tags
}
### END: Resource Group Creation ###
### BEGIN: Virtual Network Creation ###
module "virtual_network_label" {
  source     = "./modules/label"
  namespace  = "vnet"
  attributes = ["azurerm_virtual_network"]
  context    = module.labels.context
}
resource "azurerm_virtual_network" "this" {
  count               = local.e ? 1 : 0
  name                = module.virtual_network_label.id
  resource_group_name = azurerm_resource_group.this[count.index].name
  location            = var.location
  address_space       = var.address_space
  tags                = module.virtual_network_label.tags
}
### END: Virtual Network Creation ###
### BEGIN: Subnet Creation ###
module "subnet_label" {
  source     = "./modules/label"
  namespace  = "subnet"
  attributes = ["azurerm_subnet"]
  context    = module.labels.context
}
resource "azurerm_subnet" "this" {
  count                = local.e ? var.subnet_count : 0
  name                 = format("${module.subnet_label.id}%02d", count.index + 1)
  resource_group_name  = azurerm_resource_group.this[0].name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [element(local.ipv4_subnet_cidrs, count.index)]
}
### END: Subnet Creation ###
### BEGIN: Network Security Group Creation ###
module "network_security_group_label" {
  source     = "./modules/label"
  namespace  = "nsg"
  attributes = ["azurerm_network_security_group"]
  context    = module.labels.context
}
resource "azurerm_network_security_group" "this" {
  count               = local.e ? 1 : 0
  name                = module.network_security_group_label.id
  resource_group_name = azurerm_resource_group.this[0].name
  location            = var.location
  dynamic "security_rule" {
    for_each = var.default_security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = var.trusted_ip == null ? local.default_trusted_ip : var.trusted_ip
      source_address_prefixes = local.ip_whitelist
      destination_address_prefix = azurerm_subnet.this[count.index].address_prefixes[count.index]
    }
  }
  tags = module.network_security_group_label.tags
}
### END: Network Security Group Creation ###
### BEGIN: Storage Account Creation ###
module "storage_account_label" {
  source          = "./modules/label"
  namespace       = "storage_account"
  delimiter       = ""
  id_length_limit = 24
  attributes      = ["azurerm_storage_account"]
  context         = module.labels.context
}
resource "azurerm_storage_account" "this" {
  # checkov:skip=BC_AZR_GENERAL_32: Ensure storage for critical data are encrypted with Customer Managed Key
  # checkov:skip=BC_AZR_GENERAL_38:Ensure that Storage Accounts use customer-managed key for encryption
  # checkov:skip=BC_AZR_LOGGING_4: Will add logging functionality later
  # checkov:skip=BC_AZR_STORAGE_2: min_tls_version is set to 1.2
  # checkov:skip=BC_AZR_NETWORKING_18: Ensure that Storage accounts disallow public access
  count                    = local.e ? 1 : 0
  name                     = module.storage_account_label.id
  resource_group_name      = azurerm_resource_group.this[0].name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  min_tls_version          = var.storage_account_min_tls_version
  tags                     = module.storage_account_label.tags
}
### END: Storage Account Creation ###
### BEGIN: public IP creation ###
module "public_ip_label" {
  source     = "./modules/label"
  namespace  = "pubIP"
  attributes = ["azurerm_public_ip"]
  context    = module.labels.context
}
resource "azurerm_public_ip" "this" {
  count               = local.e == true ? local.instance_count[0] : 0
  name                = format("${module.public_ip_label.id}%02d", count.index + 1)
  resource_group_name = azurerm_resource_group.this[count.index].name
  location            = var.location
  allocation_method   = var.public_ip_allocation_method
  tags                = module.public_ip_label.tags
}
### END: public IP creation ###
### BEGIN: Network Interface Creation ###
module "network_interface_label" {
  source     = "./modules/label"
  count      = local.e ? local.instance_count[0] : 0
  name       = format("${join("-", [var.name, var.role])}%02d", count.index + 1)
  namespace  = "nic"
  attributes = ["azurerm_network_interface"]
  tags       = { role = var.role }
  context    = module.labels.context
}

resource "azurerm_network_interface" "this" {
  # checkov:skip=BC_AZR_NETWORKING_36: Will investigate public IP association with network interfaces at a later date.
  count                = local.e == true ? local.instance_count[0] : 0
  depends_on           = [azurerm_subnet.this, azurerm_public_ip.this]
  name                 = module.network_interface_label[count.index].id
  resource_group_name  = azurerm_resource_group.this[0].name
  location             = var.location
  enable_ip_forwarding = var.enable_ip_forwarding
  dynamic "ip_configuration" {
    for_each = local.e == true ? [local.ip_config] : []
    iterator = ip
    content {
      name                          = ip.value.name
      subnet_id                     = azurerm_subnet.this[count.index].id
      private_ip_address_allocation = ip.value.private_ip_address_allocation
      private_ip_address_version    = ip.value.private_ip_address_version
      private_ip_address            = local.role == "domain_controller" ? cidrhost(azurerm_subnet.this[count.index].address_prefixes[count.index], count.index) : null
      public_ip_address_id          = azurerm_public_ip.this[count.index].id
      primary                       = ip.value.primary
    }
  }
  tags = module.network_interface_label[count.index].tags
}
### END: Network Interface Creation ###
### BEGIN: Virtual Machine Creation ###
module "windows_virtual_machine_label" {
  source          = "./modules/label"
  name            = local.computer_name[0]
  namespace       = "vm"
  id_length_limit = 13
  delimiter       = "-"
  attributes      = ["azurerm_windows_virtual_machine", "${var.role}"]
  tags            = { role = "${var.role}" }
  context         = module.labels.context
}
resource "azurerm_windows_virtual_machine" "this" {
  for_each = local.e ? { for vm in local.virtual_machine : format("%s-%02d", vm.computer_name, vm.instance_count + 1) => vm} : 0
}
### END: Virtual Machine Creation ###
### END: main.tf ###

