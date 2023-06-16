provider "azurerm" {
  features {}
}

variable "location" {
  type    = string
  default = "Central US"
}
module "detection_lab" {
  source        = "../../"
  name          = "sanity test"
  stage         = "sanity test"
  location      = "Central US"
  address_space = ["192.168.0.0/16"]
  trusted_ip = "104.28.50.128/32"
  virtual_machine = {
    server = {
      win_server     = true
      instance_count = 1
      role           = "server"
      computer_name  = "server"
    }
    workstation = {
      win_server = false
      instance_count = 1
      role = "workstation"
      computer_name = "win10"
    }
  }
}

output "module" {
  value = module.detection_lab
}