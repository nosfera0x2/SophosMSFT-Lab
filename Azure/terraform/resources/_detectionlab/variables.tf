variable "labels" {
  description = <<EOD
  Label configuration for the created resources.
  EOD
  type = map(object{
    enabled = optional(bool)
    namespace = optional(string)
    tenant = optional(string)
    environment = optional(string)
    stage = optional(string)
    name = optional(string)
    delimiter = optional(string)
    attributes = optional(list(string))
    tags = optional(map(string))
    label_order = optional(list(string))
    label_key_case = optional(string)
    label_value_case = optional(string)
  })
}

variable "resource_group_label" {
  description = <<EOD
  Default label configuration for the azurerm_resource_group
  EOD
  type = any
  
}