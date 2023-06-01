# azurerm_resource_group module: locals.tf

locals {
  enabled = var.enabled
  e       = local.enabled
  ## Data source manipulation to extract values for defining unique and contiguous naming conventions
  data_source_map = {
    tenant_id = data.azurerm_client_config.current.tenant_id
    split     = split("-", data.azurerm_client_config.current.tenant_id)
    length    = length(split("-", data.azurerm_client_config.current.tenant_id))
  }

  tenant_id_map = {
    id_full  = local.data_source_map.tenant_id
    id_short = element(local.data_source_map.split, local.data_source_map.length)
  }
  # regions map
  region_map = {
    location       = join("", module.region.*.location)
    location_cli   = join("", module.region.*.location_cli)
    location_short = join("", module.region.*.location_short)
    location_slug  = join("", module.region.*.location_slug)
  }

  # subnet calculations
  existing_subnet_count = local.e ? length(data.azurerm_virtual_network.default[0].subnets) : 0
  base_cidr_reservations = (var.max_subnet_count == 0 ? local.existing_subnet_count : var.max_subnet_count) * var.number_of_subnets
  cidr_reservations = (local.e ? 1 : 0) * local.base_cidr_reservations
  supplied_ipv4_cidrs = var.subnet_address_space
  compute_ipv4_cidrs = local.e && (length(local.supplied_ipv4_cidrs)) == 0
  required_ipv4_subnet_bits = local.e ? ceil(log(local.cidr_reservations, 2)) : 1
  need_vnet_data = (local.compute_ipv4_cidrs && length(var.address_space)==0)
  base_ipv4_cidr_block = length(var.address_space) > 0 ? var.address_space[0] : (local.need_vnet_data ? element(data.azurerm_virtual_network.default[0].address_space,0) : "")
  ipv4_subnet_cidrs = local.compute_ipv4_cidrs ? [
    for net in range(0, local.cidr_reservations) : cidrsubnet(var.address_space, local.required_ipv4_subnet_bits, net)
  ] : local.supplied_ipv4_cidrs
}