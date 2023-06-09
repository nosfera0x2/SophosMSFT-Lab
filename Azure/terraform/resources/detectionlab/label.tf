# Detection Lab label module
module "this" {
  source = "../../modules/label"
  enabled = var.enabled
  name = var.name
  namespace = var.namespace
  environment = var.environment
  stage = var.stage
  tenant = var.tenant
  location = var.location
  attributes = var.attributes
  label_order = var.label_order
  id_length_limit = var.id_length_limit
  regex_replace_chars = var.regex_replace_chars
  delimiter = var.delimiter
  label_key_case = var.label_key_case
  label_value_case = var.label_value_case
  tags = local.tags
  labels_as_tags = var.labels_as_tags
  context = var.context
}