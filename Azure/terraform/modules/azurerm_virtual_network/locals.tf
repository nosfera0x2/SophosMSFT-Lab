locals {
  enabled = var.enabled
  e       = local.enabled && var.create_resource
  context = {
    enabled             = var.enabled
    namespace           = "vnet"
    tenant              = var.tenant == null ? data.azurerm_client_config.current.tenant_id : var.tenant
    environment         = var.environment
    stage               = var.stage
    name                = var.name
    location            = join("", module.region.*.location_cli)
    delimiter           = "."
    attributes          = compact(distinct(concat(coalesce(var.context.attributes, []), coalesce(var.attributes, ["azurerm_virtual_network"]))))
    tags                = merge(var.tags, local.default_tags)
    regex_replace_chars = var.regex_replace_chars
    label_order         = ["name", "namespace", "location"]
    id_length_limit     = 0
    label_key_case      = "lower"
    label_value_case    = "lower"
    labels_as_tags      = ["unset"]
  }

  location            = join("", module.region.*.location_cli)
  number_of_resources = var.resource_count
  resource_count      = local.e ? length([local.number_of_resources]) : 0

  default_tags = {
    terraform_managed  = true,
    region             = join("", module.region.*.location_cli)
    tenant             = data.azurerm_client_config.current.tenant_id,
    deployment_date    = formatdate("DD-MM-YYYY hh:mm:ss", time_static.deploy_date.rfc3339),
    most_recent_change = formatdate("DD-MM-YYYY hh:mm:ss", timestamp())
  }
}

resource "time_static" "deploy_date" {}