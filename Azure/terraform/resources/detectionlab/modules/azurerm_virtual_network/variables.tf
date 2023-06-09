variable "resource_group_name" {
  description = <<EOD
  The name of the resource group where the VNET will be created
  EOD
  type        = string
  default     = null
}

variable "address_space" {
  description = <<EOD
  The address space that is used the VNET
  EOD
  type        = list(string)
  default     = []
}