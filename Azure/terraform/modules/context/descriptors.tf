# context module: descriptors.tf

locals {
  descriptor_labels = { for k, v in local.descriptor_formats : k => [
    for label in v.labels : local.id_context[label]
  ] }
  descriptors = { for k, v in local.descriptor_formats : k => (
    format(v.format, local.descriptor_labels[k]...)
    )
  }
}