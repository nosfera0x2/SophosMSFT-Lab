### [BEGIN] output.tf ###
## Testing outputs ###
output "admin_password" {
  value = var.admin_password
  sensitive = true
}

output "vm_defaults" {
  value = local.vm_defaults
}
### [END] output.tf ###
