### BEGIN: locals.tf
locals {
  # defining enabled as a value from module.this.enabled
  enabled = module.this.enabled
  # abbreviating due to frequency of usage
  e = local.enabled
  ### BEGIN: default tags ###
  default_tags = {
    terraform_managed  = true,
    region             = var.location,
    tenant             = try(var.tenant, data.azurerm_client_config.current.tenant_id),
    deployment_date    = formatdate("DD-MM-YYYY hh:mm:ss", time_static.deploy_date.rfc3339),
    most_recent_change = formatdate("DD-MM-YYYY hh:mm:ss", timestamp())
  }
  tags = merge(
    var.tags,
    local.default_tags
  )
  ### END: default tags ###
  ### BEGIN: azurerm_resource_group locals ###
  resource_group_name = var.resource_group_name == null ? azurerm_resource_group.this.name : var.resource_group_name
  resource_group_location = var.resource_group_location == null ? data.azurerm_resource_group.default.location : var.resource_group_location
  ### END: azurerm_resource_group locals ###
  ### BEGIN: azurerm_subnet locals ###
  virtual_network_name = var.virtual_network_name == null ? azurerm_virtual_network.this.name : var.virtual_network_name
  ### END: azurerm_subnet locals ###
  ### BEGIN: azurerm_network_security_group locals ###
  security_rules = merge(var.default_security_roles, var.security_rules)
  ### BEGIN: ip whitelist for security group rules ###
  default_trusted_ip = join("/", [chomp(data.http.ip_whitelist.response_body), "32"])
  list_of_trusted_ips = (contains(var.list_of_trusted_ips, local.default_trusted_ip) == false ? concat(var.list_of_trusted_ips, [local.default_trusted_ip]) : var.list_of_trusted_ips)
  ip_whitelist = (contains(local.list_of_trusted_ips, var.trusted_ip) == false ? concat(local.list_of_trusted_ips, [var.trusted_ip]) : local.list_of_trusted_ips)
  ### END: ip whitelist for security group rules ###
  ### END: azurerm_network_security_group locals ###
  ### BEGIN: azurerm_storage_account locals ###
  storage_account_tier = var.storage_account_tier == null ? "Standard" : var.storage_account_tier
  storage_account_replication_type = var.storage_account_replication_type == null ? "LRS" : var.storage_account_replication_type
  ### END: azurerm_storage_account locals ###
  ### BEGIN: azurerm_public_ip locals ###
  public_ip_address_allocation = var.public_ip_address_allocation == null ? "Dynamic" : var.public_ip_address_allocationp
  ### END: azurerm_public_ip locals ###
  ### BEGIN: azurerm_network_interface locals ###
  enable_ip_forwarding = var.enable_ip_forwarding == null ? false : var.enable_ip_forwarding
  ### END: azurerm_network_interface locals ###
  ### BEGIN: Dynamic subnet calculation ###
  number_of_subnets         = length([var.max_subnet_count]) > 0 ? var.max_subnet_count : var.subnet_count
  subnet_count              = local.e ? local.number_of_subnets : 0
  existing_subnet_count     = local.e ? length(data.azurerm_virtual_network.default[0].subnets) : 0
  base_cidr_reservations    = (var.max_subnet_count == 0 ? var.subnet_count : var.max_subnet_count) * var.subnet_count
  cidr_reservations         = (local.e ? 1 : 0) * local.base_cidr_reservations
  supplied_ipv4_cidrs       = var.address_prefixes
  compute_ipv4_cidrs        = local.e && (length(local.supplied_ipv4_cidrs)) == 0
  required_ipv4_subnet_bits = local.e ? ceil(log(local.cidr_reservations, 2)) : 1
  need_vnet_data            = (local.compute_ipv4_cidrs && length(var.address_prefixes) == 0)
  base_ipv4_cidr_block      = length(var.address_prefixes) > 0 ? var.address_prefixes[0] : (local.need_vnet_data ? element(data.azurerm_virtual_network.default[0].address_space, 0) : "")
  ipv4_subnet_cidrs = local.compute_ipv4_cidrs ? [
    for net in range(0, local.cidr_reservations) : cidrsubnet(local.base_ipv4_cidr_block, local.required_ipv4_subnet_bits, net)
  ] : local.supplied_ipv4_cidrs
  ### END: Dynamic subnet calculation ###
  ### BEGIN: virtual machine variable maniplulation ###
  virtual_machine = flatten([
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
      }
    ]
  ])
  length = length(terraform_data.vm)
  instance_count = length(local.vm.*.instance_count)
  ### END: virtual machine variable maniplulation ###
}
### END: locals.tf ###

resource "terraform_data" "this" {
  for_each = terraform_data.azurerm_virtual_machine
  input = each.value.input.input["admin_username"]
}