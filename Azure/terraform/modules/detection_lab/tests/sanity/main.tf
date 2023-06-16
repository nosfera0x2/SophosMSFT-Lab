module "detection_lab" {
  source          = "../.."
  for_each = var.detection_lab
  virtual_machine = each.value.virtual_machine
  admin_password  = var.admin_password
}