provider "azurerm" {
  features {}
}

module "detection_lab" {
  source        = "../../"
  name          = "sanity test"
  stage         = "sanity test"
  location      = "Central US"
  address_space = ["192.168.0.0/16"]
  virtual_machine = {
    server = {
      win_server     = true
      instance_count = 1
      role           = "server"
      computer_name  = "server"
    }
  }
}

output "module" {
  value = module.detection_lab
}