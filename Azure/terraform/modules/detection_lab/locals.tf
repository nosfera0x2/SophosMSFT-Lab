locals {
  enabled = module.this.enabled
  e       = local.enabled

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

  azurerm_resources = {
    resource_group = {
      name = azurerm_resource_group.this[0].name
      type = "Microsoft.Resources/resourceGroups"
    },
    virtual_network = {
      name = azurerm_virtual_network.this[0].name
      type = "Microsoft.Network/virtualNetworks"
    }
  }

  ### BEGIN: ip whitelist for security group rules ###
  ip_whitelist = join("/", [chomp(data.http.ip_whitelist.response_body), "32"])
  ### END: ip whitelist for security group rules ###

  ## Begin Dynamic subnet calculation ##
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
  ## End Dynamic subnet calculation ##
  ### BEGIN: lookup role and configuration data ###
  role_config = lookup(var.vm_config, var.role)
  disk_config = local.role_config.os_disk
  ip_config   = local.role_config.ip_configuration
  ### END: lookup role and configuration data ###
  ### BEGIN: virtual machine configuration ###
  instance_count = length(var.virtual_machine)
  input = {
    win_server                 = var.win_server == null ? var.virtual_machine_context.win_server : var.win_server
    win_desktop                = var.win_desktop == null ? var.virtual_machine_context.win_desktop : var.win_desktop
    instance_count             = var.instance_count == null ? var.virtual_machine_context.instance_count : var.instance_count
    role                       = var.role == null ? var.virtual_machine_context.role : var.role
    location                   = var.location == null ? var.virtual_machine_context.location : var.location
    admin_username             = var.admin_username == null ? var.virtual_machine_context.admin_username : var.admin_username
    admin_password             = var.admin_password == null ? var.virtual_machine_context.admin_password : var.admin_password
    computer_name              = var.computer_name == null ? module.windows_virtual_machine_label.id : var.computer_name
    enable_automatic_updates   = var.enable_automatic_updates == null ? var.virtual_machine_context.enable_automatic_updates : var.enable_automatic_updates
    allow_extension_operations = var.allow_extension_operations == null ? var.virtual_machine_context.allow_extension_operations : var.allow_extension_operations
    provision_vm_agent         = var.provision_vm_agent == null ? var.virtual_machine_context.provision_vm_agent : var.provision_vm_agent
    encryption_at_host_enabled = var.encryption_at_host_enabled == null ? var.virtual_machine_context.encryption_at_host_enabled : var.encryption_at_host_enabled
    winrm_listener             = merge(var.winrm_listener, var.virtual_machine_context.winrm_listener)
  }
  winrm_listener = local.input.winrm_listener
  winrm_listner_as_list_of_maps = flatten([
    for key in keys(local.winrm_listener) : merge(
      {
        key   = key
        value = local.winrm_listener[key]
      }
    )
  ])
  vm_context = {
    win_server                 = local.input.win_server
    win_desktop                = local.input.win_desktop
    instance_count             = local.input.instance_count
    role                       = local.input.role
    location                   = local.input.location
    admin_username             = local.input.admin_username
    admin_password             = local.input.admin_password
    computer_name              = local.input.computer_name
    enable_automatic_updates   = local.input.enable_automatic_updates
    allow_extension_operations = local.input.allow_extension_operations
    provision_vm_agent         = local.input.provision_vm_agent
    encryption_at_host_enabled = local.input.encryption_at_host_enabled
    winrm_listener             = local.winrm_listener
  }
  custom_data = local.role_config.custom_data == null ? base64encode(file("${path.module}/${local.role_config.custom_data}")) : null
  #user_data   = local.role_config.user_data == null ? base64encode(file("${path.module}/${local.role_config.user_data}")) : null
  ### END: virtual machine configuration ###
}