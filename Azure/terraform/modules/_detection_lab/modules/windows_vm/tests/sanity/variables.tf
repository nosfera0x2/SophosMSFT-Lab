### [BEGIN] SANITY TEST: variables.tf ###
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
      is_windows_server = true
      instance_count = 1
      admin_username = "detectionlab"
      admin_password = null
      resource_group_name = null
      location = null
      network_interface_ids = []
      additional_unattend_config = null
      boot_diagnostics = null
      allow_extension_operations = false
      identity = null
      secret = null
      size = "Standard_D1_v2"
      provision_vm_agent = true
      patch_assessment_mode = "ImageDefault"
      patch_mode = "Manual"
      hotpatching_enabled = false
      enable_automatic_updates = false
      os_disk = {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
        diff_disk_settings = null
        disk_size_gb = 128
        write_accelerator_enabled = false
        security_encryption_type = null
        secure_vm_disk_encryption_set_id = null
        disk_encryption_set_id = null
      }
      additional_capabilities = null
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = null
        location = null
      }
      computer_name = null
      custom_data = null
      user_data = null
      license_type = "Windows_Server"
      secret = null
      source_image_id = null
      certificate = null
      winrm_listener = {
        protocol = "Http"
        certificate_url = null
      }
      timeouts = {
        create = "45m"
        delete = "45m"
        update = "45m"
        read = "5m"
      }
      ip_configuration = {
        name = "default-internal"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version = "IPv4"
        private_ip_address = null
        primary = true
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

variable "instance_count" {
  type = number
  default = null
}
### [END] SANITY TEST: variables.tf ###