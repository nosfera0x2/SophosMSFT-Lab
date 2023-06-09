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

variable "resource_group_name" {
  description = <<EOD
  The name of the resource group where the VNET will be created
  EOD
  type        = string
  default     = null
}

variable "virtual_network_name" {
  description = <<EOD
  The name of the VNET where the subnet will be created
  EOD
  type        = string
  default     = null
}