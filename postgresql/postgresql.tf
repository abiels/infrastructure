resource "azurerm_postgresql_server" "pgsql_instance" {
  name                = format("%s-%s-pgsql-%s-%s", var.prefix, terraform.workspace, var.postrgesql.name, random_integer.postgresql_server.id)
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = var.postrgesql.size

  storage_mb                   = var.postrgesql.storage_size
  backup_retention_days        = var.postrgesql.backup_retention_days
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = var.username
  administrator_login_password = var.password
  version                      = var.postrgesql.engine_version
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
  for_each            = toset(var.postrgesql.databases)
  name                = each.value
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.pgsql_instance.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}


#random
resource "random_integer" "postgresql_server" {
  min = 001
  max = 500
}
