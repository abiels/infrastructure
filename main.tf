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

module "resource-groups" {
  source              = "./resource-groups"
  resource_group_name = format("rg_%s", var.prefix)
  resource_location   = var.location
}

module "key-vault" {
  source                         = "./key-vault"
  prefix                         = var.prefix
  resource_group_name            = format("rg_%s", var.prefix)
  resource_location              = var.location
  kv_tenant_id                   = var.kv_tenant_id
  kv_object_id                   = var.kv_object_id
  key_permissions                = var.key_permissions
  storage_permissions            = var.storage_permissions
  secret_permissions             = var.secret_permissions
  kv_soft_delete_retention_days  = var.kv_soft_delete_retention_days
  kv_purge_protection_enabled    = var.kv_purge_protection_enabled
  kv_sku_name                    = var.kv_sku_name
  kv_enabled_for_disk_encryption = var.kv_enabled_for_disk_encryption
}
