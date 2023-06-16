### [BEGIN] SANITY TEST: locals.tf ###
locals {
  vm_defaults = {
    instance_count = 1
  }

  vm_inputs = {
    instance_count = var.instance_count == null ? var.virtual_machine.instance_count : var.instance_count
  }

  instance_count = local.vm_inputs.instance_count == null ? local.vm_defaults.instance_count : local.vm_inputs.instance_count

  vm_outputs = {
    instance_count = local.instance_count
  }

  vm = flatten([ for key,vm in var.virtual_machine : [
    for key in keys(vm) : merge(
      {
        key = key
        value = local.vm_outputs[key]
      }
    )
  ]])

  vm_object = flatten([
    for vm_key, vm in var.virtual_machine : [
      for index in range(vm.instance_count) : {
        role                       = vm.role
        is_windows_server          = vm.is_windows_server
        instance_count             = vm.instance_count
        admin_username             = vm.admin_username
        resource_group_name        = vm.resource_group_name
        location                   = vm.location
        network_interface_ids      = vm.network_interface_ids
        os_disk                    = vm.os_disk
        size                       = vm.size
        enable_automatic_updates   = vm.enable_automatic_updates
        additional_capabilities    = vm.additional_capabilities
        additional_unattend_config = vm.additional_unattend_config
        allow_extension_operations = vm.allow_extension_operations
        boot_diagnostics           = vm.boot_diagnostics
        computer_name              = vm.computer_name
        custom_data                = vm.custom_data
        user_data                  = vm.user_data
        hotpatching_enabled        = vm.hotpatching_enabled
        identity                   = vm.identity
        license_type               = vm.license_type
        patch_assessment_mode      = vm.patch_assessment_mode
        patch_mode                 = vm.patch_mode
        secret                     = vm.secret
        source_image_id            = vm.source_image_id
        source_image_reference     = vm.source_image_reference
        certificate                = vm.certificate
        winrm_listener             = vm.winrm_listener
        timeouts                   = vm.timeouts
        ip_configuration           = vm.ip_configuration
      }
    ]
  ])
}
### [END] SANITY TEST: locals.tf ###
