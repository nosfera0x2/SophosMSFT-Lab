### [BEGIN] SMOKE TEST: variables.tf ###
variable "virtual_machine" {
  description = <<EOD
  Virtual Machine Configuration.
  EOD
  type = map(object({
    role                  = optional(string)
    is_windows_server     = optional(bool)
    instance_count        = optional(number)
    admin_username        = optional(string)
    admin_password        = optional(string)
    resource_group_name   = optional(string)
    location              = optional(string)
    network_interface_ids = optional(list(string))
    additional_unattend_config = optional(object({
      component    = optional(string)
      pass         = optional(string)
      setting_name = optional(string)
      content      = optional(string)
    }))
    boot_diagnostics = optional(object({
      enabled     = optional(bool)
      storage_uri = optional(string)
    }))
    allow_extension_operations = optional(bool)
    identity = optional(object({
      type         = optional(string)
      identity_ids = optional(list(string))
    }))
    secret = optional(object({
      certificate = optional(string)
      key_vault_id = optional(string)
    }))
    size                     = optional(string)
    provision_vm_agent    = optional(bool)
    patch_assessment_mode = optional(string)
    patch_mode            = optional(string)
    hotpatching_enabled = optional(bool)
    enable_automatic_updates = optional(bool)
    os_disk = optional(object({
      caching              = optional(string)
      storage_account_type = optional(string)
      diff_disk_settings = optional(object({
        option    = optional(string)
        placement = optional(string)
      }))
      disk_size_gb                     = optional(number)
      write_accelerator_enabled        = optional(bool)
      security_encryption_type         = optional(string)
      secure_vm_disk_encryption_set_id = optional(string)
      disk_encryption_set_id           = optional(string)
    }))
    additional_capabilities = optional(object({
      ultra_ssd_enabled = optional(bool)
    }))
    source_image_reference = optional(object({
      publisher = optional(string)
      offer     = optional(string)
      sku       = optional(string)
      version   = optional(string)
      location = optional(string)
    }))
    computer_name       = optional(string)
    custom_data         = optional(string)
    user_data           = optional(string)
    license_type          = optional(string)
    secret = optional(object({
      source_vault_id    = optional(string)
      vault_certificates = optional(list(string))
    }))
    source_image_id = optional(string)
    certificate = optional(object({
      store = optional(string)
      url   = optional(string)
    }))
    winrm_listener = optional(object({
      protocol        = optional(string)
      certificate_url = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
      read = optional(string)
    }))
    ip_configuration = optional(object({
      name                          = optional(string)
      private_ip_address_allocation = optional(string)
      private_ip_address_version    = optional(string)
      private_ip_address            = optional(string)
      primary                       = optional(bool)
    }))
  }))
  default = {
    vm = {
      role = "server"
      is_windows_server = null
      instance_count = null
      admin_username = null
      admin_password = null
      resource_group_name = null
      location = null
      network_interface_ids = []
      additional_unattend_config = {
        component = null
        pass = null
        setting_name = null
        content = null
      }
      boot_diagnostics = {
        enabled = null
        storage_uri = null
      }
      allow_extension_operations = null
      identity = {
        type = null
        identity_ids = []
      }
      secret = {
        certificate = null
        key_vault_id = null
      }
      size = null
      provision_vm_agent = null
      patch_assessment_mode = null
      patch_mode = null
      hotpatching_enabled = null
      enable_automatic_updates = null
      os_disk = {
        caching = null
        storage_account_type = null
        diff_disk_settings = {
          option = null
          placement = null
        }
        disk_size_gb = null
        write_accelerator_enabled = null
        security_encryption_type = null
        secure_vm_disk_encryption_set_id = null
        disk_encryption_set_id = null
      }
      additional_capabilities = {
        ultra_ssd_enabled = null
      }
      source_image_reference = {
        publisher = null
        offer = null
        sku = null
        version = null
        location = null
      }
      computer_name = null
      custom_data = null
      user_data = null
      license_type = null
      secret = {
        source_vault_id = null
        vault_certificates = []
      }
      source_image_id = null
      certificate = {
        store = null
        url = null
      }
      winrm_listener = {
        protocol = null
        certificate_url = null
      }
      timeouts = {
        create = null
        delete = null
        update = null
        read = null
      }
      ip_configuration = {
        name = null
        private_ip_address_allocation = null
        private_ip_address_version = null
        private_ip_address = null
        primary = null
      }
    }
  }
  validation {
    condition =  alltrue([ for role in var.virtual_machine : contains(["server","client","domain_controller"], role["role"])])
    error_message = <<EOM
    Supported roles are 'server', 'client' and 'domain_controller'.
    EOM
  }
}

variable "role" {
  description = <<EOD
  [Required] Virtual Machine Role. Possible values are: `client`, `server` and `domain_controller`
  EOD
  type = string
  default = "server"
  validation {
    condition = contains(["server","client","domain_controller"], var.role)
    error_message = <<EOM
    Supported roles are 'server', 'client' and 'domain_controller'.
    EOM
  }
}

variable "is_windows_server" {
  description = <<EOD
  [Optional] If set to `true`, source_image_reference or source_image_id will reference either a Windows Server Platform Image or a custom Windows Server Image. If set to `false`, a Windows Desktop Platform Image or custom Windows Desktop Image will be used.
  EOD
  type = bool
  default = true
}

variable "instance_count" {
  description = <<EOD
  [Optional] The number of Windows Virtual Machine instances to create. Defaults to 1.
  EOD
  type = number
  default = 1
  validation {
    condition = alltrue([type(var.instance_count) == number])
    error_message = <<EOM
    Provided value must be a number.
    EOM
  }
}

variable "admin_username" {
  description = <<EOD
  [Optional] The name of the local administrator account for the Windows Virtual Machine. If not provided, the default value is `Administrator`.
  EOD
  type = string
  default = "Administrator"
}

variable "admin_password" {
  description = <<EOD
  [Required] The password of the local administrator account for the Windows Virtual Machine.
  EOD
  type = string
  default = null
  validation {
    condition = length(var.admin_password) >= 10
    error_message = <<EOM
    Provided value must be at least 10 characters long.
    EOM
  }
  validation {
    condition = can(regex("[A-Z]", var.admin_password))
    error_message = <<EOM
    Provided value must contain at least one uppercase letter.
    EOM
  }
  validation {
    condition = can(regex("[a-z]", var.admin_password))
    error_message = <<EOM
    Provided value must contain at least one lowercase letter.
    EOM
  }
  validation {
    condition = can(regex("[^a-zA-Z0-9]", var.admin_password))
    error_message = <<EOM
    Provided value must contain at least one special character.
    EOM
  }
  validation {
    
  }
}
### [END] SMOKE TEST: variables.tf ###