locals {
  enabled = module.this.enabled
  e = local.enabled

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
}