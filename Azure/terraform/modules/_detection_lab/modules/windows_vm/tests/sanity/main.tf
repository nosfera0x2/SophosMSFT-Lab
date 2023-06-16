### [BEGIN] SANITY TEST: main.tf ###
resource "terraform_data" "vm" {
  for_each = { for k,v in local.vm : k => v }
  input = each.value
}
#resource "terraform_data" "merge" {
#  for_each = { for k,v in local.virtual_machine : k => v }
#  input = merge(terraform_data.vm[each.key].input, (lookup(var.virtual_machine, terraform_data.vm#[each.key].input.role)))
#}
### [ENDN] SANITY TEST: main.tf ###