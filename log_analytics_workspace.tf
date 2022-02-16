resource "azurerm_log_analytics_workspace" "law" {
  name                       = format("%s-%s-law-%s", var.prefix, terraform.workspace, random_integer.key-vault.id)
  location                   = var.location
  resource_group_name        = var.resource_group_name
  sku                        = "PerGB2018"
  retention_in_days          = 30
  internet_ingestion_enabled = false
  internet_query_enabled     = false
}

resource "random_integer" "law" {
  min = 001
  max = 500
}
