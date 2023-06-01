# sanity tests
provider "azurerm" {
  features {}
}

variable "label" {
  type = map(object({
    enabled             = optional(bool)
    name                = optional(string)
    namespace           = optional(string)
    environment         = optional(string)
    stage               = optional(string)
    region              = optional(string)
    attributes          = optional(list(string))
    label_order         = optional(list(string))
    id_length_limit     = optional(number)
    regex_replace_chars = optional(string)
    delimiter           = optional(string)
    label_key_case      = optional(string)
    label_value_case    = optional(string)
    tags                = optional(map(string))
    context             = optional(any)
  }))
}

module "label" {
  source              = "../../"
  for_each            = var.label
  enabled             = true
  name                = each.value.name
  namespace           = each.value.namespace
  environment         = each.value.environment
  stage               = each.value.stage
  region              = each.value.region
  attributes          = each.value.attributes
  label_order         = each.value.label_order
  id_length_limit     = each.value.id_length_limit
  regex_replace_chars = each.value.regex_replace_chars
  delimiter           = each.value.delimiter
  label_key_case      = each.value.label_key_case
  label_value_case    = each.value.label_value_case
  tags                = each.value.tags
}

output "label" {
  value = module.label
}