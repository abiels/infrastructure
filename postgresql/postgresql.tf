resource "azurerm_postgresql_server" "pgsql_instance" {
  name                = format("%s-%s-pgsql-%s-%s", var.prefix, terraform.workspace, var.postgresql.name, random_integer.postgresql_server.id)
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = var.postgresql.size

  storage_mb                   = var.postgresql.storage_size
  backup_retention_days        = var.postgresql.backup_retention_days
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = var.username
  administrator_login_password = var.password
  version                      = var.postgresql.engine_version
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_firewall_rule" "firewall" {
  for_each            = var.allowed_ips
  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.pgsql_instance.name
  start_ip_address    = trim(each.value, "/32")
  end_ip_address      = trim(each.value, "/32")
}

resource "azurerm_postgresql_database" "database" {
  for_each            = toset(var.postgresql.databases)
  name                = each.value
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.pgsql_instance.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_data_protection_backup_vault" "backup_vaul" {
  name                = format("%s-%s-backup-vault-pgsql", var.prefix, terraform.workspace)
  resource_group_name = var.resource_group_name
  location            = var.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_protection_backup_policy_postgresql" "backup_policy" {
  name                            = format("%s-%s-daily-backup-policy-%s", var.prefix, terraform.workspace, var.postgresql.name)
  resource_group_name             = var.resource_group_name
  vault_name                      = azurerm_data_protection_backup_vault.backup_vaul.name
  backup_repeating_time_intervals = ["R/2022-02-02T02:30:00+00:00/P1D"]
  default_retention_duration      = "P3M"
}

resource "azurerm_role_assignment" "role_assignment" {
  count                = var.postgresql.backup ? 1 : 0
  scope                = azurerm_postgresql_server.pgsql_instance.id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.backup_vaul.identity.0.principal_id
  depends_on = [
    azurerm_data_protection_backup_vault.backup_vaul
  ]
}

# resource "azurerm_data_protection_backup_instance_postgresql" "backup_instance_postgresql" {
#   name                                    = "backup_instance_postgresql"
#   location                                = var.location
#   vault_id                                = azurerm_data_protection_backup_vault.backup_vaul.id
#   database_id                             = azurerm_postgresql_database.database.id
#   backup_policy_id                        = azurerm_data_protection_backup_policy_postgresql.backup_policy.id
# }


#random
resource "random_integer" "postgresql_server" {
  min = 001
  max = 500
}
