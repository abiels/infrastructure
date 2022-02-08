# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = format("%s-%s-public-ip-%s", var.prefix, terraform.workspace, random_integer.vm-windows.id)
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "security_group" {
  name                = format("%s-%s-sg-%s", var.prefix, terraform.workspace, random_integer.vm-windows.id)
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "109.251.247.244"
    destination_address_prefix = "*"
  }
}


data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.network_name
  resource_group_name  = var.resource_group_name
}

# Create network interface
resource "azurerm_network_interface" "network_interface" {
  name                = format("%s-%s-nic-%s", var.prefix, terraform.workspace, random_integer.vm-windows.id)
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = format("%s-%s-nic-config-%s", var.prefix, terraform.workspace, random_integer.vm-windows.id)
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "security_group_association" {
  network_interface_id      = azurerm_network_interface.network_interface.id
  network_security_group_id = azurerm_network_security_group.security_group.id
}

resource "azurerm_windows_virtual_machine" "windows" {
  name                = format("%s-%s-%s", var.prefix, terraform.workspace, random_integer.vm-windows.id)
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.os_username
  admin_password      = var.os_password
  network_interface_ids = [
    azurerm_network_interface.network_interface.id,
  ]

  os_disk {
    name                 = format("%s-%s-vm-os-disk-%s", var.prefix, terraform.workspace, random_integer.vm-windows.id)
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }
  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }
}

resource "random_integer" "vm-windows" {
  min = 001
  max = 500
}
