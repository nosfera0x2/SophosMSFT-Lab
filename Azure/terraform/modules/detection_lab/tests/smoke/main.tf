output "locals" {
  value = {
    role_config = local.role_config
    disk_config = local.disk_config
    ip_config   = local.ip_config
  }
}