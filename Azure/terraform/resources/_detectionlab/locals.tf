locals {
  enabled = var.enabled
  e       = local.enabled

  resource_labels = {
    resource_group = {
      name        = var.name
      namespace   = "rg"
      attributes  = ["azurerm_resource_group"]
      label_order = ["name", "namespace", "stage", "environment", "tenant", "location"]
      delimiter   = "."
    },
    virtual_network = {
      name        = var.name
      namespace   = "vnet"
      attributes  = ["azurerm_virtual_network"]
      label_order = ["name", "namespace", "location"]
      delimiter   = "."
    },
    subnet = {
      name        = var.name
      namespace   = "subnet"
      attributes  = ["azurerm_subnet"]
      label_order = ["name", "namespace", "location"]
      delimiter   = "."
    },
    network_security_group = {
      name        = var.name
      namespace   = "nsg"
      attributes  = ["azurerm_network_security_group"]
      label_order = ["name", "namespace", "location"]
      delimiter   = "."
    },
    storage_account = {
      name        = var.name
      namespace   = "sa"
      attributes  = ["azurerm_storage_account"]
      label_order = ["name", "namespace", "location"]
      delimiter   = ""
    }
  }

  context = {
    tenant           = var.tenant == null ? local.tenant : var.tenant
    attributes       = compact(distinct(concat(coalesce(var.context.attributes, []), coalesce(var.attributes, []))))
    tags             = merge(var.tags, local.default_tags)
    label_key_case   = "lower"
    label_value_case = "lower"
    delimiter        = "."
    location         = join("", module.region.*.location_cli)
  }

  default_tags = {
    terraform_managed  = true,
    region             = join("", module.region.*.location_cli)
    tenant             = data.azurerm_client_config.current.tenant_id,
    deployment_date    = formatdate("DD-MM-YYYY hh:mm:ss", time_static.deploy_date.rfc3339),
    most_recent_change = formatdate("DD-MM-YYYY hh:mm:ss", timestamp())
  }

  azurerm_resources = {
    resource_group = {
      name = azurerm_resource_group.this[0].name
      type = "Microsoft.Resources/resourceGroups"
      tag  = "rg"
    },
    virtual_network = {
      name = azurerm_virtual_network.this[0].name
      type = "Microsoft.Network/virtualNetworks"
      tag  = "vnet"
    }
  }

  tenant            = data.azurerm_client_config.current.tenant_id
  number_of_subnets = length([var.max_subnet_count]) > 0 ? var.max_subnet_count : var.subnet_count
  subnet_count      = local.e ? local.number_of_subnets : 0

  # Dynamic subnet calculation
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

  subnet_output = zipmap(tolist("${azurerm_subnet.this.*.name}"), tolist("${azurerm_subnet.this.*.address_prefixes}"))

  ip_whitelist = join("/", [chomp(data.http.ip_whitelist.response_body), "32"])

}
