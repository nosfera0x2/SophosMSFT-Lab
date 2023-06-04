variable "create_resource" {
  description = <<EOD
  If set to true, a resource group will be created. Defaults to false
  EOD
  type        = bool
  default     = false
}

variable "address_prefixes" {
  description = <<EOD
  IPv4 address prefixes in CIDR notation.
  EOD
  type        = list(string)
  default     = []
}

variable "resource_count" {
  description = <<EOD
  The number of resources to create
  EOD
  type        = number
  default     = 1
  validation {
    condition     = length([var.resource_count]) > 0
    error_message = <<EOM
    Error: Number of resources to create must by greater than 0
    EOM
  }
}

variable "max_resource_count" {
  description = <<EOD
  The maximum number of subnets to create.
  EOD
  type        = number
  default     = 0
}

variable "ipv4_cidrs" {
  type = list(object({
    subnet_cidrs = list(string)
  }))
  description = <<-EOT
    Lists of CIDRs to assign to subnets. Order of CIDRs in the lists must not change over time.
    Lists may contain more CIDRs than needed.
    EOT
  default     = []
  validation {
    condition     = length(var.ipv4_cidrs) < 2
    error_message = "Only 1 ipv4_cidrs object can be provided. Lists of CIDRs are passed via the `public` and `private` attributes of the single object."
  }
}

variable "resource_group" {
  description = <<EOD
  The name of the resource group.
  EOD
  type        = string
  default     = null
}

variable "virtual_network" {
  description = <<EOD
  The name of the virtual network.
  EOD
  type        = string
  default     = null
}