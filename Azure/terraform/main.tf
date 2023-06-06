module "lab" {
  source           = "./resources/detectionlab"
  enabled          = true
  name             = "Detection Lab"
  environment      = "msft"
  max_subnet_count = 1
  stage            = "test"
  address_space    = ["192.168.0.0/16"]
  address_prefixes = ["192.168.1.0/24"]
  location         = "Central US"
}