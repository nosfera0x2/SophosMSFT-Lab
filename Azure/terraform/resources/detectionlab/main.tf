resource "time_static" "deploy_date" {}

module "region" {
  count        = local.e ? 1 : 0
  source       = "../azure_utils"
  azure_region = var.location
}