resource "random_integer" "key-vault" {
  min = 001
  max = 500
}

resource "azurerm_key_vault" "key-vault" {
  name                        = format("%s-%s-kv-%s", var.prefix, terraform.workspace, random_integer.key-vault.id)
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enable_rbac_authorization   = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = [for ip in var.allowed_ips :ip]
  }
}
