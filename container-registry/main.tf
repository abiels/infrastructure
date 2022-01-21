resource "random_integer" "acr" {
  min = 001
  max = 500
}

resource "azurerm_container_registry" "acr" {
  name                          = format("%s%srg%s", var.prefix, terraform.workspace, random_integer.acr.id)
  resource_group_name           = var.resource_group_name
  location                      = var.resource_location
  sku                           = "Premium"
  public_network_access_enabled = true

  network_rule_set {
    default_action = "Deny"
    ip_rule = [
      for ip in var.allowed_ips : {
        action   = "Allow"
        ip_range = ip
      }
    ]
  }
  identity {
    type = "SystemAssigned"
  }
}
