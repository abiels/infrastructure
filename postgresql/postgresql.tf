locals {
  instance = [for instance in var.postrgesql : instance]
}

resource "azurerm_postgresql_server" "pgsql_instance" {
  #for_each = var.postrgesql
  #name                = format("%s-%s-pgsql-%s-%s", var.prefix, terraform.workspace, each.value.name, random_integer.postgresql_server.id)
  name                = format("%s-%s-pgsql-%s-%s", var.prefix, terraform.workspace, local.instance[0].name, random_integer.postgresql_server.id)
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = local.instance[0].size

  storage_mb                   = local.instance[0].storage_size
  backup_retention_days        = local.instance[0].backup_retention_days
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "dsrserdtdttddxfx" #azurerm_key_vault_secret.username.value
  administrator_login_password = "NhpiFBnBSLxaU4Iw" #azurerm_key_vault_secret.password.value
  version                      = local.instance[0].engine_version
  ssl_enforcement_enabled      = true
  # depends_on = [
  #   azurerm_key_vault_secret.sql-1-password,
  #   azurerm_key_vault_secret.sql-1-username
  # ]
}

resource "azurerm_postgresql_firewall_rule" "firewall" {
  name                = "firewall"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.pgsql_instance.name
  start_ip_address    = trim(var.allowed_ips["abiels"], "/32") #TODO: iterate list
  end_ip_address      = trim(var.allowed_ips["abiels"], "/32")
}

resource "azurerm_postgresql_database" "database" {
  count               = length(local.instance[0].databases)
  name                = local.instance[0].databases[count.index]
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.pgsql_instance.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
#backups
resource "azurerm_data_protection_backup_vault" "backup_vaul" {
  name                = format("%s-%s-backup-vault-%s", var.prefix, terraform.workspace, random_integer.backup_vaul.id)
  resource_group_name = var.resource_group_name
  location            = var.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_protection_backup_policy_postgresql" "backup_policy" {
  name                            = format("%s-%s-backup-policy-%s", var.prefix, terraform.workspace, random_integer.backup_vaul.id)
  resource_group_name             = var.resource_group_name
  vault_name                      = azurerm_data_protection_backup_vault.backup_vaul.name
  backup_repeating_time_intervals = ["R/2022-02-02T02:30:00+00:00/P1D"]
  default_retention_duration      = "P3M"
}

resource "azurerm_role_assignment" "role_assignment" {
  scope                = azurerm_postgresql_server.pgsql_instance.id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.backup_vaul.identity.0.principal_id
}


# resource "azurerm_data_protection_backup_instance_postgresql" "backup_instance_postgresql" {
#   name                                    = "backup_instance_postgresql"
#   location                                = var.location
#   vault_id                                = azurerm_data_protection_backup_vault.backup_vaul.id
#   database_id                             = azurerm_postgresql_database.database.id
#   backup_policy_id                        = azurerm_data_protection_backup_policy_postgresql.backup_policy.id
#   #database_credential_key_vault_secret_id = azurerm_key_vault_secret.example.versionless_id
# }

#random
resource "random_integer" "postgresql_server" {
  min = 001
  max = 500
}


resource "random_integer" "backup_vaul" {
  min = 001
  max = 500
}

resource "random_string" "username" {
  length           = 24
  special          = true
  override_special = "%@!"
}

resource "random_password" "password" {
  length           = 24
  special          = true
  override_special = "%@!"
}

# # Create KeyVault Secret
# resource "azurerm_key_vault_secret" "username" {
#   name         = "pgsql-server-username"
#   value        = random_string.username.result
#   key_vault_id = data.azurerm_key_vault.key-vault.id
# }

# resource "azurerm_key_vault_secret" "password" {
#   name         = "pgsql-server-password"
#   value        = random_password.password.result
#   key_vault_id = data.azurerm_key_vault.key-vault.id
#   depends_on = [azurerm_key_vault_secret.username]
# }


# data "azurerm_key_vault" "key-vault" {
#   name                = "abiels-dev-kv-116"
#   resource_group_name = var.resource_group_name
# }
