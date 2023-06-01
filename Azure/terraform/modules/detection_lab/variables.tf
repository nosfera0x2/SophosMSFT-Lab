# azurerm_resource_group module: variables.tf

variable "create_resource" {
  description = <<EOD
    [Optional] If set to `false`, a resource will not be created. Defaults to true
    EOD
  type        = bool
  default     = true
}

variable "defaults" {
  description = <<EOD
  A map of default values for resource labels.
  EOD
  type        = map(any)
  default = {
    rg = {
      namespace   = "rg"
      attributes  = ["azurerm_resource_group"]
      label_order = ["name", "namespace", "stage", "environment", "tenant", "region"]
    },
    vnet = {
      namespace   = "vnet"
      attributes  = ["azurerm_virtual_network"]
      label_order = ["name", "namespace", "environment", "region"]
    },
    subnet = {
      namespace   = "subnet"
      attributes  = ["azurerm_subnet"]
      label_order = ["name", "namespace", "environment", "region"]
    },
    secgroup = {
      namespace   = "secgrp"
      attributes  = ["azurerm_security_group"]
      label_order = ["name", "namespace", "environment", "region"]
    },
    vm = {
      namespace   = "vm"
      attributes  = ["azurerm_virtual_machine"]
      label_order = ["name", "namespace", "environment", "region"]
    }
  }
}

variable "address_space" {
  description = <<EOD
  [Required] A list of IPv4 address prefixes in CIDR notation.
  EOD
  type = list(string)
  default = []
}

variable "number_of_subnets" {
  description = <<EOD
  The number of subnets to create
  EOD
  type = number
  default = 1
}

variable "max_subnet_count" {
  description = <<EOD
  The maximum number of subnets to create.
  EOD
  type = number
  default = 0
}

variable "subnet_address_space" {
  description = <<EOD
  If this value is supplies, address space will be calculated based on this supplied value.
  EOD
  type = list(string)
  default = []
}

variable "security_group" {
  default = null
}


