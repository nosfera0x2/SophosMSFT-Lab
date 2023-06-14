### BEGIN: variables.tf ###
### BEGIN: virtual network variables ###
variable "address_space" {
  description = <<EOD
  The virtual network address space block in CIDR notation.
  EOD
  type        = list(string)
  default     = []
}
### END: virtual network variables ###
### BEGIN: subnet variables ###
variable "address_prefixes" {
  description = <<EOD
    Lists of CIDRs to assign to subnets. Order of CIDRs in the lists must not change over time.
    Lists may contain more CIDRs than needed.
  EOD
  default     = []
  validation {
    condition     = length(var.address_prefixes) < 2
    error_message = "Only 1 address_prefixes object can be provided. Lists of CIDRs are passed via the `public` and `private` attributes of the single object."
  }
}
variable "max_subnet_count" {
  description = <<EOD
  The maximum number of subnets to create.
  EOD
  type        = number
  default     = 0
}
variable "subnet_count" {
  description = <<EOD
  The number of subnets to create
  EOD
  type        = number
  default     = 1
  validation {
    condition     = length([var.subnet_count]) > 0
    error_message = <<EOM
    Error: Number of subnets to create must by greater than 0
    EOM
  }
}
### END: subnet variables ###
### BEGIN: security group variables ###
variable "default_security_rules" {
  description = <<EOD
  Network security rules to apply to the subnet.
  EOD
  type        = any
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
### END: security group variables ###
### BEGIN: storage account variables ###
variable "storage_account_min_tls_version" {
  description = <<EOD
  The minimum TLS version to use for the storage account.
  EOD
  type        = string
  default     = "TLS1_2"
}
variable "storage_account_tier" {
  description = <<EOD
  The storage account tier.
  EOD
  type        = string
  default     = "Standard"
}
variable "storage_account_replication_type" {
  description = <<EOD
  The storage account replication type.
  EOD
  type        = string
  default     = "LRS"
}
### END: storage account variables ###
### BEGIN: public IP variables ###
variable "public_ip_allocation_method" {
  description = <<EOD
  The public IP allocation method.
  EOD
  type        = string
  default     = "Dynamic"
}
### END: public IP variables ###
### BEGIN: network interface variables ###
variable "enable_ip_forwarding" {
  description = <<EOD
  Whether to enable IP forwarding on the network interface.
  EOD
  type        = bool
  default     = false
}
### END: network interface variables ###
### BEGIN: virtual machine variables ###
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
    winrm_listener = optional(map(object({
      protocol               = optional(string)
      certificate_url        = optional(string)
      certificate_thumbprint = optional(string)
    })))
  }))
}
variable "virtual_machine_context" {
  description = <<EOD
Default virtual machine configuration context
EOD
  type        = any
  default = {
    win_server                 = true
    win_desktop                = false
    instance_count             = 1
    role                       = "server"
    location                   = null
    admin_username             = "vagrant"
    admin_password             = "Vagrant123!"
    computer_name              = null
    custom_data                = null
    user_data                  = null
    enable_automatic_updates   = false
    allow_extension_operations = false
    provision_vm_agent         = true
    encryption_at_host_enabled = false
    winrm_listener = {
      protocol               = "Http"
      certificate_url        = null
      certificate_thumbprint = null
    }
  }
}
variable "instance_count" {
  description = <<EOD
  The number of virtual machines to create.
  EOD
  type        = number
  default     = null
}
variable "role" {
  description = <<EOD
  The role of the virtual machine. Available options are: server, workstation and domain_controller
  EOD
  type        = string
  default     = "server"
  validation {
    condition     = contains(["server", "workstation", "domain_controller"], var.role)
    error_message = <<EOM
    Invalid role. Available options are: server, workstation and domain_controller
    EOM
  }
}
variable "admin_username" {
  description = <<EOD
  Default local admin username for Windows virtual machines.
  EOD
  type        = string
  default     = "vagrant"
}
variable "admin_password" {
  description = <<EOD
  Default local admin password for Windows virtual machines.
  EOD
  type        = string
  default     = "Vagrant123!"
}
variable "allow_extension_operations" {
  description = <<EOD
  Whether to allow extension operations on the virtual machine.
  EOD
  type        = bool
  default     = false
}
variable "enable_automatic_updates" {
  description = <<EOD
  Whether to enable automatic updates on the virtual machine.
  EOD
  type        = bool
  default     = false
}
variable "provision_vm_agent" {
  description = <<EOD
  Whether to provision the VM agent on the virtual machine.
  EOD
  type        = bool
  default     = true
}
variable "encryption_at_host_enabled" {
  description = <<EOD
  Whether to enable encryption at host on the virtual machine.
  EOD
  type        = bool
  default     = false
}
variable "computer_name" {
  description = <<EOD
  The computer name of the virtual machine.
  EOD
  type        = string
  default     = null
}
variable "vm_config" {
  description = <<EOD
  VM Configuration object
  EOD
  type        = any
  default = {
    server = {
      config_name         = "server"
      custom_data         = "scripts/windows/EnablePSRemoting.ps1"
      user_data           = null
      size                = "Standard_D1_v2"
      license_type        = "Windows_Server"
      patch_mode          = "Manual"
      hotpatching_enabled = false
      os_disk = {
        caching                   = "ReadWrite"
        storage_account_type      = "Standard_LRS"
        disk_size_gb              = 128
        write_accelerator_enabled = false
      }
      ip_configuration = {
        name                          = "internal-dynamic"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version    = "IPv4"
        primary                       = true
      }
    }
    domain_controller = {
      config_name         = "domain_controller"
      custom_data         = "scripts/windows/EnablePSRemoting.ps1"
      user_data           = null
      size                = "Standard_D1_v2"
      license_type        = "Windows_Server"
      patch_mode          = "Manual"
      hotpatching_enabled = false
      os_disk = {
        caching                   = "ReadWrite"
        storage_account_type      = "Standard_LRS"
        disk_size_gb              = 128
        write_accelerator_enabled = false
      }
      ip_configuration = {
        name                          = "internal-dynamic"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version    = "IPv4"
        primary                       = true
      }
    }
    workstation = {
      config_name         = "workstation"
      custom_data         = "scripts/windows/EnablePSRemoting.ps1"
      user_data           = null
      size                = "Standard_D1_v2"
      license_type        = "Windows_Desktop"
      patch_mode          = "Manual"
      hotpatching_enabled = false
      os_disk = {
        caching                   = "ReadWrite"
        storage_account_type      = "Standard_LRS"
        disk_size_gb              = 128
        write_accelerator_enabled = false
      }
      ip_configuration = {
        dynamic = {
          name                          = "internal-static"
          private_ip_address_allocation = "Static"
          private_ip_address_version    = "IPv4"
          primary                       = true
        }

      }
    }
  }
}
variable "winrm_listener" {
  description = <<EOD
  WinRM Listener Variable
  EOD
  type = map(object({
    protocol               = optional(string)
    certificate_url        = optional(string)
    certificate_thumbprint = optional(string)
  }))
  default = null
}
variable "win_server" {
  description = <<EOD
  If set to `true`, the virtual machine will be configured as a Windows Server.
  EOD
  type        = bool
  default     = null
}
variable "win_desktop" {
  description = <<EOD
  If set to `true`, the virtual machine will be configured as a Windows Desktop.
  EOD
  type        = bool
  default     = null
}
### END: virtual machine variables ###
### END: variables.tf ###