provider "azurerm" {}

resource "azurerm_resource_group" "ehron-rg" {
  name     = "ehron-rg"
  location = "eastus"

  tags {
    environment = "ehron"
  }
}

resource "azurerm_virtual_network" "ehron-network" {
  name                = "ehron-Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = "${azurerm_resource_group.ehron-rg.name}"

  tags {
    environment = "ehron"
  }
}

resource "azurerm_subnet" "ehron-subnet" {
  name                 = "mySubnet"
  resource_group_name  = "${azurerm_resource_group.ehron-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.ehron-network.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "ehron-publicip-1" {
  name                = "ehron-publicip-1"
  location            = "eastus"
  resource_group_name = "${azurerm_resource_group.ehron-rg.name}"
  allocation_method   = "Dynamic"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_public_ip" "ehron-publicip-2" {
  name                = "ehron-publicip-2"
  location            = "eastus"
  resource_group_name = "${azurerm_resource_group.ehron-rg.name}"
  allocation_method   = "Dynamic"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_network_security_group" "ehron-nsg" {
  name                = "ehron-nsg"
  location            = "eastus"
  resource_group_name = "${azurerm_resource_group.ehron-rg.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Vault"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8200"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_network_interface" "ehron-nic-1" {
  name                      = "ehron-NIC-1"
  location                  = "eastus"
  resource_group_name       = "${azurerm_resource_group.ehron-rg.name}"
  network_security_group_id = "${azurerm_network_security_group.ehron-nsg.id}"

  ip_configuration {
    name                          = "ehron-NicConfiguration-2"
    subnet_id                     = "${azurerm_subnet.ehron-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.ehron-publicip-1.id}"
  }

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_network_interface" "ehron-nic-2" {
  name                      = "ehron-NIC-2"
  location                  = "eastus"
  resource_group_name       = "${azurerm_resource_group.ehron-rg.name}"
  network_security_group_id = "${azurerm_network_security_group.ehron-nsg.id}"

  ip_configuration {
    name                          = "ehron-NicConfiguration-2"
    subnet_id                     = "${azurerm_subnet.ehron-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.ehron-publicip-2.id}"
  }

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_virtual_machine" "ehron-vm-1" {
  name                  = "ehron-VM-1"
  location              = "eastus"
  resource_group_name   = "${azurerm_resource_group.ehron-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.ehron-nic-1.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "ehron-OsDisk-1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "vault-1"
    admin_username = "ehron"
    admin_password = "Password1234!!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "Terraform Demo"

    TTL = "24h"
    Owner = "Ehron"
  }
}

resource "azurerm_virtual_machine" "ehron-vm-2" {
  name                  = "ehron-VM-2"
  location              = "eastus"
  resource_group_name   = "${azurerm_resource_group.ehron-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.ehron-nic-2.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "ehron-OsDisk-2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "vault-2"
    admin_username = "ehron"
    admin_password = "Password1234!!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "Terraform Demo"

    TTL = "24h"
    Owner = "Ehron"
  }
}
