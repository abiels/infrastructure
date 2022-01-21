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
  resource_location   = var.location
}

module "container-registry" {
  source              = "./container-registry"
  resource_group_name = var.resource_group_name
  resource_location   = var.location
  prefix              = var.prefix
  allowed_ips         = var.allowed_ips
}
