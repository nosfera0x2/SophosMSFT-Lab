resource "time_static" "deploy_date" {}

module "region" {
  count        = var.enabled ? 1 : 0
  source       = "../../modules/azure_utils"
  azure_region = var.location
}

module "label" {
  source           = "../../modules/label"
  for_each         = local.resource_labels
  enabled          = var.enabled
  namespace        = each.value.namespace
  tenant           = local.context.tenant
  environment      = var.environment
  stage            = var.stage
  name             = var.name
  location         = local.context.location
  delimiter        = each.value.delimiter
  attributes       = each.value.attributes
  tags             = local.context.tags
  label_order      = each.value.label_order
  label_key_case   = local.context.label_key_case
  label_value_case = local.context.label_value_case
}

resource "azurerm_resource_group" "this" {
  count    = local.e ? 1 : 0
  name     = module.label["resource_group"].id
  location = var.location
  tags     = module.label["resource_group"].tags
}

resource "azurerm_virtual_network" "this" {
  count               = local.e ? 1 : 0
  name                = module.label["virtual_network"].id
  resource_group_name = azurerm_resource_group.this[0].name
  location            = var.location
  address_space       = var.address_space
  tags                = module.label["virtual_network"].tags
}

resource "azurerm_subnet" "this" {
  count                = local.subnet_count
  name                 = format("${module.label["subnet"].id}%02s", count.index + 1)
  resource_group_name  = azurerm_resource_group.this[0].name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [element(local.ipv4_subnet_cidrs, count.index)]
}

resource "azurerm_network_security_group" "this" {
  count               = local.e ? 1 : 0
  name                = format("${module.label["network_security_group"].id}%02d", count.index + 1)
  resource_group_name = azurerm_resource_group.this[0].name
  location            = var.location
  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = local.ip_whitelist
      destination_address_prefix = azurerm_subnet.this[count.index].address_prefixes[count.index]
    }
  }
  tags = module.label["network_security_group"].tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count                     = local.subnet_count
  subnet_id                 = azurerm_subnet.this[count.index].id
  network_security_group_id = azurerm_network_security_group.this[0].id
}

resource "azurerm_storage_account" "this" {
  # checkov:skip=BC_AZR_STORAGE_2: ADD REASON
  # checkov:skip=BC_AZR_GENERAL_32: ADD REASON
  # checkov:skip=BC_AZR_GENERAL_38: ADD REASON
  # checkov:skip=BC_AZR_NETWORKING_18: ADD REASON
  # checkov:skip=BC_AZR_LOGGING_4: skip logging for storage account
  count                    = local.e ? 1 : 0
  name                     = module.label["storage_account"].id
  resource_group_name      = azurerm_resource_group.this[0].name
  location                 = var.location
  account_replication_type = var.account_replication_type
  account_tier             = var.account_tier
  min_tls_version          = var.min_tls_version
  tags                     = module.label["storage_account"].tags
}



