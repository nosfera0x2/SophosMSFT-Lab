variable "instance_count" {
  description = <<EOD
  Number value that determines the number of instances to create.
  EOD
  type        = number
  default     = 1
}

variable "virtual_machine_role" {
  description = <<EOD
  A map of configuration options for specified VM roles.
  EOD
  type        = any
  default = {
    domain_controller = {
      ip_configuration = {
        name                          = "domainControllerNIC"
        private_ip_address_allocation = "Static"
      }
    },
    workstation = {
      ip_configuration = {
        name = "workstat"
      }
    }
  }
}

variable "vm_name" {
  description = <<EOD
  Virtual machine hostname
  EOD
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = <<EOD
  Name of the resource group to create the virtual machine in.
  EOD
  type        = string
  default     = null
}

variable "ip_configuration" {
  description = <<EOD
  IP configuration that can be specified to attach to specific VM instances
  EOD
  type = map(object({
    name                          = optional(string)
    subnet_id                     = optional(string)
    private_ip_address_version    = optional(string)
    private_ip_address_allocation = optional(string)
    private_ip_address            = optional(string)
    public_ip_address_id          = optional(string)
  }))
}

