resource "azurerm_postgresql_server" "pgsql_instance" {
  name                         = format("%s-%s-pgsql-%s-%s", var.prefix, terraform.workspace, var.name, random_integer.postgresql_server.id)
  location                     = var.location
  resource_group_name          = var.resource_group_name
  sku_name                     = var.sku
  storage_mb                   = var.storage_size
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true
  administrator_login          = var.username
  administrator_login_password = var.password
  version                      = var.engine_version
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
  for_each            = var.databases
  name                = each.value.name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.pgsql_instance.name
  charset             = each.value.charset
  collation           = each.value.collation
}

resource "random_integer" "postgresql_server" {
  min = 001
  max = 500
}
