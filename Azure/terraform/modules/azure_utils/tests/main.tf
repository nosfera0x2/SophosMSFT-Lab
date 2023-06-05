# azure_utils module tests: main.tf
module "region" {
  source       = "../"
  azure_region = "Central US"
}