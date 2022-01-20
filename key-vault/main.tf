data "azurerm_client_config" "current" {
}

output "account_id" {
  value = data.azurerm_client_config.current.client_id
}

resource "azurerm_key_vault" "key-vault" {
  name                        = format("kv-%s", var.prefix)
  location                    = var.resource_location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = var.kv_enabled_for_disk_encryption
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.kv_soft_delete_retention_days
  purge_protection_enabled    = var.kv_purge_protection_enabled
  sku_name                    = "standard"
  enable_rbac_authorization   = var.enable_rbac_authorization
}
