
output "locals" {
  value = {
    existing_subnet_count     = local.existing_subnet_count
    base_cidr_reservations    = local.base_cidr_reservations
    cidr_reservations         = local.cidr_reservations
    supplied_ipv4_cidrs       = local.supplied_ipv4_cidrs
    compute_ipv4_cidrs        = local.compute_ipv4_cidrs
    required_ipv4_subnet_bits = local.required_ipv4_subnet_bits
    need_vnet_data            = local.need_vnet_data
    base_ipv4_cidr_block      = local.base_ipv4_cidr_block
    ipv4_subnet_cidrs         = local.ipv4_subnet_cidrs
  }
}