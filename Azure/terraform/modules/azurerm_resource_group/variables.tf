# azurerm_resource_group module: variables.tf

variable "create_resource" {
  description = <<EOD
  If set to true, a resource group will be created. Defaults to false
  EOD
  type        = bool
  default     = false
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

variable "resource_group" {
  description = <<EOD
  The name of the resource group.
  EOD
  type        = string
  default     = null
}