module "region" {
  count        = var.enabled ? 1 : 0
  source       = "../azure_utils"
  azure_region = var.location
}

module "label" {
  source           = "../label"
  enabled          = var.enabled
  name             = var.name
  namespace        = var.namespace
  stage            = var.stage
  environment      = var.environment
  label_key_case   = "lower"
  label_value_case = "lower"
  id_length_limit  = 10
  tags = merge(
    local.default_tags,
    var.tags
  )
}

resource "azurerm_network_interface" "this" {
  count               = local.e ? var.instance_count : 0
  name                = format("${var.vm_name}-nic-%02d", count.index + 1)
  resource_group_name = var.resource_group_name
  location            = var.location
  dynamic "ip_configuration" {
    for_each = local.e ? 1 : 0
    content {
      name                          = var.virtual_nic_name
      subnet_id                     = var.subnet_id
      private_ip_address_allocation = var.private_ip_address_allocation
      private_ip_address            = var.private_ip_address
      public_ip_address_id          = var.public_ip_address_id
    }
  }
}

#resource "azurerm_public_ip" "this" {
#  count               = local.e ? 1 : 0
#  name                = format("${module.label["public_ip"].id}%02d", count.index + 1)
#  location            = var.location
#  resource_group_name = azurerm_resource_group.this[0].name
#  allocation_method   = var.allocation_method
#}

#resource "azurerm_virtual_machine" "this" {
# checkov:skip=BC_AZR_GENERAL_20: ADD REASON
# checkov:skip=BC_AZR_GENERAL_68: ADD REASON
# checkov:skip=BC_AZR_GENERAL_75: ADD REASON
#  count                 = var.vm_instance_count
#  name                  = format("${module.label.id}%02d", count.index + 1)
#  resource_group_name   = var.resource_group_name
#  location              = var.location
#  network_interface_ids = var.network_interface_ids
#  vm_size               = var.vm_size

#  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
#  delete_data_disks_on_termination = var.delete_data_disks_on_termination

#  dynamic "os_profile" {
#    count = var.enabled ? var.vm_instance_count : 0
#    content {
#      computer_name  = var.computer_name
#      admin_username = var.admin_username
#      admin_password = var.admin_password
#    }
#  }

#  dynamic "os_profile_linux_config" {
#    for_each = var.is_windows_image ? 0 : 1
#    content {
#      disable_password_authentication = var.disable_password_authentication
#      ssh_keys {
#        path     = var.ssh_public_key_path
#        key_data = var.ssh_public_key_data
#      }
#    }
#  }

#  dynamic "os_profile_windows_config" {
#    for_each = var.is_windows_image ? 1 : 0
#    content {
#      provision_vm_agent        = var.provision_vm_agent
#      enable_automatic_upgrades = var.enable_automatic_upgrades
#      timezone                  = var.timezone
#    }
#    winrm {
#      protocol        = var.winrm_protocol
#      certificate_url = var.winrm_certificate_url
#    }
#
#    dynamic "additional_unattend_config" {
#      for_each = var.unattend_config
#      content {
#        pass         = additional_unattend_config.value.pass
#        component    = additional_unattend_config.value.component
#        setting_name = additional_unattend_config.value.setting_name
#        content      = additional_unattend_config.value.content
#      }

#      dynamic "storage_os_disk" {
#        for_each = var.storage_os_disk
#        content {
#          name              = storage_os_disk.value.name
#          caching           = storage_os_disk.value.caching
#          create_option     = storage_os_disk.value.create_option
#          managed_disk_type = storage_os_disk.value.managed_disk_type
#          disk_size_gb      = storage_os_disk.value.disk_size_gb
#        }
#      }
#    }
#  }
#  tags = module.label.tags
#}

resource "time_static" "deploy_date" {}