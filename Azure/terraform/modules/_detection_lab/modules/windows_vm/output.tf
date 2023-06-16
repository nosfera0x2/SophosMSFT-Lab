#output "local_vm" {
#  value = local.vm
#}

#output "instances" {
#  value = local.instances
#}

#output "vm_roles" {
#  value = local.vm_roles
#}

#output "length" {
#  value = local.length
#}

#output "distinct" {
#  value = local.distinct
#}

#output "range" {
#  value = local.range
#}

#output "virtual_machine_defaults" {
#  value = terraform_data.virtual_machine_defaults[0]
#}

#output "virtual_machine" {
#  value = terraform_data.virtual_machine[0]
#}

#output "merged" {
#  value = terraform_data.merged
#}

#output "vm_list" {
#  value = local.vm_list
#}

#output "tuple_value" {
#  value = terraform_data.iterate_tuple_values[0].input
#}
#output "virtual_machine_defaults" {
#  value = local.virtual_machine_defaults
#}

#output "inputs" {
#  value = local.inputs
#}

#output "virtual_machine" {
#  value = local.virtual_machine[0]
#}

#output "vm" {
#  value = terraform_data.vm
#}

#output "length" {
#  value = local.length
#}

#output "coalesce" {
#  value = terraform_data.merge
#}

output "this" {
  value = terraform_data.this
}