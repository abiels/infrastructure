# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = format("%s-%s-public-ip-%s", var.prefix, terraform.workspace, random_integer.vm.id)
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "security_group" {
  name                = format("%s-%s-sg-%s", var.prefix, terraform.workspace, random_integer.vm.id)
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "109.251.247.244"
    destination_address_prefix = "*"
  }
}

# resource "azurerm_network_security_group" "security_group" {
#   name                = format("%s-%s-sg-%s", var.prefix, terraform.workspace, random_integer.vm.id)
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   for_each = var.network_security_rules
#   security_rule {
#     name                       = each.value.name
#     priority                   = each.value.priority
#     direction                  = each.value.direction
#     access                     = each.value.access
#     protocol                   = each.value.protocol
#     source_port_range          = each.value.source_port_range
#     destination_port_range     = each.value.destination_port_range
#     source_address_prefix      = each.value.source_address_prefix
#     destination_address_prefix = each.value.destination_address_prefix
#   }
# }
#can't connect to resource with for_each

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.network_name
  resource_group_name  = var.resource_group_name
}

# Create network interface
resource "azurerm_network_interface" "network_interface" {
  name                = format("%s-%s-nic-%s", var.prefix, terraform.workspace, random_integer.vm.id)
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = format("%s-%s-nic-config-%s", var.prefix, terraform.workspace, random_integer.vm.id)
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.network_interface.id
  network_security_group_id = azurerm_network_security_group.security_group.id
}

# Create (and display) an SSH key
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
output "tls_private_key" {
  value     = tls_private_key.private_key.private_key_pem
  sensitive = true
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "virtual_machine" {
  name                = format("%s-%s-vm-linux-%s", var.prefix, terraform.workspace, random_integer.vm.id)
  resource_group_name = var.resource_group_name
  location            = var.location

  network_interface_ids = [azurerm_network_interface.network_interface.id]
  size                  = var.vm_size

  os_disk {
    name                 = format("%s-%s-vm-os-disk-%s", var.prefix, terraform.workspace, random_integer.vm.id)
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }
  computer_name                   = format("%s-%s-vm-%s", var.prefix, terraform.workspace, random_integer.vm.id)
  admin_username                  = var.os_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.os_username
    public_key = tls_private_key.private_key.public_key_openssh
  }

}

resource "random_integer" "vm" {
  min = 001
  max = 500
}
