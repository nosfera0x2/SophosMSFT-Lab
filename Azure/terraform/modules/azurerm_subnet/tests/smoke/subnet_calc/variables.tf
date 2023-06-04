variable "max_resource_count" {
  type    = number
  default = 0
}

variable "resource_count" {
  type    = number
  default = 1
}

variable "ipv4_cidrs" {
  type    = list(string)
  default = []
}

variable "address_prefixes" {
  type    = list(string)
  default = []
}