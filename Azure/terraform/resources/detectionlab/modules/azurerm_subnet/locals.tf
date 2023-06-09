locals {
  enabled = module.this.enabled
  e       = local.enabled

  default_tags = {
    terraform_managed  = true,
    region             = var.location,
    tenant             = try(var.tenant, data.azurerm_client_config.current.tenant_id),
    deployment_date    = formatdate("DD-MM-YYYY hh:mm:ss", time_static.deploy_date.rfc3339),
    most_recent_change = formatdate("DD-MM-YYYY hh:mm:ss", timestamp())
  }

  tags = merge(
    var.tags,
    local.default_tags
  )

  azurerm_resources = {
    resource_group = {
      name = data.azurerm_resources.default["resource_group"].name
      type = "Microsoft.Resources/resourceGroups"
    },
    virtual_network = {
      name = data.azurerm_resources.default["virtual_network"].name
      type = "Microsoft.Network/virtualNetworks"
    }
  }

  ## Begin Dynamic subnet calculation ##
  number_of_subnets         = length([var.max_subnet_count]) > 0 ? var.max_subnet_count : var.subnet_count
  subnet_count              = local.e ? local.number_of_subnets : 0
  existing_subnet_count     = local.e ? length(data.azurerm_virtual_network.default[0].subnets) : 0
  base_cidr_reservations    = (var.max_subnet_count == 0 ? var.subnet_count : var.max_subnet_count) * var.subnet_count
  cidr_reservations         = (local.e ? 1 : 0) * local.base_cidr_reservations
  supplied_ipv4_cidrs       = var.address_prefixes
  compute_ipv4_cidrs        = local.e && (length(local.supplied_ipv4_cidrs)) == 0
  required_ipv4_subnet_bits = local.e ? ceil(log(local.cidr_reservations, 2)) : 1
  need_vnet_data            = (local.compute_ipv4_cidrs && length(var.address_prefixes) == 0)
  base_ipv4_cidr_block      = length(var.address_prefixes) > 0 ? var.address_prefixes[0] : (local.need_vnet_data ? element(data.azurerm_virtual_network.default[0].address_space, 0) : "")
  ipv4_subnet_cidrs = local.compute_ipv4_cidrs ? [
    for net in range(0, local.cidr_reservations) : cidrsubnet(local.base_ipv4_cidr_block, local.required_ipv4_subnet_bits, net)
  ] : local.supplied_ipv4_cidrs
  ## End Dynamic subnet calculation ##
}