locals {
  role_config = lookup(var.vm_config, var.role)
  disk_config = local.role_config.os_disk
  ip_config   = local.role_config.ip_config
}