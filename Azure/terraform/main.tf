provider "azurerm" {
  features {}
}

module "detection_lab" {
  source = "./modules/detection_lab"
  name = var.name
  stage = var.stage
  location = var.location
  address_space = var.address_space
  

}