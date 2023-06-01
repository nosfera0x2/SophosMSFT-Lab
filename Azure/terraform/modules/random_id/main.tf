# random_id module: main.tf

resource "random_pet" "self" {
    length = var.length
    separator = var.delimiter
}