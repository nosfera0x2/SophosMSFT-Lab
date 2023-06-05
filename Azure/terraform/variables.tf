variable "enabled" {
  description = <<EOD
  If set to `true`, the module will be enabled. Default is `true`.
  EOD
  type = bool
  default = true
}


variable "create_resource_group" {
  description = <<EOD
  If set to `true`, an azurerm_resource_group will be created. Default is `true`.
  EOD
  type        = bool
  default     = true
}

variable "tags" {
  description = <<EOD
  A map of tags to apply to the provisioned resources. These will be included with a set of default tags that are already applied to each resource at deployment time.
  EOD
  type        = map(string)
  default     = {}
}
