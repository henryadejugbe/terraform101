terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.0.2"
        }
    }
    required_version = ">=1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rgproject444" {
  name     = "rgproject444"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnetp444" {
  name                = "vnetp444"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rgproject444.location
  resource_group_name = azurerm_resource_group.rgproject444.name

  tags = {
    environment = "Dev"
  }
}  

resource "azurerm_subnet" "project4-subnet" {
  name                 = "project4-subnet"
  resource_group_name  = azurerm_resource_group.rgproject444.name
  virtual_network_name = azurerm_virtual_network.vnetp444.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "p4-sg" {
  name                = "p4-sg"
  location            = azurerm_resource_group.rgproject444.location
  resource_group_name = azurerm_resource_group.rgproject444.name

  tags = {
    environment = "Dev"
  }
}

  resource "azurerm_network_security_rule" "p4-rule" {
    name                       = "p4-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    resource_group_name         = azurerm_resource_group.rgproject444.name
    network_security_group_name = azurerm_network_security_group.p4-sg.name
}

resource "azurerm_subnet_network_security_group_association" "p4-snsga" {
  subnet_id                 = azurerm_subnet.project4-subnet.id
  network_security_group_id = azurerm_network_security_group.p4-sg.id
}

resource "azurerm_network_interface" "p444-nic" {
  name                = "p444-nic"
  location            = azurerm_resource_group.rgproject444.location
  resource_group_name = azurerm_resource_group.rgproject444.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.project4-subnet.id
    private_ip_address_allocation = "Dynamic"
  
  }
  tags = {
    environment = "dev"
  }
}
resource "azurerm_linux_virtual_machine" "p444-vm" {
  name                  = "p444-vm"
  location              = azurerm_resource_group.rgproject444.location
  resource_group_name   = azurerm_resource_group.rgproject444.name
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  admin_password        = "admin59!"
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.p444-nic.id,]

  os_disk {
  caching              = "ReadWrite"
  storage_account_type = "Standard_LRS"
  }

source_image_reference {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18.04-LTS"
  version   = "latest"
  }
}
