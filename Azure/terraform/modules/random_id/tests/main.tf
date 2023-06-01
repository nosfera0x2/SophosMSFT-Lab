# random_id module tests: main.tf

module "namespace_id" {
    source = "../"
    for_each = var.lengths
    byte_length = each.value.length
}

output "id" {
    value = module.namespace_id
}

variable "lengths" {
    default = {
        one = {
            length = 1
        },
        two = {
            length = 2
        },
        three = {
            length = 3
        },
        ten = {
            length = 10
        }
    }
}