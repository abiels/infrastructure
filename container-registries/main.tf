resource "azurerm_container_registry" "acr" {
  name                = "acr${var.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.resource_location
  sku                 = "Basic"
  admin_enabled       = false
}