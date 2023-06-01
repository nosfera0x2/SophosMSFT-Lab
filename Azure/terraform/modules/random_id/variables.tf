# random_id module: variables.tf

variable "delimiter" {
    description = <<EOD
    [Optional] Separator used in the random_pet ID generator
    EOD
    type = string
    default = "_"
}

variable "length" {
    description = <<EOD
    [Optional] The number of words in the generated ID
    EOD
    type = string
    default = 2
}