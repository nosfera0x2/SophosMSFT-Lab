module "label" {
  source = "../label"
  enabled = module.this.enabled
  name = var.name
  namespace = try(join("-", [var.namespace, "rg"]), "rg")
  environment = var.environment
  stage = var.stage
  location = var.location
  attributes = ["azurerm_resource_group"]
  label_order = ["name","namespace","environment","location"]
  id_length_limit = 30
  context = module.this.context
}