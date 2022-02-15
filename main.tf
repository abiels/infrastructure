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

resource "azurerm_virtual_network" "main" {
  name                = format("%s-%s-vnet-%s", var.prefix, terraform.workspace, var.virtual_network_name)
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.vnet_address_space]
}

module "virtual-subnet" {
  source               = "./virtual-subnet"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = var.resource_group_name
  location             = var.location
  prefix               = var.prefix
  vnet_address_space   = var.vnet_address_space
  for_each             = var.subnets
  name                 = each.value.name
  addr_range           = each.value.addr_range
  service_endpoints    = each.value.service_endpoints
  depends_on = [
    azurerm_virtual_network.main
  ]
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
  source = "./postgresql"
  name   = "production"
  sku    = "B_Gen5_1"
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

resource "azurerm_app_service_plan" "default" {
  name                = format("%s-%s-app-service-plan-%s", var.prefix, terraform.workspace, random_integer.app_service_plan.id)
  kind                = "Linux"
  reserved            = true
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    tier = var.azurerm_app_service_sku_tier
    size = var.azurerm_app_service_sku_size
  }
}

module "app-service" {
  source                         = "./app-service"
  app_service_plan_id            = azurerm_app_service_plan.default.id
  for_each = {
    nginx = {
     service_name                    = "nginx"
     image                           = "nginx"
     image_version                   = "latest"
     health_check_path               = "/"
     health_check_max_ping_failures  = "2"},
    getting-started = {
     service_name = "getting-started"
     image                           = "docker/getting-started"
     image_version                   = "latest"
     health_check_path               = "/"
     health_check_max_ping_failures  = "2" 
    }
  }
  service_name                   = each.value.service_name
  image                          = each.value.image
  image_version                  = each.value.image_version
  health_check_path              = each.value.health_check_path
  health_check_max_ping_failures = each.value.health_check_max_ping_failures
  resource_group_name            = var.resource_group_name
  location                       = var.location
  prefix                         = var.prefix
}
