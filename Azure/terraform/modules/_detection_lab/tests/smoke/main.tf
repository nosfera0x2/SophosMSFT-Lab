locals {
  vm = flatten([
    for vm_key, vm in var.virtual_machine : [
      for index in range(vm.instance_count) : {
        win_server                 = vm.win_server
        win_desktop                = vm.win_desktop
        instance_count             = vm.instance_count
        role                       = vm.role
        location                   = vm.location
        admin_username             = vm.admin_username
        admin_password             = vm.admin_password
        computer_name              = vm.computer_name
        custom_data                = vm.custom_data
        user_data                  = vm.user_data
        enable_automatic_updates   = vm.enable_automatic_updates
        allow_extension_operations = vm.allow_extension_operations
        provision_vm_agent         = vm.provision_vm_agent
        encryption_at_host_enabled = vm.encryption_at_host_enabled
      }
    ]
  ])
  virtual_machine = {
    win_server                 = [for vm in var.virtual_machine : vm.win_server]
    computer_name              = [for vm in var.virtual_machine : vm.computer_name]
    instance_count             = [for vm in var.virtual_machine : vm.instance_count]
    role                       = [for vm in var.virtual_machine : vm.role]
    custom_data                = [for vm in var.virtual_machine : vm.custom_data]
    user_data                  = [for vm in var.virtual_machine : vm.user_data]
    enable_automatic_updates   = [for vm in var.virtual_machine : vm.enable_automatic_updates]
    allow_extension_operations = [for vm in var.virtual_machine : vm.allow_extension_operations]
    provision_vm_agent         = [for vm in var.virtual_machine : vm.provision_vm_agent]
    encryption_at_host_enabled = [for vm in var.virtual_machine : vm.encryption_at_host_enabled]
  }
}

variable "virtual_machine" {
  description = <<EOD
  Virtual Machine object
  EOD
  type = map(object({
    win_server                 = optional(bool)
    win_desktop                = optional(bool)
    instance_count             = optional(number)
    role                       = optional(string)
    location                   = optional(string)
    admin_username             = optional(string)
    admin_password             = optional(string)
    computer_name              = optional(string)
    custom_data                = optional(string)
    user_data                  = optional(string)
    enable_automatic_updates   = optional(bool)
    allow_extension_operations = optional(bool)
    provision_vm_agent         = optional(bool)
    encryption_at_host_enabled = optional(bool)
    winrm_listener = optional(object({
      protocol               = optional(string)
      certificate_url        = optional(string)
      certificate_thumbprint = optional(string)
    }))
  }))
  default = {}
}

output "vm" {
  value = local.vm
}

