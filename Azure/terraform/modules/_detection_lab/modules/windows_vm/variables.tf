### BEGIN: variables.tf ###
### BEGIN: global variables ###
variable "resource_group_name" {
  description = <<EOD
  An optional resource group name to provision the resources in if this differs from the resource group created in this module.
  EOD
  type = string
  default = null
}
variable "virtual_network_name" {
  description = <<EOD
  An optional virtual network name to provision the subnet in ff this differs from the virtual network created in this module.
  EOD
  type = string
  default = null
}
### END: global variables ###
### BEGIN: azurerm_virtual_network variables ###
variable "address_space" {
  description = <<EOD
  IPv4 address space in CIDR notation to be used when creating the virtual network. (Currently IPv4 is only supported)
  EOD
  type = list(string)
  default = []
}
### END: azurerm_virtual_network variables ###
### BEGIN: azurerm_network_security_group variables ###
variable "default_security_rules" {
  description = <<EOD
  Default security group rules for the module. These rules will be applied to all subnets.
  EOD
  type = any
  default = {
    ssh = {
      name                   = "ssh"
      priority               = 1001
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "22"
    },
    winrm = {
      name                   = "winrm"
      priority               = 1005
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "5985-5986"
    },
    windows_ata = {
      name                   = "WindowsATA"
      priority               = 1006
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "443"
    }
  }
}
variable "security_rules" {
  description = <<EOD
  Optional additional security rules that can be added to the security group.
  EOD
  type = map(object({
    name = optional(string)
    priority = optional(number)
    direction = optional(string)
    access = optional(string)
    protocol = optional(string)
    source_port_range = optional(string)
    destination_port_range = optional(string)
  }))
  default = {}
}
### END: azurerm_network_security_group variables ###
### BEGIN: azurerm_storage_account variables ###
variable "storage_account_tier" {
  description = <<EOD
  The storage account tier.
  EOD
  type = string
  default = null
}
variable "storage_account_replication_type" {
  description = <<EOD
  The storage account replication type.
  EOD
  type = string
  default = null
}
### END: azurerm_storage_account variables ###
### BEGIN: azurerm_public_ip variables ###
variable "public_ip_allocation_method" {
  description = <<EOD
  The public IP allocation method.
  EOD
  type = string
  default = "Dynamic"
  validation {
    condition = contains(["Dynamic", "Static"], var.public_ip_allocation_method)
    error_message = <<EOM
    Invalid public IP allocation method. Valid values are "Dynamic" or "Static".
    EOM
  }
}
### END: azurerm_public_ip variables ###
### BEGIN: azurerm_network_interface variables ###
variable "enable_ip_forwarding" {
  description = <<EOD
  If set to `true` the network interface will be enabled for IP forwarding.
  EOD
  type = bool
  default = null
}
### END: azurerm_network_interface variables ###
### BEGIN: azurerm_virtual_machine variables ###
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
    provision_vm_agent    = optional(bool)
    network_interface_ids = optional(list(string))
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
    size                     = optional(string)
    enable_automatic_updates = optional(bool)
    additional_capabilities = optional(object({
      ultra_ssd_enabled = optional(bool)
    }))
    additional_unattend_config = optional(object({
      component    = optional(string)
      pass         = optional(string)
      setting_name = optional(string)
      content      = optional(string)
    }))
    allow_extension_operations = optional(bool)
    boot_diagnostics = optional(object({
      enabled     = optional(bool)
      storage_uri = optional(string)
    }))
    computer_name       = optional(string)
    custom_data         = optional(string)
    user_data           = optional(string)
    hotpatching_enabled = optional(bool)
    identity = optional(map(object({
      type         = optional(string)
      identity_ids = optional(list(string))
    })))
    license_type          = optional(string)
    patch_assessment_mode = optional(string)
    patch_mode            = optional(string)
    secret = optional(object({
      source_vault_id    = optional(string)
      vault_certificates = optional(list(string))
    }))
    source_image_id = optional(string)
    source_image_reference = optional(object({
      publisher = optional(string)
      offer     = optional(string)
      sku       = optional(string)
      version   = optional(string)
    }))
    certificate = optional(object({
      store = optional(string)
      url   = optional(string)
    }))
    winrm_listener = optional(map(object({
      protocol        = optional(string)
      certificate_url = optional(string)
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
    ip_configuration = optional(map(object({
      name = optional(string)
      private_ip_address_allocation = optional(string)
      private_ip_address_version = optional(string)
      private_ip_address = optional(string)
      primary = optional(bool)
    })))
  }))
  default = {
    server = {
      role                       = "server"
      is_windows_server          = true
      instance_count             = 1
      admin_username             = "detectionlab-admin"
      additional_unattend_config = null
      allow_extension_operations = false
      boot_diagnostics           = null
      identity                   = null
      secret                     = null
      size                       = "Standard_D1_v2"
      provision_vm_agent         = true
      patch_assessment_mode      = "ImageDefault"
      patch_mode                 = "Manual"
      hotpatching_enabled        = false
      enable_automatic_updates   = false
      os_disk = {
        name                             = "server-os-disk"
        caching                          = "ReadWrite"
        storage_account_type             = "Standard_LRS"
        diff_disk_settings               = null
        disk_size_gb                     = 128
        write_accelerator_enabled        = false
        security_encryption_type         = null
        secure_vm_disk_encryption_set_id = null
        disk_encryption_set_id           = null
      }
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = null
      }
      certificate = null
      winrm_listener = {
        protocol        = "Http"
        certificate_url = null
      }
      timeouts = {
        create = "45m"
        delete = "45m"
        update = "45m"
        read   = "5m"
      }
      ip_configuration = {
        name = "server-ip-configuration"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version = "IPv4"
        private_ip_address = null
        primary = true
      }
    }
    domain_controller = {
      role                       = "server"
      is_windows_server          = true
      instance_count             = 1
      admin_username             = "detectionlab-admin"
      additional_unattend_config = null
      allow_extension_operations = false
      boot_diagnostics           = null
      identity                   = null
      secret                     = null
      size                       = "Standard_D1_v2"
      provision_vm_agent         = true
      patch_assessment_mode      = "ImageDefault"
      patch_mode                 = "Manual"
      hotpatching_enabled        = false
      enable_automatic_updates   = false
      os_disk = {
        name                             = "domain-controller-os-disk"
        caching                          = "ReadWrite"
        storage_account_type             = "Standard_LRS"
        diff_disk_settings               = null
        disk_size_gb                     = 128
        write_accelerator_enabled        = false
        security_encryption_type         = null
        secure_vm_disk_encryption_set_id = null
        disk_encryption_set_id           = null
      }
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = null
      }
      certificate = null
      winrm_listener = {
        protocol        = "Http"
        certificate_url = null
      }
      timeouts = {
        create = "45m"
        delete = "45m"
        update = "45m"
        read   = "5m"
      }
      ip_configuration = {
        name = "domain-controller-ip-configuration"
        private_ip_address_allocation = "Static"
        private_ip_address_version = "IPv4"
        private_ip_address = null
        primary = true
      }
    }
    client = {
      role                       = "client"
      is_windows_server          = true
      instance_count             = 1
      admin_username             = "detectionlab-admin"
      additional_unattend_config = null
      allow_extension_operations = false
      boot_diagnostics           = null
      identity                   = null
      secret                     = null
      size                       = "Standard_D1_v2"
      provision_vm_agent         = true
      patch_assessment_mode      = "ImageDefault"
      patch_mode                 = "Manual"
      hotpatching_enabled        = false
      enable_automatic_updates   = false
      os_disk = {
        name                             = "client-os-disk"
        caching                          = "ReadWrite"
        storage_account_type             = "Standard_LRS"
        diff_disk_settings               = null
        disk_size_gb                     = 128
        write_accelerator_enabled        = false
        security_encryption_type         = null
        secure_vm_disk_encryption_set_id = null
        disk_encryption_set_id           = null
      }
      source_image_reference = {
        publisher = "MicrosoftWindowsDesktop"
        offer     = "Windows-10"
        sku       = "19h1-pro"
        version   = null
      }
      certificate = null
      winrm_listener = {
        protocol        = "Http"
        certificate_url = null
      }
      timeouts = {
        create = "45m"
        delete = "45m"
        update = "45m"
        read   = "5m"
      }
      ip_configuration = {
        name = "client-ip-configuration"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version = "IPv4"
        private_ip_address = null
        primary = true
      }
    }
  }
}

variable "virtual_machine_defaults" {
  description = <<EOD
  Default Virtual Machine Configurations mapped to VM roles. These values are used when the associated settings are not specified in the virtual_machine variable.
  EOD
  type        = map(any)
  default = {
    server = {
      role                       = "server"
      is_windows_server          = true
      instance_count             = 1
      admin_username             = "detectionlab-admin"
      additional_unattend_config = null
      allow_extension_operations = false
      boot_diagnostics           = null
      identity                   = null
      secret                     = null
      size                       = "Standard_D1_v2"
      provision_vm_agent         = true
      patch_assessment_mode      = "ImageDefault"
      patch_mode                 = "Manual"
      hotpatching_enabled        = false
      enable_automatic_updates   = false
      os_disk = {
        name                             = "server-os-disk"
        caching                          = "ReadWrite"
        storage_account_type             = "Standard_LRS"
        diff_disk_settings               = null
        disk_size_gb                     = 128
        write_accelerator_enabled        = false
        security_encryption_type         = null
        secure_vm_disk_encryption_set_id = null
        disk_encryption_set_id           = null
      }
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = null
      }
      certificate = null
      winrm_listener = {
        protocol        = "Http"
        certificate_url = null
      }
      timeouts = {
        create = "45m"
        delete = "45m"
        update = "45m"
        read   = "5m"
      }
    }
    domain_controller = {
      role                       = "server"
      is_windows_server          = true
      instance_count             = 1
      admin_username             = "detectionlab-admin"
      additional_unattend_config = null
      allow_extension_operations = false
      boot_diagnostics           = null
      identity                   = null
      secret                     = null
      size                       = "Standard_D1_v2"
      provision_vm_agent         = true
      patch_assessment_mode      = "ImageDefault"
      patch_mode                 = "Manual"
      hotpatching_enabled        = false
      enable_automatic_updates   = false
      os_disk = {
        name                             = "domain-controller-os-disk"
        caching                          = "ReadWrite"
        storage_account_type             = "Standard_LRS"
        diff_disk_settings               = null
        disk_size_gb                     = 128
        write_accelerator_enabled        = false
        security_encryption_type         = null
        secure_vm_disk_encryption_set_id = null
        disk_encryption_set_id           = null
      }
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = null
      }
      certificate = null
      winrm_listener = {
        protocol        = "Http"
        certificate_url = null
      }
      timeouts = {
        create = "45m"
        delete = "45m"
        update = "45m"
        read   = "5m"
      }
    }
    client = {
      role                       = "client"
      is_windows_server          = true
      instance_count             = 1
      admin_username             = "detectionlab-admin"
      additional_unattend_config = null
      allow_extension_operations = false
      boot_diagnostics           = null
      identity                   = null
      secret                     = null
      size                       = "Standard_D1_v2"
      provision_vm_agent         = true
      patch_assessment_mode      = "ImageDefault"
      patch_mode                 = "Manual"
      hotpatching_enabled        = false
      enable_automatic_updates   = false
      os_disk = {
        name                             = "client-os-disk"
        caching                          = "ReadWrite"
        storage_account_type             = "Standard_LRS"
        diff_disk_settings               = null
        disk_size_gb                     = 128
        write_accelerator_enabled        = false
        security_encryption_type         = null
        secure_vm_disk_encryption_set_id = null
        disk_encryption_set_id           = null
      }
      source_image_reference = {
        publisher = "MicrosoftWindowsDesktop"
        offer     = "Windows-10"
        sku       = "19h1-pro"
        version   = null
      }
      certificate = null
      winrm_listener = {
        protocol        = "Http"
        certificate_url = null
      }
      timeouts = {
        create = "45m"
        delete = "45m"
        update = "45m"
        read   = "5m"
      }
    }
  }
}
variable "instance_count" {
  description = <<EOD
  The number of instances to create.
  EOD
  type        = number
  default     = 1
}
variable "role" {
  description = <<EOD
  Virtual Machine role. Determines the default configuration values for source_reference_image and os_disk configurations.
  EOD
  type        = string
  default     = "server"
  validation {
    condition     = contains(["server", "client", "domain_controller"], var.role)
    error_message = <<EOM
    Invalid role. Valid roles are: server, client, domain_controller
    EOM
  }
}
### END: azurerm_virtual_machine variables ###
### END: variables.tf ###
