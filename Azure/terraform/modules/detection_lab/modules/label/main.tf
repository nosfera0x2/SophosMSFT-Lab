locals {
  defaults = {
    label_order         = ["name", "namespace", "stage", "environment", "tenant", "location"]
    regex_replace_chars = "/[^a-zA-Z0-9-]/"
    delimiter           = "."
    replacement         = ""
    id_length_limit     = 0
    id_hash_length      = 5
    label_key_case      = "lower"
    label_value_case    = "lower"
  }

  default_labels_as_tags          = keys(local.tags_context)
  context_labels_as_tags_is_unset = try(contains(var.context.labels_as_tags, "unset"), true)

  input = {
    enabled             = var.enabled == null ? var.context.enabled : var.enabled
    name                = var.name == null ? var.context.name : var.name
    namespace           = var.namespace == null ? var.context.namespace : var.namespace
    environment         = var.environment == null ? var.context.environment : var.environment
    stage               = var.stage == null ? var.context.stage : var.stage
    tenant              = var.tenant == null ? var.context.tenant : var.tenant
    location            = var.location == null ? var.context.location : var.location
    attributes          = compact(distinct(concat(coalesce(var.context.attributes, []), coalesce(var.attributes, []))))
    label_order         = var.label_order == null ? var.context.label_order : var.label_order
    id_length_limit     = var.id_length_limit == null ? var.context.id_length_limit : var.id_length_limit
    regex_replace_chars = var.regex_replace_chars == null ? var.context.regex_replace_chars : var.regex_replace_chars
    delimiter           = var.delimiter == null ? var.context.delimiter : var.delimiter
    label_key_case      = var.label_key_case == null ? lookup(var.context, "label_key_case") : var.label_key_case
    label_value_case    = var.label_value_case == null ? lookup(var.context, "label_value_case") : var.label_value_case
    tags                = merge(var.context.tags, var.tags)
    labels_as_tags      = local.context_labels_as_tags_is_unset ? var.labels_as_tags : var.labels_as_tags == null ? var.context.labels_as_tags : var.context.labels_as_tags
  }

  enabled        = local.input.enabled
  replacement    = local.defaults.replacement
  id_hash_length = local.defaults.id_hash_length

  string_label_names  = ["name", "namespace", "stage", "environment", "tenant", "location"]
  regex_replace_chars = coalesce(local.input.regex_replace_chars, local.defaults.regex_replace_chars)

  normalized_labels = { for k in local.string_label_names : k =>
    local.input[k] == null ? "" : replace(local.input[k], local.regex_replace_chars, local.replacement)
  }
  normalized_attributes = compact(distinct([for v in local.input.attributes : replace(v, local.regex_replace_chars, local.replacement)]))

  formatted_labels = { for k in local.string_label_names : k => local.label_value_case == "none" ? local.normalized_labels[k] :
    local.label_value_case == "title" ? title(lower(local.normalized_labels[k])) :
    local.label_value_case == "upper" ? upper(local.normalized_labels[k]) : lower(local.normalized_labels[k])
  }

  attributes = compact(distinct([
    for v in local.normalized_attributes : (local.label_value_case == "none" ? v :
      local.label_value_case == "title" ? title(lower(v)) :
    local.label_value_case == "upper" ? upper(v) : lower(v))
  ]))

  location    = local.formatted_labels["location"]
  namespace   = local.formatted_labels["namespace"]
  tenant      = local.formatted_labels["tenant"]
  environment = local.formatted_labels["environment"]
  stage       = local.formatted_labels["stage"]
  name        = local.formatted_labels["name"]

  delimiter        = local.input.delimiter == null ? local.defaults.delimiter : local.input.delimiter
  label_order      = local.input.label_order == null ? local.defaults.label_order : coalescelist(local.input.label_order, local.defaults.label_order)
  id_length_limit  = local.input.id_length_limit == null ? local.defaults.id_length_limit : local.input.id_length_limit
  label_key_case   = local.input.label_key_case == null ? local.defaults.label_key_case : local.input.label_key_case
  label_value_case = local.input.label_value_case == null ? local.defaults.label_value_case : local.input.label_value_case

  labels_as_tags = contains(local.input.labels_as_tags, "default") ? local.default_labels_as_tags : local.input.labels_as_tags

  tags = merge(local.generated_tags, local.input.tags)

  tags_as_list_of_maps = flatten([
    for key in keys(local.tags) : merge(
      {
        key   = key
        value = local.tags[key]
    })
  ])

  tags_context = {
    namespace   = local.namespace
    tenant      = local.tenant
    environment = local.environment
    stage       = local.stage
    # For AWS we need `Name` to be disambiguated since it has a special meaning
    name       = local.id
    attributes = local.id_context.attributes
  }

  generated_tags = {
    for l in setintersection(keys(local.tags_context), local.labels_as_tags) :
    local.label_key_case == "upper" ? upper(l) : (
      local.label_key_case == "lower" ? lower(l) : title(lower(l))
    ) => local.tags_context[l] if length(local.tags_context[l]) > 0
  }

  id_context = {
    namespace   = local.namespace
    tenant      = local.tenant
    environment = local.environment
    stage       = local.stage
    name        = local.name
    attributes  = join(local.delimiter, local.attributes)
    location    = local.location
  }

  labels = [for l in local.label_order : local.id_context[l] if length(local.id_context[l]) > 0]

  id_full = join(local.delimiter, local.labels)
  # Create a truncated ID if needed
  delimiter_length = length(local.delimiter)
  # Calculate length of normal part of ID, leaving room for delimiter and hash
  id_truncated_length_limit = local.id_length_limit - (local.id_hash_length + local.delimiter_length)
  # Truncate the ID and ensure a single (not double) trailing delimiter
  id_truncated = local.id_truncated_length_limit <= 0 ? "" : "${trimsuffix(substr(local.id_full, 0, local.id_truncated_length_limit), local.delimiter)}${local.delimiter}"
  # Support usages that disallow numeric characters. Would prefer tr 0-9 q-z but Terraform does not support it.
  # Probably would have been better to take the hash of only the characters being removed,
  # so identical removed strings would produce identical hashes, but it is not worth breaking existing IDs for.
  id_hash_plus = "${md5(local.id_full)}qrstuvwxyz"
  id_hash_case = local.label_value_case == "title" ? title(local.id_hash_plus) : local.label_value_case == "upper" ? upper(local.id_hash_plus) : local.label_value_case == "lower" ? lower(local.id_hash_plus) : local.id_hash_plus
  id_hash      = replace(local.id_hash_case, local.regex_replace_chars, local.replacement)
  # Create the short ID by adding a hash to the end of the truncated ID
  id_short = substr("${local.id_truncated}${local.id_hash}", 0, local.id_length_limit)
  id       = local.id_length_limit != 0 && length(local.id_full) > local.id_length_limit ? local.id_short : local.id_full


  # Context of this label to pass to other label modules
  output_context = {
    enabled             = local.enabled
    namespace           = local.namespace
    tenant              = local.tenant
    environment         = local.environment
    stage               = local.stage
    name                = local.name
    location            = local.location
    delimiter           = local.delimiter
    attributes          = local.attributes
    tags                = local.tags
    label_order         = local.label_order
    regex_replace_chars = local.regex_replace_chars
    id_length_limit     = local.id_length_limit
    label_key_case      = local.label_key_case
    label_value_case    = local.label_value_case
    labels_as_tags      = local.labels_as_tags
  }
}