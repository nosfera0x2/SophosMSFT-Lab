variable "detection_lab" {
  type = map(object({
    enabled = optional(bool)
    virtual_machine = optional(map(any))
    admin_password = optional(string)
  }))
}

variable "admin_password" {
  type = string
  sensitive = true
}