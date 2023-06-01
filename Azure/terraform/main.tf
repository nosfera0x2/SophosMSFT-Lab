# terraform init, plan, apply, destroy
# Note: does not support idempotence, don't execute twice with same scope.
# https://www.terraform.io/docs/providers/azurerm/index.html
# latest test: terraform 0.12.18
#
# FIXME!
# * apply: provisioning not working on Windows
# Error: Unsupported argument [...] An argument named "connection" is not expected here.
#    apply => Error: timeout - last error: SSH authentication failed (root@:22): ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey], no supported methods remain
# * apply: linux provisioning
#	=> works but script ends with error code for some reason (post bro install and splunk restart)

# Specify the provider and access details
provider "azurerm" {
  features {}
}

# https://github.com/terraform-providers/terraform-provider-azurerm/blob/1940d84dba45e41b2f1f868a22d7f7af1adea8a0/examples/virtual-machines/virtual_machine/vm-joined-to-active-directory/modules/active-directory/2-virtual-machine.tf
locals {
    custom_data_content  = file("${path.module}/files/winrm.ps1")
}
resource "azurerm_resource_group" "detectionlab" {
  name = "DetectionLab-terraform"
  location = var.region
}
resource "azurerm_virtual_network" "detectionlab-network" {
  name = "DetectionLab-vnet"
  address_space = ["192.168.0.0/16"]
  location = var.region
  resource_group_name = azurerm_resource_group.detectionlab.name
}
# Create a subnet to launch our instances into
resource "azurerm_subnet" "detectionlab-subnet" {
  name                 = "DetectionLab-Subnet"
  resource_group_name  = azurerm_resource_group.detectionlab.name
  virtual_network_name = azurerm_virtual_network.detectionlab-network.name
  address_prefixes       = ["192.168.56.0/24"]
}
resource "azurerm_network_security_group" "detectionlab-nsg" {
  name                = "DetectionLab-nsg"
  location = var.region
  resource_group_name  = azurerm_resource_group.detectionlab.name

  # SSH access
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    # source_address_prefix      = "*"
    source_address_prefixes    = var.ip_whitelist
    destination_address_prefix = "*"
  }

  # RDP
  security_rule {
    name                       = "RDP"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.ip_whitelist
    destination_address_prefix = "*"
  }

  # WinRM
  security_rule {
    name                       = "WinRM"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985-5986"
    source_address_prefixes    = var.ip_whitelist
    destination_address_prefix = "*"
  }

  # Windows ATA
  security_rule {
    name                       = "WindowsATA"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.ip_whitelist
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "detectionlab-nsg" {
  subnet_id                 = azurerm_subnet.detectionlab-subnet.id
  network_security_group_id = azurerm_network_security_group.detectionlab-nsg.id
}

# Storage
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group_name  = azurerm_resource_group.detectionlab.name
  }
  byte_length = 8
}
resource "azurerm_storage_account" "detectionlab-storageaccount" {
  name                = "diag${random_id.randomId.hex}"
  location = var.region
  resource_group_name  = azurerm_resource_group.detectionlab.name
  account_replication_type = "LRS"
  account_tier = "Standard"
  min_tls_version = "TLS1_2"
}

resource "azurerm_network_interface" "dc-nic" {
  name = "dc-nic"
  location = var.region
  resource_group_name  = azurerm_resource_group.detectionlab.name

  ip_configuration {
    name                          = "DC-NicConfiguration"
    subnet_id                     = azurerm_subnet.detectionlab-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.56.102"
    public_ip_address_id          = azurerm_public_ip.dc-publicip.id
  }
}
resource "azurerm_public_ip" "dc-publicip" {
  name                = "dc-public-ip"
  location            = var.region
  resource_group_name = azurerm_resource_group.detectionlab.name
  allocation_method   = "Static"

  tags = {
    role = "dc"
  }
}
resource "azurerm_network_interface" "win10-nic" {
  name = "win10-nic"
  location = var.region
  resource_group_name  = azurerm_resource_group.detectionlab.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.detectionlab-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.56.104"
    public_ip_address_id          = azurerm_public_ip.win10-publicip.id
  }
}
resource "azurerm_public_ip" "win10-publicip" {
  name                = "win10-public-ip"
  location            = var.region
  resource_group_name = azurerm_resource_group.detectionlab.name
  allocation_method   = "Static"

  tags = {
    role = "win10"
  }
}
resource "azurerm_virtual_machine" "dc" {
  name = "dc.windomain.local"
  location = var.region
  resource_group_name   = azurerm_resource_group.detectionlab.name
  network_interface_ids = [azurerm_network_interface.dc-nic.id]
  vm_size               = "Standard_D1_v2"

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "dc"
    admin_username = "vagrant"
    admin_password = "Vagrant123"
    custom_data    = local.custom_data_content
  }
  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = false

    # Auto-Login's required to configure WinRM
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>Vagrant123</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>vagrant</Username></AutoLogon>"
    }

    # Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
    # https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/examples/virtual-machines/provisioners/windows/files/FirstLogonCommands.xml
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = file("${path.module}/files/FirstLogonCommands.xml")
    }
  }

  storage_os_disk {
    name              = "OsDiskDc"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  tags = {
    role = "dc"
  }
}

resource "azurerm_virtual_machine" "win10" {
  name = "win10.windomain.local"
  location = var.region
  resource_group_name  = azurerm_resource_group.detectionlab.name
  network_interface_ids = [azurerm_network_interface.win10-nic.id]
  vm_size               = "Standard_D1_v2"

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "19h1-pron"
    version   = "latest"
  }

  os_profile {
    computer_name  = "win10"
    admin_username = "vagrant"
    admin_password = "Vagrant123"
    custom_data    = local.custom_data_content
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = false

    # Auto-Login's required to configure WinRM
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>Vagrant123</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>vagrant</Username></AutoLogon>"
    }

    # Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
    # https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/examples/virtual-machines/provisioners/windows/files/FirstLogonCommands.xml
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = file("${path.module}/files/FirstLogonCommands.xml")
    }
  }

  storage_os_disk {
    name              = "OsDiskWin10"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  tags = {
    role = "win10"
  }
}
# Creation of the Ansible Inventory
resource "local_file" "inventory" {
    content = templatefile("../Ansible/inventory.tmpl",
      {
        dc_public_ip = azurerm_public_ip.dc-publicip.ip_address
        win10_public_ip = azurerm_public_ip.win10-publicip.ip_address
      }
    )
    filename = "../Ansible/inventory.yml"
}

