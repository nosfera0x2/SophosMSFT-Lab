provider "azurerm" {
  features {}
}

module "vm" {
  source = "../../"
}