variable "vm_config" {
  description = <<EOD
  VM Configuration object
  EOD
  type        = any
  default = {
    server = {
      config_name  = "server"
      custom_data  = "./scripts/windows/EnablePSRemoting.ps1"
      user_data    = null
      size         = "Standard_D1_v2"
      license_type = "Windows_Server"
      os_disk = {
        caching                   = "ReadWrite"
        storage_account_type      = "Standard_LRS"
        disk_size_gb              = 128
        write_accelerator_enabled = false
      }
      ip_configuration = {
        name                          = "internal-dynamic"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version    = "IPv4"
        primary                       = true
      }
    }
    domain_controller = {
      config_name  = "domain_controller"
      custom_data  = "./scripts/windows/EnablePSRemoting.ps1"
      user_data    = null
      size         = "Standard_D1_v2"
      license_type = "Windows_Server"
      os_disk = {
        caching                   = "ReadWrite"
        storage_account_type      = "Standard_LRS"
        disk_size_gb              = 128
        write_accelerator_enabled = false
      }
      ip_configuration = {
        name                          = "internal-dynamic"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version    = "IPv4"
        primary                       = true
      }
    }
    workstation = {
      config_name  = "workstation"
      custom_data  = "./scripts/windows/EnablePSRemoting.ps1"
      user_data    = null
      size         = "Standard_D1_v2"
      license_type = "Windows_Desktop"
      os_disk = {
        caching                   = "ReadWrite"
        storage_account_type      = "Standard_LRS"
        disk_size_gb              = 128
        write_accelerator_enabled = false
      }
      ip_configuration = {
        dynamic = {
          name                          = "internal-static"
          private_ip_address_allocation = "Static"
          private_ip_address_version    = "IPv4"
          primary                       = true
        }

      }
    }
  }
}

variable "role" {
  description = <<EOD
  The role of the virtual machine. Available options are: server, workstation and domain_controller
  EOD
  type        = string
  default     = "server"
  validation {
    condition     = contains(["server", "workstation", "domain_controller"], var.role)
    error_message = <<EOM
    Invalid role. Available options are: server, workstation and domain_controller
    EOM
  }
}