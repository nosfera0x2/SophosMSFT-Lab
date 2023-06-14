locals {
  virtual_machine = [for vm in var.virtual_machine : {
    vm  = vm.computer_name
  }]
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
  value = [ for vm in var.virtual_machine : vm.computer_name ]
}

