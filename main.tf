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

data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "key-vault" {
  name                        = format("kv-%s", var.prefix)
  location                    = var.location
  resource_group_name         = format("rg_%s", var.prefix)
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enable_rbac_authorization   = true
  
  network_acls {
    bypass = "AzureServices"
    default_action = "Deny"
    ip_rules = var.allowed_ips
  }
}

module "resource-groups" {
  source              = "./resource-groups"
  resource_group_name = format("rg_%s", var.prefix)
  resource_location   = var.location
}
