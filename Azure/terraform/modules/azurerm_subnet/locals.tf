locals {
  enabled = var.enabled
  e       = local.enabled && var.create_resource
  context = {
    enabled             = var.enabled
    namespace           = "subnet"
    tenant              = var.tenant == null ? data.azurerm_client_config.current.tenant_id : var.tenant
    environment         = var.environment
    stage               = var.stage
    name                = var.name
    location            = join("", module.region.*.location_cli)
    delimiter           = "."
    attributes          = compact(distinct(concat(coalesce(var.context.attributes, []), coalesce(var.attributes, ["azurerm_subnet"]))))
    tags                = merge(var.tags, local.default_tags)
    regex_replace_chars = var.regex_replace_chars
    label_order         = ["name", "namespace", "location"]
    id_length_limit     = 0
    label_key_case      = "lower"
    label_value_case    = "lower"
    labels_as_tags      = ["unset"]
  }

  location            = join("", module.region.*.location_cli)
  number_of_resources = length([var.max_resource_count]) > 0 ? var.max_resource_count : var.resource_count
  resource_count      = local.e ? local.number_of_resources : 0

  default_tags = {
    terraform_managed  = true,
    region             = join("", module.region.*.location_cli)
    tenant             = data.azurerm_client_config.current.tenant_id,
    deployment_date    = formatdate("DD-MM-YYYY hh:mm:ss", time_static.deploy_date.rfc3339),
    most_recent_change = formatdate("DD-MM-YYYY hh:mm:ss", timestamp())
  }

  # Dynamic subnet calculation
  existing_subnet_count     = local.e ? length(data.azurerm_virtual_network.default[0].subnets) : 0
  base_cidr_reservations    = (var.max_resource_count == 0 ? var.resource_count : var.max_resource_count) * var.resource_count
  cidr_reservations         = (local.e ? 1 : 0) * local.base_cidr_reservations
  supplied_ipv4_cidrs       = var.address_prefixes
  compute_ipv4_cidrs        = local.e && (length(local.supplied_ipv4_cidrs)) == 0
  required_ipv4_subnet_bits = local.e ? ceil(log(local.cidr_reservations, 2)) : 1
  need_vnet_data            = (local.compute_ipv4_cidrs && length(var.address_prefixes) == 0)
  base_ipv4_cidr_block      = length(var.address_prefixes) > 0 ? var.address_prefixes[0] : (local.need_vnet_data ? element(data.azurerm_virtual_network.default[0].address_space, 0) : "")
  ipv4_subnet_cidrs = local.compute_ipv4_cidrs ? [
    for net in range(0, local.cidr_reservations) : cidrsubnet(local.base_ipv4_cidr_block, local.required_ipv4_subnet_bits, net)
  ] : local.supplied_ipv4_cidrs

  subnet_names    = toset(azurerm_subnet.this.*.name)
  subnet_prefixes = toset(azurerm_subnet.this.*.address_prefixes)
}

resource "time_static" "deploy_date" {}

