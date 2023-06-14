locals {
  enabled = var.enabled
  e       = local.enabled

  labels = {
    network_interface = {
      namespace = "vnic"

    }
  }

  default_tags = {
    terraform_managed  = true,
    region             = join("", module.region.*.location_cli)
    tenant             = data.azurerm_client_config.current.tenant_id,
    deployment_date    = formatdate("DD-MM-YYYY hh:mm:ss", time_static.deploy_date.rfc3339),
    most_recent_change = formatdate("DD-MM-YYYY hh:mm:ss", timestamp())
  }

}