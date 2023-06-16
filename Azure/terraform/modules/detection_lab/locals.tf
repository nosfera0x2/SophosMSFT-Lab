### [BEGIN] locals.tf ###
locals {
  vm_defaults = flatten([
    for key, vm in var.virtual_machine : {
      admin_username = var.admin_username
      #admin_password = var.admin_password
      instance_count = var.instance_count
      location = var.azure_location
      allow_extension_operations = var.allow_extension_operations
      timeouts = {
        create = "45m"
        delete = "45m"
        update = "45m"
        read = "5m"
      }
    }
  ])
}
### [END] locals.tf ###
