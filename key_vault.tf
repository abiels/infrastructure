resource "azurerm_key_vault" "key-vault" {
  name                        = format("%s-%s-kv", var.prefix, terraform.workspace)
  location                    = var.location
  resource_group_name         = format("%s-%s-rg", var.prefix, terraform.workspace)
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enable_rbac_authorization   = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = [var.allowed_ips.abiels]
  }
}
