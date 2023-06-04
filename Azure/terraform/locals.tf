locals {
  enabled = var.enabled
  e = local.enabled == true && var.create_resource_group == true
  default_module_context = {
    
  }
}