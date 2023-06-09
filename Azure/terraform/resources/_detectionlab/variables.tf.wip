variable "address_space" {
  description = <<EOD
  IPv4 address prefixes in CIDR notation.
  EOD
  type        = list(string)
  default     = []
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

variable "security_rules" {
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

variable "ip_configuration" {
  description = <<EOD
  IP configuration that can be specified to attach to specific VM instances
  EOD
  type        = any
  default = {
    domain_controller = {
      name                          = "domain_controller"
      private_ip_address_allocation = "Static"
    }
  }
}

variable "account_replication_type" {
  description = <<EOD
  The type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS.
  EOD
  type = string
  default = "LRS"
}

variable "account_tier" {
  description = <<EOD
  Defines the Tier to use for this storage account. Valid options are Standard and Premium.
  EOD
  type = string
  default = "Standard"
}

variable "min_tls_version" {
  description = <<EOD
  The minimum TLS version to use for this storage account. Valid options are TLS1_0, TLS1_1, TLS1_2.
  EOD
  type = string
  default = "TLS1_2"
}