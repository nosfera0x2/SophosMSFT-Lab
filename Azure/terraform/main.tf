module "detection_lab" {
  source                = "./resources/detection_lab"
  enabled               = true
  create_resource_group = true
  create_vnet           = true
  create_subnet         = false
  name                  = "detection-lab"
  environment           = "prod"
  number_of_subnets     = 2
  stage                 = "lab"
  ipv4_address_space    = ["192.168.0.0/16"]
  location              = "Central US"
}