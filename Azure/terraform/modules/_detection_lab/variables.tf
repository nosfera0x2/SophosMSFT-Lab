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
    resource_group_name = optional(string)
    location = optional(string)
    size = optional(string)
    network_interface_ids = optional(list(string))
    enable_automatic_updates = optional(bool)
    win_server                 = optional(bool)
    instance_count             = optional(number)
    role                       = optional(string)
    computer_name              = optional(string)
    custom_data                = optional(string)
    user_data                  = optional(string)
    hotpatching_enabled        = optional(bool)
    patch_mode                 = optional(string)
    allow_extension_operations = optional(bool)
    provision_vm_agent         = optional(bool)
    encryption_at_host_enabled = optional(bool)
  }))
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
variable "winrm_https_listener" {
  description = <<EOD
  Whether to enable the WinRM HTTPS listener on the virtual machine.
  EOD
  type        = bool
  default     = false
}
variable "hotpatching_enabled" {
  description = <<EOD
  Whether to enable hotpatching on the virtual machine.
  EOD
  type        = bool
  default     = false
}
variable "patch_mode" {
  description = <<EOD
  The patch mode to use on the virtual machine.
  EOD
  type        = string
  default     = "Manual"
  validation {
    condition     = contains(["AutomaticByOS", "Manual"], var.patch_mode)
    error_message = <<EOM
    Invalid patch mode. Available options are: AutomaticByOS, Manual
    EOM
  }
}
variable "trusted_ip" {
  description = <<EOD
  The trusted IP address to use for WinRM connections. Must be provided in CIDR notation.
  EOD
  type        = string
  default     = null
}
variable "list_of_trusted_ips" {
  description = <<EOD
  The list of trusted IP addresses to use for WinRM connections. Must be provided in CIDR notation.
  EOD
  type        = list(string)
  default     = []
}
### END: virtual machine variables ###
### END: variables.tf ###