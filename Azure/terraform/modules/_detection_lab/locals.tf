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
  default_trusted_ip = join("/", [chomp(data.http.ip_whitelist.response_body), "32"])
  list_of_trusted_ips = (contains(var.list_of_trusted_ips, local.default_trusted_ip) == false ? concat(var.list_of_trusted_ips, [local.default_trusted_ip]) : var.list_of_trusted_ips)
  ip_whitelist = (contains(local.list_of_trusted_ips, var.trusted_ip) == false ? concat(local.list_of_trusted_ips, [var.trusted_ip]) : local.list_of_trusted_ips)
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
  ### BEGIN: virtual machine configuration ###
  ### Default values
virtual_machine = flatten([
  for vm_key, vm in var.virtual_machine : [
    for index in range(vm.instance_count) : {
      win_server = vm.win_server
      instance_count = vm.instance_count
      role = vm.role
      computer_name = vm.computer_name
      custom_data = vm.custom_data
      user_data = vm.user_data
      enable_automatic_updates = vm.enable_automatic_updates
      allow_extension_operations = vm.allow_extension_operations
      provision_vm_agent = vm.provision_vm_agent
      encryption_at_host_enabled = vm.encryption_at_host_enabled
      patch_mode = vm.patch_mode
      hotpatching_enabled = vm.hotpatching_enabled
    }
  ]
])
  irtual_machine = {
    win_server                 = [for vm in var.virtual_machine : vm.win_server]
    computer_name              = [for vm in var.virtual_machine : vm.computer_name]
    instance_count             = [for vm in var.virtual_machine : vm.instance_count]
    role                       = [for vm in var.virtual_machine : vm.role]
    custom_data                = [for vm in var.virtual_machine : vm.custom_data]
    user_data                  = [for vm in var.virtual_machine : vm.user_data]
    enable_automatic_updates   = [for vm in var.virtual_machine : vm.enable_automatic_updates]
    allow_extension_operations = [for vm in var.virtual_machine : vm.allow_extension_operations]
    provision_vm_agent         = [for vm in var.virtual_machine : vm.provision_vm_agent]
    encryption_at_host_enabled = [for vm in var.virtual_machine : vm.encryption_at_host_enabled]
    patch_mode                 = [for vm in var.virtual_machine : vm.patch_mode]
    hotpatching_enabled        = [for vm in var.virtual_machine : vm.hotpatching_enabled]
  }
  ### Assess input variables
  vm = {
    win_server                 = local.virtual_machine.win_server
    instance_count             = local.virtual_machine.instance_count
    role                       = local.virtual_machine.role
    computer_name              = local.virtual_machine.computer_name
    enable_automatic_updates   = local.virtual_machine.enable_automatic_updates == null ? var.enable_automatic_updates : false
    hotpatching_enabled        = local.virtual_machine.hotpatching_enabled == null ? var.hotpatching_enabled : false
    patch_mode                 = local.virtual_machine.patch_mode == null ? var.patch_mode : "Manual"
    allow_extension_operations = local.virtual_machine.allow_extension_operations == null ? var.allow_extension_operations : false
    provision_vm_agent         = local.virtual_machine.provision_vm_agent == null ? var.provision_vm_agent : true
    encryption_at_host_enabled = local.virtual_machine.encryption_at_host_enabled == null ? var.encryption_at_host_enabled : false
  }
  ### BEGIN: lookup role and configuration data ###
  role_config = lookup(local.vm_role_config, local.role[0])
  disk_config = local.role_config.os_disk
  ip_config   = local.role_config.ip_config
  ### END: lookup role and configuration data ###

  ### Merge input and default values
  win_server                 = local.vm.win_server
  instance_count             = [ for i in local.vm.instance_count : i.count ]
  role                       = local.vm.role
  location                   = var.location
  admin_username             = var.admin_username
  admin_password             = var.admin_password
  computer_name              = local.vm.computer_name
  enable_automatic_updates   = local.vm.enable_automatic_updates
  hotpatching_enabled        = local.vm.hotpatching_enabled
  patch_mode                 = local.vm.patch_mode
  allow_extension_operations = local.vm.allow_extension_operations
  provision_vm_agent         = local.vm.provision_vm_agent
  encryption_at_host_enabled = local.vm.encryption_at_host_enabled

  ### Role configuration maps
  vm_role_config = {
    server = {
      size         = "Standard_D1_v2"
      license_type = "Windows_Server"
      os_disk = {
        caching                   = "ReadWrite"
        storage_account_type      = "Standard_LRS"
        disk_size_gb              = 128
        write_accelerator_enabled = false
      }
      ip_config = {
        name                          = "internal-dynamic"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version    = "IPv4"
        private_ip_address            = null
        primary                       = true
      }
    }
    domain_controller = {
      size         = "Standard_D1_v2"
      license_type = "Windows_Server"
      os_disk = {
        caching                   = "ReadWrite"
        storage_account_type      = "Standard_LRS"
        disk_size_gb              = 128
        write_accelerator_enabled = false
      }
      ip_config = {
        name                          = "internal-static"
        private_ip_address_allocation = "Static"
        private_ip_address_version    = "IPv4"
        primary                       = true
      }
    }
    workstation = {
      size         = "Standard_D1_v2"
      license_type = "Windows_Client"
      os_disk = {
        caching                   = "ReadWrite"
        storage_account_type      = "Standard_LRS"
        disk_size_gb              = 128
        write_accelerator_enabled = false
      }
      ip_config = {
        name                          = "internal-dynamic"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version    = "IPv4"
        private_ip_address            = null
        primary                       = true
      }
    }
  }

  winrm_listener = {
    http = {
      protocol               = "Http"
      certificate_url        = null
    }
    https = {
      protocol               = "Https"
      certificate_url        = null
    }
  }

  ### END: virtual machine configuration ###
}