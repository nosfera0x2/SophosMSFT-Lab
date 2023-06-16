### [BEGIN] SANITY TEST: output.tf ###
output "vm_terraform_data"{
  value = terraform_data.vm
}

output "vm_outputs" {
  value = local.vm_outputs
}
### [END] SANITY TEST: output.tf ###