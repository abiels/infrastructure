terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.92.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "abiels_tfstate"
    storage_account_name = "tfstateih0w1"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

data "azurerm_client_config" "current" {}

module "resource-groups" {
  source              = "./resource-groups"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "virtual-network" {
  source              = "./virtual-network"
  resource_group_name = var.resource_group_name
  location            = var.location
  prefix              = var.prefix
  vnet_address_space  = var.vnet_address_space
  subnets             = var.subnets
}

module "postgresql_development" {
  source = "./postgresql"
  name   = "development"
  sku    = "B_Gen5_1"
  databases = {
    dev-db1 = { name = "dev-db1",
                charset = "UTF8",
                collation = "English_United States.1252" },
    dev-db2 = { name = "dev-db2",
                charset = "UTF8",
                collation = "English_United States.1252" }
  }
  backup                  = false
  threat_detection_policy = false
  storage_size            = 5120
  engine_version          = 11
  backup_retention_days   = 7
  username                = "pgadmin"
  password                = random_password.password.result
  resource_group_name     = var.resource_group_name
  location                = var.location
  prefix                  = var.prefix
  allowed_ips             = var.allowed_ips
}

module "postgresql_production" {
  source                  = "./postgresql"
  name                    = "production"
  sku                     = "B_Gen5_1"
  databases = {
    prod-db1 = { name = "prod-db1",
                charset = "UTF8",
                collation = "English_United States.1252" },
    prod-db2 = { name = "prod-db2",
                charset = "UTF8",
                collation = "English_United States.1252" }
  }
  backup                  = true
  threat_detection_policy = false
  storage_size            = 5120
  engine_version          = 11
  backup_retention_days   = 7
  username                = "pgadmin"
  password                = random_password.password.result
  resource_group_name     = var.resource_group_name
  location                = var.location
  prefix                  = var.prefix
  allowed_ips             = var.allowed_ips
}

resource "random_password" "password" {
  length           = 24
  special          = true
  override_special = "%@!"
}

module "virtual-machine-linux" {
  source                       = "./virtual-machine-linux"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  prefix                       = var.prefix
  subnet_name                  = "abiels-dev-subnet-app-8"
  network_name                 = "abiels-dev-vnet-8"
  os_disk_storage_account_type = "Premium_LRS"
  vm_size                      = "Standard_DS1_v2"
  source_image_reference = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_username = "azureuser"
  network_security_rules = { ssh = {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "109.251.247.244"
    destination_address_prefix = "*"}
  }
}

module "virtual-machine-linux" {
  source                       = "./virtual-machine-linux"
  os_disk_storage_account_type = "Standard_LRS"
  vm_size                      = "Standard_DS1_v2"
  os_username                  = "azureuser"
  subnet_name                  = "abiels-dev-subnet-app-8"
  network_name                 = "abiels-dev-vnet-8"
  source_image_reference = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  network_security_rules = { ssh = {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "109.251.247.244"
    destination_address_prefix = "*"}
  }
  resource_group_name          = var.resource_group_name
  location                     = var.location
  prefix                       = var.prefix
}

module "virtual-machine-windows" {
  source                       = "./virtual-machine-windows"
  os_username                  = "win-admin-rYoYC7pb6LRq1RXx"
  os_password                  = random_password.password.result
  os_disk_storage_account_type = "Standard_LRS"
  vm_size                      = "Standard_F2"
  subnet_name                  = "abiels-dev-subnet-app-8"
  network_name                 = "abiels-dev-vnet-8"
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  network_security_rules = { rdp = {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "109.251.247.244"
    destination_address_prefix = "*"}
  }
  resource_group_name          = var.resource_group_name
  location                     = var.location
  prefix                       = var.prefix
}
