provider "azurerm"{
    features{}
}

module "lab" {
    source = "../../"
    enabled = true
    name = "detection lab"
    environment = "test"
    stage = "test"
    region = "Central US"
    address_space = ["192.168.0.0/16"]
    number_of_subnets = 2
}