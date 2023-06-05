variable "enabled" {
  description = <<EOD
  If set to `true`, the detection lab resource will be created. Default is `true`.
  EOD
  type        = bool
  default     = true
}

variable "name" {
  description = <<EOD
  A custom name that is attached as a name label to the provisioned resources. Default is `detection-lab`.
  EOD
  type        = string
  default     = "detection-lab"
}

variable "environment" {
  description = <<EOD
  The environment that the resources will be provisioned in. Currently, the default is set to `prod`, however, this will be changes to support lookup functionality for deployment to various Azure environments depending on needs and requirements.
  EOD
  type        = string
  default     = "prod"
}

variable "stage" {
  description = <<EOD
  The stage that the resources will be provisioned in. Currently, the default is lab, however, this will be changed to support lookup functionality in the future.
  EOD
  type        = string
  default     = "lab"
}

variable "ipv4_address_space" {
  description = <<EOD
  [Required] The IPv4 address space in CIDR notation for the provisioned VNET.
  EOD
  type        = list(string)
}

variable "location" {
  description = <<EOD
  The Azure region where the resources will be provisioned. The default is `Central US`.
  EOD
  type        = string
  default     = "Central US"
}

variable "tags" {
  description = <<EOD
  A map of tags to apply to the provisioned resources. These will be included with a set of default tags that are already applied to each resource at deployment time.
  EOD
  type        = map(string)
  default     = {}
}


variable "create_subnet" {
  description = <<EOD
  If set to `true`, an azurerm_subnet will be created. Default is `true`.
  EOD
  type        = bool
  default     = true
}

variable "create_vnet" {
  description = <<EOD
  If set to `true`, an azurerm_virtual_network will be created. Default is `true`.
  EOD
  type        = bool
  default     = true
}

variable "create_resource_group" {
  description = <<EOD
  If set to `true`, an azurerm_resource_group will be created. Default is `true`.
  EOD
  type        = bool
  default     = true
}

variable "resource_count" {
  description = <<EOD
  Variable defines the number of subnets to create. The default value is 1.
  EOD
  type        = number
  default     = 1
}

variable "number_of_subnets" {
  description = <<EOD
  Variable defines the maximum number of subnets to create. The default value is 0. If this value is defined, it will override the value set in `resource_count`.
  EOD
  type        = number
  default     = 0
}

variable "virtual_network_name" {
  description = <<EOD
  The name of the virtual network that the subnets will be created in. By default, the subnets are created in the associated virtual network created by the module.
  EOD
  type        = string
  default     = null
}

variable "address_prefixes" {
  description = <<EOD
  The address prefixes for the subnets. The default value is []. If this value is defined, the address_prefixes must be contiquous and must be a subset of the address space defined in the virtual network. If this value is not defined, the address prefixes will be automatically calculated based on the number of subnets defined in `resource_count` or `max_resource_count`.
  EOD
  type        = list(string)
  default     = []
}

variable "resource_group_name" {
  description = <<EOD
  The name of the resource group that the subnets will be created in. By default, the subnets are created in the associated resource group created by the module.
  EOD
  type        = string
  default     = null
}