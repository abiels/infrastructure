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

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "dsrserdtdttddxfx" #azurerm_key_vault_secret.username.value
  administrator_login_password = "NhpiFBnBSLxaU4Iw" #azurerm_key_vault_secret.password.value
  version                      = "9.6"
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

resource "random_integer" "postgresql_server" {
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


data "azurerm_key_vault" "key-vault" {
  name                = "abiels-dev-kv-3"
  resource_group_name = var.resource_group_name
}
